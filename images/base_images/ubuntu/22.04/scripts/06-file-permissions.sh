#!/bin/bash
# STIG file permissions and ownership hardening
# Implements file system security controls

set -e

echo "=== Starting File Permissions Hardening ==="

# STIG V-238380: System must have appropriate file permissions on critical files
chmod 644 /etc/passwd
chmod 644 /etc/group
chmod 640 /etc/shadow
chmod 640 /etc/gshadow
chown root:root /etc/passwd
chown root:root /etc/group
chown root:shadow /etc/shadow
chown root:shadow /etc/gshadow

# STIG V-238381: System must set permissions on SSH public host key files
for key in /etc/ssh/ssh_host_*key.pub; do
    if [ -f "$key" ]; then
        chmod 644 "$key"
        chown root:root "$key"
    fi
done

# STIG V-238382: System must set permissions on SSH private host key files
for key in /etc/ssh/ssh_host_*key; do
    if [ -f "$key" ] && [[ "$key" != *.pub ]]; then
        chmod 600 "$key"
        chown root:root "$key"
    fi
done

# STIG V-238383: System must set permissions on SSH daemon configuration
chmod 644 /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config

# STIG V-238384: System must prevent unauthorized changes to PAM configuration
find /etc/pam.d -type f -exec chmod 644 {} \; 2>/dev/null || true
find /etc/pam.d -type f -exec chown root:root {} \; 2>/dev/null || true

# STIG V-238385: System must set appropriate permissions on audit configuration files
if [ -f /etc/audit/auditd.conf ]; then
    chmod 640 /etc/audit/auditd.conf
    chown root:root /etc/audit/auditd.conf
fi

if [ -d /etc/audit/rules.d ]; then
    find /etc/audit/rules.d -type f -exec chmod 640 {} \; 2>/dev/null || true
    find /etc/audit/rules.d -type f -exec chown root:root {} \; 2>/dev/null || true
fi

# STIG V-238386: System must protect audit tools from unauthorized access
AUDIT_TOOLS=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/audispd"
    "/sbin/augenrules"
)

for tool in "${AUDIT_TOOLS[@]}"; do
    if [ -f "$tool" ]; then
        chmod 755 "$tool"
        chown root:root "$tool"
    fi
done

# STIG V-238387: System must set appropriate permissions on cron files
if [ -f /etc/crontab ]; then
    chmod 600 /etc/crontab
    chown root:root /etc/crontab
fi

if [ -d /etc/cron.d ]; then
    chmod 700 /etc/cron.d
    chown root:root /etc/cron.d
    find /etc/cron.d -type f -exec chmod 600 {} \;
    find /etc/cron.d -type f -exec chown root:root {} \;
fi

if [ -d /etc/cron.daily ]; then
    chmod 700 /etc/cron.daily
    chown root:root /etc/cron.daily
    find /etc/cron.daily -type f -exec chmod 700 {} \;
    find /etc/cron.daily -type f -exec chown root:root {} \;
fi

if [ -d /etc/cron.weekly ]; then
    chmod 700 /etc/cron.weekly
    chown root:root /etc/cron.weekly
    find /etc/cron.weekly -type f -exec chmod 700 {} \;
    find /etc/cron.weekly -type f -exec chown root:root {} \;
fi

if [ -d /etc/cron.monthly ]; then
    chmod 700 /etc/cron.monthly
    chown root:root /etc/cron.monthly
    find /etc/cron.monthly -type f -exec chmod 700 {} \;
    find /etc/cron.monthly -type f -exec chown root:root {} \;
fi

if [ -d /etc/cron.hourly ]; then
    chmod 700 /etc/cron.hourly
    chown root:root /etc/cron.hourly
    find /etc/cron.hourly -type f -exec chmod 700 {} \;
    find /etc/cron.hourly -type f -exec chown root:root {} \;
fi

# STIG V-238388: System must set appropriate permissions on at files
if [ -f /etc/at.allow ]; then
    chmod 640 /etc/at.allow
    chown root:root /etc/at.allow
fi

if [ -f /etc/at.deny ]; then
    chmod 640 /etc/at.deny
    chown root:root /etc/at.deny
fi

# STIG V-238390: System must set appropriate permissions on log files
find /var/log -type f -exec chmod 640 {} \;
find /var/log -type f -exec chown root:root {} \;

# STIG V-238391: System must set appropriate ownership on home directories
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        if id "$user" >/dev/null 2>&1; then
            primary_group=$(id -gn "$user")
            chown "$user:$primary_group" "$user_home"
            chmod 750 "$user_home"
        fi
    fi
done

# STIG V-238392: System must set appropriate permissions on user files
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        if id "$user" >/dev/null 2>&1; then
            primary_group=$(id -gn "$user")
            find "$user_home" -type f -exec chmod 640 {} \; 2>/dev/null || true
            find "$user_home" -type d -exec chmod 750 {} \; 2>/dev/null || true
            find "$user_home" -exec chown "$user:$primary_group" {} \; 2>/dev/null || true
        fi
    fi
done

# STIG V-238393: System must remove world-writable permissions from system files
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /002 -type f -exec chmod o-w {} \; 2>/dev/null || true

# STIG V-238394: System must remove world-writable permissions from system directories
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /002 -type d -exec chmod o-w {} \; 2>/dev/null || true

# STIG V-238395: System must set sticky bit on world-writable directories
find / -type d \( -perm -0002 -a ! -perm -1000 \) -exec chmod +t {} \; 2>/dev/null || true

# STIG V-238396: System must set appropriate permissions on library files
find /lib /lib64 /usr/lib /usr/lib64 -type f -perm /022 -exec chmod 644 {} \; 2>/dev/null || true

# STIG V-238397: System must set appropriate ownership on library files
find /lib /lib64 /usr/lib /usr/lib64 -type f -exec chown root:root {} \; 2>/dev/null || true

# STIG V-238398: System must remove SUID and SGID from unnecessary files
UNNECESSARY_SUID_SGID=(
    "/usr/bin/at"
    "/usr/bin/gpasswd"
    "/usr/bin/newgrp"
    "/usr/bin/chfn"
    "/usr/bin/chsh"
    "/usr/bin/write"
    "/usr/bin/wall"
)

for file in "${UNNECESSARY_SUID_SGID[@]}"; do
    if [ -f "$file" ]; then
        chmod u-s,g-s "$file" 2>/dev/null || true
    fi
done

# STIG V-238399: System must ensure proper permissions on device files
find /dev -type c -perm /002 -exec chmod o-w {} \; 2>/dev/null || true
find /dev -type b -perm /002 -exec chmod o-w {} \; 2>/dev/null || true

echo "=== File Permissions Hardening Complete ==="
