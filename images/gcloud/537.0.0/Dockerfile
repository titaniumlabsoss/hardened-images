# gcloud Hardened Image
# Security-hardened gcloud built for multiple architectures

FROM titaniumlabs/builder:10 AS builder

# Use APP_VERSION to determine the binary's version
ARG APP_VERSION="537.0.0"

# Use TARGETARCH to determine the correct binary
ARG TARGETARCH

# Install Python and dependencies for gcloud SDK installation
RUN microdnf install -y python3 python3-libs python3-pip && \
    microdnf clean all && \
    ln -sf /usr/bin/python3 /usr/bin/python

# Download gcloud binary
WORKDIR /tmp
RUN ARCH=$(case "$TARGETARCH" in \
      amd64) echo "x86_64" ;; \
      arm64) echo "arm" ;; \
      *) echo "unsupported" && exit 1 ;; \
    esac) && \
    curl -sSL "https://storage.googleapis.com/cloud-sdk-release/google-cloud-sdk-${APP_VERSION}-linux-${ARCH}.tar.gz" -o "gcloud.tar.gz" && \
    tar -xf gcloud.tar.gz

# Install gcloud with privacy flags in builder stage to avoid permission issues
RUN /tmp/google-cloud-sdk/install.sh \
    --usage-reporting false \
    --command-completion false \
    --path-update false \
    --quiet

# Final stage
FROM titaniumlabs/rockylinux:10

ARG APP_VERSION="537.0.0"

LABEL org.opencontainers.image.base.name="titaniumlabs/rockylinux:10" \
      org.opencontainers.image.description="gcloud packaged by Titanium Labs" \
      org.opencontainers.image.documentation="https://github.com/titaniumlabsoss/hardened-images/blob/main/images/gcloud/README.md" \
      org.opencontainers.image.source="https://github.com/titaniumlabs/hardened-images/tree/main/images/gcloud" \
      org.opencontainers.image.title="gcloud" \
      org.opencontainers.image.vendor="Titanium Labs" \
      org.opencontainers.image.version="$APP_VERSION"

# Switch to root to copy complete Python installation
USER root

# Copy complete Python installation and essential libraries from builder stage
COPY --from=builder /usr/bin/python3* /usr/bin/
COPY --from=builder /usr/lib64/python3.12/ /usr/lib64/python3.12/
COPY --from=builder /usr/lib64/libpython3* /usr/lib64/
COPY --from=builder /usr/lib64/libsqlite3* /usr/lib64/
COPY --from=builder /usr/lib64/libz.so* /usr/lib64/
COPY --from=builder /usr/lib64/libcrypto.so* /usr/lib64/
COPY --from=builder /usr/lib64/libssl.so* /usr/lib64/
COPY --from=builder /usr/lib64/libffi.so* /usr/lib64/
COPY --from=builder /usr/lib64/libexpat.so* /usr/lib64/
COPY --from=builder /usr/lib64/libuuid.so* /usr/lib64/
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    chmod +x /usr/bin/python3* && \
    ldconfig

# Copy installed gcloud SDK from builder stage
COPY --from=builder /tmp/google-cloud-sdk /opt/google-cloud-sdk

# Add gcloud to PATH and create symlinks
RUN ln -sf /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud && \
    ln -sf /opt/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil && \
    ln -sf /opt/google-cloud-sdk/bin/bq /usr/local/bin/bq

# Verify the binary works
RUN gcloud version

# Switch back to non-root user for runtime security
USER 1001:1001

# Default command
CMD ["gcloud"]
