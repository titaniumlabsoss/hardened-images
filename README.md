# Titanium Labs' Hardened Images

Production-ready, security-hardened container images. Minimal attack surface, automated security updates, compliance-ready.

## Why Hardened Images?

Traditional container images often prioritize convenience over security. Our hardened images are built with:

- **Minimal attack surface** - Only essential packages and dependencies
- **Non-root execution** - All processes run as unprivileged users
- **Read-only filesystems** - Immutable runtime environments where possible
- **Regular security updates** - Automated vulnerability scanning and patching
- **Compliance ready** - Built with SOC2, HIPAA, and enterprise standards in mind

## Available Images

| Image | Description | Pulls |
|-------|-------------|-------|
| `N/A` | N/A | ![Docker Pulls](https:img.shields.io/docker/pulls/titaniumlabsoss/IMAGE)

*More images coming soon...*

## Security Features

### **Hardening Applied**
- Minimal base images (Alpine/Ubuntu minimal)
- Non-root user execution
- Removed unnecessary packages and utilities
- Security-focused file permissions
- Read-only root filesystem where applicable

### **Continuous Monitoring**
- Daily vulnerability scans
- Automated security updates
- SBOM (Software Bill of Materials) generation
- CVE tracking and remediation

### **Compliance**
- CIS Benchmark compliance
- NIST guidelines implementation
- Documentation for SOC2/HIPAA environments

## How We Keep Images Hardened

### Secure Build Process

Our hardening methodology follows industry best practices:

1. **Minimal Base Images**
   - Start with Alpine Linux or Ubuntu minimal
   - Remove package managers and shells when possible
   - Only install absolutely necessary dependencies

2. **Security-First Configuration**
   ```dockerfile
   # Simple example or a hardening practice
   RUN addgroup -g 1001 appuser && \
       adduser -u 1001 -G appuser -s /bin/sh -D appuser
   USER 1001
   WORKDIR /app
   # Read-only filesystem
   VOLUME ["/tmp", "/var/log"]
   ```

3. **Automated Security Pipeline**
   - **Vulnerability Scanning**: Trivy scans before every release
   - **Zero-CVE Policy**: Block releases with HIGH/CRITICAL vulnerabilities
   - **SBOM Generation**: Full software bill of materials for compliance

### Continuous Hardening

- **Weekly Security Reviews**: Manual assessment of new vulnerabilities
- **Upstream Monitoring**: Track security advisories from official images
- **Community Feedback**: Security issues reported via GitHub Security tab
- **Automated Testing**: Security configurations tested in CI/CD pipeline

### Transparency & Verification

Every image includes:
- **Security Report**: Vulnerability scan results published
- **Build Logs**: Complete build process documented
- **SBOM**: Machine-readable software inventory
- **Signature**: Images signed with Cosign for supply chain security

### Security Standards

Our images are hardened against:
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [NIST Container Security Guidelines](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [OWASP Container Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- Industry-specific compliance (HIPAA, SOC2, PCI-DSS considerations)

## Image Variants

Each image provides multiple variants:

- `latest` - Latest stable hardened version on Ubuntu minimal
- `[version]` - Specific application version on Ubuntu minimal (e.g., `postgres:16`)
- `[version]-alpine` - Alpine-based minimal variant

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Building Images Locally

```bash
# Clone the repository
git clone git@github.com:titaniumlabsoss/hardened-images.git
cd hardened-images

# Build an image
cd images/APP/VERSION/OS
docker build -t titaniumlabs/APP .
```

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Security

If you discover a security vulnerability **do not open a public issue**, instead send an email to `security@titaniumlabs.io`

---

**Titanium Labs** - Forging the future of cybersecurity through open-source innovation.

