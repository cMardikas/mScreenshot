# Author: b0yd @rwincey
# Website: securifera.com
# Simplified and updated by Mart Meier
# Updated for Selenium 4.x
#
# Behavior:
#   - Tries to capture HTTP or HTTPS on any port (non-standard web UIs too).
#   - Uses nmap's service hints (-s name, -t tunnel) if provided; otherwise
#     tries HTTP first and falls back to HTTPS if the response looks wrong.
#   - Exits 0 on a successful screenshot, 1 on nothing-to-capture.

import argparse
import os
import sys
import time

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options


def short_reason(exc):
    """Reduce a Selenium/WebDriver exception to a single-line reason.

    Selenium dumps the full Chromium C++ stacktrace in str(exc); we only
    want the human-readable bit (e.g. 'net::ERR_CONNECTION_REFUSED').
    """
    msg = str(exc).strip()
    # First line only.
    line = msg.splitlines()[0] if msg else exc.__class__.__name__
    # Strip leading 'Message: ' that Selenium 4.x prefixes.
    if line.startswith("Message: "):
        line = line[len("Message: "):]
    # Drop trailing '(Session info: ...)' parens that sometimes appear inline.
    cut = line.find(" (Session info:")
    if cut != -1:
        line = line[:cut]
    return line.strip() or exc.__class__.__name__


EMPTY_PAGE = "<html><head></head><body></body></html>"
HTTPS_HINT_STRINGS = (
    "use the HTTPS scheme",
    "was sent to HTTPS port",
    "The plain HTTP request",
    "Client sent an HTTP request to an HTTPS server",
)


def build_driver():
    options = Options()
    if os.name == "nt":
        options.binary_location = "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
    else:
        options.binary_location = "/usr/bin/chromium"

    options.add_argument("--headless=new")
    options.add_argument("--ignore-certificate-errors")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument(
        "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/130.0.6723.69 Safari/537.36"
    )

    try:
        service = Service("/usr/bin/chromedriver")
        driver = webdriver.Chrome(service=service, options=options)
    except Exception as e:
        print(f"screenshot failed to start Chrome: {short_reason(e)}", file=sys.stderr)
        sys.exit(1)

    driver.set_window_size(640, 480)
    driver.set_page_load_timeout(30)
    return driver


def try_navigate(driver, url):
    """Return (ok, source). ok=False if the request failed outright."""
    try:
        driver.get(url)
        time.sleep(2)
        return True, driver.page_source or ""
    except Exception as e:
        print(f"screenshot failed for {url}: {short_reason(e)}", file=sys.stderr)
        return False, ""


def looks_empty(source):
    if not source:
        return True
    s = source.strip()
    if s == EMPTY_PAGE:
        return True
    # Chrome's default error page body is tiny and lacks any head content.
    if len(s) < 64:
        return True
    return False


def looks_like_https_wanted(source):
    return any(h in source for h in HTTPS_HINT_STRINGS)


def pick_initial_scheme(port, service, tunnel):
    """Return ('https','http') or ('http','https') — preferred scheme first."""
    tunnel = (tunnel or "").lower()
    service = (service or "").lower()

    if tunnel == "ssl" or "https" in service or "ssl" in service:
        return ("https", "http")
    return ("http", "https")


def capture(driver, ip, port, service, tunnel, output_dir):
    first, second = pick_initial_scheme(port, service, tunnel)

    netloc = f"{ip}:{port}" if port else ip

    # Attempt #1
    url1 = f"{first}://{netloc}"
    ok1, src1 = try_navigate(driver, url1)

    good_url = None
    if ok1 and not looks_empty(src1) and not looks_like_https_wanted(src1):
        good_url = url1
    else:
        # Attempt #2
        url2 = f"{second}://{netloc}"
        ok2, src2 = try_navigate(driver, url2)
        if ok2 and not looks_empty(src2):
            good_url = url2
        elif ok1 and not looks_empty(src1):
            # Fall back to the first response even if it hinted at HTTPS.
            # Go back to it so the screenshot matches what we saved.
            try_navigate(driver, url1)
            good_url = url1

    if not good_url:
        return None

    filename = f"{ip}_{port}.png" if port else f"{ip}.png"
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
        filename = os.path.join(output_dir, filename)

    try:
        driver.save_screenshot(filename)
        print(f"Saved: {filename} ({good_url})")
        return filename
    except Exception as e:
        print(f"screenshot failed for {good_url}: {short_reason(e)}", file=sys.stderr)
        return None


def main():
    parser = argparse.ArgumentParser(description="Screenshot a web service on any port.")
    parser.add_argument("-u", dest="host", required=True, help="Target IP or hostname")
    parser.add_argument("-p", dest="port", required=False, default="", help="Port")
    parser.add_argument("-s", dest="service", required=False, default="", help="nmap service name hint")
    parser.add_argument("-t", dest="tunnel", required=False, default="", help="nmap tunnel hint (e.g. 'ssl')")
    parser.add_argument("-q", dest="query", required=False, default="", help="URL path/query (unused, kept for compat)")
    parser.add_argument("-o", dest="output_dir", required=False, default="", help="Output directory")
    args = parser.parse_args()

    driver = build_driver()
    try:
        result = capture(driver, args.host, args.port, args.service, args.tunnel, args.output_dir)
    finally:
        driver.quit()

    if not result:
        sys.exit(1)


if __name__ == "__main__":
    main()
