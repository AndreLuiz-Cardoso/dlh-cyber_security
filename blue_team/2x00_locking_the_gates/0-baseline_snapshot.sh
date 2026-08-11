#!/bin/bash
#
# 0-baseline_snapshot.sh
# -----------------------------------------------------------------------------
# MedDefense Health Systems -- Infrastructure Hardening (2x00 Locking the Gates)
#
# Purpose: Capture the COMPLETE security state of a Linux server BEFORE any
#          hardening is applied. This is the measurement baseline that every
#          subsequent task improves against ("show the delta").
#
# Connects to MedDefense findings:
#   - 1x02 Finding 009 (SSH password auth) -> we snapshot current SSH config
#   - 1x02 Finding 026 (outdated kernel / CVEs) -> we snapshot kernel + sysctl
#   - Crimson Tide advisory (breaches start on a misconfigured reachable server)
#     -> we snapshot open ports, services, SUID/SGID and world-writable files
#
# Design notes:
#   - Read-only: this script CHANGES NOTHING. It only observes and records.
#   - Idempotent by nature: re-running produces a fresh, equivalent snapshot.
#   - Emits a human-readable summary to stdout AND a structured JSON artifact
#     to /var/log/meddefense (or ./ if not writable) for auto-checking and for
#     the post-hardening diff in later tasks.
# -----------------------------------------------------------------------------

set -o pipefail

# ---- resolve an output location we can actually write to --------------------
OUT_DIR="/var/log/meddefense"
if ! mkdir -p "$OUT_DIR" 2>/dev/null || [ ! -w "$OUT_DIR" ]; then
    OUT_DIR="$(pwd)"
fi
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
JSON_OUT="${OUT_DIR}/baseline_snapshot.json"

# ---- helpers ----------------------------------------------------------------
# json_escape: make an arbitrary string safe to embed inside a JSON "..." value
json_escape() {
    # escapes backslash, double-quote, tab, CR and newline
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' \
        | awk 'BEGIN{ORS=""} {print sep $0; sep="\\n"}'
}

# array_from_lines: turn newline-separated input into a JSON array of strings
array_from_lines() {
    local first=1
    printf '['
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        if [ $first -eq 1 ]; then first=0; else printf ','; fi
        printf '"%s"' "$(printf '%s' "$line" | json_escape)"
    done
    printf ']'
}

# ---- 1. system identification ----------------------------------------------
HOSTNAME_VAL="$(hostname 2>/dev/null)"
if [ -r /etc/os-release ]; then
    OS_VAL="$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}")"
else
    OS_VAL="$(uname -s)"
fi
KERNEL_VAL="$(uname -r 2>/dev/null)"
UPTIME_VAL="$(uptime -p 2>/dev/null || uptime 2>/dev/null | tr -s ' ')"

# ---- 2. running services ----------------------------------------------------
# Prefer systemd; fall back to a process count if systemctl is absent.
if command -v systemctl >/dev/null 2>&1; then
    SERVICES_RAW="$(systemctl list-units --type=service --state=running --no-legend --no-pager 2>/dev/null | awk '{print $1}')"
else
    SERVICES_RAW="$(service --status-all 2>/dev/null | awk '/\[ \+ \]/{print $NF}')"
fi
SERVICES_COUNT="$(printf '%s\n' "$SERVICES_RAW" | grep -c . )"

# ---- 3. open ports / listening sockets -------------------------------------
if command -v ss >/dev/null 2>&1; then
    PORTS_RAW="$(ss -tulnH 2>/dev/null | awk '{print $1"/"$5}')"
else
    PORTS_RAW="$(netstat -tuln 2>/dev/null | awk 'NR>2{print $1"/"$4}')"
fi
PORTS_COUNT="$(printf '%s\n' "$PORTS_RAW" | grep -c . )"

# ---- 4. SUID and SGID binaries ---------------------------------------------
# Search real filesystems only; suppress permission-denied noise.
SUID_RAW="$(find / -xdev -type f -perm -4000 2>/dev/null | sort)"
SGID_RAW="$(find / -xdev -type f -perm -2000 2>/dev/null | sort)"
SUID_COUNT="$(printf '%s\n' "$SUID_RAW" | grep -c . )"
SGID_COUNT="$(printf '%s\n' "$SGID_RAW" | grep -c . )"

# ---- 5. world-writable files (excluding virtual filesystems) ---------------
WW_RAW="$(find / -xdev -type f -perm -0002 \
            -not -path '/proc/*' -not -path '/sys/*' -not -path '/dev/*' \
            2>/dev/null | sort)"
WW_COUNT="$(printf '%s\n' "$WW_RAW" | grep -c . )"

# ---- 6. security-relevant sysctl parameters --------------------------------
SYSCTL_KEYS=(
    net.ipv4.ip_forward
    net.ipv4.conf.all.accept_redirects
    net.ipv4.conf.all.send_redirects
    net.ipv4.conf.all.accept_source_route
    net.ipv4.tcp_syncookies
    net.ipv4.conf.all.rp_filter
    net.ipv4.icmp_echo_ignore_broadcasts
    kernel.randomize_va_space
    fs.suid_dumpable
)
SYSCTL_PAIRS=""
for key in "${SYSCTL_KEYS[@]}"; do
    val="$(sysctl -n "$key" 2>/dev/null)"
    [ -z "$val" ] && val="unset"
    SYSCTL_PAIRS+="${key}=${val}"$'\n'
done

# ---- 7. current SSH configuration ------------------------------------------
# Read the effective directives we care about from sshd_config (defaults noted).
SSHD_CONF="/etc/ssh/sshd_config"
get_ssh() {  # $1 = directive name, $2 = default if not explicitly set
    local v
    v="$(grep -Ei "^[[:space:]]*$1[[:space:]]+" "$SSHD_CONF" 2>/dev/null | tail -1 | awk '{print $2}')"
    [ -z "$v" ] && v="$2(default)"
    printf '%s' "$v"
}
SSH_PERMITROOT="$(get_ssh PermitRootLogin 'prohibit-password')"
SSH_PASSAUTH="$(get_ssh PasswordAuthentication 'yes')"
SSH_PUBKEY="$(get_ssh PubkeyAuthentication 'yes')"
SSH_X11="$(get_ssh X11Forwarding 'no')"
SSH_MAXAUTH="$(get_ssh MaxAuthTries '6')"
SSH_CLIENTALIVE="$(get_ssh ClientAliveInterval '0')"
SSH_PERMITEMPTY="$(get_ssh PermitEmptyPasswords 'no')"
SSH_PROTOCOL="$(get_ssh Protocol '2')"

# ---- 8. user accounts and sudo membership ----------------------------------
# Real login users = UID >= 1000 with a valid login shell, plus root.
LOGIN_USERS_RAW="$(awk -F: '($3>=1000 && $3<65534) || $3==0 {print $1":uid="$3":shell="$7}' /etc/passwd 2>/dev/null | sort)"
SUDO_MEMBERS_RAW="$(getent group sudo 2>/dev/null | awk -F: '{print $4}' | tr ',' '\n' | grep -c .)"
[ -z "$SUDO_MEMBERS_RAW" ] && SUDO_MEMBERS_RAW=0
SUDO_LIST="$(getent group sudo 2>/dev/null | awk -F: '{print $4}' | tr ',' '\n' | sort)"

# =============================================================================
#  HUMAN-READABLE SUMMARY (matches the project's Expected Output)
# =============================================================================
echo "Hostname: ${HOSTNAME_VAL}"
echo "OS: ${OS_VAL}"
echo "Kernel: ${KERNEL_VAL}"
echo "Running services: ${SERVICES_COUNT}"
echo "Open ports: ${PORTS_COUNT}"
echo "SUID binaries: ${SUID_COUNT}"
echo "SGID binaries: ${SGID_COUNT}"
echo "World-writable files: ${WW_COUNT}"

# =============================================================================
#  STRUCTURED JSON ARTIFACT (machine-readable, feeds later diff tasks)
# =============================================================================
{
    printf '{\n'
    printf '  "snapshot_type": "baseline",\n'
    printf '  "captured_at_utc": "%s",\n' "$TIMESTAMP"
    printf '  "system": {\n'
    printf '    "hostname": "%s",\n' "$(printf '%s' "$HOSTNAME_VAL" | json_escape)"
    printf '    "os": "%s",\n' "$(printf '%s' "$OS_VAL" | json_escape)"
    printf '    "kernel": "%s",\n' "$(printf '%s' "$KERNEL_VAL" | json_escape)"
    printf '    "uptime": "%s"\n' "$(printf '%s' "$UPTIME_VAL" | json_escape)"
    printf '  },\n'

    printf '  "counts": {\n'
    printf '    "running_services": %s,\n' "$SERVICES_COUNT"
    printf '    "open_ports": %s,\n' "$PORTS_COUNT"
    printf '    "suid_binaries": %s,\n' "$SUID_COUNT"
    printf '    "sgid_binaries": %s,\n' "$SGID_COUNT"
    printf '    "world_writable_files": %s,\n' "$WW_COUNT"
    printf '    "sudo_members": %s\n' "$SUDO_MEMBERS_RAW"
    printf '  },\n'

    printf '  "running_services": '
    printf '%s\n' "$SERVICES_RAW" | array_from_lines
    printf ',\n'

    printf '  "open_ports": '
    printf '%s\n' "$PORTS_RAW" | array_from_lines
    printf ',\n'

    printf '  "suid_binaries": '
    printf '%s\n' "$SUID_RAW" | array_from_lines
    printf ',\n'

    printf '  "sgid_binaries": '
    printf '%s\n' "$SGID_RAW" | array_from_lines
    printf ',\n'

    printf '  "world_writable_files": '
    printf '%s\n' "$WW_RAW" | array_from_lines
    printf ',\n'

    printf '  "sysctl": {\n'
    first=1
    while IFS='=' read -r k v; do
        [ -z "$k" ] && continue
        if [ $first -eq 1 ]; then first=0; else printf ',\n'; fi
        printf '    "%s": "%s"' "$k" "$(printf '%s' "$v" | json_escape)"
    done <<< "$SYSCTL_PAIRS"
    printf '\n  },\n'

    printf '  "ssh_config": {\n'
    printf '    "PermitRootLogin": "%s",\n' "$SSH_PERMITROOT"
    printf '    "PasswordAuthentication": "%s",\n' "$SSH_PASSAUTH"
    printf '    "PubkeyAuthentication": "%s",\n' "$SSH_PUBKEY"
    printf '    "X11Forwarding": "%s",\n' "$SSH_X11"
    printf '    "MaxAuthTries": "%s",\n' "$SSH_MAXAUTH"
    printf '    "ClientAliveInterval": "%s",\n' "$SSH_CLIENTALIVE"
    printf '    "PermitEmptyPasswords": "%s",\n' "$SSH_PERMITEMPTY"
    printf '    "Protocol": "%s"\n' "$SSH_PROTOCOL"
    printf '  },\n'

    printf '  "login_users": '
    printf '%s\n' "$LOGIN_USERS_RAW" | array_from_lines
    printf ',\n'

    printf '  "sudo_members": '
    printf '%s\n' "$SUDO_LIST" | array_from_lines
    printf '\n'

    printf '}\n'
} > "$JSON_OUT"

echo ""
echo "Baseline JSON written to: ${JSON_OUT}"
exit 0
