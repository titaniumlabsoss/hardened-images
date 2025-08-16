<!-- markdownlint-disable MD041 -->
<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

# Ubuntu Hardened Images

Security-hardened Ubuntu container images implementing DISA STIG controls, CIS benchmarks, and enterprise security best practices.

## Available Versions

- [`24.04`, `latest`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/base_images/ubuntu/24.04/Dockerfile)

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
