#!/bin/bash
# STIG package management and system hardening
# Implements various STIG controls for package security

set -e

echo "=== Starting Package Hardening ==="

# STIG V-238222: System must have automatic security updates configured
cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# STIG V-238223: System must notify of available package updates
cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::DevRelease "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

# STIG V-238224: System must use AppArmor (container-compatible)
# Note: AppArmor profiles will be enforced by the container runtime

# STIG V-238225: AppArmor must be configured
# Note: Container runtime will handle AppArmor profile enforcement

# STIG V-238226: System must disable kernel core dumps
mkdir -p /etc/security/limits.d
cat > /etc/security/limits.d/stig-core-dumps.conf << EOF
* hard core 0
* soft core 0
EOF

# STIG V-238227: System must disable kernel module loading
mkdir -p /etc/sysctl.d
echo "kernel.modules_disabled = 1" >> /etc/sysctl.d/99-stig.conf

# STIG V-238228: System must disable USB mass storage
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/stig-usb.conf << EOF
install usb-storage /bin/true
blacklist usb-storage
EOF

# STIG V-238229: System must disable firewire
cat > /etc/modprobe.d/stig-firewire.conf << EOF
install firewire-core /bin/true
install firewire-ohci /bin/true
install firewire-sbp2 /bin/true
blacklist firewire-core
blacklist firewire-ohci
blacklist firewire-sbp2
EOF

# STIG V-238230: System must enable AppArmor profiles (container-compatible)
# Note: AppArmor enforcement handled by container runtime and host system

# STIG V-238231: System must not have unnecessary packages installed
# Remove common unnecessary packages
UNNECESSARY_PACKAGES=(
    "at"
    "avahi-daemon"
    "cups"
    "dhcp"
    "dovecot"
    "ftp"
    "httpd"
    "inetd"
    "ldap"
    "nfs"
    "nis"
    "ntalk"
    "postfix"
    "rlogin"
    "rsh"
    "sendmail"
    "snmp"
    "squid"
    "talk"
    "telnet"
    "tftp"
    "xinetd"
    "ypbind"
)

for package in "${UNNECESSARY_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii.*${package}"; then
        apt-get remove -y "${package}" || true
    fi
done

echo "=== Package Hardening Complete ==="
