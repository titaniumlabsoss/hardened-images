#!/bin/bash
# STIG V-238196: Ubuntu 22.04 LTS must be a vendor-supported release
# Base system setup and essential packages

set -e

echo "=== Starting Base Setup ==="

# Update package lists
apt-get update

# Install essential STIG-required packages
apt-get install -y --no-install-recommends \
    aide \
    auditd \
    chrony \
    iptables-persistent \
    libpam-pwquality \
    openssh-server \
    vlock \
    apparmor \
    apparmor-utils \
    clamav \
    clamav-daemon \
    fail2ban \
    rsyslog \
    ufw \
    sudo

# Note: All these packages are STIG-required:
# - aide: STIG V-238208 (file integrity monitoring)
# - auditd: STIG V-238252+ (audit logging)
# - chrony: STIG V-238200 (time synchronization)
# - iptables-persistent: STIG V-238290+ (firewall)
# - libpam-pwquality: STIG V-238330+ (password policy)
# - openssh-server: STIG V-238310+ (secure remote access)
# - vlock: STIG V-238327 (screen locking)
# - apparmor: STIG V-238230+ (mandatory access control)
# - clamav: STIG V-238304 (antivirus)
# - fail2ban: STIG V-238307 (intrusion prevention)
# - rsyslog: STIG V-238254 (centralized logging)
# - ufw: STIG V-238290 (uncomplicated firewall)

# STIG V-238200: Remove systemd-timesyncd package
if dpkg -l | grep -q systemd-timesyncd; then
    apt-get purge -y systemd-timesyncd
fi

# STIG V-238201: Remove ntp package
if dpkg -l | grep -q ntp; then
    apt-get purge -y ntp
fi

# STIG V-238202: Remove telnet package
if dpkg -l | grep -q telnetd; then
    apt-get remove -y telnetd
fi

# STIG V-238203: Remove rsh-server package
if dpkg -l | grep -q rsh-server; then
    apt-get remove -y rsh-server
fi

# STIG V-238204: Remove nis package
if dpkg -l | grep -q nis; then
    apt-get remove -y nis
fi

# STIG V-238205: Remove x11-common package (if present)
if dpkg -l | grep -q x11-common; then
    apt-get remove -y x11-common
fi

# Create non-root user for security (STIG V-238366)
useradd -r -u 1001 -g root -s /bin/bash -m appuser

# STIG V-238362: Disable Ctrl-Alt-Delete (container-compatible)
# Note: Containers don't use systemd, this would be configured on the host

# STIG V-238363: System must prevent direct logon to shared accounts
echo "account required pam_access.so" >> /etc/pam.d/login

# STIG V-238220: Remove unnecessary packages
apt-get autoremove -y

echo "=== Base Setup Complete ==="
