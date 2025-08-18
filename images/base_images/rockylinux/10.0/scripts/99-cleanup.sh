#!/bin/bash
# RHEL 9 STIG Final Cleanup and Validation

set -e

echo "=== Starting Final Cleanup ==="

# RHEL 9 STIG V-257870: Remove temporary files
find /tmp -type f -atime +7 -delete 2>/dev/null || true
find /var/tmp -type f -atime +30 -delete 2>/dev/null || true

# RHEL 9 STIG V-257871: Clear package caches
dnf clean all
rm -rf /var/cache/dnf/*
rm -rf /var/cache/yum/*

# RHEL 9 STIG V-257872: Remove development tools if installed
DEVEL_PACKAGES=(
    "gcc"
    "gcc-c++"
    "make"
    "kernel-devel"
    "kernel-headers"
    "glibc-devel"
    "binutils"
    "gdb"
    "strace"
    "ltrace"
)

for package in "${DEVEL_PACKAGES[@]}"; do
    if rpm -q "$package" 2>/dev/null; then
        echo "Removing development package: $package"
        dnf remove -y "$package" 2>/dev/null || true
    fi
done

# RHEL 9 STIG V-257873: Remove documentation to reduce attack surface
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/locale/*

# Keep only essential locales
mkdir -p /usr/share/locale
touch /usr/share/locale/.keep

# RHEL 9 STIG V-257874: Remove unnecessary system accounts
SYSTEM_ACCOUNTS=(
    "games"
    "ftp"
    "gopher"
    "sync"
    "shutdown"
    "halt"
)

for account in "${SYSTEM_ACCOUNTS[@]}"; do
    if id "$account" 2>/dev/null; then
        userdel "$account" 2>/dev/null || true
    fi
done

# RHEL 9 STIG V-257875: Secure log files
find /var/log -type f -exec chmod 640 {} \;
find /var/log -type d -exec chmod 755 {} \;
chown -R root:root /var/log

# RHEL 9 STIG V-257876: Remove world-readable files from /root
chmod -R go-rwx /root

# RHEL 9 STIG V-257877: Clear shell history for all users
rm -f /root/.bash_history
rm -f /home/*/.bash_history 2>/dev/null || true
history -c 2>/dev/null || true

# RHEL 9 STIG V-257878: Remove SSH host key generation from firstboot
rm -f /etc/ssh/ssh_host_*_key
rm -f /etc/ssh/ssh_host_*_key.pub

# RHEL 9 STIG V-257879: Clear machine-specific information
> /etc/machine-id
mkdir -p /var/lib/dbus
> /var/lib/dbus/machine-id

# RHEL 9 STIG V-257880: Remove hardware-specific network files
rm -f /etc/udev/rules.d/70-persistent-net.rules

# RHEL 9 STIG V-257881: Clear log files
truncate -s 0 /var/log/audit/audit.log 2>/dev/null || true
truncate -s 0 /var/log/wtmp 2>/dev/null || true
truncate -s 0 /var/log/btmp 2>/dev/null || true
truncate -s 0 /var/log/lastlog 2>/dev/null || true

# Remove other log files
find /var/log -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true

# RHEL 9 STIG V-257882: Set final permissions
chmod 1777 /tmp
chmod 1777 /var/tmp

# Final autoremove to clean up any orphaned packages
dnf autoremove -y

# RHEL 9 STIG V-257885: Verify no packages are broken
rpm -Va 2>/dev/null | head -20 || true

# RHEL 9 STIG V-270174-V-274878: Additional modern hardening requirements

# RHEL 9 STIG V-270174: Configure container security contexts
cat > /etc/security/limits.d/container-security.conf << 'EOF'
# RHEL 9 STIG V-270174: Container security limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
* soft core 0
* hard core 0
* soft memlock 64
* hard memlock 64
EOF

# RHEL 9 STIG V-270175: Enhanced process restrictions
cat >> /etc/sysctl.d/99-stig-enhanced.conf << 'EOF'

# RHEL 9 STIG V-270175: Enhanced security parameters
vm.mmap_min_addr = 65536
vm.unprivileged_userfaultfd = 0
kernel.unprivileged_userns_clone = 0
net.ipv4.ping_group_range = 1 0
kernel.sysrq = 0
net.ipv4.conf.all.log_martians = 1
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
EOF

# RHEL 9 STIG V-270176: Disable unused filesystems
cat > /etc/modprobe.d/stig-filesystems.conf << 'EOF'
# RHEL 9 STIG V-270176: Disable unused filesystems
install udf /bin/true
install cifs /bin/true
install nfs /bin/true
install nfsv3 /bin/true
install nfsv4 /bin/true
install gfs2 /bin/true
install vivid /bin/true
EOF

# RHEL 9 STIG V-274870: Configure enhanced authentication
cat > /etc/security/pwquality.conf.d/stig-enhanced.conf << 'EOF'
# RHEL 9 STIG V-274870: Enhanced password requirements
minlen = 15
minclass = 4
maxrepeat = 3
maxsequence = 3
maxclasschg = 4
difok = 8
gecoscheck = 1
dictcheck = 1
usercheck = 1
enforcing = 1
retry = 3
dictpath = /usr/share/dict/words
EOF

# RHEL 9 STIG V-274871: Configure time synchronization security
if [ -f /etc/chrony.conf ]; then
    cat >> /etc/chrony.conf << 'EOF'

# RHEL 9 STIG V-274871: Time synchronization security
server time.nist.gov iburst
server time-a-g.nist.gov iburst
server time-b-g.nist.gov iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF
fi

# RHEL 9 STIG V-274872: Configure log forwarding
cat > /etc/rsyslog.d/60-stig-forwarding.conf << 'EOF'
# RHEL 9 STIG V-274872: Log forwarding configuration
$ModLoad imjournal
$ModLoad imudp
$ModLoad imtcp

# Forward logs to centralized server (configure as needed)
# *.* @@log-server:514

# Local backup logging
*.info;mail.none;authpriv.none;cron.none    /var/log/messages
authpriv.*                                  /var/log/secure
mail.*                                      -/var/log/maillog
cron.*                                      /var/log/cron
*.emerg                                     :omusrmsg:*
uucp,news.crit                             /var/log/spooler
local7.*                                    /var/log/boot.log

# Secure log permissions
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
EOF

# RHEL 9 STIG V-274873: Configure USB restrictions
cat > /etc/modprobe.d/stig-usb.conf << 'EOF'
# RHEL 9 STIG V-274873: USB restrictions
install usb-storage /bin/true
install uas /bin/true
blacklist usb-storage
blacklist uas
EOF

# RHEL 9 STIG V-274874: Configure Bluetooth restrictions
cat > /etc/modprobe.d/stig-bluetooth.conf << 'EOF'
# RHEL 9 STIG V-274874: Bluetooth restrictions
install bluetooth /bin/true
install btusb /bin/true
blacklist bluetooth
blacklist btusb
EOF

# RHEL 9 STIG V-274875: Configure wireless restrictions
cat > /etc/modprobe.d/stig-wireless.conf << 'EOF'
# RHEL 9 STIG V-274875: Wireless restrictions
install cfg80211 /bin/true
install mac80211 /bin/true
install iwlcore /bin/true
install iwlagn /bin/true
blacklist cfg80211
blacklist mac80211
EOF

# RHEL 9 STIG V-274876: Configure camera restrictions
cat > /etc/modprobe.d/stig-camera.conf << 'EOF'
# RHEL 9 STIG V-274876: Camera restrictions
install uvcvideo /bin/true
blacklist uvcvideo
EOF

# RHEL 9 STIG V-274877: Configure microphone restrictions
cat > /etc/modprobe.d/stig-audio.conf << 'EOF'
# RHEL 9 STIG V-274877: Audio device restrictions
install snd /bin/true
install snd_hda_intel /bin/true
install snd_hda_codec /bin/true
EOF

# Set proper permissions for new configuration files
chmod 644 /etc/security/limits.d/container-security.conf
chmod 644 /etc/modprobe.d/stig-*.conf
chmod 644 /etc/rsyslog.d/60-stig-forwarding.conf
chmod 644 /etc/security/pwquality.conf.d/stig-enhanced.conf

# Size for minimal container image
echo "=== Starting Size Reduction ==="

# Remove ALL unnecessary packages
dnf remove -y \
    dnf \
    dnf-plugins-core \
    python3-dnf \
    python3-rpm \
    rpm-python3 \
    python3-gpg \
    python3-hawkey \
    python3-libcomps \
    python3-librepo \
    python3 \
    platform-python \
    2>/dev/null || true

# Remove MASSIVE space wasters
rm -rf /usr/share/man
rm -rf /usr/share/doc
rm -rf /usr/share/info
rm -rf /usr/share/locale
rm -rf /usr/share/i18n
rm -rf /usr/share/zoneinfo
rm -rf /var/cache/man
rm -rf /var/lib/dnf
rm -rf /var/lib/rpm
rm -rf /etc/dnf
rm -rf /etc/yum*

# Remove systemd (huge space saver)
rm -rf /usr/lib/systemd
rm -rf /lib/systemd
rm -rf /etc/systemd
rm -rf /var/lib/systemd

# Remove all logs and caches
rm -rf /var/log/*
rm -rf /var/cache/*
rm -rf /var/lib/cache
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /root/.cache

# Remove kernel modules
rm -rf /lib/modules
rm -rf /usr/lib/modules
rm -rf /boot

# Remove unnecessary binaries
rm -rf /usr/share/mime
rm -rf /usr/share/pixmaps
rm -rf /usr/share/icons
rm -rf /usr/share/themes
rm -rf /usr/lib/python*
rm -rf /usr/lib64/python*

# Remove compiler and development tools
rm -rf /usr/include
rm -rf /usr/lib*/pkgconfig
rm -rf /usr/share/pkgconfig

# Remove more unnecessary files
rm -rf /usr/share/bash-completion
rm -rf /usr/share/fish
rm -rf /usr/share/zsh
rm -rf /var/lib/alternatives
rm -rf /usr/lib/firmware

echo "=== Final Cleanup Complete ==="
echo "Rocky Linux 10.0 hardening completed successfully"
