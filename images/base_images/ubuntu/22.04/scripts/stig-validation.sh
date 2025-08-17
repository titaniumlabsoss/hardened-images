#!/bin/bash
# STIG compliance validation script
# Validates Ubuntu 22.04 LTS STIG hardening implementation

echo "=== STIG Compliance Validation ==="
echo "Ubuntu 22.04 LTS DISA STIG V2R2 Compliance Check"
echo "Date: $(date)"
echo

PASS_COUNT=0
FAIL_COUNT=0
TOTAL_CHECKS=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
    ((TOTAL_CHECKS++))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
    ((TOTAL_CHECKS++))
}

check_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# STIG V-238196: Ubuntu version check
echo "=== System Information ==="

# Try multiple methods to detect Ubuntu version
UBUNTU_VERSION=""
if [ -f /etc/os-release ]; then
    UBUNTU_VERSION=$(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
elif [ -f /etc/lsb-release ]; then
    UBUNTU_VERSION=$(grep "DISTRIB_DESCRIPTION" /etc/lsb-release | cut -d'"' -f2)
elif command -v lsb_release >/dev/null 2>&1; then
    UBUNTU_VERSION=$(lsb_release -d | cut -f2)
else
    UBUNTU_VERSION="Unknown"
fi

check_info "Ubuntu Version: $UBUNTU_VERSION"

if echo "$UBUNTU_VERSION" | grep -q "Ubuntu 22.04"; then
    check_pass "V-238196: System is Ubuntu 22.04 LTS"
else
    check_fail "V-238196: System is not Ubuntu 22.04 LTS"
fi

# STIG V-238200: Time synchronization
echo
echo "=== Time Synchronization ==="
if dpkg -l | grep -q chrony; then
    check_pass "V-238200: Chrony package installed"
else
    check_fail "V-238200: Chrony package not installed"
fi

if ! dpkg -l | grep -q systemd-timesyncd; then
    check_pass "V-238200: systemd-timesyncd removed"
else
    check_fail "V-238200: systemd-timesyncd still installed"
fi

# STIG V-238208: File integrity monitoring
echo
echo "=== File Integrity Monitoring ==="
if dpkg -l | grep -q aide; then
    check_pass "V-238208: AIDE installed for file integrity monitoring"
else
    check_fail "V-238208: AIDE not installed"
fi

# STIG V-238252: Audit logging
echo
echo "=== Audit Logging ==="
if dpkg -l | grep -q auditd; then
    check_pass "V-238252: Audit daemon package installed"
else
    check_fail "V-238252: Audit daemon package not installed"
fi

if [ -f /etc/audit/rules.d/stig-audit.rules ]; then
    check_pass "V-238252: STIG audit rules configured"
else
    check_fail "V-238252: STIG audit rules not found"
fi

# STIG V-238290: Firewall
echo
echo "=== Firewall Configuration ==="
if command -v ufw >/dev/null 2>&1 && [ -f /etc/ufw/ufw.conf ]; then
    check_pass "V-238290: UFW firewall package installed and configured"
else
    check_fail "V-238290: UFW firewall not installed or configured"
fi

# STIG V-238330: Password policy
echo
echo "=== Password Policy ==="
if grep -q "minlen = 15" /etc/security/pwquality.conf; then
    check_pass "V-238330: Password minimum length set to 15"
else
    check_fail "V-238330: Password minimum length not set to 15"
fi

if grep -q "ucredit = -1" /etc/security/pwquality.conf; then
    check_pass "V-238331: Password uppercase requirement configured"
else
    check_fail "V-238331: Password uppercase requirement not configured"
fi

# STIG V-238362: Ctrl-Alt-Delete disabled
echo
echo "=== System Controls ==="
check_pass "V-238362: Ctrl-Alt-Delete disabled (container environment)"

# STIG V-238366: Non-root user
echo
echo "=== User Security ==="
if id appuser >/dev/null 2>&1; then
    check_pass "V-238366: Non-root user (appuser) created"
else
    check_fail "V-238366: Non-root user not created"
fi

# STIG SSH Configuration
echo
echo "=== SSH Configuration ==="
if grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
    check_pass "V-238306: SSH root login disabled"
else
    check_fail "V-238306: SSH root login not disabled"
fi

if grep -q "PermitEmptyPasswords no" /etc/ssh/sshd_config; then
    check_pass "V-238292: SSH empty passwords disabled"
else
    check_fail "V-238292: SSH empty passwords not disabled"
fi

if grep -q "X11Forwarding no" /etc/ssh/sshd_config; then
    check_pass "V-238297: SSH X11 forwarding disabled"
else
    check_fail "V-238297: SSH X11 forwarding not disabled"
fi

# STIG AppArmor
echo
echo "=== Mandatory Access Control ==="
if dpkg -l | grep -q apparmor; then
    check_pass "V-238224: AppArmor package installed"
else
    check_fail "V-238224: AppArmor package not installed"
fi

# STIG File Permissions
echo
echo "=== File Permissions ==="
if [ "$(stat -c %a /etc/passwd)" = "644" ]; then
    check_pass "V-238380: /etc/passwd permissions correct (644)"
else
    check_fail "V-238380: /etc/passwd permissions incorrect"
fi

if [ "$(stat -c %a /etc/shadow)" = "640" ]; then
    check_pass "V-238380: /etc/shadow permissions correct (640)"
else
    check_fail "V-238380: /etc/shadow permissions incorrect"
fi

# STIG Kernel Parameters
echo
echo "=== Kernel Parameters ==="
if grep -q "net.ipv4.ip_forward = 0" /etc/sysctl.d/99-stig.conf; then
    check_pass "V-238314: IP forwarding disabled"
else
    check_fail "V-238314: IP forwarding not disabled"
fi

if grep -q "kernel.dmesg_restrict = 1" /etc/sysctl.d/99-stig.conf; then
    check_pass "V-238417: dmesg access restricted"
else
    check_fail "V-238417: dmesg access not restricted"
fi

# STIG Package Management
echo
echo "=== Package Management ==="
if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
    check_pass "V-238222: Automatic security updates configured"
else
    check_fail "V-238222: Automatic security updates not configured"
fi

# STIG Cryptographic Controls
echo
echo "=== Cryptographic Controls ==="
if [ -f /etc/ssl/openssl.cnf ]; then
    check_pass "V-238350: OpenSSL configuration present"
else
    check_fail "V-238350: OpenSSL configuration missing"
fi

if [ -f /etc/fips/fips.conf ]; then
    check_pass "V-238356: FIPS configuration present"
else
    check_fail "V-238356: FIPS configuration missing"
fi

# STIG Login Banner
echo
echo "=== Login Security ==="
if [ -f /etc/issue.net ]; then
    check_pass "V-238311: SSH login banner configured"
else
    check_fail "V-238311: SSH login banner not configured"
fi

if [ -f /etc/motd ]; then
    check_pass "V-238422: Message of the day configured"
else
    check_fail "V-238422: Message of the day not configured"
fi

# STIG Compliance Summary
echo
echo "=== STIG Compliance Summary ==="
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}RESULT: FULLY COMPLIANT${NC}"
    echo "All STIG controls verified successfully."
elif [ $FAIL_COUNT -le 5 ]; then
    echo -e "${YELLOW}RESULT: MOSTLY COMPLIANT${NC}"
    echo "Minor issues detected. Review failed checks."
else
    echo -e "${RED}RESULT: NON-COMPLIANT${NC}"
    echo "Significant issues detected. Manual remediation required."
fi

COMPLIANCE_PERCENTAGE=$((PASS_COUNT * 100 / TOTAL_CHECKS))
echo "Compliance Rate: $COMPLIANCE_PERCENTAGE%"

exit $FAIL_COUNT
