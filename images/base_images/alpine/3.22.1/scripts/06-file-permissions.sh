#!/bin/sh
# Alpine Linux File Permissions and System Hardening
# Implements STIG-equivalent file permission controls

set -e

echo "=== Starting File Permissions Hardening ==="

# Set file permissions for system files (STIG V-257848)
[ -f /etc/passwd ] && chmod 644 /etc/passwd
[ -f /etc/shadow ] && chmod 000 /etc/shadow
[ -f /etc/group ] && chmod 644 /etc/group
[ -f /etc/gshadow ] && chmod 000 /etc/gshadow
[ -f /etc/ssh/sshd_config ] && chmod 600 /etc/ssh/sshd_config
[ -f /etc/ssh/ssh_config ] && chmod 644 /etc/ssh/ssh_config

# Secure important directories (STIG V-257849)
chmod 755 /etc 2>/dev/null || true
chmod 755 /usr 2>/dev/null || true
chmod 755 /usr/bin 2>/dev/null || true
chmod 755 /usr/sbin 2>/dev/null || true
chmod 755 /bin 2>/dev/null || true
chmod 755 /sbin 2>/dev/null || true

# Remove world-writable files and directories (STIG V-257850)
find / -xdev -type f -perm -002 -exec chmod o-w {} \; 2>/dev/null || true
find / -xdev -type d -perm -002 ! -path "/tmp" ! -path "/var/tmp" -exec chmod o-w {} \; 2>/dev/null || true

# Find and secure files with no owner (STIG V-257851)
find / -xdev -nouser -exec chown root {} \; 2>/dev/null || true
find / -xdev -nogroup -exec chgrp root {} \; 2>/dev/null || true

# Set sticky bit on world-writable directories (STIG V-257852)
find / -xdev -type d -perm -002 -a ! -perm -1000 -exec chmod +t {} \; 2>/dev/null || true

# Remove SUID/SGID from unnecessary files (STIG V-257853)
SUID_SGID_FILES="
/usr/bin/at
/usr/bin/crontab
/usr/bin/wall
/usr/bin/write
/usr/bin/newgrp
/usr/sbin/unix_chkpwd
/usr/sbin/usernetctl
"

for file in $SUID_SGID_FILES; do
    if [ -f "$file" ]; then
        chmod ug-s "$file" 2>/dev/null || true
    fi
done

# Set umask for all users (STIG V-257854)
cat >> /etc/profile << 'EOF'
# Set restrictive umask
umask 077
EOF

# Fix existing umask setting in shell rc files
for rcfile in /etc/bashrc /etc/zshrc /etc/ash_profile; do
    if [ -f "$rcfile" ]; then
        sed -i 's/umask [0-9]*/umask 077/g' "$rcfile" 2>/dev/null || true
        grep -q "umask 077" "$rcfile" || echo "umask 077" >> "$rcfile"
    fi
done

# Configure logrotate for system logs (STIG V-257855)
if command -v logrotate >/dev/null 2>&1; then
    mkdir -p /etc/logrotate.d
    cat > /etc/logrotate.d/stig << 'EOF'
# STIG log rotation
/var/log/*.log {
    missingok
    rotate 5
    weekly
    maxage 30
    compress
    notifempty
    create 0640 root root
    sharedscripts
}

/var/log/messages {
    missingok
    rotate 5
    weekly
    maxage 30
    compress
    notifempty
    create 0640 root root
}

/var/log/secure {
    missingok
    rotate 5
    weekly
    maxage 30
    compress
    notifempty
    create 0640 root root
}
EOF
fi

# Secure cron directories (STIG V-257856)
[ -f /etc/crontab ] && chmod 600 /etc/crontab
[ -d /etc/cron.d ] && chmod 700 /etc/cron.d
[ -d /etc/cron.daily ] && chmod 700 /etc/cron.daily
[ -d /etc/cron.hourly ] && chmod 700 /etc/cron.hourly
[ -d /etc/cron.monthly ] && chmod 700 /etc/cron.monthly
[ -d /etc/cron.weekly ] && chmod 700 /etc/cron.weekly

# Alpine uses periodic instead of cron
[ -d /etc/periodic ] && chmod 700 /etc/periodic
[ -d /etc/periodic/daily ] && chmod 700 /etc/periodic/daily
[ -d /etc/periodic/weekly ] && chmod 700 /etc/periodic/weekly
[ -d /etc/periodic/monthly ] && chmod 700 /etc/periodic/monthly

# Remove cron.deny and at.deny, create allow files
rm -f /etc/cron.deny /etc/at.deny
touch /etc/cron.allow /etc/at.allow 2>/dev/null || true
[ -f /etc/cron.allow ] && chmod 600 /etc/cron.allow && chown root:root /etc/cron.allow
[ -f /etc/at.allow ] && chmod 600 /etc/at.allow && chown root:root /etc/at.allow

# Secure kernel modules (STIG V-257857)
[ -d /lib/modules ] && find /lib/modules -type d -name "kernel" -exec chmod 700 {} \; 2>/dev/null || true
[ -d /lib/modules ] && find /lib/modules -name "*.ko" -type f -exec chmod 600 {} \; 2>/dev/null || true

# Set proper ownership for system files (STIG V-257859)
chown root:root /etc/passwd /etc/group /etc/shadow 2>/dev/null || true
[ -f /etc/gshadow ] && chown root:root /etc/gshadow
[ -f /etc/ssh/sshd_config ] && chown root:root /etc/ssh/sshd_config
chown root:root /etc/issue /etc/issue.net 2>/dev/null || true

# Create directory for security audit logs
mkdir -p /var/log/audit
chmod 750 /var/log/audit
chown root:root /var/log/audit

# Set permissions on home directories
for dir in /home/*; do
    if [ -d "$dir" ]; then
        chmod 750 "$dir" 2>/dev/null || true
    fi
done

# Ensure root home directory is secure
[ -d /root ] && chmod 700 /root

echo "=== File Permissions Hardening Complete ==="
