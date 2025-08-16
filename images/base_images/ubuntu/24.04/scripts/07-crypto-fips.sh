#!/bin/bash
# FIPS and cryptographic compliance configuration

set -e

echo "=== Starting Cryptographic/FIPS Configuration ==="

# STIG V-270744: FIPS mode configuration
# Note: Full FIPS enablement requires Ubuntu Pro subscription and kernel modules
# This configures the system for FIPS compliance where possible

# Configure strong cryptographic algorithms for SSH
cat > /etc/ssh/sshd_config.d/99-stig-crypto.conf << 'EOF'
# STIG V-270667: SSH server ciphers
Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr

# STIG V-270668: SSH server MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

# STIG V-270669: SSH key exchange algorithms
KexAlgorithms ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group14-sha256

# STIG V-270708: Disable X11 forwarding
X11Forwarding no

# STIG V-270709: Use localhost for X11 forwarding
X11UseLocalhost yes

# STIG V-270717: Disable empty passwords and user environment
PermitEmptyPasswords no
PermitUserEnvironment no

# STIG V-270741: Use PAM for authentication
UsePAM yes

# STIG V-270722: Enable public key authentication
PubkeyAuthentication yes

# STIG V-270742, V-270743: Session timeouts
ClientAliveInterval 600
ClientAliveCountMax 1
EOF

# Configure SSH client with FIPS-approved algorithms
cat > /etc/ssh/ssh_config.d/99-stig-crypto.conf << 'EOF'
# STIG V-270670: SSH client ciphers
Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr

# STIG V-270671: SSH client MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
EOF

# STIG V-270745: Configure DOD PKI certificate authorities
# Create directory for DOD certificates
mkdir -p /usr/local/share/ca-certificates

# Configure ca-certificates if the package is installed
if [ -f /etc/ca-certificates.conf ]; then
    # Disable non-DOD certificates (example configuration)
    sed -i -E 's/^([^!#]+)/!\1/' /etc/ca-certificates.conf
else
    echo "Note: ca-certificates not installed - certificate management will be manual"
fi

# STIG V-270672, V-270673: Configure PKI/PIV authentication
# Only configure if PKCS#11 packages are installed
if command -v pkcs11-tool >/dev/null 2>&1; then
    mkdir -p /etc/pam_pkcs11
    cat > /etc/pam_pkcs11/pam_pkcs11.conf << 'EOF'
# STIG-compliant PKCS#11 configuration
use_first_pass;
try_first_pass;
use_authtok;

pkcs11_module opensc {
    module = /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so;
    description = "OpenSC PKCS#11 module";

    # STIG V-270723: Certificate validation with OCSP
    cert_policy = ca,signature,ocsp_on;

    # STIG V-270738: Use local CRL when network unavailable
    cert_policy = ca,signature,ocsp_on,crl_auto;
}
EOF
else
    echo "Note: PKCS#11 tools not installed - smart card authentication not configured"
fi

# Configure SSSD for PKI authentication if installed
if command -v sssd >/dev/null 2>&1; then
    mkdir -p /etc/sssd
    cat > /etc/sssd/sssd.conf << 'EOF'
[sssd]
services = nss,pam,ssh
config_file_version = 2

[pam]
pam_cert_auth = True
offline_credentials_expiration = 1

[domain/example.com]
ldap_user_certificate = userCertificate;binary
certificate_verification = ca_cert,ocsp
ca_cert = /etc/ssl/certs/ca-certificates.crt
EOF
    chmod 600 /etc/sssd/sssd.conf
else
    echo "Note: SSSD not installed - domain authentication not configured"
fi

# STIG V-270751, V-270752: Configure chrony for secure time synchronization
cat > /etc/chrony/chrony.conf << 'EOF'
# STIG-compliant time synchronization
server pool.ntp.org iburst maxpoll 16
makestep 1 -1

# Security settings
driftfile /var/lib/chrony/drift
rtcsync
logdir /var/log/chrony
EOF

# Enable chrony service for container environment
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl enable chrony
else
    # Create enable link manually
    mkdir -p /etc/systemd/system/multi-user.target.wants
    ln -sf /lib/systemd/system/chrony.service /etc/systemd/system/multi-user.target.wants/chrony.service
fi

echo "=== Cryptographic/FIPS Configuration Complete ==="
