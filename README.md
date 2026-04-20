# mScreenshot

Network scanner with automatic web service screenshots and HTML reporting. Wraps nmap with service detection, Selenium-based screenshotting, and a clean Bootstrap report.

## What it does

1. Discovery pass: fast SYN sweep across all 65535 ports on every host in the target range
2. Enumeration pass: `-sV` version detection + NSE runs only against the host:port pairs that were actually open (much faster than single-pass `-p- -sV`)
3. Takes screenshots of every discovered HTTP/HTTPS service using headless Chromium
4. Generates a single self-contained HTML report with sortable tables, inline screenshots, and export options (CSV, Excel, PDF)

## Quick start

```bash
make
sudo ./mScreenshot -d "Office network" 10.1.0.0/16
```

## Requirements

```bash
sudo apt install nmap xsltproc chromium chromium-driver python3-selenium ethtool
```

| Dependency | Purpose |
|---|---|
| nmap | Port scanning and service detection |
| xsltproc | XML to HTML report conversion |
| chromium | Headless browser for screenshots |
| chromium-driver | WebDriver for Selenium |
| python3-selenium | Python browser automation |
| ethtool (optional) | Used to disable TSO/GSO/GRO on active interfaces before scan |

## Usage

```
Usage: mScreenshot [options] <target>

  <target>        IP, CIDR range, or dash range to scan
                  examples: 10.90.0.0/16  192.168.1.0/24  10.0.0.1-50

Options:
  -d, --desc      Scan description (e.g., "Office network")
  -e, --exclude   Extra IPs/CIDRs to exclude (comma-separated)
                  (local host IPs are auto-detected and always excluded)
  -c, --clean     Remove all reports and screenshots, then exit
  -r, --report    Regenerate HTML from most recent XML (skip scan)
  -h, --help      Show this help
```

## Examples

```bash
# Scan a /24 with description
sudo ./mScreenshot -d "Office network" 192.168.1.0/24

# Scan a single host
sudo ./mScreenshot 10.0.0.1

# Scan with dash range
sudo ./mScreenshot -d "DMZ servers" 10.0.0.1-50

# Clean all previous results
./mScreenshot --clean

# Regenerate HTML report from existing XML
./mScreenshot --report

# Exclude extra hosts from the scan (in addition to this host's own IPs)
sudo ./mScreenshot -e 10.0.0.5,10.0.0.6 10.0.0.0/24
```

## Output

A single HTML file named with description and timestamp:

```
report_office-network_2026-03-26_2044.html
```

Without `-d`, the target range is used:

```
report_192.168.1.0-24_2026-03-26_2044.html
```

## Report features

- Scanned hosts overview with up/down status
- Open services table with hostname, port, protocol, service, product, version, SSL certificate info
- Web services table with inline screenshots
- Per-host collapsible detail panels
- Keyword highlighting (e.g., highlight `sha1`, `password`, `md5`)
- Export to CSV, Excel, PDF
- Sortable columns with IP address sorting
- DataTables search and filtering

## Project structure

```
mScreenshot/
├── mScreenshot.c              # Main C wrapper
├── Makefile
├── screenshots/               # PNG output dir (created at scan time)
└── scripts/
    ├── http-screenshot.nse    # nmap NSE script — triggers screenshots
    ├── screenshot.py          # Selenium screenshotter
    └── nmap-bootstrap.xsl     # HTML report template
```

## How it works

```
mScreenshot
    │
    ├── validates target input (prevents injection)
    ├── checks all dependencies
    ├── auto-detects local IPs (→ nmap --exclude)
    ├── disables TSO/GSO/GRO on active interfaces (ethtool)
    │
    ├── pass 1 / discovery          ─ fork() → nmap
    │       ├── -sS -p-              SYN sweep, all ports
    │       ├── -T5 --min-rate 10000 aggressive throughput
    │       ├── --max-rtt-timeout    500ms, not the default 1.25s
    │       ├── --min-parallelism 256 keep probes in flight
    │       ├── --min-hostgroup 64   scan many hosts in parallel
    │       └── -oG /tmp/...gnmap    small greppable output
    │               └── parsed for host:port pairs
    │
    ├── pass 2 / version + screenshots ─ fork() → nmap
    │       ├── -sV --version-intensity 7  version probes
    │       ├── -p <open-ports-only>       targeted, not -p-
    │       ├── -Pn                        hosts already proven up
    │       ├── --script=scripts/          loads http-screenshot.nse
    │       │       └── calls screenshot.py per HTTP port
    │       │               └── headless Chromium → saves PNG
    │       │               └── base64 encodes into XML output
    │       └── -oA report_...             XML + .nmap + .gnmap
    │
    └── fork() → xsltproc
            └── XML + XSL → HTML report
```

## Nmap flags

mScreenshot runs nmap **twice** — a fast SYN sweep to find open ports, then a targeted `-sV` + NSE pass against just those host:port pairs. This is dramatically faster than a single-pass `-p- -sV --version-intensity 9` on anything bigger than a handful of hosts.

### Pass 1 — discovery (aggressive)

Pass 1 is a pure port-discovery sweep — any ports it finds get re-probed properly in pass 2, so we crank the throughput here.

| Flag | Purpose |
|---|---|
| `-sS` | SYN stealth scan |
| `-p-` | All 65535 ports |
| `-n` / `-vv` | No DNS, extra verbose |
| `-T5` | Most aggressive built-in timing template |
| `--open` | Show only open ports on screen |
| `--reason` | State reason codes in output |
| `--defeat-rst-ratelimit` | Don't slow down on RST floods |
| `--min-rate 10000` | Target packet rate — keeps the wire full on big ranges |
| `--max-rtt-timeout 500ms` | Don't wait the default 1.25s on every filtered port |
| `--min-parallelism 256` | Keep at least 256 probes in flight |
| `--min-hostgroup 64` | Fire probes against up to 64 hosts simultaneously |
| `--max-retries 1` | Single retransmit budget — this pass is about being fast |
| `--stats-every 10s` | Print progress every 10 seconds |
| `--exclude <ips>` | Auto-excludes this host's own IPv4 addresses (loopback and link-local are skipped); any extras from `-e/--exclude` are appended |
| `-oG /tmp/...gnmap` | Greppable output — small, parsed, then deleted |

### Pass 2 — version detection + screenshots

| Flag | Purpose |
|---|---|
| `-sS -sV` | SYN scan with version detection |
| `--version-intensity 7` | Default intensity — catches HTTP on odd ports without intensity-9's overhead |
| `-p <open-ports-only>` | Targeted at the exact union of open ports from pass 1 |
| `-Pn` | Skip host discovery — pass 1 already proved these hosts are up |
| `-n` / `-vv` / `-T4` / `--open` / `--reason` / `--defeat-rst-ratelimit` | Same as pass 1 |
| `--max-retries 1` | Same aggressive retry cap |
| `--stats-every 10s` | Progress ticks |
| `--script=scripts/` | Loads the NSE that drives screenshot.py |
| `-oA report_...` | Write all three output formats (.xml for HTML report, .nmap and .gnmap for inspection) |

### Pre-scan NIC tweaks

Before the scan runs, `ethtool -K <iface> tso off gso off gro off` is issued on every active non-loopback interface (best-effort, silently skipped if `ethtool` is missing). These offloads (TCP Segmentation Offload, Generic Segmentation Offload, Generic Receive Offload) let the NIC or kernel split and merge packets for throughput — great for normal traffic, but they can mangle nmap's hand-crafted SYN packets and its view of replies, causing false negatives.

## Building

```bash
make
```

## Local testing

`tests/test_servers.py` spins up three local web services on different ports to exercise the screenshot logic without scanning anything external:

| Port | Behavior |
|---|---|
| 8088 | Plain HTTP, Tomcat-style landing page |
| 8843 | TLS that also accepts plain HTTP and replies with Tomcat's "This combination of host and port requires TLS" 400 — the misdetection edge case |
| 8443 | Pure HTTPS only |

Usage:

```bash
# Terminal 1 — start the test servers (generates a self-signed cert on first run)
python3 tests/test_servers.py

# Terminal 2 — scan loopback
sudo ./mScreenshot 127.0.0.1
```

Quick sanity check from any terminal:

```bash
curl http://127.0.0.1:8088/      # Tomcat landing
curl http://127.0.0.1:8843/      # 'requires TLS' error
curl -k https://127.0.0.1:8843/  # real secure landing
```

## License

MIT
