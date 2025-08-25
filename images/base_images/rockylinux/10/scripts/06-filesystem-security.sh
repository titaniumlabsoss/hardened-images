#!/bin/bash
# RHEL 9 STIG Filesystem Security Configuration

set -e

echo "=== Starting Filesystem Security Configuration ==="

# RHEL 9 STIG V-257826: Configure filesystem security parameters
cat >> /etc/sysctl.d/99-stig-filesystem.conf << 'EOF'
# RHEL 9 STIG V-257826-V-257842: Filesystem security settings

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

# Disable access to /proc/kcore
kernel.kcore_uses_strict_verification = 1
EOF

# RHEL 9 STIG V-257827: Configure filesystem mount options (container context)
cat > /etc/fstab.container-notes << 'EOF'
# RHEL 9 STIG Filesystem Mount Security (Host Configuration Required):
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

# RHEL 9 STIG V-257828: Configure directory permissions
SECURE_DIRECTORIES=(
    "/etc 755 root:root"
    "/bin 755 root:root"
    "/sbin 755 root:root"
    "/usr/bin 755 root:root"
    "/usr/sbin 755 root:root"
    "/usr/local/bin 755 root:root"
    "/usr/local/sbin 755 root:root"
    "/var 755 root:root"
    "/var/log 755 root:root"
    "/var/tmp 1777 root:root"
    "/tmp 1777 root:root"
)

for dir_spec in "${SECURE_DIRECTORIES[@]}"; do
    read -r dir perms owner <<< "$dir_spec"
    if [ -d "$dir" ]; then
        chmod "$perms" "$dir"
        chown "$owner" "$dir"
    fi
done

# RHEL 9 STIG V-257833: Configure log file permissions
LOG_DIRECTORIES=(
    "/var/log"
    "/var/log/audit"
    "/var/log/aide"
)

for log_dir in "${LOG_DIRECTORIES[@]}"; do
    if [ -d "$log_dir" ]; then
        find "$log_dir" -type f -exec chmod 640 {} \; 2>/dev/null || true
        find "$log_dir" -type d -exec chmod 750 {} \; 2>/dev/null || true
        chown -R root:root "$log_dir" 2>/dev/null || true
    fi
done

# RHEL 9 STIG V-257834: Configure temporary file cleanup
cat > /etc/tmpfiles.d/stig-cleanup.conf << 'EOF'
# RHEL 9 STIG V-257834: Temporary file cleanup
d /tmp 1777 root root 1d
d /var/tmp 1777 root root 30d
D /tmp/.X11-unix 1777 root root 1d
D /tmp/.ICE-unix 1777 root root 1d
D /tmp/.font-unix 1777 root root 1d
D /tmp/.Test-unix 1777 root root 1d
D /tmp/.XIM-unix 1777 root root 1d
r! /tmp/.*
r! /var/tmp/.*
EOF

# RHEL 9 STIG V-257836: Remove SUID/SGID bits from unnecessary files
UNNECESSARY_SUID_FILES=(
    "/usr/bin/chage"
    "/usr/bin/gpasswd"
    "/usr/bin/wall"
    "/usr/bin/chfn"
    "/usr/bin/chsh"
    "/usr/bin/newgrp"
    "/usr/bin/write"
    "/usr/sbin/unix_chkpwd"
    "/usr/sbin/usernetctl"
)

for suid_file in "${UNNECESSARY_SUID_FILES[@]}"; do
    if [ -f "$suid_file" ]; then
        chmod u-s,g-s "$suid_file" 2>/dev/null || true
    fi
done

# RHEL 9 STIG V-257837: Configure audit log file permissions
if [ -d "/var/log/audit" ]; then
    chmod 750 /var/log/audit
    chown root:root /var/log/audit
    find /var/log/audit -type f -exec chmod 600 {} \; 2>/dev/null || true
fi

# RHEL 9 STIG V-257838: Configure system configuration file permissions
SYSTEM_CONFIGS=(
    "/etc/passwd 644 root:root"
    "/etc/group 644 root:root"
    "/etc/shadow 000 root:root"
    "/etc/gshadow 000 root:root"
    "/etc/sudoers 440 root:root"
    "/etc/sudoers.d 750 root:root"
    "/etc/ssh/sshd_config 600 root:root"
    "/etc/ssh 755 root:root"
    "/etc/issue 644 root:root"
    "/etc/issue.net 644 root:root"
    "/etc/motd 644 root:root"
)

for config_spec in "${SYSTEM_CONFIGS[@]}"; do
    read -r config perms owner <<< "$config_spec"
    if [ -e "$config" ]; then
        chmod "$perms" "$config"
        chown "$owner" "$config"
    fi
done

# RHEL 9 STIG V-257839: Configure cron permissions
CRON_DIRECTORIES=(
    "/etc/cron.d"
    "/etc/cron.daily"
    "/etc/cron.hourly"
    "/etc/cron.monthly"
    "/etc/cron.weekly"
)

for cron_dir in "${CRON_DIRECTORIES[@]}"; do
    if [ -d "$cron_dir" ]; then
        chmod 700 "$cron_dir"
        chown root:root "$cron_dir"
    fi
done

if [ -f "/etc/crontab" ]; then
    chmod 600 /etc/crontab
    chown root:root /etc/crontab
fi

# RHEL 9 STIG V-257840: Configure at permissions
if [ -d "/var/spool/at" ]; then
    chmod 700 /var/spool/at
    chown root:root /var/spool/at
fi

# RHEL 9 STIG V-257841: Configure mail permissions
if [ -d "/var/spool/mail" ]; then
    chmod 1777 /var/spool/mail
    chown root:mail /var/spool/mail
fi

echo "=== Filesystem Security Configuration Complete ==="
