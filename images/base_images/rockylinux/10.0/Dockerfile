# Rocky Linux 10.0 UBI Hardened Image
# Security-hardened Rocky Linux base implementing DISA STIG controls

FROM rockylinux/rockylinux:10.0-ubi

# Set environment variables
ENV TZ=UTC \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Run all hardening steps in a single layer for minimal size
COPY scripts/ /tmp/scripts
RUN chmod +x /tmp/scripts/*.sh && \
    mv /tmp/scripts/compliance-check.sh /opt/compliance-check.sh && \
    /tmp/scripts/01-base-setup.sh && \
    /tmp/scripts/02-package-hardening.sh && \
    /tmp/scripts/03-authentication.sh && \
    /tmp/scripts/04-audit-logging.sh && \
    /tmp/scripts/05-kernel-modules.sh && \
    /tmp/scripts/06-filesystem-security.sh && \
    /tmp/scripts/07-file-permissions.sh && \
    /tmp/scripts/08-crypto-fips.sh && \
    /tmp/scripts/09-network-security.sh && \
    /tmp/scripts/99-cleanup.sh

# Clean up
RUN rm -rf /tmp/scripts \
    /var/cache/dnf/* \
    /var/cache/yum/* \
    /tmp/* \
    /var/tmp/*

# Run compliance test as root
RUN /opt/compliance-check.sh

# Switch to non-root user for runtime security
USER 1001:1001

# Minimal command
CMD ["/bin/bash"]
