<!-- markdownlint-disable MD041 -->
<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

<p align="center">
    <a href="https://github.com/titaniumlabsoss/hardened-images"><img src="https://badgen.net/github/stars/titaniumlabsoss/hardened-images?icon=github" /></a>
    <a href="https://github.com/titaniumlabsoss/hardened-images"><img src="https://badgen.net/github/forks/titaniumlabsoss/hardened-images?icon=github" /></a>
    <a href="https://github.com/titaniumlabsoss/hardened-images/actions/workflows/build-images.yml"><img src="https://github.com/titaniumlabsoss/hardened-images/actions/workflows/build-images.yml/badge.svg" /></a>
    <a href="https://github.com/titaniumlabsoss/hardened-images/security"><img src="https://img.shields.io/github/issues-search/titaniumlabsoss/hardened-images?query=is%3Aopen%20is%3Aissue%20label%3Asecurity&label=security%20issues" /></a>
    <a href="https://hub.docker.com/u/titaniumlabs"><img src="https://badgen.net/docker/pulls/titaniumlabs/rockylinux?icon=docker" /></a>
    <a href="https://github.com/titaniumlabsoss/hardened-images/blob/main/LICENSE"><img src="https://badgen.net/badge/license/Apache-2.0/blue" /></a>
</p>

# Titanium Labs' Hardened Images

Production-ready, security-hardened container images. Minimal attack surface, automated security updates, compliance-ready.

## Why Hardened Images?

Traditional container images often prioritize convenience over security. Our hardened images are built with:

- **Minimal attack surface** - Only essential packages and dependencies
- **Non-root execution** - All processes run as unprivileged users
- **Read-only filesystems** - Immutable runtime environments where possible
- **Regular security updates** - Automated vulnerability scanning and patching
- **Compliance ready** - Built with SOC2, HIPAA, and enterprise standards in mind

## Security Features

### **Hardening Applied**

- Minimal hardened base images (Alpine and Rocky Linux)
- Non-root user execution
- Removed unnecessary packages and utilities
- Security-focused file permissions
- Read-only root filesystem where applicable

### **Continuous Monitoring**

- Daily vulnerability scans with Trivy
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

   - Start with Alpine Linux or Rocky Linux
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

Our comprehensive security scanning pipeline includes multiple industry-leading tools:

- **Multi-Scanner Approach**:
  - **Trivy**: Primary vulnerability scanner for OS and library vulnerabilities
  - **Snyk**: Dependency analysis and known vulnerability database
  - **Grype**: Additional vulnerability detection with Anchore's database
  - **Hadolint**: Dockerfile best practices and security linting

- **Security Controls**:
  - **Zero-CVE Policy**: Block releases with HIGH/CRITICAL vulnerabilities
  - **SARIF Integration**: All results uploaded to GitHub Security tab
  - **Pre-push Scanning**: Images scanned before registry push
  - **Daily Scheduled Scans**: Continuous monitoring for new vulnerabilities

- **Compliance & Reporting**:
  - **SBOM Generation**: Automatic SPDX and CycloneDX format SBOMs with Syft
  - **Security Attestations**: In-toto attestations for supply chain security
  - **Artifact Storage**: 30-day retention of all security reports
  - **Documentation Sync**: README files automatically synchronized to DockerHub

### Continuous Hardening

- **Weekly Security Reviews**: Manual assessment of new vulnerabilities
- **Upstream Monitoring**: Track security advisories from official images
- **Community Feedback**: Security issues reported via GitHub Security tab
- **Automated Testing**: Security configurations tested in CI/CD pipeline
- **Auto-Documentation**: DockerHub repository descriptions updated when README files change

### Transparency & Verification

Every image includes:

- **Security Report**: Vulnerability scan results published
- **Build Logs**: Complete build process documented
- **SBOM**: Machine-readable software inventory
- **Signature**: Images signed with Cosign for supply chain security

### Security Standards

Our images are hardened against:

- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [DISA STIG](https://www.cyber.mil/stigs)
- [NIST Container Security Guidelines](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [OWASP Container Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

## Get an Image

The recommended way to get any of the Titanium Labs Hardened Images is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/u/titaniumlabs/).

```bash
docker pull titaniumlabs/APP
```

To use a specific version, you can pull a versioned tag:

```bash
docker pull titaniumlabs/APP:[TAG]
```

## Image Variants

Each image provides multiple variants:

- `latest` - Latest stable hardened version
- `[version]` - Specific application version (e.g., `24.04`)
- `[version]-minimal` - Alpine-based minimal variant
- `[version]-YYYYMMDD` - Version with build date
- `[version]-minimal-YYYYMMDD` - Minimal version with build date

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Building Images Locally

```bash
# Clone the repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images

# Build an image
cd images/APP/VERSION/OS
docker build -t titaniumlabs/APP .
```

> [!TIP]
> Remember to replace the `APP`, `VERSION`, and `OS` placeholders in the example command above with the correct values.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Security

If you discover a security vulnerability **do not open a public issue**, instead send an email to `security@titaniumlabs.io`

---

<p align="center">
    <strong>Titanium Labs</strong> - Forging the future of cybersecurity through open-source innovation.
</p>
