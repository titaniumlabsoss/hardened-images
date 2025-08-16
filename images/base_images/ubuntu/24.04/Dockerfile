# Ubuntu 24.04 LTS Hardened Image
# Based on DISA STIG essential controls

FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LC_ALL=C

# Run all hardening steps in a single layer for minimal size
COPY scripts/ /tmp/scripts
RUN chmod +x /tmp/scripts/*.sh && \
    mv /tmp/scripts/stig-validation.sh /opt/stig-validation.sh && \
    /tmp/scripts/01-base-setup.sh && \
    /tmp/scripts/02-package-hardening.sh && \
    /tmp/scripts/03-authentication.sh && \
    /tmp/scripts/04-audit-logging.sh && \
    /tmp/scripts/05-network-security.sh && \
    /tmp/scripts/06-file-permissions.sh && \
    /tmp/scripts/07-crypto-fips.sh && \
    /tmp/scripts/99-cleanup.sh

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/scripts

# Health check with minimal overhead
HEALTHCHECK --interval=60s --timeout=5s --start-period=5s --retries=2 \
    CMD echo "healthy" || exit 1

# Switch to non-root user for runtime security (STIG V-270724)
USER 1001:1001
WORKDIR /home/appuser

# Minimal command
CMD ["/bin/bash"]
