#!/bin/sh
# Alpine Linux Compliance Check Script
# Validates STIG-equivalent security controls

echo "================================================"
echo "Alpine Linux Security Compliance Check"
echo "================================================"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo "[FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "1. AUTHENTICATION AND ACCESS CONTROLS"
echo "--------------------------------------"

# Check root account is locked
# In Alpine, check if password field in shadow is ! or * (locked) or shell is nologin
ROOT_LOCKED=0
if grep -q "^root:!" /etc/shadow 2>/dev/null || grep -q "^root:\*" /etc/shadow 2>/dev/null; then
    ROOT_LOCKED=1
fi
if grep -q "^root:.*:/sbin/nologin" /etc/passwd 2>/dev/null; then
    ROOT_LOCKED=1
fi
if passwd -S root 2>/dev/null | grep -q "L\|NP"; then
    ROOT_LOCKED=1
fi

if [ "$ROOT_LOCKED" -eq 1 ]; then
    check_pass "Root account is locked"
else
    check_fail "Root account is not locked"
fi

# Check password policy
if [ -f /etc/security/pwquality.conf ]; then
    if grep -q "minlen = 15" /etc/security/pwquality.conf; then
        check_pass "Password minimum length is 15"
    else
        check_fail "Password minimum length is not 15"
    fi
else
    check_fail "Password quality configuration not found"
fi

# Check umask setting
if grep -q "umask 077" /etc/profile; then
    check_pass "Default umask is 077"
else
    check_fail "Default umask is not 077"
fi

# Check session timeout
if grep -q "TMOUT=900" /etc/profile; then
    check_pass "Session timeout is configured"
else
    check_fail "Session timeout is not configured"
fi

echo ""
echo "2. NETWORK SECURITY"
echo "-------------------"

# Check IP forwarding is disabled
if [ -f /etc/sysctl.d/99-stig-network.conf ]; then
    if grep -q "net.ipv4.ip_forward = 0" /etc/sysctl.d/99-stig-network.conf; then
        check_pass "IPv4 forwarding is disabled"
    else
        check_fail "IPv4 forwarding is not disabled"
    fi
  
    if grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.d/99-stig-network.conf; then
        check_pass "IPv6 is disabled"
    else
        check_fail "IPv6 is not disabled"
    fi
else
    check_fail "Network security configuration not found"
fi

# Check SSH configuration
if [ -f /etc/ssh/sshd_config ]; then
    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
        check_pass "SSH root login is disabled"
    else
        check_fail "SSH root login is not disabled"
    fi
  
    if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        check_pass "SSH password authentication is disabled"
    else
        check_fail "SSH password authentication is not disabled"
    fi
else
    check_fail "SSH configuration not found"
fi

echo ""
echo "3. FILE PERMISSIONS"
echo "-------------------"

# Check critical file permissions
if [ -f /etc/shadow ]; then
    SHADOW_PERMS=$(stat -c %a /etc/shadow)
    if [ "$SHADOW_PERMS" = "0" ] || [ "$SHADOW_PERMS" = "000" ]; then
        check_pass "/etc/shadow has correct permissions (000)"
    else
        check_fail "/etc/shadow has incorrect permissions ($SHADOW_PERMS)"
    fi
fi

if [ -f /etc/passwd ]; then
    PASSWD_PERMS=$(stat -c %a /etc/passwd)
    if [ "$PASSWD_PERMS" = "644" ]; then
        check_pass "/etc/passwd has correct permissions (644)"
    else
        check_fail "/etc/passwd has incorrect permissions ($PASSWD_PERMS)"
    fi
fi

echo ""
echo "4. KERNEL MODULES"
echo "-----------------"

# Check for blacklisted modules
if [ -f /etc/modprobe.d/stig-blacklist.conf ]; then
    if grep -q "install dccp /bin/true" /etc/modprobe.d/stig-blacklist.conf; then
        check_pass "Unnecessary network protocols are blacklisted"
    else
        check_fail "Unnecessary network protocols are not blacklisted"
    fi
  
    if grep -q "install usb-storage /bin/true" /etc/modprobe.d/stig-blacklist.conf; then
        check_pass "USB storage is disabled"
    else
        check_fail "USB storage is not disabled"
    fi
else
    check_fail "Kernel module blacklist not found"
fi

echo ""
echo "5. AUDIT AND LOGGING"
echo "--------------------"

# Check audit configuration
if [ -d /var/log/audit ]; then
    check_pass "Audit log directory exists"
else
    check_fail "Audit log directory does not exist"
fi

if [ -f /etc/audit/auditd.conf ] || [ -f /var/log/messages ]; then
    check_pass "Logging is configured"
else
    check_fail "Logging is not properly configured"
fi

echo ""
echo "6. CRYPTOGRAPHY"
echo "---------------"

# Check SSH host keys
if [ -f /etc/ssh/ssh_host_rsa_key ]; then
    RSA_KEY_SIZE=$(ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key 2>/dev/null | awk '{print $1}')
    if [ "$RSA_KEY_SIZE" -ge 3072 ]; then
        check_pass "SSH RSA key is strong (>= 3072 bits)"
    else
        check_fail "SSH RSA key is weak (< 3072 bits)"
    fi
fi

# Check for weak SSH algorithms
if [ -f /etc/ssh/sshd_config ]; then
    if grep -q "Ciphers.*aes256-ctr" /etc/ssh/sshd_config; then
        check_pass "Strong SSH ciphers are configured"
    else
        check_fail "Strong SSH ciphers are not configured"
    fi
fi

echo ""
echo "7. SYSTEM HARDENING"
echo "-------------------"

# Check for non-root user
if id appuser >/dev/null 2>&1; then
    check_pass "Non-root user 'appuser' exists"
else
    check_fail "Non-root user 'appuser' does not exist"
fi

# Check security banner
if [ -f /etc/issue ]; then
    if grep -q "NOTICE TO USERS" /etc/issue; then
        check_pass "Security banner is configured"
    else
        check_fail "Security banner is not configured"
    fi
else
    check_fail "Security banner file not found"
fi

# Check for world-writable files
WORLD_WRITABLE=$(find / -xdev -type f -perm -002 2>/dev/null | grep -v "^/tmp\|^/var/tmp" | wc -l)
if [ "$WORLD_WRITABLE" -eq 0 ]; then
    check_pass "No unauthorized world-writable files found"
else
    check_fail "Found $WORLD_WRITABLE world-writable files"
fi

echo ""
echo "================================================"
echo "Compliance Check Summary"
echo "================================================"
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "STATUS: COMPLIANT - All security controls passed"
    exit 0
else
    echo "STATUS: NON-COMPLIANT - Some security controls failed"
    echo "Please review failed items and remediate as necessary"
    exit 1
fi
