#!/bin/bash
# STIG network security hardening
# Implements firewall, SSH, and network protocol hardening

set -e

echo "=== Starting Network Security Hardening ==="

# STIG V-238290: Enable UFW firewall (container-compatible)
# Note: Firewall rules configured but not activated during build
# Container runtime and host system will handle firewall enforcement

# Configure UFW defaults in config file instead of running commands
mkdir -p /etc/ufw
cat > /etc/ufw/ufw.conf << EOF
# /etc/ufw/ufw.conf
ENABLED=yes
LOGLEVEL=low
EOF

# Set default policies in config
echo "DEFAULT_INPUT_POLICY=\"DROP\"" >> /etc/default/ufw
echo "DEFAULT_OUTPUT_POLICY=\"DROP\"" >> /etc/default/ufw
echo "DEFAULT_FORWARD_POLICY=\"DROP\"" >> /etc/default/ufw

# STIG V-238291: Configure SSH daemon
cat > /etc/ssh/sshd_config << EOF
# STIG V-238291-V-238320: SSH Configuration

# STIG V-238291: SSH Protocol version 2
Protocol 2

# STIG V-238292: SSH must not allow empty passwords
PermitEmptyPasswords no

# STIG V-238293: SSH must not allow host-based authentication
HostbasedAuthentication no

# STIG V-238294: SSH must not allow user environment processing
PermitUserEnvironment no

# STIG V-238295: SSH must not allow compression
Compression no

# STIG V-238296: SSH must not allow TCP forwarding
AllowTcpForwarding no

# STIG V-238297: SSH must not allow X11 forwarding
X11Forwarding no

# STIG V-238298: SSH must display login banner
Banner /etc/issue.net

# STIG V-238299: SSH must timeout idle sessions
ClientAliveInterval 300
ClientAliveCountMax 0

# STIG V-238300: SSH must limit concurrent sessions
MaxSessions 1

# STIG V-238301: SSH must not accept environment variables
AcceptEnv none

# STIG V-238302: SSH must not allow rhosts files
IgnoreRhosts yes

# STIG V-238303: SSH must use approved encryption algorithms
Ciphers aes256-ctr,aes192-ctr,aes128-ctr

# STIG V-238304: SSH must use approved MAC algorithms
MACs hmac-sha2-512,hmac-sha2-256

# STIG V-238305: SSH must use approved key exchange algorithms
KexAlgorithms ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group14-sha256

# STIG V-238306: SSH must not allow root login
PermitRootLogin no

# STIG V-238307: SSH must not allow password authentication
PasswordAuthentication no

# STIG V-238308: SSH must use privilege separation
UsePrivilegeSeparation yes

# STIG V-238309: SSH must not allow agent forwarding
AllowAgentForwarding no

# STIG V-238310: SSH must not allow gateway ports
GatewayPorts no

# Additional security settings
Port 22
AddressFamily inet
ListenAddress 0.0.0.0
SyslogFacility AUTHPRIV
LogLevel INFO
LoginGraceTime 60
StrictModes yes
MaxAuthTries 3
MaxStartups 10:30:60
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
UsePAM yes
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

# STIG V-238311: Create SSH banner
cat > /etc/issue.net << EOF
***WARNING***
This system is for the use of authorized users only. Individuals
using this computer system without authority or in excess of their
authority are subject to having all their activities on this system
monitored and recorded by system personnel. Anyone using this
system expressly consents to such monitoring and is advised that
if such monitoring reveals possible evidence of criminal activity
system personal may provide the evidence of such monitoring to law
enforcement officials.
EOF

# STIG V-238312: Set SSH banner permissions
chmod 644 /etc/issue.net

# STIG V-238313: Disable IPv6 if not needed
mkdir -p /etc/sysctl.d
cat >> /etc/sysctl.d/99-stig.conf << EOF
# STIG V-238313: Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# STIG V-238314: Network parameters for security
cat >> /etc/sysctl.d/99-stig.conf << EOF

# STIG V-238314: IP forwarding must be disabled
net.ipv4.ip_forward = 0

# STIG V-238315: Source routing must be disabled
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# STIG V-238316: ICMP redirects must not be accepted
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# STIG V-238317: Secure ICMP redirects must not be accepted
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# STIG V-238318: ICMP redirects must not be sent
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# STIG V-238319: Broadcast ICMP requests must be ignored
net.ipv4.icmp_echo_ignore_broadcasts = 1

# STIG V-238320: Bogus ICMP responses must be ignored
net.ipv4.icmp_ignore_bogus_error_responses = 1

# STIG V-238321: Reverse path filtering must be enabled
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# STIG V-238322: TCP SYN cookies must be enabled
net.ipv4.tcp_syncookies = 1

# STIG V-238323: Log martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
EOF

# STIG V-238324: Configure firewall rules
# Allow SSH (port 22) for management - configured for runtime
mkdir -p /etc/ufw/applications.d
cat > /etc/ufw/applications.d/openssh << EOF
[OpenSSH]
title=Secure shell server, an rshd replacement
description=OpenSSH is a free implementation of the Secure Shell protocol.
ports=22/tcp
EOF

# STIG V-238325: Configure TCP Wrappers
cat > /etc/hosts.allow << EOF
# STIG V-238325: Allow SSH from any host (modify as needed)
sshd: ALL
EOF

cat > /etc/hosts.deny << EOF
# STIG V-238326: Deny all other services
ALL: ALL
EOF

# STIG V-238326: Set permissions on network configuration files
chmod 644 /etc/hosts.allow
chmod 644 /etc/hosts.deny

# STIG V-238327: Configure network time protocol
mkdir -p /etc/chrony
cat > /etc/chrony/chrony.conf << EOF
# STIG V-238327: Configure NTP servers
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 3.pool.ntp.org iburst

# Security settings
driftfile /var/lib/chrony/chrony.drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony/chrony.keys
commandkey 1
generatecommandkey
noclientlog
logchange 0.5
logdir /var/log/chrony
EOF

# Enable and start chrony (container-compatible)
# Note: Time synchronization handled by container host system

echo "=== Network Security Hardening Complete ==="
