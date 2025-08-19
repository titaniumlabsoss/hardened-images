# Alpine Linux 3.22.1 Hardened Image
# Security-hardened Alpine Linux base implementing STIG-equivalent controls

FROM alpine:3.22.1

LABEL org.opencontainers.image.base.name="docker.io/titaniumlabs/alpine:3.22.1" \
      org.opencontainers.image.description="Application packaged by Titanium Labs" \
      org.opencontainers.image.documentation="https://github.com/titaniumlabsoss/hardened-images/blob/main/images/base_images/alpine/README.md" \
      org.opencontainers.image.source="https://github.com/titaniumlabsoss/hardened-images/tree/main/images/base_images/alpine" \
      org.opencontainers.image.title="alpine" \
      org.opencontainers.image.vendor="Titanium Labs" \
      org.opencontainers.image.version="3.22.1"

# Set environment variables
ENV TZ=UTC \
    LANG=C \
    LC_ALL=C \
    HISTFILE=/dev/null \
    HISTSIZE=0

# Run all hardening steps in a single layer for minimal size
COPY scripts/ /tmp/scripts
RUN chmod +x /tmp/scripts/*.sh && \
    mv /tmp/scripts/compliance-check.sh /opt/compliance-check.sh && \
    /tmp/scripts/01-base-setup.sh && \
    /tmp/scripts/02-authentication.sh && \
    /tmp/scripts/03-kernel-modules.sh && \
    /tmp/scripts/04-filesystem-security.sh && \
    /tmp/scripts/05-network-security.sh && \
    /tmp/scripts/06-file-permissions.sh && \
    /tmp/scripts/07-audit-logging.sh && \
    /tmp/scripts/08-crypto-hardening.sh && \
    /tmp/scripts/99-cleanup.sh

# Clean up
RUN rm -rf /tmp/scripts \
    /var/cache/apk/* \
    /tmp/* \
    /var/tmp/*

# Run compliance test as root
RUN /opt/compliance-check.sh

# Switch to non-root user for runtime security
USER 1001:1001

# Minimal command
CMD ["/bin/sh"]
