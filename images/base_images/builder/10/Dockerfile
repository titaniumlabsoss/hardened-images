# Rocky Linux Builder Image
# Less-hardened Rocky Linux with essential build tools for compiling software

FROM rockylinux/rockylinux:10-minimal

LABEL org.opencontainers.image.base.name="rockylinux/rockylinux:10-minimal" \
      org.opencontainers.image.description="Rocky Linux Builder with development tools packaged by Titanium Labs" \
      org.opencontainers.image.documentation="https://github.com/titaniumlabsoss/hardened-images/blob/main/images/base_images/builder/README.md" \
      org.opencontainers.image.source="https://github.com/titaniumlabsoss/hardened-images/tree/main/images/base_images/builder" \
      org.opencontainers.image.title="builder" \
      org.opencontainers.image.vendor="Titanium Labs" \
      org.opencontainers.image.version="10"

# Install essential build tools and development packages
RUN microdnf update -y && \
    microdnf install -y \
        # Core build tools
        gcc \
        gcc-c++ \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkgconfig \
        # Essential libraries and headers
        glibc-devel \
        libgcc \
        libstdc++-devel \
        kernel-headers \
        # Compression and archive tools
        tar \
        gzip \
        bzip2 \
        xz \
        unzip \
        # Network and download tools
        curl \
        wget \
        # Version control
        git \
        # Text processing
        sed \
        grep \
        gawk \
        # File utilities
        findutils \
        diffutils \
        patch \
        # Additional useful tools
        which \
        file \
        && microdnf clean all \
    && rm -rf /var/cache/dnf

# Set environment variables for build
ENV CC=gcc \
    CXX=g++ \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Create build directory
WORKDIR /build

# Default command
CMD ["/bin/bash"]
