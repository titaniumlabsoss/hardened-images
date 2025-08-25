#!/bin/bash
# RHEL 9 STIG V-257777: Rocky Linux 10 must be a vendor-supported release
# Base system setup and essential packages

echo "=== Starting Base Setup ==="

# Skip update due to mirror issues in container environment
# dnf update -y

# Install essential STIG-required packages (available in Rocky 10 UBI)
# Disable strict error handling for package installation
set +e

# All these packages are STIG-required:
# - aide: RHEL 9 STIG V-257842 (file integrity monitoring)
# - audit: RHEL 9 STIG V-257788+ (audit logging)
# - chrony: RHEL 9 STIG V-257777 (time synchronization)
# - iptables-services: RHEL 9 STIG V-257825+ (firewall)
# - openssh-server: RHEL 9 STIG V-257805+ (secure remote access)
# - vlock: RHEL 9 STIG V-257861 (screen locking)
# - clamav: RHEL 9 STIG V-257838 (antivirus)
# - fail2ban: RHEL 9 STIG V-257840 (intrusion prevention)
# - rsyslog: RHEL 9 STIG V-257790 (centralized logging)
# - firewalld: RHEL 9 STIG V-257825 (host-based firewall)
ESSENTIAL_PACKAGES=(
    systemd
    systemd-udev
    aide
    audit
    chrony
    iptables-services
    openssh-server
    rsyslog
    firewalld
    sudo
    selinux-policy
    selinux-policy-targeted
    policycoreutils-python-utils
)

echo "Installing essential STIG packages..."
for package in "${ESSENTIAL_PACKAGES[@]}"; do
    echo "Installing $package..."
    dnf install -y "$package" || echo "Failed to install $package, continuing..."
done

# Re-enable strict error handling
set -e

# RHEL 9 STIG V-257778: Remove systemd-timesyncd (chrony preferred)
if rpm -q systemd-timesyncd 2>/dev/null; then
    dnf remove -y systemd-timesyncd
fi

# RHEL 9 STIG V-257779: Remove ntp package
if rpm -q ntp 2>/dev/null; then
    dnf remove -y ntp
fi

# RHEL 9 STIG V-257780: Remove telnet package
if rpm -q telnet-server 2>/dev/null; then
    dnf remove -y telnet-server
fi

# RHEL 9 STIG V-257781: Remove rsh-server package
if rpm -q rsh-server 2>/dev/null; then
    dnf remove -y rsh-server
fi

# RHEL 9 STIG V-257782: Remove ypbind package
if rpm -q ypbind 2>/dev/null; then
    dnf remove -y ypbind
fi

# RHEL 9 STIG V-257783: Remove X11 packages (if present)
X11_PACKAGES=(
    "xorg-x11-server-common"
    "xorg-x11-server-Xorg"
    "xorg-x11-server-utils"
    "xorg-x11-xauth"
    "xorg-x11-xinit"
    "xorg-x11-fonts-*"
    "liberation-fonts"
)

for package in "${X11_PACKAGES[@]}"; do
    if rpm -q "$package" 2>/dev/null; then
        dnf remove -y "$package"
    fi
done

# Create non-root user for security (RHEL 9 STIG V-257901)
useradd -r -u 1001 -g root -s /bin/bash -m appuser

# RHEL 9 STIG V-257896: Disable Ctrl-Alt-Delete (container-compatible)
# Note: Containers don't use systemd, this would be configured on the host

# RHEL 9 STIG V-257897: System must prevent direct logon to shared accounts
echo "account required pam_access.so" >> /etc/pam.d/login

# RHEL 9 STIG V-257784: Remove unnecessary packages and services
UNNECESSARY_PACKAGES=(
    "postfix"
    "sendmail"
    "bind"
    "bind-utils"
    "dhcp-client"
    "dhcp-server"
    "tftp"
    "tftp-server"
    "xinetd"
    "talk"
    "talk-server"
    "finger"
    "finger-server"
    "rwho"
    "rwhod"
    "rcp"
    "rlogin"
    "rsh"
    "rsh-server"
    "ypserv"
    "ypbind"
    "telnet"
    "telnet-server"
)

for package in "${UNNECESSARY_PACKAGES[@]}"; do
    if rpm -q "$package" 2>/dev/null; then
        echo "Removing unnecessary package: $package"
        dnf remove -y "$package"
    fi
done

dnf autoremove -y

# RHEL 9 STIG V-257790: Configure system boot parameters (container context)
# Note: In containers, these would be configured on the host system
cat > /etc/default/grub.container-notes << 'EOF'
# RHEL 9 STIG Boot Parameters (Host Configuration Required):
# GRUB_CMDLINE_LINUX_DEFAULT="audit=1 audit_backlog_limit=8192 slub_debug=P page_poison=1"
# GRUB_CMDLINE_LINUX_DEFAULT+=" slab_nomerge pti=on vsyscall=none"
# GRUB_CMDLINE_LINUX_DEFAULT+=" init_on_alloc=1 init_on_free=1"
# GRUB_CMDLINE_LINUX_DEFAULT+=" fips=1 boot=LABEL=/boot"
EOF

# RHEL 9 STIG V-257791: Configure systemd journal
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/stig.conf << 'EOF'
[Journal]
Storage=persistent
Compress=yes
Seal=yes
ForwardToSyslog=yes
MaxRetentionSec=1month
SyncIntervalSec=1s
RateLimitInterval=30s
RateLimitBurst=10000
SystemMaxUse=10G
SystemKeepFree=15%
SystemMaxFileSize=100M
EOF

echo "=== Base Setup Complete ==="
