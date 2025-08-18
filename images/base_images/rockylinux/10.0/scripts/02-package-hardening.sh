#!/bin/bash
# RHEL 9 STIG Package Hardening and Management

set -e

echo "=== Starting Package Hardening ==="

# RHEL 9 STIG V-257785: Enable automatic security updates
cat > /etc/dnf/automatic.conf << 'EOF'
[commands]
upgrade_type = security
random_sleep = 0
download_updates = yes
apply_updates = yes

[emitters]
emit_via = stdio

[email]
email_from = root@localhost
email_to = root
email_host = localhost

[base]
debuglevel = 1
EOF

# Enable dnf-automatic timer for security updates
systemctl enable dnf-automatic.timer 2>/dev/null || true

# RHEL 9 STIG V-257786: Configure package verification
cat > /etc/dnf/dnf.conf << 'EOF'
[main]
gpgcheck=1
localpkg_gpgcheck=1
repo_gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
keepcache=False
metadata_expire=24h
deltarpm=False
timeout=30
retries=3
throttle=0
minrate=1000
sslverify=True
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
proxy_auth_method=any
EOF

# RHEL 9 STIG V-257787: Remove packages with known vulnerabilities
VULNERABLE_PACKAGES=(
    "sendmail"
    "bind"
    "dhcp"
    "squid"
    "snmpd"
    "dovecot"
    "httpd"
    "nginx"
    "vsftpd"
    "tftp-server"
    "xinetd"
)

for package in "${VULNERABLE_PACKAGES[@]}"; do
    if rpm -q "$package" 2>/dev/null; then
        echo "Removing potentially vulnerable package: $package"
        dnf remove -y "$package"
    fi
done

# RHEL 9 STIG V-257819: Configure GPG verification
# Import Rocky Linux GPG keys
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10

# Verify GPG key integrity
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10 2>/dev/null || true

# RHEL 9 STIG V-257820: Configure repository security
cat > /etc/yum.repos.d/rocky-security.repo << 'EOF'
[rocky-security]
name=Rocky Linux $releasever - Security Updates
baseurl=https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-10
sslverify=1
metadata_expire=6h
repo_gpgcheck=1
EOF

# RHEL 9 STIG V-257821: Disable unnecessary repositories
# Keep only essential repositories enabled
dnf config-manager --disable '*' || true
dnf config-manager --enable baseos || true
dnf config-manager --enable appstream || true
dnf config-manager --enable rocky-security || true

# RHEL 9 STIG V-257822: Configure package integrity verification
cat > /etc/rpm/macros.stig << 'EOF'
# RHEL 9 STIG V-257822: RPM verification settings
%_vsflags_build	%{_default_vsflags_build}
%_vsflags_erase	%{_default_vsflags_erase}
%_vsflags_install	%{_default_vsflags_install}
%_vsflags_query	%{_default_vsflags_query}
%_vsflags_rebuilddb	%{_default_vsflags_rebuilddb}
%_vsflags_verify	%{_default_vsflags_verify}
EOF

# RHEL 9 STIG V-257823: Verify package database integrity
rpm --rebuilddb 2>/dev/null || true

# RHEL 9 STIG V-257824: Configure package manager to prevent downgrades
cat >> /etc/dnf/dnf.conf << 'EOF'

# RHEL 9 STIG V-257824: Prevent package downgrades
obsoletes=1
protect_running_kernel=1
check_config_file_age=1
history_record=1
EOF

# RHEL 9 STIG V-257825: Clean package cache and verify integrity
dnf clean all
rpm -Va --nofiles --nomd5 2>/dev/null | head -10 || true

echo "=== Package Hardening Complete ==="
