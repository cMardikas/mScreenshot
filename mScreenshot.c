


// mScreenshot.c — nmap scan wrapper with screenshots and HTML report
// Build: gcc -O2 -Wall mScreenshot.c -o mScreenshot
// Run:   sudo ./mScreenshot -d "Office network" 10.90.0.0/16

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <time.h>
#include <dirent.h>
#include <errno.h>
#include <libgen.h>
#include <stdint.h>

#define MSCREENSHOT_VERSION "v.10"
#define MSCREENSHOT_BUILD   __DATE__ " " __TIME__

#define SCRIPT_DIR      "scripts"
#define SCREENSHOT_DIR  "screenshots"
#define XSL_FILE        SCRIPT_DIR "/nmap-bootstrap.xsl"

// ─── Report name builder ─────────────────────────────────────────────────────

static char s_report_base[512] = "";
static char s_report_xml[560]  = "";
static char s_report_html[560] = "";

static void sanitize_for_filename(char *out, size_t outsz, const char *in) {
    size_t j = 0;
    for (size_t i = 0; in[i] && j + 1 < outsz; i++) {
        char c = in[i];
        if (c == ' ' || c == '\t') {
            if (j > 0 && out[j-1] != '-') out[j++] = '-';
        } else if (c == '/' || c == '\\' || c == ':' || c == '*' ||
                   c == '?' || c == '"' || c == '<' || c == '>' || c == '|') {
            if (j > 0 && out[j-1] != '-') out[j++] = '-';
        } else if (isalnum(c) || c == '-' || c == '_' || c == '.') {
            out[j++] = tolower(c);
        }
    }
    // Trim trailing dashes
    while (j > 0 && out[j-1] == '-') j--;
    out[j] = '\0';
}

static void build_report_name(const char *target, const char *description) {
    char ts[32];
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    strftime(ts, sizeof(ts), "%Y-%m-%d_%H%M", t);

    if (description && description[0]) {
        char safe_desc[128];
        sanitize_for_filename(safe_desc, sizeof(safe_desc), description);
        snprintf(s_report_base, sizeof(s_report_base), "report_%s_%s", safe_desc, ts);
    } else {
        char safe_target[128];
        sanitize_for_filename(safe_target, sizeof(safe_target), target);
        snprintf(s_report_base, sizeof(s_report_base), "report_%s_%s", safe_target, ts);
    }
}

// ─── Input validation ────────────────────────────────────────────────────────

static bool is_valid_target(const char *target) {
    for (const char *p = target; *p; p++) {
        char c = *p;
        if (isdigit(c) || c == '.' || c == ':' || c == '/' ||
            c == '-' || c == ',' || c == ' ' ||
            (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))
            continue;
        return false;
    }
    for (const char *p = target; *p; p++)
        if (isdigit(*p)) return true;
    return false;
}

// ─── Path helpers ────────────────────────────────────────────────────────────

static char s_exe_dir[4096] = "";

static void detect_exe_dir(const char *argv0) {
    char buf[4096];

    ssize_t n = readlink("/proc/self/exe", buf, sizeof(buf) - 1);
    if (n > 0) {
        buf[n] = '\0';
        char *dir = dirname(buf);
        snprintf(s_exe_dir, sizeof(s_exe_dir), "%s", dir);
        return;
    }

    if (argv0[0] == '/') {
        snprintf(buf, sizeof(buf), "%s", argv0);
    } else {
        char cwd[2048];
        if (getcwd(cwd, sizeof(cwd)))
            snprintf(buf, sizeof(buf), "%s/%s", cwd, argv0);
        else
            snprintf(buf, sizeof(buf), "%s", argv0);
    }
    char *dir = dirname(buf);
    snprintf(s_exe_dir, sizeof(s_exe_dir), "%s", dir);
}

static void build_path(char *out, size_t outsz, const char *filename) {
    snprintf(out, outsz, "%s/%s", s_exe_dir, filename);
}

// ─── CIDR description ────────────────────────────────────────────────────────

static void describe_target(const char *target) {
    char ip_part[64] = "";
    int prefix = -1;
    const char *slash = strchr(target, '/');

    if (slash) {
        size_t ip_len = (size_t)(slash - target);
        if (ip_len >= sizeof(ip_part)) ip_len = sizeof(ip_part) - 1;
        memcpy(ip_part, target, ip_len);
        ip_part[ip_len] = '\0';
        prefix = atoi(slash + 1);
    }

    if (prefix >= 0 && prefix <= 32) {
        unsigned int a, b, c, d;
        if (sscanf(ip_part, "%u.%u.%u.%u", &a, &b, &c, &d) == 4) {
            uint32_t ip   = (a << 24) | (b << 16) | (c << 8) | d;
            uint32_t mask = prefix == 0 ? 0 : (~0U << (32 - prefix));
            uint32_t net  = ip & mask;
            uint32_t bcast = net | ~mask;
            uint32_t first = net + 1;
            uint32_t last  = bcast - 1;
            uint32_t hosts = (prefix >= 31) ? (1U << (32 - prefix)) : (bcast - net - 1);

            printf("  network   : %u.%u.%u.%u/%d\n",
                   (net>>24)&0xff, (net>>16)&0xff, (net>>8)&0xff, net&0xff, prefix);
            printf("  range     : %u.%u.%u.%u - %u.%u.%u.%u\n",
                   (first>>24)&0xff, (first>>16)&0xff, (first>>8)&0xff, first&0xff,
                   (last>>24)&0xff,  (last>>16)&0xff,  (last>>8)&0xff,  last&0xff);
            printf("  netmask   : %u.%u.%u.%u\n",
                   (mask>>24)&0xff, (mask>>16)&0xff, (mask>>8)&0xff, mask&0xff);
            printf("  hosts     : %u\n", hosts);
        } else {
            printf("  target    : %s\n", target);
        }
    } else if (strchr(target, '-')) {
        printf("  target    : %s (dash range)\n", target);
    } else if (strchr(target, ',')) {
        printf("  target    : %s (multiple targets)\n", target);
    } else {
        printf("  target    : %s (single host)\n", target);
    }
}

// ─── File checks ─────────────────────────────────────────────────────────────

static bool file_exists(const char *path) {
    struct stat st;
    return stat(path, &st) == 0;
}

static bool check_command(const char *cmd) {
    char buf[256];
    snprintf(buf, sizeof(buf), "which %s >/dev/null 2>&1", cmd);
    return system(buf) == 0;
}

static int check_dependencies(void) {
    int ok = 1;

    if (!check_command("nmap")) {
        fprintf(stderr, "  [!] nmap not found\n");
        ok = 0;
    }
    if (!check_command("xsltproc")) {
        fprintf(stderr, "  [!] xsltproc not found (apt install xsltproc)\n");
        ok = 0;
    }
    if (!check_command("chromium") && !check_command("chromium-browser") &&
        !check_command("google-chrome")) {
        fprintf(stderr, "  [!] chromium not found (apt install chromium)\n");
        ok = 0;
    }
    if (!check_command("chromedriver")) {
        fprintf(stderr, "  [!] chromedriver not found (apt install chromium-driver)\n");
        ok = 0;
    }
    if (system("python3 -c 'import selenium' >/dev/null 2>&1") != 0) {
        fprintf(stderr, "  [!] python3 selenium not found (apt install python3-selenium)\n");
        ok = 0;
    }

    char xsl[4096], nse[4096], py[4096];
    build_path(xsl, sizeof(xsl), XSL_FILE);
    build_path(nse, sizeof(nse), SCRIPT_DIR "/http-screenshot.nse");
    build_path(py, sizeof(py), SCRIPT_DIR "/screenshot.py");

    if (!file_exists(xsl)) {
        fprintf(stderr, "  [!] %s not found\n", xsl);
        ok = 0;
    }
    if (!file_exists(nse)) {
        fprintf(stderr, "  [!] %s not found\n", nse);
        ok = 0;
    }
    if (!file_exists(py)) {
        fprintf(stderr, "  [!] %s not found\n", py);
        ok = 0;
    }

    return ok;
}

// ─── Clean ───────────────────────────────────────────────────────────────────

static int clean_pngs(const char *dir) {
    DIR *d = opendir(dir);
    if (!d) return 0;
    struct dirent *e;
    int count = 0;
    while ((e = readdir(d)) != NULL) {
        size_t len = strlen(e->d_name);
        if (len > 4 && strcmp(e->d_name + len - 4, ".png") == 0) {
            char path[512];
            snprintf(path, sizeof(path), "%s/%s", dir, e->d_name);
            if (remove(path) == 0) count++;
        }
    }
    closedir(d);
    return count;
}

static void clean_reports(void) {
    DIR *d = opendir(".");
    if (!d) return;
    struct dirent *e;
    int reports = 0;
    while ((e = readdir(d)) != NULL) {
        if (strncmp(e->d_name, "report_", 7) == 0) {
            if (remove(e->d_name) == 0) reports++;
        }
    }
    closedir(d);

    // Clean PNGs from the dedicated screenshots dir, plus any stragglers
    // in the current dir and scripts dir from earlier versions.
    char shots_dir[4096], scripts_dir[4096];
    build_path(shots_dir,   sizeof(shots_dir),   SCREENSHOT_DIR);
    build_path(scripts_dir, sizeof(scripts_dir), SCRIPT_DIR);
    int screenshots = clean_pngs(shots_dir);
    screenshots += clean_pngs(".");
    screenshots += clean_pngs(scripts_dir);

    if (reports > 0)
        printf("  removed %d report file(s)\n", reports);
    if (screenshots > 0)
        printf("  removed %d screenshot(s)\n", screenshots);
    if (reports == 0 && screenshots == 0)
        printf("  nothing to clean\n");
}

// ─── Run scan ────────────────────────────────────────────────────────────────

static int run_scan(const char *target) {
    char scripts_dir[4096], shots_dir[4096];
    build_path(scripts_dir, sizeof(scripts_dir), SCRIPT_DIR);
    build_path(shots_dir,   sizeof(shots_dir),   SCREENSHOT_DIR);

    // Make sure the screenshots dir exists before nmap launches the NSE.
    if (mkdir(shots_dir, 0755) != 0 && errno != EEXIST) {
        fprintf(stderr, "  [!] cannot create %s: %s\n", shots_dir, strerror(errno));
        return 1;
    }

    printf("  scripts     : %s\n", scripts_dir);
    printf("  screenshots : %s\n", shots_dir);
    printf("  output      : %s\n", s_report_html);
    printf("\n");
    printf("  ─── nmap output ────────────────────────────────────────\n\n");

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {
        char script_arg[4096];
        char script_args[4200];
        snprintf(script_arg,  sizeof(script_arg),  "--script=%s/", scripts_dir);
        snprintf(script_args, sizeof(script_args), "screenshot_dir=%s", shots_dir);

        execlp("nmap", "nmap",
               script_arg,
               "--script-args", script_args,
               "-p-",
               "-sV",
               "-n",
               "-v",
               "--defeat-rst-ratelimit",
               "--host-timeout", "600s",
               "--stats-every", "10s",
               "-oX", s_report_xml,
               target,
               (char *)NULL);

        perror("exec nmap");
        _exit(127);
    }

    int status;
    waitpid(pid, &status, 0);

    if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
        fprintf(stderr, "\n  [!] nmap exited with code %d\n", WEXITSTATUS(status));
        return 1;
    }
    if (WIFSIGNALED(status)) {
        fprintf(stderr, "\n  [!] nmap killed by signal %d\n", WTERMSIG(status));
        return 1;
    }

    printf("\n  ─── scan complete ──────────────────────────────────────\n\n");
    return 0;
}

// ─── Generate HTML report ────────────────────────────────────────────────────

static int generate_report(void) {
    if (!file_exists(s_report_xml)) {
        fprintf(stderr, "  [!] %s not found — scan may have failed\n", s_report_xml);
        return 1;
    }

    char xsl[4096];
    build_path(xsl, sizeof(xsl), XSL_FILE);

    printf("  generating HTML report...\n");

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {
        execlp("xsltproc", "xsltproc",
               "-o", s_report_html,
               xsl,
               s_report_xml,
               (char *)NULL);
        perror("exec xsltproc");
        _exit(127);
    }

    int status;
    waitpid(pid, &status, 0);

    if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
        // Remove the intermediate XML
        remove(s_report_xml);
        printf("  report    : %s\n", s_report_html);
        return 0;
    }

    fprintf(stderr, "  [!] xsltproc failed\n");
    return 1;
}

// ─── Banner ──────────────────────────────────────────────────────────────────

static void print_banner(void) {
    printf("\n");
    printf("          ██████╗ ██████╗██████╗ ███████╗███████╗███╗   ██╗███████╗██╗  ██╗ ██████╗ ████████╗\n");
    printf("         ██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝████╗  ██║██╔════╝██║  ██║██╔═══██╗╚══██╔══╝\n");
    printf("  ██╗████╗╚█████╗██║     ██████╔╝█████╗  █████╗  ██╔██╗ ██║███████╗███████║██║   ██║   ██║   \n");
    printf("  ██╔██╔██╗╚═══██╗██║    ██╔══██╗██╔══╝  ██╔══╝  ██║╚██╗██║╚════██║██╔══██║██║   ██║   ██║   \n");
    printf("  ██║╚╝ ██║█████╔╝╚█████╗██║  ██║███████╗███████╗██║ ╚████║███████║██║  ██║╚██████╔╝   ██║   \n");
    printf("  ╚═╝   ╚═╝╚════╝  ╚════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   \n");
    printf("\n");
    printf("  version : %s\n", MSCREENSHOT_VERSION);
    printf("  build   : %s\n", MSCREENSHOT_BUILD);
    printf("\n");
}

// ─── Usage ───────────────────────────────────────────────────────────────────

static void print_usage(const char *prog) {
    printf("Usage: %s [options] <target>\n\n", prog);
    printf("  <target>        IP, CIDR range, or dash range to scan\n");
    printf("                  examples: 10.90.0.0/16  192.168.1.0/24  10.0.0.1-50\n\n");
    printf("Options:\n");
    printf("  -d, --desc      Scan description (e.g., \"Office network\")\n");
    printf("  -c, --clean     Remove all report_* files and screenshots, then exit\n");
    printf("  -r, --report    Generate HTML report from existing XML (skip scan)\n");
    printf("  -h, --help      Show this help\n\n");
    printf("Examples:\n");
    printf("  sudo ./mScreenshot -d \"Office network\" 10.90.0.0/16\n");
    printf("  sudo ./mScreenshot 192.168.1.0/24\n");
    printf("  sudo ./mScreenshot -d \"DMZ\" 10.0.0.1\n\n");
    printf("Output:\n");
    printf("  report_<desc>_<date>_<time>.html    HTML report with screenshots\n");
}

// ─── Main ────────────────────────────────────────────────────────────────────

int main(int argc, char **argv) {
    detect_exe_dir(argv[0]);

    bool do_clean = false;
    bool do_report_only = false;
    const char *target = NULL;
    const char *description = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        }
        if (strcmp(argv[i], "-c") == 0 || strcmp(argv[i], "--clean") == 0) {
            do_clean = true;
            continue;
        }
        if (strcmp(argv[i], "-r") == 0 || strcmp(argv[i], "--report") == 0) {
            do_report_only = true;
            continue;
        }
        if ((strcmp(argv[i], "-d") == 0 || strcmp(argv[i], "--desc") == 0) && i + 1 < argc) {
            description = argv[++i];
            continue;
        }
        if (argv[i][0] == '-') {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            return 1;
        }
        target = argv[i];
    }

    print_banner();

    // Clean mode
    if (do_clean) {
        printf("  cleaning previous results...\n");
        clean_reports();
        printf("  done.\n\n");
        return 0;
    }

    // Report-only mode — find most recent XML
    if (do_report_only) {
        if (!check_command("xsltproc")) {
            fprintf(stderr, "  [!] xsltproc not found\n");
            return 1;
        }
        // Find most recent report_*.xml
        DIR *d = opendir(".");
        struct dirent *e;
        char newest[512] = "";
        time_t newest_time = 0;
        if (d) {
            while ((e = readdir(d)) != NULL) {
                size_t len = strlen(e->d_name);
                if (strncmp(e->d_name, "report_", 7) == 0 &&
                    len > 4 && strcmp(e->d_name + len - 4, ".xml") == 0) {
                    struct stat st;
                    if (stat(e->d_name, &st) == 0 && st.st_mtime > newest_time) {
                        newest_time = st.st_mtime;
                        snprintf(newest, sizeof(newest), "%s", e->d_name);
                    }
                }
            }
            closedir(d);
        }
        if (!newest[0]) {
            fprintf(stderr, "  [!] no report_*.xml found\n\n");
            return 1;
        }
        // Strip .xml to get base name, set global paths
        newest[strlen(newest) - 4] = '\0';
        snprintf(s_report_base, sizeof(s_report_base), "%s", newest);
        snprintf(s_report_xml,  sizeof(s_report_xml),  "%s.xml",  s_report_base);
        snprintf(s_report_html, sizeof(s_report_html), "%s.html", s_report_base);
        printf("  using     : %s\n", s_report_xml);
        int rc = generate_report();
        printf("\n");
        return rc;
    }

    // Scan mode — need a target
    if (!target) {
        fprintf(stderr, "  [!] no target specified\n\n");
        print_usage(argv[0]);
        return 1;
    }

    if (!is_valid_target(target)) {
        fprintf(stderr, "  [!] invalid target: %s\n", target);
        fprintf(stderr, "      use IP, CIDR, or range (e.g., 10.0.0.0/24)\n\n");
        return 1;
    }

    // Build the report filename
    build_report_name(target, description);
    snprintf(s_report_xml,  sizeof(s_report_xml),  "%s.xml",  s_report_base);
    snprintf(s_report_html, sizeof(s_report_html), "%s.html", s_report_base);

    // Show target info
    describe_target(target);
    if (description)
        printf("  label     : %s\n", description);
    printf("\n");

    // Check we're root (nmap needs it for SYN scan)
    if (geteuid() != 0) {
        fprintf(stderr, "  [!] must run as root (nmap needs raw sockets)\n\n");
        return 1;
    }

    // Check all dependencies
    printf("  checking dependencies...\n");
    if (!check_dependencies()) {
        fprintf(stderr, "\n  [!] missing dependencies, cannot continue\n\n");
        return 1;
    }
    printf("  all dependencies OK\n\n");

    // Run the scan
    int rc = run_scan(target);
    if (rc != 0) return rc;

    // Generate HTML report
    rc = generate_report();
    printf("\n");
    return rc;
}

