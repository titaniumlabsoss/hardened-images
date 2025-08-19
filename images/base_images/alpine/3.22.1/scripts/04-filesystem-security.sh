#!/bin/sh
# Alpine Linux Filesystem Security Configuration
# Implements STIG-equivalent filesystem controls

set -e

echo "=== Starting Filesystem Security Configuration ==="

# Configure filesystem security parameters (STIG V-257826-V-257842)
cat > /etc/sysctl.d/99-stig-filesystem.conf << 'EOF'
# Filesystem security settings

# Disable core dumps for SUID programs
fs.suid_dumpable = 0

# Protect against hardlink attacks
fs.protected_hardlinks = 1

# Protect against symlink attacks
fs.protected_symlinks = 1

# Protect FIFOs and regular files in sticky directories
fs.protected_fifos = 2
fs.protected_regular = 2

# Set maximum number of memory map areas
vm.max_map_count = 262144

# Disable kernel address exposure
kernel.kptr_restrict = 2

# Restrict dmesg access
kernel.dmesg_restrict = 1

# Disable performance events for unprivileged users
kernel.perf_event_paranoid = 3

# Restrict unprivileged BPF
kernel.unprivileged_bpf_disabled = 1

# Restrict userns creation
kernel.unprivileged_userns_clone = 0
EOF

# Configure filesystem mount options notes (STIG V-257827)
cat > /etc/fstab.container-notes << 'EOF'
# STIG Filesystem Mount Security (Host Configuration Required):
#
# Example secure mount options for host system:
# /boot                   ext4    defaults,nosuid,nodev,noexec        1 2
# /tmp                    tmpfs   defaults,nosuid,nodev,noexec        0 0
# /var/tmp                ext4    defaults,nosuid,nodev,noexec        1 2
# /home                   ext4    defaults,nosuid,nodev               1 2
# /var                    ext4    defaults,nosuid                     1 2
# /var/log                ext4    defaults,nosuid,nodev,noexec        1 2
# /var/log/audit          ext4    defaults,nosuid,nodev,noexec        1 2
#
# Container runtime should use --read-only and --tmpfs options appropriately
EOF

# Configure directory permissions (STIG V-257828)
SECURE_DIRECTORIES="
/etc:755:root:root
/bin:755:root:root
/sbin:755:root:root
/usr/bin:755:root:root
/usr/sbin:755:root:root
/usr/local/bin:755:root:root
/usr/local/sbin:755:root:root
/var:755:root:root
/var/log:755:root:root
/var/tmp:1777:root:root
/tmp:1777:root:root
"

echo "$SECURE_DIRECTORIES" | while IFS=: read -r dir perms owner group; do
    if [ -d "$dir" ]; then
        chmod "$perms" "$dir"
        chown "$owner:$group" "$dir"
    fi
done

# Configure log file permissions (STIG V-257833)
LOG_DIRECTORIES="/var/log"

for log_dir in $LOG_DIRECTORIES; do
    if [ -d "$log_dir" ]; then
        find "$log_dir" -type f -exec chmod 640 {} \; 2>/dev/null || true
        find "$log_dir" -type d -exec chmod 750 {} \; 2>/dev/null || true
        chown -R root:root "$log_dir" 2>/dev/null || true
    fi
done

# Configure temporary file cleanup (STIG V-257834)
mkdir -p /etc/periodic/daily
cat > /etc/periodic/daily/stig-cleanup << 'EOF'
#!/bin/sh
# Temporary file cleanup
find /tmp -type f -atime +1 -delete 2>/dev/null
find /var/tmp -type f -atime +30 -delete 2>/dev/null
find /tmp -name ".*" -type f -delete 2>/dev/null
find /var/tmp -name ".*" -type f -delete 2>/dev/null
EOF
chmod 755 /etc/periodic/daily/stig-cleanup

# Remove SUID/SGID bits from unnecessary files (STIG V-257836)
UNNECESSARY_SUID_FILES="
/usr/bin/chage
/usr/bin/gpasswd
/usr/bin/wall
/usr/bin/chfn
/usr/bin/chsh
/usr/bin/newgrp
/usr/bin/write
/usr/sbin/unix_chkpwd
/usr/sbin/usernetctl
"

for suid_file in $UNNECESSARY_SUID_FILES; do
    if [ -f "$suid_file" ]; then
        chmod u-s,g-s "$suid_file" 2>/dev/null || true
    fi
done

# Configure system configuration file permissions (STIG V-257838)
SYSTEM_CONFIGS="
/etc/passwd:644:root:root
/etc/group:644:root:root
/etc/shadow:000:root:root
/etc/gshadow:000:root:root
/etc/sudoers:440:root:root
/etc/sudoers.d:750:root:root
/etc/ssh/sshd_config:600:root:root
/etc/ssh:755:root:root
/etc/issue:644:root:root
/etc/issue.net:644:root:root
/etc/motd:644:root:root
"

echo "$SYSTEM_CONFIGS" | while IFS=: read -r config perms owner group; do
    if [ -e "$config" ]; then
        chmod "$perms" "$config"
        chown "$owner:$group" "$config"
    fi
done

# Configure cron permissions (STIG V-257839)
CRON_DIRECTORIES="
/etc/cron.d
/etc/cron.daily
/etc/cron.hourly
/etc/cron.monthly
/etc/cron.weekly
/etc/periodic/daily
/etc/periodic/weekly
/etc/periodic/monthly
"

for cron_dir in $CRON_DIRECTORIES; do
    if [ -d "$cron_dir" ]; then
        chmod 700 "$cron_dir"
        chown root:root "$cron_dir"
    fi
done

if [ -f "/etc/crontab" ]; then
    chmod 600 /etc/crontab
    chown root:root /etc/crontab
fi

echo "=== Filesystem Security Configuration Complete ==="
