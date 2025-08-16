#!/bin/bash
# STIG V-270774: Ubuntu 24.04 LTS must be a vendor-supported release
# Base system setup and essential packages

set -e

echo "=== Starting Base Setup ==="

# Update package lists
apt-get update

# Install essential STIG-required packages (minimal but compliant)
apt-get install -y --no-install-recommends \
    aide \
    auditd \
    chrony \
    iptables-persistent \
    libpam-pwquality \
    openssh-server \
    vlock

# Note: All these packages are STIG-required:
# - aide: STIG V-270773 (file integrity monitoring)
# - auditd: STIG V-270648+ (audit logging)
# - chrony: STIG V-270645 (time synchronization)
# - iptables-persistent: STIG V-270695+ (firewall - minimal alternative to UFW)
# - libpam-pwquality: STIG V-270716+ (password policy)
# - openssh-server: STIG V-270755+ (secure remote access)
# - vlock: STIG V-270712 (screen locking)

# STIG V-270645: Remove systemd-timesyncd package
if dpkg -l | grep -q systemd-timesyncd; then
    apt-get purge -y systemd-timesyncd
fi

# STIG V-270646: Remove ntp package
if dpkg -l | grep -q ntp; then
    apt-get purge -y ntp
fi

# STIG V-270647: Remove telnet package
if dpkg -l | grep -q telnetd; then
    apt-get remove -y telnetd
fi

# STIG V-270648: Remove rsh-server package
if dpkg -l | grep -q rsh-server; then
    apt-get remove -y rsh-server
fi

# Set timezone to UTC (STIG V-270820)
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone

# STIG V-270716: Set default umask
echo "UMASK 077" >> /etc/login.defs

echo "=== Base Setup Complete ==="
