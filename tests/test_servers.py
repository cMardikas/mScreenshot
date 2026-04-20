#!/usr/bin/env python3
"""
mScreenshot local test fixture.

Spins up three local web services that exercise the screenshot logic:

  Port 8088 — plain HTTP. Returns a Tomcat-style landing page.
              Expected: mScreenshot picks http://, screenshot succeeds.

  Port 8843 — TLS that ALSO accepts plain HTTP on the same socket.
              On TLS  → returns the real "secure landing" page.
              On HTTP → returns Tomcat's real "This combination of host
                        and port requires TLS." 400 error.
              This is the bug case: nmap may label this 'http' (no TLS hint)
              and screenshot.py would then capture the error page instead
              of the real one.

  Port 8443 — pure HTTPS. Plain HTTP gets a TLS handshake error.
              Expected: mScreenshot picks https://, screenshot succeeds.

Usage:
    sudo apt install -y python3 openssl
    python3 test_servers.py            # generates a self-signed cert in CWD
    python3 test_servers.py --certdir /tmp/mscreenshot_test

In another terminal, run mScreenshot against 127.0.0.1 (or the host's LAN IP
if you're scanning across the bridge):

    sudo ./mScreenshot 127.0.0.1
    # or pass an explicit port range to keep pass-1 fast:
    # the C wrapper currently doesn't expose -p, so the full /32 + -p- still
    # finishes in seconds for a single host.

Stop the servers with Ctrl-C.
"""
import argparse
import os
import socket
import ssl
import subprocess
import sys
import threading


LANDING_HTTP = b"""<!DOCTYPE html><html><head>
<title>Apache Tomcat/9.0 - Welcome</title></head>
<body><h1>Apache Tomcat/9.0</h1>
<p>If you are seeing this, you have successfully installed Tomcat. Congratulations!</p>
</body></html>"""

LANDING_HTTPS = b"""<!DOCTYPE html><html><head>
<title>Apache Tomcat/9.0 - Secure Admin</title></head>
<body><h1>Tomcat Manager (HTTPS)</h1>
<p>This is the real secure admin landing page. Your connection is encrypted.</p>
</body></html>"""

# Real Tomcat error body returned when you HTTP a TLS-only port.
TOMCAT_TLS_ERROR_BODY = b"""<!doctype html><html lang="en"><head>
<title>HTTP Status 400 - Bad Request</title>
<style type="text/css">body {font-family:Tahoma,Arial,sans-serif;}</style></head>
<body><h1>HTTP Status 400 - Bad Request</h1><hr class="line" />
<p><b>Type</b> Exception Report</p><p><b>Message</b> Bad Request</p>
<p><b>Description</b> The server cannot or will not process the request due to
something that is perceived to be a client error.</p>
<p><b>Note</b> This combination of host and port requires TLS.</p>
<hr class="line" /></body></html>"""


def http_response(body, status=b"200 OK"):
    return (b"HTTP/1.1 " + status + b"\r\n"
            b"Content-Type: text/html; charset=UTF-8\r\n"
            b"Content-Length: " + str(len(body)).encode() + b"\r\n"
            b"Connection: close\r\n\r\n" + body)


def consume_http_request(conn, max_bytes=8192, idle_timeout=0.4):
    """Read until end-of-headers OR until the peer goes idle briefly.

    nmap's -sV does a 'NULL probe' (connects but sends nothing, waiting
    for the server to speak first). Our handler must NOT block on recv()
    in that case — we want to fall through and send our HTTP response
    immediately so nmap fingerprints it as a web server and moves on.
    """
    data = b""
    conn.settimeout(idle_timeout)
    while b"\r\n\r\n" not in data and len(data) < max_bytes:
        try:
            chunk = conn.recv(4096)
        except socket.timeout:
            break
        except Exception:
            break
        if not chunk:
            break
        data += chunk
    return data


def serve_plain_http(port, body):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("0.0.0.0", port))
    sock.listen(50)

    def handle(conn):
        try:
            consume_http_request(conn)
            conn.sendall(http_response(body))
        finally:
            try: conn.shutdown(socket.SHUT_RDWR)
            except Exception: pass
            conn.close()

    def loop():
        while True:
            c, _ = sock.accept()
            threading.Thread(target=handle, args=(c,), daemon=True).start()

    threading.Thread(target=loop, daemon=True).start()
    print(f"[+] :{port}  plain HTTP")


def serve_tls_with_plain_fallback(port, certfile, keyfile, https_body, plain_body):
    sctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    sctx.load_cert_chain(certfile=certfile, keyfile=keyfile)

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("0.0.0.0", port))
    sock.listen(50)

    def handle(conn):
        try:
            # Peek for a TLS ClientHello with a short timeout so nmap's
            # NULL probe doesn't stall here forever.
            conn.settimeout(0.4)
            try:
                peek = conn.recv(1, socket.MSG_PEEK)
            except socket.timeout:
                peek = b""
            if peek and peek[0] == 0x16:
                # TLS ClientHello — wrap and serve the real HTTPS landing.
                tls = sctx.wrap_socket(conn, server_side=True)
                consume_http_request(tls)
                tls.sendall(http_response(https_body))
                try: tls.shutdown(socket.SHUT_RDWR)
                except Exception: pass
                tls.close()
            else:
                # Plain HTTP (or NULL probe) — return Tomcat's "requires TLS".
                consume_http_request(conn)
                conn.sendall(http_response(plain_body, status=b"400 Bad Request"))
                try: conn.shutdown(socket.SHUT_RDWR)
                except Exception: pass
                conn.close()
        except Exception:
            try: conn.close()
            except Exception: pass

    def loop():
        while True:
            c, _ = sock.accept()
            threading.Thread(target=handle, args=(c,), daemon=True).start()

    threading.Thread(target=loop, daemon=True).start()
    print(f"[+] :{port}  TLS + plain-HTTP fallback (the bug case)")


def serve_tls_only(port, certfile, keyfile, body):
    sctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    sctx.load_cert_chain(certfile=certfile, keyfile=keyfile)

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("0.0.0.0", port))
    sock.listen(50)

    def handle(conn):
        try:
            # If the peer doesn't initiate a TLS handshake, drop the
            # connection fast so nmap's NULL probe times out cleanly.
            conn.settimeout(2.0)
            tls = sctx.wrap_socket(conn, server_side=True)
            consume_http_request(tls)
            tls.sendall(http_response(body))
            try: tls.shutdown(socket.SHUT_RDWR)
            except Exception: pass
            tls.close()
        except Exception:
            try: conn.close()
            except Exception: pass

    def loop():
        while True:
            c, _ = sock.accept()
            threading.Thread(target=handle, args=(c,), daemon=True).start()

    threading.Thread(target=loop, daemon=True).start()
    print(f"[+] :{port}  pure HTTPS")


def ensure_cert(certdir):
    cert = os.path.join(certdir, "cert.pem")
    key  = os.path.join(certdir, "key.pem")
    if os.path.exists(cert) and os.path.exists(key):
        return cert, key
    os.makedirs(certdir, exist_ok=True)
    print(f"[*] generating self-signed cert in {certdir} ...")
    rc = subprocess.call([
        "openssl", "req", "-x509", "-newkey", "rsa:2048",
        "-keyout", key, "-out", cert,
        "-days", "30", "-nodes", "-subj", "/CN=localhost",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if rc != 0:
        print("[!] openssl failed; install with: sudo apt install openssl",
              file=sys.stderr)
        sys.exit(1)
    return cert, key


def main():
    ap = argparse.ArgumentParser(description="mScreenshot local test fixture")
    ap.add_argument("--certdir", default=os.path.dirname(os.path.abspath(__file__)),
                    help="directory for cert.pem / key.pem (default: this script's dir)")
    args = ap.parse_args()

    cert, key = ensure_cert(args.certdir)

    print("")
    print("=" * 60)
    print("mScreenshot test fixture — three local web services")
    print("=" * 60)
    serve_plain_http(8088, LANDING_HTTP)
    serve_tls_with_plain_fallback(8843, cert, key, LANDING_HTTPS, TOMCAT_TLS_ERROR_BODY)
    serve_tls_only(8443, cert, key, LANDING_HTTPS)
    print("")
    print("Quick sanity check from another terminal:")
    print("  curl http://127.0.0.1:8088/      # Tomcat landing")
    print("  curl http://127.0.0.1:8843/      # 'requires TLS' error")
    print("  curl -k https://127.0.0.1:8843/  # secure landing")
    print("  curl -k https://127.0.0.1:8443/  # secure landing")
    print("")
    print("Run mScreenshot in another terminal:")
    print("  sudo ./mScreenshot 127.0.0.1")
    print("")
    print("Press Ctrl-C to stop.")

    try:
        threading.Event().wait()
    except KeyboardInterrupt:
        print("\n[*] stopped")


if __name__ == "__main__":
    main()
