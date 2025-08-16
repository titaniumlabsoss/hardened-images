<!-- markdownlint-disable MD041 -->
<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

<p align="center">
    <a href="https://github.com/titaniumlabsoss/hardened-images/actions/workflows/build-images.yml"><img src="https://github.com/titaniumlabsoss/hardened-images/actions/workflows/build-images.yml/badge.svg" /></a>
    <a href="https://hub.docker.com/u/titaniumlabs"><img src="https://badgen.net/docker/pulls/titaniumlabs/ubuntu?icon=docker" /></a>
    <a href="https://github.com/titaniumlabsoss/hardened-images/blob/main/LICENSE"><img src="https://badgen.net/badge/license/Apache-2.0/blue" /></a>
</p>

# Ubuntu Hardened Images

Security-hardened Ubuntu container images implementing DISA STIG controls, CIS benchmarks, and enterprise security best practices.

## Image Metadata

```yaml
image_name: "ubuntu"
docker_repo: "titaniumlabs"
architectures: "amd64, arm64"
description: "Ubuntu is a Debian-based Linux operating system that runs from the desktop to the cloud, to all your internet connected things. This hardened version implements DISA STIG controls, CIS benchmarks, and security best practices for a minimal attack surface and maximum security posture."

# Security features across all Ubuntu versions
security_features:
  - "DISA STIG V-270724: Non-root user execution (UID 1001)"
  - "Minimal package installation with only essential components"
  - "Hardened kernel parameters and system configuration"
  - "Disabled unnecessary services and network ports"
  - "Enhanced file permissions and access controls"
  - "FIPS-compliant cryptographic modules where applicable"
  - "Comprehensive audit logging configuration"
  - "Network security hardening and firewall rules"
  - "Automated vulnerability scanning and patching"
  - "Read-only filesystem where applicable"
  - "Secure defaults for all system configurations"

# Supported tags for all Ubuntu versions
supported_tags:
  - "24.04, latest - [Dockerfile](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/base_images/ubuntu/24.04/Dockerfile)"

# All available variants across Ubuntu versions
variants:
  - tag: "latest"
    description: "Points to the latest LTS version (24.04) - recommended for production use"
  - tag: "24.04"
    description: "Ubuntu 24.04 LTS (Noble Numbat) with full DISA STIG hardening"

# Usage examples for different versions
versions:
  - tag: "24.04"
    comment: "Latest LTS version (recommended)"

# Build paths for different versions
image_path: "base_images/ubuntu"
```

## Available Versions

### Ubuntu 24.04 LTS (Noble Numbat)
- **Path**: `images/base_images/ubuntu/24.04/`
- **Tags**: `24.04`, `latest`
- **Status**: Current LTS (recommended)
- **Support**: Until April 2029

## Quick Start

```bash
# Use latest LTS version (24.04)
docker pull titaniumlabs/ubuntu:latest
docker run --rm -it titaniumlabs/ubuntu:latest

# Use specific LTS version
docker pull titaniumlabs/ubuntu:24.04
docker run --rm -it titaniumlabs/ubuntu:24.04

# Use as base image
FROM titaniumlabs/ubuntu:24.04
# Your application here
```

## Security Validation

All Ubuntu variants include security validation tools:

```bash
# Run STIG compliance validation
docker run --rm titaniumlabs/ubuntu:latest /opt/stig-validation.sh

# View security report
docker run --rm titaniumlabs/ubuntu:latest cat /opt/security-report.json

# Check hardening status
docker run --rm titaniumlabs/ubuntu:latest id
# Should show: uid=1001(appuser) gid=1001(appuser)
```

## What's Hardened

### System Security
- Non-root execution (UID/GID 1001)
- Minimal package installation
- Disabled unnecessary services
- Secure file permissions
- Hardened kernel parameters

### Network Security
- Firewall rules configured
- Network services disabled
- Secure SSH configuration
- IPv6 disabled by default

### Audit & Logging
- Comprehensive audit rules
- Security event logging
- File integrity monitoring
- Access control logging

### Cryptography
- FIPS-compliant algorithms
- Strong encryption defaults
- Secure key management
- TLS/SSL hardening

## Compliance Standards

All Ubuntu hardened images meet:

- **DISA STIG**: Department of Defense Security Technical Implementation Guide
- **CIS Benchmarks**: Center for Internet Security best practices
- **NIST 800-53**: National Institute of Standards cybersecurity framework
- **NIST 800-190**: Container security guidelines
- **FIPS 140-2**: Federal cryptographic standards

## Building Locally

```bash
# Clone repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images
./scripts/build-images.sh --filter ubuntu

# Run security validation
docker run --rm titaniumlabs/ubuntu:24.04 /opt/stig-validation.sh
```

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Security

If you discover a security vulnerability **do not open a public issue**, instead send an email to `security@titaniumlabs.io`

---

<p align="center">
    <strong>Titanium Labs</strong> - Forging the future of cybersecurity through open-source innovation.
</p>
