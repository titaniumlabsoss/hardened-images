<!-- markdownlint-disable MD041 -->
<p align="center">
  <img width="360" src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

<p align="center">
  <a href="https://github.com/titaniumlabsoss/hardened-images"><img src="https://badgen.net/github/stars/titaniumlabsoss/hardened-images?icon=github" /></a>
  <a href="https://github.com/titaniumlabsoss/hardened-images"><img src="https://badgen.net/github/forks/titaniumlabsoss/hardened-images?icon=github" /></a>
  <a href="https://github.com/titaniumlabsoss/hardened-images/actions/workflows/build-images.yml"><img src="https://github.com/titaniumlabsoss/hardened-images/actions/workflows/build-images.yml/badge.svg" /></a>
  <a href="https://github.com/titaniumlabsoss/hardened-images/actions/workflows/daily-security-scan.yml"><img src="https://img.shields.io/github/actions/workflow/status/titaniumlabsoss/hardened-images/daily-security-scan.yml?label=security%20scan&logo=security" /></a>
  <a href="https://github.com/titaniumlabsoss/hardened-images/security"><img src="https://img.shields.io/github/issues-search/titaniumlabsoss/hardened-images?query=is%3Aopen%20is%3Aissue%20label%3Asecurity&label=security%20issues" /></a>
  <a href="https://hub.docker.com/u/titaniumlabs"><img src="https://badgen.net/docker/pulls/titaniumlabs/rockylinux?icon=docker" /></a>
  <a href="https://github.com/titaniumlabsoss/hardened-images/blob/main/LICENSE"><img src="https://badgen.net/badge/license/Apache-2.0/blue" /></a>
</p>

# Titanium Labs - Hardened Images

**Production-grade, security-hardened container images**. Designed with a *minimal attack surface*, automated remediation, and compliance at the core.

Built for enterprises where trust, discipline, and resilience are non-negotiable.

## Why Hardened Images?

Most container images prioritize convenience. We prioritize **security and discipline**.

Every Titanium Labs hardened image is crafted with:

- **Minimal footprint** — only essential packages
- **Non-root execution** — processes run unprivileged
- **Immutable runtime** — read-only filesystems where possible
- **Automated remediation** — daily scanning and patching
- **Compliance-ready** — SOC2, HIPAA, CIS, NIST and DISA STIG benchmarks

## Security Architecture

### Hardening at the Core
- Rocky Linux hardened bases
- Reduced system utilities
- Security-focused permissions
- Non-root defaults
- Read-only root filesystem

### Continuous Monitoring
- Daily scans with **Trivy, Snyk, Grype**
- SBOM generation (SPDX, CycloneDX)
- CVE tracking and automated remediation
- Zero-CVE release policy

### Compliance
- CIS Docker Benchmark
- NIST SP 800-190
- DISA STIG
- SOC2/HIPAA documentation support

## Methodology

We follow a **secure-by-design** philosophy, applied with precision:

- Pre-push scans prevent registry contamination
- GitHub Security integration via SARIF
- In-toto attestations for supply chain integrity

## Getting Started

The simplest way is to pull from our Docker Hub Registry:

```bash
docker pull titaniumlabs/APP
```

Use tags for precision:

```bash
docker pull titaniumlabs/APP:[VERSION]
```

Variants
- latest — latest stable hardened build
- [version] — specific release (e.g., 10)
- [version]-YYYYMMDD — date-stamped release

## Contributing

We welcome contributions with the same discipline we apply to security. Please read the Contributing Guide.

```bash
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images/images/APP/VERSION/OS
docker build -t titaniumlabs/APP .
```

## Security Disclosure

If you discover a vulnerability, do not open a public issue. Please email us at: `security@titaniumlabs.io`

<p align="center">
  <strong>Titanium Labs</strong> · Forging the future of cybersecurity with open-source precision.
</p>
