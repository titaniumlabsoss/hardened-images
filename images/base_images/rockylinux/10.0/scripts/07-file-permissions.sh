#!/bin/bash
# RHEL 9 STIG File Permissions and System Hardening

set -e

echo "=== Starting File Permissions Hardening ==="

# RHEL 9 STIG V-257848: Set file permissions for system files
[ -f /etc/passwd ] && chmod 644 /etc/passwd
[ -f /etc/shadow ] && chmod 000 /etc/shadow
[ -f /etc/group ] && chmod 644 /etc/group
[ -f /etc/gshadow ] && chmod 000 /etc/gshadow
[ -f /etc/ssh/sshd_config ] && chmod 600 /etc/ssh/sshd_config
[ -f /etc/ssh/ssh_config ] && chmod 644 /etc/ssh/ssh_config

# RHEL 9 STIG V-257849: Secure important directories
chmod 755 /etc
chmod 755 /usr
chmod 755 /usr/bin
chmod 755 /usr/sbin
chmod 755 /bin
chmod 755 /sbin

# RHEL 9 STIG V-257850: Remove world-writable files and directories
find / -xdev -type f -perm -002 -exec chmod o-w {} \; 2>/dev/null || true
find / -xdev -type d -perm -002 -exec chmod o-w {} \; 2>/dev/null || true

# RHEL 9 STIG V-257851: Find and secure files with no owner
find / -xdev -nouser -exec chown root {} \; 2>/dev/null || true
find / -xdev -nogroup -exec chgrp root {} \; 2>/dev/null || true

# RHEL 9 STIG V-257852: Set sticky bit on world-writable directories
find / -xdev -type d -perm -002 -a ! -perm -1000 -exec chmod +t {} \; 2>/dev/null || true

# RHEL 9 STIG V-257853: Remove SUID/SGID from unnecessary files
SUID_SGID_FILES=(
    "/usr/bin/at"
    "/usr/bin/crontab"
    "/usr/bin/wall"
    "/usr/bin/write"
    "/usr/bin/newgrp"
    "/usr/sbin/unix_chkpwd"
    "/usr/sbin/usernetctl"
)

for file in "${SUID_SGID_FILES[@]}"; do
    if [ -f "$file" ]; then
        chmod ug-s "$file"
    fi
done

# RHEL 9 STIG V-257854: Set umask for all users
cat >> /etc/profile << 'EOF'
# RHEL 9 STIG V-257854: Set restrictive umask
umask 077
EOF

# Fix existing umask setting in /etc/bashrc
sed -i 's/umask 022/umask 077/g' /etc/bashrc

cat >> /etc/bashrc << 'EOF'
# RHEL 9 STIG V-257854: Set restrictive umask
umask 077
EOF

# RHEL 9 STIG V-257855: Configure logrotate for audit logs
cat > /etc/logrotate.d/audit << 'EOF'
# RHEL 9 STIG V-257855: Audit log rotation
/var/log/audit/audit.log {
    missingok
    rotate 5
    weekly
    maxage 30
    compress
    notifempty
    sharedscripts
    postrotate
        /sbin/service auditd restart 2> /dev/null > /dev/null || true
    endscript
}
EOF

# RHEL 9 STIG V-257856: Secure cron
[ -f /etc/crontab ] && chmod 600 /etc/crontab
[ -d /etc/cron.d ] && chmod 700 /etc/cron.d
[ -d /etc/cron.daily ] && chmod 700 /etc/cron.daily
[ -d /etc/cron.hourly ] && chmod 700 /etc/cron.hourly
[ -d /etc/cron.monthly ] && chmod 700 /etc/cron.monthly
[ -d /etc/cron.weekly ] && chmod 700 /etc/cron.weekly

# Remove cron.deny and at.deny, create allow files
rm -f /etc/cron.deny /etc/at.deny
touch /etc/cron.allow /etc/at.allow
chmod 600 /etc/cron.allow /etc/at.allow
chown root:root /etc/cron.allow /etc/at.allow

# RHEL 9 STIG V-257857: Secure kernel modules
[ -d /lib/modules ] && find /lib/modules -type d -name "kernel" -exec chmod 700 {} \; 2>/dev/null || true
[ -d /lib/modules ] && find /lib/modules -name "*.ko" -type f -exec chmod 600 {} \; 2>/dev/null || true

# RHEL 9 STIG V-257858: Configure file integrity monitoring (AIDE)
cat > /etc/aide.conf << 'EOF'
# RHEL 9 STIG V-257858: AIDE configuration
database=file:/var/lib/aide/aide.db.gz
database_out=file:/var/lib/aide/aide.db.new.gz
gzip_dbout=yes
verbose=5
report_url=file:/var/log/aide/aide.log
report_url=stdout

# Rules
FIPSR = p+i+n+u+g+s+m+c+acl+selinux+xattrs+sha256
NORMAL = p+i+n+u+g+s+m+c+acl+selinux+xattrs+md5
DIR = p+i+n+u+g+acl+selinux+xattrs
PERMS = p+i+n+u+g+acl+selinux
LOG = >
LSPP = FIPSR+sha512

# Directories to monitor
/boot   FIPSR
/bin    FIPSR
/sbin   FIPSR
/lib    FIPSR
/lib64  FIPSR
/opt    FIPSR
/usr    FIPSR
/root   FIPSR
!/usr/src
!/usr/tmp

/etc    PERMS
!/etc/mtab
!/etc/.*~

/var/log   LOG
!/var/log/aide
!/var/log/aide/aide.log

# Critical files
/etc/passwd FIPSR
/etc/group FIPSR
/etc/shadow FIPSR
/etc/gshadow FIPSR
/etc/sudoers FIPSR
EOF

# Initialize AIDE database
mkdir -p /var/lib/aide /var/log/aide
aide --init 2>/dev/null || true
if [ -f /var/lib/aide/aide.db.new.gz ]; then
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
fi

# RHEL 9 STIG V-257859: Set proper ownership for system files
chown root:root /etc/passwd /etc/group /etc/shadow /etc/gshadow
chown root:root /etc/ssh/sshd_config
chown root:root /etc/issue /etc/issue.net
chown -R root:root /etc/audit
chown -R root:root /var/log/audit

echo "=== File Permissions Hardening Complete ==="
