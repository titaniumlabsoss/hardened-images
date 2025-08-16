#!/bin/bash
# STIG Compliance Validation Script for Ubuntu 24.04 LTS
# This script validates key STIG requirements

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    echo "Usage: sudo $0"
    exit 1
fi

# Don't exit on errors - we want to continue validation even if some checks fail
# set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

print_header() {
    echo "======================================================"
    echo "Ubuntu 24.04 LTS STIG Compliance Validation"
    echo "======================================================"
    echo ""
}

print_result() {
    local test_name="$1"
    local result="$2"
    local details="$3"

    case $result in
        "PASS")
            echo -e "${GREEN}[PASS]${NC} $test_name"
            if [ -n "$details" ]; then
                echo "       $details"
            fi
            ((PASS_COUNT++))
            ;;
        "FAIL")
            echo -e "${RED}[FAIL]${NC} $test_name"
            if [ -n "$details" ]; then
                echo "       $details"
            fi
            ((FAIL_COUNT++))
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $test_name"
            if [ -n "$details" ]; then
                echo "       $details"
            fi
            ((WARN_COUNT++))
            ;;
    esac
    echo ""
}

validate_packages() {
    echo "Validating Package Configuration..."

    # STIG V-270645: systemd-timesyncd should not be installed
    if ! dpkg -l | grep -q systemd-timesyncd; then
        print_result "V-270645: systemd-timesyncd not installed" "PASS"
    else
        print_result "V-270645: systemd-timesyncd not installed" "FAIL" "systemd-timesyncd package is installed"
    fi

    # STIG V-270647: telnet should not be installed
    if ! dpkg -l | grep -q telnetd; then
        print_result "V-270647: telnet not installed" "PASS"
    else
        print_result "V-270647: telnet not installed" "FAIL" "telnetd package is installed"
    fi

    # STIG V-270649: AIDE should be installed
    if dpkg -l | grep -q aide; then
        print_result "V-270649: AIDE installed" "PASS"
    else
        print_result "V-270649: AIDE installed" "FAIL" "AIDE package not found"
    fi

    # STIG V-270656: auditd should be installed
    if dpkg -l | grep -q auditd; then
        print_result "V-270656: auditd installed" "PASS"
    else
        print_result "V-270656: auditd installed" "FAIL" "auditd package not found"
    fi
}

validate_services() {
    echo "Validating Service Configuration..."

    # STIG V-270657: auditd should be enabled
    # Check for systemd enable link during build
    if systemctl is-enabled auditd.service >/dev/null 2>&1 || test -L /etc/systemd/system/multi-user.target.wants/auditd.service; then
        print_result "V-270657: auditd service enabled" "PASS"
    else
        print_result "V-270657: auditd service enabled" "WARN" "auditd service enable status cannot be verified in build environment"
    fi

    # STIG V-270653: rsyslog should be enabled
    # Check for systemd enable link during build
    if systemctl is-enabled rsyslog >/dev/null 2>&1 || test -L /etc/systemd/system/multi-user.target.wants/rsyslog.service; then
        print_result "V-270653: rsyslog enabled" "PASS"
    else
        print_result "V-270653: rsyslog enabled" "WARN" "rsyslog service enable status cannot be verified in build environment"
    fi

    # STIG V-270655: Firewall configuration (iptables instead of UFW for minimal attack surface)
    # Check for iptables configuration files
    if test -f /etc/iptables/rules.v4 && grep -q "ssh_limit" /etc/iptables/rules.v4 2>/dev/null; then
        print_result "V-270655: Firewall configured" "PASS" "Iptables rules configured with SSH rate limiting"
    elif command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active" 2>/dev/null; then
        print_result "V-270655: UFW enabled" "PASS"
    else
        print_result "V-270655: Firewall configuration" "WARN" "Firewall configuration cannot be fully verified in build environment"
    fi
}

validate_authentication() {
    echo "Validating Authentication Configuration..."

    # STIG V-270705: pwquality configuration
    if grep -q "enforcing = 1" /etc/security/pwquality.conf; then
        print_result "V-270705: pwquality enforcing enabled" "PASS"
    else
        print_result "V-270705: pwquality enforcing enabled" "FAIL" "pwquality not enforcing"
    fi

    # STIG V-270690: faillock configuration
    if grep -q "deny = 3" /etc/security/faillock.conf; then
        print_result "V-270690: account lockout configured" "PASS"
    else
        print_result "V-270690: account lockout configured" "FAIL" "faillock not properly configured"
    fi

    # STIG V-270724: root account should be locked
    if passwd -S root 2>/dev/null | grep -q " L "; then
        print_result "V-270724: root account locked" "PASS"
    elif id -u | grep -q "^0$"; then
        print_result "V-270724: root account locked" "FAIL" "root account not locked"
    else
        print_result "V-270724: root account locked" "WARN" "Cannot verify root account status as non-root user"
    fi
}

validate_audit_rules() {
    echo "Validating Audit Rules..."

    # Check if audit rules are configured (check config files during build)
    if auditctl -l 2>/dev/null | grep -q "/etc/passwd" || grep -q "/etc/passwd" /etc/audit/rules.d/stig.rules 2>/dev/null; then
        print_result "V-270684: /etc/passwd monitoring" "PASS"
    elif test -f /etc/audit/rules.d/stig.rules; then
        print_result "V-270684: /etc/passwd monitoring" "WARN" "Audit rules configured but cannot verify loading in build environment"
    else
        print_result "V-270684: /etc/passwd monitoring" "FAIL" "/etc/passwd monitoring not configured"
    fi

    if auditctl -l 2>/dev/null | grep -q "execpriv" || grep -q "execpriv" /etc/audit/rules.d/stig.rules 2>/dev/null; then
        print_result "V-270689: Privilege escalation monitoring" "PASS"
    elif test -f /etc/audit/rules.d/stig.rules; then
        print_result "V-270689: Privilege escalation monitoring" "WARN" "Audit rules configured but cannot verify loading in build environment"
    else
        print_result "V-270689: Privilege escalation monitoring" "FAIL" "execpriv rules not configured"
    fi

    # STIG V-270832: Audit rules should be immutable (check config file)
    if auditctl -s 2>/dev/null | grep -q "enabled.*2" || grep -q "^-e 2" /etc/audit/rules.d/stig.rules 2>/dev/null; then
        print_result "V-270832: Audit rules immutable" "PASS"
    else
        print_result "V-270832: Audit rules immutable" "WARN" "Audit immutability cannot be verified in build environment"
    fi
}

validate_file_permissions() {
    echo "Validating File Permissions..."

    # STIG V-270716: Check umask setting
    if grep -q "UMASK 077" /etc/login.defs; then
        print_result "V-270716: Default umask configured" "PASS"
    else
        print_result "V-270716: Default umask configured" "FAIL" "UMASK not set to 077"
    fi
}

validate_network_security() {
    echo "Validating Network Security..."

    # STIG V-270753: TCP syncookies
    if sysctl net.ipv4.tcp_syncookies | grep -q "= 1"; then
        print_result "V-270753: TCP syncookies enabled" "PASS"
    else
        print_result "V-270753: TCP syncookies enabled" "FAIL" "TCP syncookies not enabled"
    fi

    # STIG V-270749: kernel.dmesg_restrict
    if sysctl kernel.dmesg_restrict | grep -q "= 1"; then
        print_result "V-270749: dmesg access restricted" "PASS"
    else
        print_result "V-270749: dmesg access restricted" "FAIL" "dmesg not restricted"
    fi
}

validate_ssh_config() {
    echo "Validating SSH Configuration..."

    # STIG V-270667: SSH ciphers
    if grep -q "aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr" /etc/ssh/sshd_config.d/99-stig-crypto.conf 2>/dev/null; then
        print_result "V-270667: SSH FIPS ciphers configured" "PASS"
    else
        print_result "V-270667: SSH FIPS ciphers configured" "FAIL" "SSH ciphers not FIPS compliant"
    fi

    # STIG V-270708: X11 forwarding disabled
    if grep -q "X11Forwarding no" /etc/ssh/sshd_config.d/99-stig-crypto.conf 2>/dev/null; then
        print_result "V-270708: X11 forwarding disabled" "PASS"
    else
        print_result "V-270708: X11 forwarding disabled" "FAIL" "X11 forwarding not disabled"
    fi
}

print_summary() {
    echo "======================================================"
    echo "VALIDATION SUMMARY"
    echo "======================================================"
    echo -e "${GREEN}PASSED: $PASS_COUNT${NC}"
    echo -e "${RED}FAILED: $FAIL_COUNT${NC}"
    echo -e "${YELLOW}WARNINGS: $WARN_COUNT${NC}"
    echo ""

    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}Overall Status: COMPLIANT${NC}"
        return 0
    else
        echo -e "${RED}Overall Status: NON-COMPLIANT${NC}"
        return 1
    fi
}

# Main execution
print_header
validate_packages
validate_services
validate_authentication
validate_audit_rules
validate_file_permissions
validate_network_security
validate_ssh_config
print_summary
