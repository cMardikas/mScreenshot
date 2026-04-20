# mScreenshot

Network scanner with automatic web service screenshots and HTML reporting. Wraps nmap with service detection, Selenium-based screenshotting, and a clean Bootstrap report.

## What it does

1. Scans the target range for all open ports with service version detection
2. Takes screenshots of every discovered HTTP/HTTPS service using headless Chromium
3. Generates a single self-contained HTML report with sortable tables, inline screenshots, and export options (CSV, Excel, PDF)

## Quick start

```bash
make
sudo ./mScreenshot -d "Office network" 10.1.0.0/16
```

## Requirements

```bash
sudo apt install nmap xsltproc chromium chromium-driver python3-selenium
```

| Dependency | Purpose |
|---|---|
| nmap | Port scanning and service detection |
| xsltproc | XML to HTML report conversion |
| chromium | Headless browser for screenshots |
| chromium-driver | WebDriver for Selenium |
| python3-selenium | Python browser automation |

## Usage

```
Usage: mScreenshot [options] <target>

  <target>        IP, CIDR range, or dash range to scan
                  examples: 10.90.0.0/16  192.168.1.0/24  10.0.0.1-50

Options:
  -d, --desc      Scan description (e.g., "Office network")
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
    ├── displays CIDR range breakdown
    │
    ├── fork() → nmap
    │       ├── -p-          all ports
    │       ├── -sV          service version detection
    │       ├── --script=    loads http-screenshot.nse
    │       │       └── calls screenshot.py per HTTP port
    │       │               └── headless Chromium → saves PNG
    │       │               └── base64 encodes into XML output
    │       └── -oX          XML output
    │
    ├── fork() → xsltproc
    │       └── XML + XSL → HTML report
    │
    └── removes intermediate XML
```

## Nmap flags

| Flag | Purpose |
|---|---|
| `-p-` | Scan all 65535 ports |
| `-Pn` | Skip host discovery — treat every address as up (avoids firewalled hosts being dropped) |
| `-sV` | Service version detection (needed for screenshot triggers) |
| `--version-intensity 9` | Try every version probe so HTTP on odd ports is caught |
| `-n` | No DNS resolution |
| `-vv` | Extra verbose output |
| `-T4` | Aggressive timing — fast and safe on LAN/office networks |
| `--open` | Show only open ports in on-screen progress (XML still contains all states) |
| `--reason` | Include state reason codes (syn-ack, no-response) in XML |
| `--defeat-rst-ratelimit` | Don't slow down on RST floods |
| `--max-retries 2` | Cap retransmit budget — keeps scans moving on flaky networks |
| `--stats-every 10s` | Print progress every 10 seconds |
| `-oA report_...` | Write all three output formats (.xml for HTML report, .nmap and .gnmap for inspection) |

## Building

```bash
make
```

## License

MIT
