#!/bin/bash
# Package and service hardening according to STIG requirements

set -e

echo "=== Starting Package Hardening ==="

# STIG V-270695: Configure APT to prevent installation of unsigned packages
cat > /etc/apt/apt.conf.d/99-security << 'EOF'
APT::Get::AllowUnauthenticated "false";
EOF

# STIG V-270773: Configure APT to remove unused components after updates
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
EOF

# STIG V-270718: Disable USB storage
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/DISASTIG.conf << 'EOF'
# Disable USB storage
install usb-storage /bin/true
blacklist usb-storage
EOF

# STIG V-270755: Disable wireless adapters (if any)
# This will be handled by listing and disabling any wireless interfaces found

# Remove unnecessary packages that could pose security risks
apt-get remove -y --purge \
    at \
    rsh-client \
    rsh-redone-client \
    talk \
    telnet \
    tftp \
    xinetd \
    ypbind \
    nis 2>/dev/null || true

# STIG V-270712: Disable Ctrl-Alt-Delete
# Configure for container environment
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl disable ctrl-alt-del.target
    systemctl mask ctrl-alt-del.target
else
    # Disable via target file
    rm -f /etc/systemd/system/ctrl-alt-del.target 2>/dev/null || true
    ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target
fi

# STIG V-270746: Disable kdump if not needed
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl disable kdump.service 2>/dev/null || true
else
    # Remove service link if exists
    rm -f /etc/systemd/system/multi-user.target.wants/kdump.service 2>/dev/null || true
fi

# Clean package cache
apt-get autoremove -y
apt-get autoclean

echo "=== Package Hardening Complete ==="
