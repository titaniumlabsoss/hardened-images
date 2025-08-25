#!/bin/bash
# RHEL 9 STIG Authentication and Access Control

set -e

echo "=== Starting Authentication Hardening ==="

# RHEL 9 STIG V-257898: Configure password policy
cat > /etc/security/pwquality.conf << 'EOF'
# RHEL 9 STIG V-257898-V-257910: Password requirements
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
EOF

# RHEL 9 STIG V-257911: Configure password aging
cat >> /etc/login.defs << 'EOF'
PASS_MAX_DAYS 60
PASS_MIN_DAYS 1
PASS_WARN_AGE 7
UMASK 077
CREATE_HOME yes
USERGROUPS_ENAB yes
ENCRYPT_METHOD SHA512
EOF

# RHEL 9 STIG V-257912: Configure account lockout
cat > /etc/security/faillock.conf << 'EOF'
# RHEL 9 STIG V-257912-V-257915: Account lockout policy
dir = /var/run/faillock
audit
silent
deny = 3
fail_interval = 900
unlock_time = 0
root_unlock_time = 60
EOF

# RHEL 9 STIG V-257916: Configure PAM for authentication
cat > /etc/pam.d/system-auth << 'EOF'
#%PAM-1.0
# RHEL 9 STIG compliant PAM configuration

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
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
EOF

# RHEL 9 STIG V-257917: Configure sudo
cat > /etc/sudoers.d/stig << 'EOF'
# RHEL 9 STIG V-257917: Sudo configuration
Defaults    timestamp_timeout=0
Defaults    !visiblepw
Defaults    always_set_home
Defaults    match_group_by_gid
Defaults    always_query_group_plugin
Defaults    env_reset
Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS"
Defaults    env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin
EOF

# RHEL 9 STIG V-257918: Disable root login
passwd -l root

# RHEL 9 STIG V-257919: Configure user shell timeout
cat >> /etc/profile << 'EOF'
# RHEL 9 STIG V-257919: Session timeout
TMOUT=900
readonly TMOUT
export TMOUT
EOF

cat >> /etc/bashrc << 'EOF'
# RHEL 9 STIG V-257919: Session timeout
TMOUT=900
readonly TMOUT
export TMOUT
EOF

# RHEL 9 STIG V-257920: Restrict access to su command
chmod 4750 /bin/su

echo "=== Authentication Hardening Complete ==="
