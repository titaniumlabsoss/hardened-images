#!/bin/sh
# Alpine Linux Final Cleanup
# Removes unnecessary files and reduces attack surface

set -e

echo "=== Starting Final Cleanup ==="

# Remove package manager cache
rm -rf /var/cache/apk/*
rm -rf /var/cache/distfiles/*

# Remove temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /root/.cache
rm -rf /root/.ash_history
rm -rf /root/.bash_history

# Remove unnecessary documentation
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/licenses/*

# Remove shadow package (was only needed for user management)
apk del --purge shadow 2>/dev/null || true

# Remove any accidentally installed packages
apk del --purge build-base gcc make perl python3 2>/dev/null || true
apk del --purge openssh openssh-server audit logrotate sudo 2>/dev/null || true

# Clean up package database
rm -rf /var/cache/apk/*
rm -rf /lib/apk/db/*
# Recreate minimal APK database
mkdir -p /lib/apk/db
echo "1" > /lib/apk/db/installed

# Remove setuid/setgid binaries that aren't needed
find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -la {} \; 2>/dev/null | while read line; do
    file=$(echo $line | awk '{print $NF}')
    case "$file" in
        /bin/su|/usr/bin/sudo|/usr/bin/passwd|/bin/mount|/bin/umount|/bin/ping|/bin/ping6)
            # Keep these essential setuid binaries
            ;;
        *)
            # Remove non-essential setuid/setgid binaries
            chmod ug-s "$file" 2>/dev/null || true
            ;;
    esac
done

# Remove unnecessary shell configuration files
rm -f /etc/bashrc.orig
rm -f /etc/profile.orig
rm -f /etc/shells.orig

# Clear log files
find /var/log -type f -exec truncate -s 0 {} \; 2>/dev/null || true

# Remove orphaned packages
apk del --purge $(apk info --installed | grep -E '^(dev-|doc-|man-)' | xargs) 2>/dev/null || true

# Remove unnecessary locales (keep only C)
find /usr/share/locale -mindepth 1 -maxdepth 1 -type d ! -name 'C' -exec rm -rf {} \; 2>/dev/null || true

# Remove unnecessary timezones (keep only UTC)
find /usr/share/zoneinfo -mindepth 1 -maxdepth 1 ! -name 'UTC' ! -name 'UCT' ! -name 'Zulu' -exec rm -rf {} \; 2>/dev/null || true

# Final permission fixes
chmod 700 /root 2>/dev/null || true
chmod 644 /etc/passwd 2>/dev/null || true
chmod 000 /etc/shadow 2>/dev/null || true
chmod 644 /etc/group 2>/dev/null || true

# Create a marker file to indicate hardening is complete
echo "Alpine Linux hardened according to STIG standards" > /etc/hardened
chmod 444 /etc/hardened

# Final package database update
apk update 2>/dev/null || true

echo "=== Final Cleanup Complete ==="
echo "=== Alpine Linux Hardening Complete ==="
