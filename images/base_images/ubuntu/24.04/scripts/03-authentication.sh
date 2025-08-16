#!/bin/bash
# Authentication and access control hardening

set -e

echo "=== Starting Authentication Hardening ==="

# STIG V-270705: Configure pwquality
cat > /etc/security/pwquality.conf << 'EOF'
# STIG password complexity requirements

# Minimum password length (15 characters minimum)
minlen = 15

# Uppercase character requirement (-1 = at least 1 required, positive = max credit)
ucredit = -1

# Lowercase character requirement (-1 = at least 1 required, positive = max credit)
lcredit = -1

# Digit character requirement (-1 = at least 1 required, positive = max credit)
dcredit = -1

# Other/special character requirement (-1 = at least 1 required, positive = max credit)
ocredit = -1

# Minimum number of character classes that must change between old and new password
difok = 8

# Enable dictionary checking to prevent common dictionary words
dictcheck = 1

# Enforce all password quality rules (1 = enabled, 0 = disabled)
enforcing = 1
EOF

# STIG V-270690: Configure faillock (account lockout)
cat > /etc/security/faillock.conf << 'EOF'
# STIG account lockout requirements

# Enable audit logging of authentication failures and lockouts
audit

# Suppress informational messages to users about lockout status
silent

# Number of failed login attempts before account lockout (3 attempts)
deny = 3

# Time window in seconds for counting failed attempts (900 sec = 15 minutes)
# Failed attempts within this interval count toward the deny limit
fail_interval = 900

# Account unlock time in seconds (0 = manual unlock required by administrator)
# Setting to 0 means locked accounts must be manually unlocked
unlock_time = 0
EOF

# Update PAM configuration for password quality
cp /etc/pam.d/common-password /etc/pam.d/common-password.bak
cat > /etc/pam.d/common-password << 'EOF'
# PAM configuration for password - STIG compliant

# Password quality enforcement using pwquality module
# requisite = must succeed or authentication fails immediately
# retry=3 allows up to 3 attempts to enter a compliant password
password requisite pam_pwquality.so retry=3

# Unix password module for actual password storage and validation
# success=1 = skip next module if this succeeds
# default=ignore = ignore this module's result for final authentication decision
# obscure = additional password complexity checks
# sha512 = use SHA-512 hashing algorithm (stronger than MD5/SHA-1)
# shadow = store passwords in /etc/shadow (more secure than /etc/passwd)
# remember=5 = prevent reuse of last 5 passwords
# rounds=100000 = use 100,000 hash rounds for increased security against brute force
password [success=1 default=ignore] pam_unix.so obscure sha512 shadow remember=5 rounds=100000

# Deny module - explicitly denies access if reached
# requisite = authentication fails immediately if this module is reached
# This acts as a fallback security measure
password requisite pam_deny.so

# Permit module - allows access (should not be reached due to success=1 above)
# required = must be present but result doesn't affect authentication
# This is typically used for accounting/logging purposes
password required pam_permit.so
EOF

# Update PAM configuration for authentication with faillock
cp /etc/pam.d/common-auth /etc/pam.d/common-auth.bak
sed -i '/pam_unix.so/a auth     [default=die]  pam_faillock.so authfail\nauth     sufficient     pam_faillock.so authsucc' /etc/pam.d/common-auth

# STIG V-270706: Configure pam_faildelay
echo "auth    required    pam_faildelay.so    delay=4000000" >> /etc/pam.d/common-auth

# STIG V-270710: Configure last login display
echo "session     required      pam_lastlog.so showfailed" >> /etc/pam.d/login

# STIG V-270721: Configure smart card authentication (PIV)
echo "auth    [success=2 default=ignore] pam_pkcs11.so" >> /etc/pam.d/common-auth

# STIG V-270707: Remove NOPASSWD from sudoers
sed -i '/NOPASSWD/d' /etc/sudoers 2>/dev/null || true
find /etc/sudoers.d/ -type f -exec sed -i '/NOPASSWD/d' {} \; 2>/dev/null || true

# STIG V-270677: Set concurrent session limit
echo "* hard maxlogins 10" >> /etc/security/limits.conf

# STIG V-270680: Set session timeout
cat > /etc/profile.d/99-terminal_tmout.sh << 'EOF'
TMOUT=600
export TMOUT
readonly TMOUT
EOF

# STIG V-270724: Lock root account
passwd -l root

# STIG V-270730, V-270731: Set password aging
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS    1/' /etc/login.defs
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS    60/' /etc/login.defs

# STIG V-270683: Set account inactivity period
useradd -D -f 35

# STIG V-270739: Set password encryption method
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs

echo "=== Authentication Hardening Complete ==="
