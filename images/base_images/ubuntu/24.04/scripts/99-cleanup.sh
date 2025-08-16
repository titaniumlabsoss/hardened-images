#!/bin/bash
# Final cleanup and optimization for minimal image size

set -e

echo "=== Starting Final Cleanup ==="

# Stage 1: Package cleanup
apt-get clean
apt-get autoremove -y --purge
apt-get autoclean

# Remove package management artifacts
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*
rm -rf /var/cache/debconf/*
rm -rf /var/lib/dpkg/info/*.postinst
rm -rf /var/lib/dpkg/info/*.prerm
rm -rf /var/lib/dpkg/info/*.postrm

# Stage 2: Remove documentation
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/locale/[a-z]*  # Keep C locale only
rm -rf /usr/share/pixmaps/*
rm -rf /usr/share/applications/*
rm -rf /usr/share/mime/*
rm -rf /usr/share/icons/*
rm -rf /usr/share/sounds/*
rm -rf /usr/share/themes/*

# Stage 3: Remove development artifacts
find /usr -name "*.a" -delete 2>/dev/null || true
find /usr -name "*.la" -delete 2>/dev/null || true
find /usr -name "*-config" -type f -delete 2>/dev/null || true
find /usr/include -type f -delete 2>/dev/null || true
find /usr/lib/pkgconfig -type f -delete 2>/dev/null || true
find /usr/share/pkgconfig -type f -delete 2>/dev/null || true

# Stage 4: Clean temporary and cache files
rm -rf /tmp/* /var/tmp/*
rm -rf /root/.cache
rm -rf /var/cache/ldconfig/aux-cache
rm -rf /var/cache/fontconfig/*
rm -rf /usr/share/glib-2.0/schemas/gschemas.compiled

# Stage 5: Clean logs (they'll be recreated as needed)
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
find /var/log -type f -name "*.gz" -delete 2>/dev/null || true
find /var/log -type f -name "*.old" -delete 2>/dev/null || true
find /var/log -type f -name "*.[0-9]" -delete 2>/dev/null || true

# Stage 6: Remove SSH host keys (security risk in container images)
# SSH host keys should be generated at runtime, not baked into images
rm -f /etc/ssh/ssh_host_*

# Stage 7: Clear shell artifacts
history -c 2>/dev/null || true
rm -f /root/.bash_history
rm -f /root/.lesshst
rm -f /root/.wget-hsts

# Stage 8: Remove Python artifacts
find /usr -name "*.pyc" -delete 2>/dev/null || true
find /usr -name "*.pyo" -delete 2>/dev/null || true
find /usr -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Stage 9: Clean installation artifacts
find /usr /var /etc -name "*.dpkg-*" -delete 2>/dev/null || true
find /usr -name "*.orig" -delete 2>/dev/null || true
find /usr -name "*.rej" -delete 2>/dev/null || true

# Stage 10: Remove unnecessary shared libraries (be careful here)
# Only remove clearly unnecessary ones
find /usr/lib -name "*.so.*" -path "*/gconv/*" -delete 2>/dev/null || true

# Stage 11: Compress man pages and documentation that remains
find /usr/share/man -type f -name "*.gz" -delete 2>/dev/null || true

# Set final system state (skip systemctl in container build)
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl daemon-reload
else
    echo "Skipping systemctl daemon-reload in container build environment"
fi

echo "=== Final Cleanup Complete ==="
echo "=== STIG Hardening Process Completed ==="
