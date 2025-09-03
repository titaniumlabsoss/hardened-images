# Kubectl Hardened Image
# Security-hardened kubectl built for multiple architectures

FROM titaniumlabs/builder:10 AS builder

# Use APP_VERSION to determine the binary's version
ARG APP_VERSION="v1.33.3"

# Use TARGETARCH to determine the correct binary
ARG TARGETARCH

# Download kubectl binary
WORKDIR /tmp
RUN curl -LO "https://dl.k8s.io/release/${APP_VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x kubectl

# Validate the kubectl binary against the checksum
RUN curl -LO "https://dl.k8s.io/release/${APP_VERSION}/bin/linux/${TARGETARCH}/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install Kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

# Final stage
FROM titaniumlabs/rockylinux:10

ARG APP_VERSION="v1.33.3"

LABEL org.opencontainers.image.base.name="titaniumlabs/rockylinux:10" \
      org.opencontainers.image.description="kubectl packaged by Titanium Labs" \
      org.opencontainers.image.documentation="https://github.com/titaniumlabsoss/hardened-images/blob/main/images/kubectl/README.md" \
      org.opencontainers.image.source="https://github.com/titaniumlabsoss/hardened-images/tree/main/images/kubectl" \
      org.opencontainers.image.title="kubectl" \
      org.opencontainers.image.vendor="Titanium Labs" \
      org.opencontainers.image.version="$APP_VERSION"

# Copy kubectl and kustomize from builder
COPY --from=builder /tmp/kubectl /usr/local/bin/kubectl
COPY --from=builder /tmp/kustomize /usr/local/bin/kustomize

# Verify the binary works
RUN kubectl version --client
RUN kustomize version

# Default command
CMD ["kubectl"]
