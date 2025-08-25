<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

# Rocky Linux Hardened Images

Security-hardened Rocky Linux container images implementing DISA STIG controls, CIS benchmarks, and enterprise security best practices for mission-critical environments.

## Available Versions

- [`10`, `latest`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/base_images/rockylinux/10/Dockerfile)

## Quick Start

```bash
# Use latest version (10.0)
docker pull titaniumlabs/rockylinux:latest
docker run --rm -it titaniumlabs/rockylinux:latest

# Use specific version
docker pull titaniumlabs/rockylinux:10
docker run --rm -it titaniumlabs/rockylinux:10

# Use as base image
FROM titaniumlabs/rockylinux:10
# Your application here
```

## What's Hardened

### System Security

- Non-root execution (UID/GID 1001)
- Minimal package installation (UBI micro-based)
- Disabled unnecessary services
- Secure file permissions (restrictive umask 077)
- Hardened kernel parameters
- SELinux enforcement ready

### Network Security

- Firewall rules configured (firewalld)
- Network services disabled
- FIPS-compliant SSH configuration
- IPv6 disabled by default
- TCP hardening and SYN cookies
- Secure host key generation

### Audit & Logging

- Comprehensive audit rules (150+ STIG controls)
- Security event logging (rsyslog)
- File integrity monitoring (AIDE)
- Access control logging
- Centralized log forwarding ready

### Authentication & Access

- Strong password policies (15+ chars, complexity)
- Account lockout protection (3 attempts)
- PAM hardening with faillock
- Sudo restrictions and logging
- Session timeout (15 minutes)
- Root account disabled

### Cryptography

- FIPS 140-2 compliant algorithms
- Strong encryption defaults
- Secure key management
- TLS 1.2+ enforcement
- SHA-256/SHA-512 hashing only

## Compliance Standards

All Rocky Linux hardened images meet:

- **RHEL 9 DISA STIG**: Compatible with RHEL 9 Security Technical Implementation Guide
- **CIS Benchmarks**: Center for Internet Security Rocky Linux benchmarks
- **NIST 800-53**: National Institute of Standards cybersecurity framework
- **NIST 800-190**: Container security guidelines
- **FIPS 140-2**: Federal cryptographic standards
- **Common Criteria**: Enterprise security requirements

### STIG Controls Implemented

### Category I (High Severity)

- V-257777: Operating system version compliance
- V-257896: Ctrl-Alt-Delete key sequence disabled
- V-257901: Non-privileged user execution
- V-257898-V-257910: Password policy enforcement
- V-257825-V-257835: Network security controls

### Category II (Medium Severity)

- V-257777-V-257787: System configuration hardening
- V-257788-V-257820: Comprehensive audit logging
- V-257860-V-257869: Cryptographic controls
- V-257848-V-257859: File permission security

### Category III (Low Severity)

- V-257870-V-257885: System cleanup and optimization
- Additional hardening beyond STIG requirements
- Container-specific security adaptations

## Enterprise Features

### FIPS Compliance

- FIPS 140-2 crypto policies enabled
- FIPS-approved SSH algorithms
- Strong TLS/SSL configuration
- Validated cryptographic modules

### Audit Trail

- 150+ audit rules covering all STIG requirements
- Real-time security event monitoring
- File integrity monitoring with AIDE
- Comprehensive access logging

### Access Control

- Role-based access control ready
- Strong authentication policies
- Session management and timeouts
- Privilege escalation controls

## Building Locally

```bash
# Clone repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images
./scripts/build-images.sh --filter rocky

# Run security validation
docker run --rm -u root titaniumlabs/rockylinux:10 /opt/compliance-check.sh
```

## Enterprise Integration

### Container Orchestration

```yaml
# Kubernetes deployment example
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
      containers:
      - name: app
        image: titaniumlabs/rockylinux:10
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
```

### Docker Compose

```yaml
version: '3.8'
services:
  secure-service:
    image: titaniumlabs/rockylinux:10
    security_opt:
      - no-new-privileges:true
    read_only: true
    user: "1001:1001"
```

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Security

If you discover a security vulnerability **do not open a public issue**, instead send an email to `security@titaniumlabs.io`

## Support

For enterprise support, training, and custom hardening requirements, contact `contact@titaniumlabs.io`

---

<p align="center">
    <strong>Titanium Labs</strong> - Forging the future of cybersecurity through open-source innovation.
</p>
