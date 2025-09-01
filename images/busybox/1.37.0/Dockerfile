# BusyBox 1.37.0 Hardened Image
# Security-hardened BusyBox built from official image with DISA STIG controls and CIS benchmarks

# Use this image itself to pull the Busybox binary
FROM titaniumlabs/busybox:1.37.0 AS source

# Use hardened Rocky Linux for final image setup
FROM titaniumlabs/rockylinux:10 AS builder

# Switch to root for build operations
USER root

# Create secure directory structure
RUN mkdir -p /opt/secure/{bin,sbin,etc,tmp} && \
    chmod 755 /opt/secure /opt/secure/bin /opt/secure/sbin /opt/secure/etc && \
    chmod 1777 /opt/secure/tmp

# Copy BusyBox binary from official image
COPY --from=source /bin/busybox /opt/secure/bin/busybox
RUN chmod 755 /opt/secure/bin/busybox

# Create symlinks for all BusyBox commands
RUN cd /opt/secure/bin && \
    ./busybox --list | while read cmd; do \
        if [ "$cmd" != "busybox" ]; then \
            ln -sf busybox "$cmd"; \
        fi; \
    done

# Create minimal user setup
RUN echo "busybox:x:1001:1001:BusyBox User:/tmp:/bin/sh" > /opt/secure/etc/passwd && \
    echo "busybox:x:1001:" > /opt/secure/etc/group && \
    echo "busybox:*:19000:0:99999:7:::" > /opt/secure/etc/shadow

# Set secure permissions
RUN chmod 644 /opt/secure/etc/passwd /opt/secure/etc/group && \
    chmod 640 /opt/secure/etc/shadow && \
    chmod 755 /opt/secure/bin/busybox

# Final minimal stage - using scratch for absolute minimal footprint
FROM scratch

LABEL org.opencontainers.image.base.name="scratch" \
      org.opencontainers.image.description="BusyBox packaged by Titanium Labs" \
      org.opencontainers.image.documentation="https://github.com/titaniumlabsoss/hardened-images/blob/main/images/busybox/README.md" \
      org.opencontainers.image.source="https://github.com/titaniumlabsoss/hardened-images/tree/main/images/busybox" \
      org.opencontainers.image.title="busybox" \
      org.opencontainers.image.vendor="Titanium Labs" \
      org.opencontainers.image.version="1.37.0"

# Copy minimal filesystem from builder
COPY --from=builder /opt/secure/bin /bin
COPY --from=builder /opt/secure/sbin /sbin
COPY --from=builder /opt/secure/etc /etc
COPY --from=builder /opt/secure/tmp /tmp

# Copy required libraries from source
COPY --from=source /lib /lib

# Set environment variables for security
ENV HOME=/tmp \
    PATH=/bin:/sbin:/usr/bin:/usr/sbin \
    SHELL=/bin/sh \
    USER=busybox \
    TZ=UTC

# Switch to non-root user for runtime security
USER 1001:1001

# Set working directory
WORKDIR /tmp

# Default command - interactive shell
CMD ["/bin/sh"]
