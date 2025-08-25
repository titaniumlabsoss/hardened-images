# Rocky Linux 10.0 UBI Hardened Image
# Security-hardened Rocky Linux base implementing DISA STIG controls

# Use full Rocky Linux image for building and installing packages
FROM rockylinux/rockylinux:10 AS builder

# Run hardening scripts in a single layer
COPY scripts/ /tmp/scripts
RUN chmod +x /tmp/scripts/*.sh && \
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

# Final stage using UBI micro for minimal size
FROM rockylinux/rockylinux:10-ubi-micro

LABEL org.opencontainers.image.base.name="docker.io/titaniumlabs/rockylinux:10" \
      org.opencontainers.image.description="Application packaged by Titanium Labs" \
      org.opencontainers.image.documentation="https://github.com/titaniumlabsoss/hardened-images/blob/main/images/base_images/rockylinux/README.md" \
      org.opencontainers.image.source="https://github.com/titaniumlabsoss/hardened-images/tree/main/images/base_images/rockylinux" \
      org.opencontainers.image.title="rockylinux" \
      org.opencontainers.image.vendor="Titanium Labs" \
      org.opencontainers.image.version="10"

# Set environment variables
ENV TZ=UTC \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Copy essential files and configurations from builder stage
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /etc/shadow /etc/shadow
COPY --from=builder /etc/pam.d/ /etc/pam.d/
COPY --from=builder /etc/sysctl.d/ /etc/sysctl.d/
COPY --from=builder /etc/security/ /etc/security/
COPY --from=builder /etc/modprobe.d/ /etc/modprobe.d/

# Set correct umask for compliance in multiple places
RUN echo "umask 0077" >> /etc/profile && \
    echo "umask 0077" >> /etc/bash.bashrc && \
    echo "umask 0077" >> /etc/bashrc

# Switch to non-root user for runtime security
USER 1001:1001

# Minimal command
CMD ["/bin/bash"]
