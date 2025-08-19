<!-- markdownlint-disable MD041 -->
<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

# Alpine Linux Hardened Images

Ultra-lightweight security-hardened Alpine Linux container images implementing STIG-equivalent controls, CIS benchmarks, and enterprise security best practices for cloud-native environments.

## Available Versions

- [`3.22.1`, `latest`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/base_images/alpine/3.22.1/Dockerfile)

## Quick Start

```bash
# Use latest version
docker pull titaniumlabs/alpine:latest
docker run --rm -it titaniumlabs/alpine:latest

# Use specific version
docker pull titaniumlabs/alpine:3.22.1
docker run --rm -it titaniumlabs/alpine:3.22.1

# Use as base image
FROM titaniumlabs/alpine:3.22.1
# Your application here
```

## Security Validation

All Alpine Linux variants include comprehensive security validation tools:

```bash
# Run compliance validation
docker run --rm titaniumlabs/alpine:latest /opt/compliance-check.sh

# Check hardening status
docker run --rm titaniumlabs/alpine:latest id
# Should show: uid=1001(appuser) gid=1001(appuser)

# Verify security configurations
docker run --rm titaniumlabs/alpine:latest cat /etc/hardened

# Check disabled modules
docker run --rm titaniumlabs/alpine:latest cat /etc/modprobe.d/stig-blacklist.conf
```

## What's Hardened

### System Security

- Non-root execution (UID/GID 1001)
- Minimal package installation (~15-20MB total)
- Disabled unnecessary services and modules
- Secure file permissions (restrictive umask 077)
- Hardened kernel parameters
- Read-only root filesystem ready

### Network Security

- IPv4 forwarding disabled
- IPv6 completely disabled
- ICMP redirects blocked
- Source routing disabled
- TCP SYN cookies enabled
- Strong SSH configuration (when installed)
- Security banners configured
- Network stack hardening

### Kernel Modules

- USB storage disabled
- Wireless modules blacklisted
- Bluetooth disabled
- Unnecessary filesystems blocked
- Network protocols (DCCP, SCTP, RDS, TIPC) disabled
- Module loading restrictions

### Authentication & Access

- Root account locked
- Strong password policies (15+ chars, complexity)
- Account lockout protection (3 attempts)
- Session timeout (900 seconds)
- PAM hardening (when available)
- Restricted su command access

### Cryptography

- Strong SSL/TLS configuration
- SSH host keys (RSA 4096, ECDSA 521, Ed25519)
- TLS 1.2+ enforcement
- Weak algorithms disabled
- Strong cipher suites only

### Audit & Logging

- Comprehensive audit rules (when audit installed)
- System call auditing
- File modification tracking
- Authentication event logging
- Log rotation configured
- Centralized logging ready

## Compliance Standards

All Alpine Linux hardened images meet:

- **STIG-Equivalent**: Controls adapted from RHEL 9 DISA STIG
- **CIS Benchmarks**: Center for Internet Security Alpine Linux benchmarks
- **NIST 800-53**: National Institute of Standards cybersecurity framework
- **NIST 800-190**: Container security guidelines
- **Cloud-Native Security**: Optimized for Kubernetes and container platforms

### Security Controls Implemented

#### Critical Security (High Priority)

- Operating system hardening
- Non-privileged user execution
- Password policy enforcement
- Network security controls
- Kernel module restrictions

#### System Hardening (Medium Priority)

- Filesystem permission security
- Audit logging configuration
- Cryptographic controls
- Session management
- Access control lists

#### Additional Hardening (Low Priority)

- System cleanup and optimization
- Documentation removal
- Package minimization
- Attack surface reduction

## Ultra-Lightweight Profile

Despite comprehensive hardening:

- **Base Alpine**: ~7MB
- **Hardened Image**: ~15-20MB
- **Memory Usage**: <10MB idle
- **Startup Time**: <1 second

Perfect for:
- Microservices
- Serverless functions
- Edge computing
- IoT deployments
- CI/CD pipelines

## Building Locally

```bash
# Clone repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images

# Build Alpine 3.22.1
cd images/base_images/alpine/3.22.1
docker build -t titaniumlabs/alpine:3.22.1 .

# Run security validation
docker run --rm titaniumlabs/alpine:3.22.1 /opt/compliance-check.sh
```

## Cloud-Native Integration

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-alpine-app
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: app
        image: titaniumlabs/alpine:3.22.1
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
        resources:
          limits:
            memory: "64Mi"
            cpu: "100m"
          requests:
            memory: "32Mi"
            cpu: "50m"
```

### Docker Compose

```yaml
version: '3.8'
services:
  alpine-service:
    image: titaniumlabs/alpine:3.22.1
    security_opt:
      - no-new-privileges:true
      - seccomp:default
    read_only: true
    user: "1001:1001"
    tmpfs:
      - /tmp:noexec,nosuid,nodev
      - /var/tmp:noexec,nosuid,nodev
```

### Docker Run with Security Options

```bash
docker run --rm -it \
  --security-opt no-new-privileges \
  --security-opt seccomp=default \
  --cap-drop ALL \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,nodev \
  --tmpfs /var/tmp:noexec,nosuid,nodev \
  titaniumlabs/alpine:3.22.1
```

## Hardening Scripts

The modular hardening approach includes:

1. **01-base-setup.sh** - Base system configuration
2. **02-authentication.sh** - Authentication controls
3. **03-kernel-modules.sh** - Module restrictions
4. **04-filesystem-security.sh** - Filesystem hardening
5. **05-network-security.sh** - Network stack security
6. **06-file-permissions.sh** - Permission enforcement
7. **07-audit-logging.sh** - Audit configuration
8. **08-crypto-hardening.sh** - Cryptographic settings
9. **99-cleanup.sh** - Final optimization
10. **compliance-check.sh** - Security validation

## Use Cases

### Microservices
```dockerfile
FROM titaniumlabs/alpine:3.22.1
RUN apk add --no-cache nodejs
COPY --chown=1001:1001 app/ /app
USER 1001
CMD ["node", "/app/server.js"]
```

### CI/CD Pipeline
```dockerfile
FROM titaniumlabs/alpine:3.22.1
RUN apk add --no-cache git curl
USER 1001
ENTRYPOINT ["/bin/sh"]
```

### Static Binary Deployment
```dockerfile
FROM titaniumlabs/alpine:3.22.1 AS runtime
COPY --from=builder /app/binary /usr/local/bin/
USER 1001
ENTRYPOINT ["/usr/local/bin/binary"]
```

## Limitations

Some controls adapted for Alpine Linux:

- No SELinux (uses seccomp/capabilities instead)
- Limited PAM support (basic implementation)
- Some audit features require privileged mode
- FIPS mode requires kernel support
- Systemd-specific controls not applicable

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
