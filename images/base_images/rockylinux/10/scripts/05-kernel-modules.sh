#!/bin/bash
# RHEL 9 STIG Kernel Module Security Configuration

set -e

echo "=== Starting Kernel Module Security Configuration ==="

# RHEL 9 STIG V-257804: Disable unused network protocols
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/stig-blacklist.conf << 'EOF'
# RHEL 9 STIG V-257804-V-257808: Disable unused network protocols and modules

# Network protocols
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true

# File systems
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true

# USB storage
install usb-storage /bin/true

# Firewire support
install firewire-core /bin/true
install firewire-ohci /bin/true
install firewire-sbp2 /bin/true

# Bluetooth
install bluetooth /bin/true
install btusb /bin/true

# Wireless
install cfg80211 /bin/true
install mac80211 /bin/true

# Legacy network protocols
install atm /bin/true
install can /bin/true
install rds /bin/true
install af_802154 /bin/true

# Rare filesystems
install adfs /bin/true
install affs /bin/true
install befs /bin/true
install bfs /bin/true
install efs /bin/true
install erofs /bin/true
install exofs /bin/true
install f2fs /bin/true
install gfs2 /bin/true
install hpfs /bin/true
install jfs /bin/true
install nilfs2 /bin/true
install ntfs /bin/true
install ocfs2 /bin/true
install omfs /bin/true
install qnx4 /bin/true
install qnx6 /bin/true

# Exotic network modules
install x25 /bin/true
install rose /bin/true
install decnet /bin/true
install econet /bin/true
install af_802154 /bin/true
install phonet /bin/true
install 6lowpan /bin/true
install ieee802154 /bin/true
install ieee802154_socket /bin/true

# Infiniband
install ib_core /bin/true
install ib_mad /bin/true
install ib_sa /bin/true
install ib_cm /bin/true
install iw_cm /bin/true
install rdma_cm /bin/true
install rdma_ucm /bin/true
EOF

# RHEL 9 STIG V-257805: Blacklist additional modules based on system use
cat > /etc/modprobe.d/stig-network-blacklist.conf << 'EOF'
# RHEL 9 STIG V-257805: Additional network module restrictions

# Disable IPv6
alias net-pf-10 off
alias ipv6 off
blacklist ipv6

# Disable rare network protocols
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc

# Disable AppleTalk
blacklist appletalk

# Disable IPX
blacklist ipx

# Disable DECnet
blacklist decnet

# Disable X.25
blacklist x25

# Disable Rose
blacklist rose

# Disable Econet
blacklist econet
EOF

# RHEL 9 STIG V-257806: Configure kernel module loading restrictions
cat > /etc/security/limits.d/stig-modules.conf << 'EOF'
# RHEL 9 STIG V-257806: Restrict kernel module operations
* hard core 0
* soft core 0
EOF

# RHEL 9 STIG V-257807: Configure module signature verification
mkdir -p /etc/sysctl.d
cat >> /etc/sysctl.d/99-stig-modules.conf << 'EOF'

# RHEL 9 STIG V-257807: Module signature verification
kernel.modules_disabled = 1
kernel.module_sig_enforce = 1
EOF

# RHEL 9 STIG V-257808: Remove unnecessary kernel modules from initramfs
if [ -f /etc/dracut.conf ]; then
    cat >> /etc/dracut.conf << 'EOF'

# RHEL 9 STIG V-257808: Dracut configuration for security
add_dracutmodules+=" "
omit_dracutmodules+=" usrmount base network ifcfg network-legacy "
install_items+=" /etc/modprobe.d/stig-blacklist.conf /etc/modprobe.d/stig-network-blacklist.conf "
EOF
fi

# Set proper permissions
chmod 644 /etc/modprobe.d/stig-blacklist.conf
chmod 644 /etc/modprobe.d/stig-network-blacklist.conf
chmod 644 /etc/security/limits.d/stig-modules.conf

echo "=== Kernel Module Security Configuration Complete ==="
