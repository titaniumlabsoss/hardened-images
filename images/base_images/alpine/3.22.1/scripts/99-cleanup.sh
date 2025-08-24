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

# Remove all text editors and file modification tools
echo "=== Removing Text Editors and File Modification Tools ==="
rm -f /usr/bin/vi /usr/bin/vim /usr/bin/nano /usr/bin/emacs /usr/bin/pico
rm -f /usr/bin/ed /usr/bin/ex /usr/bin/sed /usr/bin/awk /usr/bin/gawk
rm -f /bin/vi /bin/nano /bin/ed /bin/sed /bin/awk
rm -rf /usr/share/vim* /usr/share/nano* /usr/share/emacs*
rm -rf /etc/vimrc /etc/nanorc

# Remove network communication tools
echo "=== Removing Network Communication Tools ==="
rm -f /usr/bin/wget /usr/bin/curl /usr/bin/lynx /usr/bin/links
rm -f /usr/bin/ftp /usr/bin/sftp /usr/bin/scp /usr/bin/rsync
rm -f /usr/bin/nc /usr/bin/netcat /usr/bin/nmap /usr/bin/telnet
rm -f /usr/bin/ssh /usr/bin/ssh-keygen /usr/bin/ssh-copy-id
rm -f /bin/wget /bin/curl /bin/nc /bin/netcat

# Remove file manipulation utilities
echo "=== Removing File Manipulation Utilities ==="
rm -f /usr/bin/patch /usr/bin/diff /usr/bin/cmp
rm -f /usr/bin/tar /usr/bin/gzip /usr/bin/gunzip /usr/bin/zip /usr/bin/unzip
rm -f /usr/bin/bzip2 /usr/bin/bunzip2 /usr/bin/xz /usr/bin/unxz
rm -f /bin/tar /bin/gzip /bin/gunzip

# Remove process and system inspection tools
echo "=== Removing System Inspection Tools ==="
rm -f /usr/bin/ps /usr/bin/top /usr/bin/htop /usr/bin/lsof /usr/bin/netstat
rm -f /usr/bin/ss /usr/bin/strace /usr/bin/ltrace /usr/bin/gdb
rm -f /usr/bin/objdump /usr/bin/readelf /usr/bin/hexdump /usr/bin/strings
rm -f /bin/ps /bin/netstat

# Remove package manager after all installations complete
# This prevents package installation attacks in the final container
echo "=== Removing Package Manager for Security ==="

# Remove apk binary and related tools
rm -f /sbin/apk
rm -rf /lib/apk
rm -rf /var/cache/apk
rm -rf /usr/share/apk
rm -rf /etc/apk

echo "=== Final Cleanup Complete ==="
echo "=== Alpine Linux Hardening Complete ==="
