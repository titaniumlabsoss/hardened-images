#!/bin/bash
# STIG authentication and access control hardening
# Implements PAM, password policies, and user access controls

set -e

echo "=== Starting Authentication Hardening ==="

# STIG V-238330: Password minimum length must be 15 characters
cat > /etc/security/pwquality.conf << EOF
# STIG V-238330: Password minimum length
minlen = 15

# STIG V-238331: Password must contain at least one uppercase character
ucredit = -1

# STIG V-238332: Password must contain at least one lowercase character
lcredit = -1

# STIG V-238333: Password must contain at least one numeric character
dcredit = -1

# STIG V-238334: Password must contain at least one special character
ocredit = -1

# STIG V-238335: Password must differ from previous passwords
difok = 8

# STIG V-238336: Password maximum age
maxrepeat = 3
maxclassrepeat = 4
maxsequence = 3
dictcheck = 1
usercheck = 1
enforcing = 1
EOF

# STIG V-238337: Configure password history
sed -i 's/password.*pam_unix.so.*/password required pam_unix.so use_authtok sha512 shadow remember=5/' /etc/pam.d/common-password

# STIG V-238338: Password minimum age must be 1 day
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS\t1/' /etc/login.defs

# STIG V-238339: Password maximum age must be 60 days
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS\t60/' /etc/login.defs

# STIG V-238340: Password warning age must be 7 days
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE\t7/' /etc/login.defs

# STIG V-238341: Account lockout must be configured
cat > /etc/pam.d/common-auth << EOF
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# STIG V-238341: Account lockout after 3 unsuccessful attempts
auth    required        pam_faillock.so preauth silent audit deny=3 unlock_time=900
auth    [default=die]   pam_faillock.so authfail audit deny=3 unlock_time=900
auth    sufficient     pam_faillock.so authsucc audit deny=3 unlock_time=900
auth    [success=1 default=ignore]      pam_unix.so nullok_secure
auth    requisite                       pam_deny.so
auth    required                        pam_permit.so
auth    optional                        pam_cap.so 
EOF

# STIG V-238342: Session timeout must be set
cat >> /etc/profile << EOF

# STIG V-238342: Set session timeout to 10 minutes
TMOUT=600
readonly TMOUT
export TMOUT
EOF

# STIG V-238343: Root login must be restricted
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# STIG V-238344: Configure sudo timeout
echo "Defaults timestamp_timeout=0" >> /etc/sudoers.d/stig-timeout

# STIG V-238345: Must use multifactor authentication
cat > /etc/pam.d/sshd << EOF
#%PAM-1.0
auth       substack     password-auth
auth       include      postlogin
account    required     pam_sepermit.so
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
EOF

# STIG V-238346: System must prevent non-privileged users from executing privileged functions
chmod 750 /usr/bin/su
chmod 750 /usr/bin/sudo

# STIG V-238347: All interactive user home directories must be group-owned by the home directory owner's primary group
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        if id "$user" >/dev/null 2>&1; then
            primary_group=$(id -gn "$user")
            chown "$user:$primary_group" "$user_home"
        fi
    fi
done

# STIG V-238348: Set umask to 077
echo "umask 077" >> /etc/profile
echo "umask 077" >> /etc/bash.bashrc

echo "=== Authentication Hardening Complete ==="
