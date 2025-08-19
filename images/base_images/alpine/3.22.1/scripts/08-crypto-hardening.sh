#!/bin/sh
# Alpine Linux Cryptography Hardening
# Implements STIG-equivalent cryptographic controls

set -e

echo "=== Starting Cryptography Hardening ==="

# Configure strong cryptographic defaults
cat > /etc/ssl/openssl.cnf << 'EOF'
# OpenSSL configuration for STIG compliance
openssl_conf = openssl_init

[openssl_init]
providers = provider_sect
ssl_conf = ssl_sect

[provider_sect]
default = default_sect

[default_sect]
activate = 1

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
CipherString = ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS:!RC4:!3DES
Ciphersuites = TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256
MinProtocol = TLSv1.2
Options = PrioritizeChaCha,ServerPreference
EOF

# Configure SSH for strong algorithms (STIG V-257863)
if [ -d /etc/ssh ]; then
    # Append crypto settings to sshd_config if not already present
    if ! grep -q "^Ciphers aes256-ctr" /etc/ssh/sshd_config 2>/dev/null; then
        cat >> /etc/ssh/sshd_config << 'EOF'

# STIG-approved SSH algorithms
Ciphers aes256-ctr,aes192-ctr,aes128-ctr,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-256,hmac-sha2-512,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
PubkeyAcceptedKeyTypes rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-ed25519
HostKeyAlgorithms rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-ed25519
EOF
    fi
  
    # Skip generating SSH keys to save space - they will be generated if SSH is installed later
    # Remove weak host keys if they exist
    rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key.pub 2>/dev/null || true
  
    # Set proper permissions for SSH keys
    chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true
    chmod 644 /etc/ssh/ssh_host_*_key.pub 2>/dev/null || true
fi

# Configure kernel crypto settings (STIG V-257869)
cat >> /etc/sysctl.d/99-stig-crypto.conf << 'EOF'
# Kernel crypto settings
# Note: FIPS mode requires kernel support
crypto.fips_enabled = 1
EOF

# Configure strong password hashing
# Update PAM configuration if PAM is available
if [ -d /etc/pam.d ]; then
    # Configure PAM for strong authentication (STIG V-257865)
    cat > /etc/pam.d/system-auth-ac << 'EOF'
#%PAM-1.0
# STIG Strong authentication configuration

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
session     required      pam_unix.so
EOF
fi

# Configure certificate validation (STIG V-257867)
# Update CA certificates
update-ca-certificates 2>/dev/null || true

# Create placeholder for DoD CA certificates
mkdir -p /etc/ssl/certs/dod
cat > /etc/ssl/certs/dod/README << 'EOF'
# DoD PKI CA certificates should be placed here
# This is a placeholder for DoD CA chain
# In production, actual DoD CA certificates should be installed
EOF

# Configure TLS settings for various services
cat > /etc/ssl/tls-settings.conf << 'EOF'
# TLS configuration for STIG compliance
# Minimum TLS version: 1.2
# Strong cipher suites only
# Perfect Forward Secrecy preferred
# 
# Applications should reference these settings:
MinProtocol = TLSv1.2
CipherString = ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS:!RC4:!3DES:!DES:!EXPORT:!SSLv2:!SSLv3:!TLSv1:!TLSv1.1
EOF

# Set proper permissions for crypto files
chmod 644 /etc/ssl/openssl.cnf
chmod 644 /etc/ssl/tls-settings.conf
[ -d /etc/ssl/certs ] && chmod 755 /etc/ssl/certs
[ -d /etc/ssl/private ] && chmod 700 /etc/ssl/private

# Remove or disable weak crypto libraries if present
WEAK_CRYPTO_PACKAGES="
libssl1.0.0
openssl1.0
"

for package in $WEAK_CRYPTO_PACKAGES; do
    if apk info -e $package 2>/dev/null; then
        echo "Removing weak crypto package: $package"
        apk del $package 2>/dev/null || true
    fi
done

echo "=== Cryptography Hardening Complete ==="
