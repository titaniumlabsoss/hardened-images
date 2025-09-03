# aws-cli Hardened Image
# Security-hardened aws-cli built for multiple architectures

FROM titaniumlabs/builder:10 AS builder

# Use APP_VERSION to determine the binary's version
ARG APP_VERSION="2.28.23"

# Use TARGETARCH to determine the correct binary
ARG TARGETARCH

# Install zlib for AWS CLI
RUN microdnf install -y zlib && \
    microdnf clean all

# Download aws-cli binary
WORKDIR /tmp
RUN ARCH=$(case "$TARGETARCH" in \
      amd64) echo "x86_64" ;; \
      arm64) echo "aarch64" ;; \
      *) echo "unsupported" && exit 1 ;; \
    esac) && \
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${APP_VERSION}.zip" -o "awscli.zip" && \
    unzip awscli.zip

# Final stage
FROM titaniumlabs/rockylinux:10

ARG APP_VERSION="2.28.23"

LABEL org.opencontainers.image.base.name="titaniumlabs/rockylinux:10" \
      org.opencontainers.image.description="aws-cli packaged by Titanium Labs" \
      org.opencontainers.image.documentation="https://github.com/titaniumlabsoss/hardened-images/blob/main/images/aws-cli/README.md" \
      org.opencontainers.image.source="https://github.com/titaniumlabsoss/hardened-images/tree/main/images/aws-cli" \
      org.opencontainers.image.title="aws-cli" \
      org.opencontainers.image.vendor="Titanium Labs" \
      org.opencontainers.image.version="$APP_VERSION"

# Switch to root to install AWS CLI and copy zlib
USER root

# Copy zlib library from builder stage
COPY --from=builder /usr/lib64/libz.so.1* /usr/lib64/

# Copy folder from builder
COPY --from=builder /tmp/aws /tmp/aws

# Install aws-cli to system directories
RUN /tmp/aws/install -i /usr/local/aws-cli -b /usr/local/bin && rm -rf /tmp/aws

# Switch back to non-root user for runtime security
USER 1001:1001

# Verify the binary works
RUN aws --version

# Default command
CMD ["aws"]
