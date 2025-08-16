#!/bin/bash
# File permissions and ownership hardening

set -e

echo "=== Starting File Permissions Hardening ==="

# STIG V-270696, V-270697: Library file permissions and ownership
find /lib /lib64 /usr/lib -perm /022 -type f -exec chmod 755 '{}' \; 2>/dev/null || true
find /lib /usr/lib /lib64 ! -user root -type f -exec chown root '{}' \; 2>/dev/null || true

# STIG V-270698, V-270699, V-270700: Library directory permissions and ownership
find /lib /usr/lib /lib64 ! -user root -type d -exec chown root '{}' \; 2>/dev/null || true
find /lib /usr/lib /lib64 ! -group root -type f -exec chgrp root '{}' \; 2>/dev/null || true
find /lib /usr/lib /lib64 ! -group root -type d -exec chgrp root '{}' \; 2>/dev/null || true

# STIG V-270701, V-270702, V-270703: System command permissions and ownership
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /022 -type f -exec chmod 755 '{}' \; 2>/dev/null || true
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -type f -exec chown root '{}' \; 2>/dev/null || true

# Set proper group ownership for system commands
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -type f -perm -u=x -exec chgrp root '{}' \; 2>/dev/null || true

# STIG V-270824, V-270825, V-270826: System command directories
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /022 -type d -exec chmod 755 '{}' \; 2>/dev/null || true
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -type d -exec chown root '{}' \; 2>/dev/null || true
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -group root -type d -exec chgrp root '{}' \; 2>/dev/null || true

# STIG V-270750: Set sticky bit on world-writable directories
find / -type d -perm -002 ! -perm -1000 -exec chmod +t '{}' \; 2>/dev/null || true

# STIG V-270756: Set permissions on log files
find /var/log -perm /137 ! -name '*[bw]tmp' ! -name '*lastlog' -type f -exec chmod 640 '{}' \; 2>/dev/null || true

# STIG V-270757: Configure systemd journal permissions
cat > /usr/lib/tmpfiles.d/systemd.conf << 'EOF'
# STIG-compliant systemd journal permissions
z /run/log/journal 2640 root systemd-journal - -
Z /run/log/journal/%m ~2640 root systemd-journal - -
z /var/log/journal 2640 root systemd-journal - -
z /var/log/journal/%m 2640 root systemd-journal - -
z /var/log/journal/%m/system.journal 0640 root systemd-journal - -
EOF

# STIG V-270758, V-270759, V-270760: Configure journalctl permissions
if [ -f /usr/bin/journalctl ]; then
    chmod 740 /usr/bin/journalctl
    chown root:root /usr/bin/journalctl
else
    echo "Note: journalctl not found - journal access will be managed by systemd"
fi

# STIG V-270765, V-270766, V-270767: /var/log directory permissions
if getent group syslog >/dev/null; then
    chgrp syslog /var/log
else
    chgrp adm /var/log
fi
chown root /var/log
chmod 755 /var/log

# STIG V-270768, V-270769, V-270770: /var/log/syslog file permissions
if [ -f /var/log/syslog ]; then
    chgrp adm /var/log/syslog
    if getent passwd syslog >/dev/null; then
        chown syslog /var/log/syslog
    else
        chown root /var/log/syslog
    fi
    chmod 640 /var/log/syslog
fi

# STIG V-270775, V-270776, V-270777: Audit configuration file permissions
chmod -R 0640 /etc/audit/audit*.{rules,conf} /etc/audit/rules.d/* 2>/dev/null || true
chown root /etc/audit/audit*.{rules,conf} /etc/audit/rules.d/* 2>/dev/null || true
chown :root /etc/audit/audit*.{rules,conf} /etc/audit/rules.d/* 2>/dev/null || true

# STIG V-270821, V-270822, V-270823: Audit tool permissions
chmod 0755 /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/audispd* /sbin/augenrules 2>/dev/null || true
chown root /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/audispd* /sbin/augenrules 2>/dev/null || true
chown :root /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/audispd* /sbin/augenrules 2>/dev/null || true

# STIG V-270827, V-270828, V-270829: Audit log file permissions
mkdir -p /var/log/audit
chmod 0600 /var/log/audit/* 2>/dev/null || true
chown root /var/log/audit/* 2>/dev/null || true
chgrp root /var/log/audit/* 2>/dev/null || true

# STIG V-270830: Audit log directory permissions
chmod 750 /var/log/audit

# Set proper permissions on sensitive files
# Note: SSH host keys are removed during cleanup and should be generated at runtime
chmod 600 /etc/shadow* /etc/gshadow* 2>/dev/null || true
chmod 644 /etc/passwd /etc/group 2>/dev/null || true

# Secure /tmp and /var/tmp
chmod 1777 /tmp /var/tmp

# Set proper permissions on critical system files
chmod 644 /etc/hosts /etc/hostname /etc/resolv.conf 2>/dev/null || true
chmod 600 /etc/sudoers 2>/dev/null || true
find /etc/sudoers.d -type f -exec chmod 600 '{}' \; 2>/dev/null || true

echo "=== File Permissions Hardening Complete ==="
