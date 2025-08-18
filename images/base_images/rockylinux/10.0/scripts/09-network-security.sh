#!/bin/bash
# RHEL 9 STIG Network Security Configuration

set -e

echo "=== Starting Network Security Configuration ==="

# RHEL 9 STIG V-257825: Configure firewalld
systemctl enable firewalld 2>/dev/null || true

# RHEL 9 STIG V-257826: Configure kernel parameters for network security
cat > /etc/sysctl.d/99-stig-network.conf << 'EOF'
# RHEL 9 STIG V-257826-V-257835: Network security parameters

# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable packet redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Disable source routed packets
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable secure ICMP redirects
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore ping requests
net.ipv4.icmp_echo_ignore_all = 1

# Ignore broadcast ping requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable IPv6 router advertisements
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Disable IPv6 entirely (STIG requirement for most environments)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# Enable TCP SYN cookies
net.ipv4.tcp_syncookies = 1

# Disable core dumps
fs.suid_dumpable = 0

# Address space layout randomization
kernel.randomize_va_space = 2

# Restrict access to kernel logs
kernel.dmesg_restrict = 1

# Restrict access to kernel pointers
kernel.kptr_restrict = 2

# Disable kernel module loading after boot
kernel.modules_disabled = 1

# RHEL 9 STIG V-257792: Additional kernel security parameters
kernel.yama.ptrace_scope = 1
kernel.kexec_load_disabled = 1
kernel.unprivileged_bpf_disabled = 1
net.core.bpf_jit_harden = 2

# RHEL 9 STIG V-257793: Network stack hardening
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_rfc1337 = 1
net.ipv4.ip_local_port_range = 32768 60999
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 3

# RHEL 9 STIG V-257794: Memory protection
kernel.exec-shield = 1
kernel.randomize_va_space = 2

# RHEL 9 STIG V-257795: File system security
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2

# RHEL 9 STIG V-257796: Process restrictions
kernel.perf_event_paranoid = 3
kernel.unprivileged_userns_clone = 0
EOF

# RHEL 9 STIG V-257836: Configure SSH daemon
cat > /etc/ssh/sshd_config << 'EOF'
# RHEL 9 STIG V-257836-V-257845: SSH daemon configuration

# Protocol and encryption
Protocol 2
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256,hmac-sha2-512

# Authentication
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Session settings
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
UsePrivilegeSeparation sandbox

# Timeouts and limits
ClientAliveInterval 300
ClientAliveCountMax 0
LoginGraceTime 60
MaxAuthTries 3
MaxSessions 4
MaxStartups 10:30:60

# Logging
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# Host keys
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Miscellaneous
Compression no
UseDNS no
PermitUserEnvironment no
PermitTunnel no
Banner /etc/issue.net
EOF

# RHEL 9 STIG V-257846: Create security banner
cat > /etc/issue.net << 'EOF'
*****************************************************************************
*                                                                           *
*                               NOTICE TO USERS                             *
*                                                                           *
*     This system is for authorized use only. Users (authorized or          *
*     unauthorized) have no explicit or implicit expectation of privacy.    *
*                                                                           *
*     Any or all uses of this system and all files on this system may be    *
*     intercepted, monitored, recorded, copied, audited, inspected, and     *
*     disclosed to authorized personnel and law enforcement officials.      *
*                                                                           *
*     By using this system, the user consents to such interception,         *
*     monitoring, recording, copying, auditing, inspection, and disclosure  *
*     at the discretion of authorized personnel.                            *
*                                                                           *
*     Unauthorized or improper use of this system may result in civil and   *
*     criminal penalties and administrative or disciplinary action, as      *
*     appropriate. By continuing to use this system you indicate your       *
*     awareness of and consent to these terms and conditions of use.        *
*                                                                           *
*     LOG OFF IMMEDIATELY if you do not agree to the conditions stated      *
*     in this warning.                                                      *
*                                                                           *
*****************************************************************************
EOF

cp /etc/issue.net /etc/issue

# RHEL 9 STIG V-257847: Configure TCP wrappers
cat > /etc/hosts.allow << 'EOF'
# RHEL 9 STIG V-257847: TCP wrappers allow
# Only allow connections from authorized networks
# sshd: 192.168.1.0/255.255.255.0
# ALL: LOCAL
EOF

cat > /etc/hosts.deny << 'EOF'
# RHEL 9 STIG V-257847: TCP wrappers deny
# Deny all other connections
ALL: ALL
EOF

# Set proper permissions
chmod 644 /etc/hosts.allow
chmod 644 /etc/hosts.deny
chmod 644 /etc/issue
chmod 644 /etc/issue.net
chmod 600 /etc/ssh/sshd_config

echo "=== Network Security Configuration Complete ==="
