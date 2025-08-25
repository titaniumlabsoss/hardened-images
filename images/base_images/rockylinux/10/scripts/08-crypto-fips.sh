#!/bin/bash
# RHEL 9 STIG Cryptography and FIPS Configuration

set -e

echo "=== Starting Cryptography and FIPS Configuration ==="

# RHEL 9 STIG V-257860: Enable FIPS mode
# Note: Full FIPS enablement requires kernel boot parameters
# This script configures userspace FIPS compliance

# Install FIPS-related packages
dnf install -y \
    crypto-policies \
    crypto-policies-scripts

# RHEL 9 STIG V-257861: Set system crypto policy to FIPS
update-crypto-policies --set FIPS 2>/dev/null || {
    echo "Warning: Could not set FIPS crypto policy in container environment"
    # Fallback to manual FIPS configuration
    update-crypto-policies --set DEFAULT:NO-MD5:NO-SHA1:NO-WEAKMAC 2>/dev/null || true
}

# RHEL 9 STIG V-257862: Configure OpenSSL for FIPS
cat > /etc/pki/tls/openssl_fips.cnf << 'EOF'
# RHEL 9 STIG V-257862: OpenSSL FIPS configuration
openssl_conf = openssl_init

[openssl_init]
providers = provider_sect

[provider_sect]
fips = fips_sect
base = base_sect

[base_sect]
activate = 1

[fips_sect]
activate = 1
module_mac = SHA256:8cb5b76e9bf111c
EOF

# RHEL 9 STIG V-257863: Configure SSH for FIPS-approved algorithms
cat >> /etc/ssh/sshd_config << 'EOF'

# RHEL 9 STIG V-257863: FIPS-approved SSH algorithms
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256,hmac-sha2-512
KexAlgorithms diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521
PubkeyAcceptedKeyTypes rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-ed25519
EOF

# RHEL 9 STIG V-257864: Generate strong SSH host keys
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N '' -q
fi

if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
    ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N '' -q
fi

if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' -q
fi

# Remove weak host keys
rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key.pub

# RHEL 9 STIG V-257865: Configure PAM for strong authentication
cat > /etc/pam.d/system-auth-ac << 'EOF'
#%PAM-1.0
# RHEL 9 STIG V-257865: Strong authentication configuration

auth        required      pam_env.so
auth        required      pam_faillock.so preauth silent audit deny=3 unlock_time=0 fail_interval=900
auth        sufficient    pam_unix.so try_first_pass sha512
auth        [default=die] pam_faillock.so authfail audit deny=3 unlock_time=0 fail_interval=900
auth        required      pam_deny.so

account     required      pam_unix.so
account     required      pam_faillock.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=15 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1 difok=8 maxrepeat=3
password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok remember=5 rounds=5000
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
EOF

# RHEL 9 STIG V-257866: Configure entropy sources
mkdir -p /etc/systemd/system/rngd.service.d
cat > /etc/systemd/system/rngd.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=/sbin/rngd -f -r /dev/urandom
EOF

# RHEL 9 STIG V-257867: Configure certificate validation
cat > /etc/pki/ca-trust/source/anchors/DoD_PKE_CA_chain.pem << 'EOF'
# DoD PKI CA certificates would be placed here
# This is a placeholder for DoD CA chain
# In production, actual DoD CA certificates should be installed
EOF

# Update CA trust store
update-ca-trust 2>/dev/null || true

# RHEL 9 STIG V-257868: Configure TLS settings
cat > /etc/ssl/openssl.cnf << 'EOF'
# RHEL 9 STIG V-257868: TLS configuration
openssl_conf = default_conf

[default_conf]
ssl_conf = ssl_sect

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
CipherString = ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS
Ciphersuites = TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256
MinProtocol = TLSv1.2
Options = PrioritizeChaCha,ServerPreference
EOF

# RHEL 9 STIG V-257869: Configure kernel crypto settings
cat >> /etc/sysctl.d/99-stig-crypto.conf << 'EOF'
# RHEL 9 STIG V-257869: Kernel crypto settings
crypto.fips_enabled = 1
EOF

# Set proper permissions for crypto files
chmod 644 /etc/pki/tls/openssl_fips.cnf
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub
chmod 644 /etc/ssl/openssl.cnf

echo "=== Cryptography and FIPS Configuration Complete ==="
