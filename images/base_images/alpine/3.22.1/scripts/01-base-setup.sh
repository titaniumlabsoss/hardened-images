#!/bin/sh
# Alpine Linux STIG-equivalent Base Setup
# Implements security controls matching RHEL 9 STIG standards

echo "=== Starting Alpine Base Setup ==="

# Update system packages
# Update package index only (no upgrade to save space)
apk update && apk upgrade

# Install essential security packages (Alpine equivalents)
ESSENTIAL_PACKAGES="
    shadow
    openssh
    ca-certificates
    openssl
    libcap
    libseccomp
    audit
    logrotate
"

for package in $ESSENTIAL_PACKAGES; do
    echo "Installing $package..."
    apk add --no-cache $package || echo "Failed to install $package, continuing..."
done

# Remove unnecessary packages and services
UNNECESSARY_PACKAGES="
    telnet
    rsh
    ypbind
    tftp
    talk
    xinetd
"

for package in $UNNECESSARY_PACKAGES; do
    if apk info -e $package 2>/dev/null; then
        echo "Removing unnecessary package: $package"
        apk del $package
    fi
done

# Create non-root user for security (STIG V-257901)
addgroup -g 1001 appuser 2>/dev/null || true
adduser -D -u 1001 -G appuser -s /bin/sh -h /home/appuser appuser 2>/dev/null || true

echo "=== Base Setup Complete ==="
