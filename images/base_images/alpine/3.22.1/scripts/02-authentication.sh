#!/bin/sh
# Alpine Linux Authentication and Access Control
# Implements STIG-equivalent authentication controls

set -e

echo "=== Starting Authentication Hardening ==="

# Configure password policy (STIG V-257898-V-257910)
mkdir -p /etc/security
cat > /etc/security/pwquality.conf << 'EOF'
# STIG Password requirements
minlen = 15
minclass = 4
maxrepeat = 3
maxclasschg = 4
difok = 8
gecoscheck = 1
dictcheck = 1
usercheck = 1
enforcing = 1
retry = 3
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
EOF

# Configure password aging (STIG V-257911)
cat >> /etc/login.defs << 'EOF'
PASS_MAX_DAYS 60
PASS_MIN_DAYS 1
PASS_WARN_AGE 7
UMASK 077
CREATE_HOME yes
USERGROUPS_ENAB yes
ENCRYPT_METHOD SHA512
SHA_CRYPT_MIN_ROUNDS 5000
SHA_CRYPT_MAX_ROUNDS 500000
EOF

# Configure account lockout (STIG V-257912-V-257915)
cat > /etc/security/faillock.conf << 'EOF'
# Account lockout policy
dir = /var/run/faillock
audit
silent
deny = 3
fail_interval = 900
unlock_time = 0
root_unlock_time = 60
EOF

# Configure PAM for Alpine (if PAM is available)
if [ -d /etc/pam.d ]; then
    cat > /etc/pam.d/system-auth << 'EOF'
#%PAM-1.0
# STIG compliant PAM configuration for Alpine

auth        required      pam_env.so
auth        required      pam_faillock.so preauth silent audit deny=3 unlock_time=0 fail_interval=900
auth        sufficient    pam_unix.so try_first_pass
auth        [default=die] pam_faillock.so authfail audit deny=3 unlock_time=0 fail_interval=900
auth        required      pam_deny.so

account     required      pam_unix.so
account     required      pam_faillock.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok remember=5
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
session     required      pam_unix.so
EOF
fi

# Lock root account (STIG V-257918)
# In Alpine, we need to set the password field to ! or * to lock the account
# First, ensure shadow package is installed for passwd command
sed -i 's/^root:[^:]*:/root:!:/' /etc/shadow 2>/dev/null || true
# Also try using passwd -l if available (requires shadow package)
passwd -l root 2>/dev/null || true
# Double-check by setting the shell to nologin
sed -i 's|^root:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*$|root:x:0:0:root:/root:/sbin/nologin|' /etc/passwd 2>/dev/null || true

# Configure user shell timeout (STIG V-257919)
cat >> /etc/profile << 'EOF'
# Session timeout
TMOUT=900
readonly TMOUT
export TMOUT
EOF

# Configure shell history
cat >> /etc/profile << 'EOF'
# Security settings for shell history
HISTFILE=/dev/null
HISTSIZE=0
HISTFILESIZE=0
export HISTFILE HISTSIZE HISTFILESIZE
EOF

# Restrict access to su command (STIG V-257920)
if [ -f /bin/su ]; then
    chmod 4750 /bin/su
    chgrp wheel /bin/su 2>/dev/null || chgrp root /bin/su
fi

echo "=== Authentication Hardening Complete ==="
