# Security Scanning Architecture

## Overview

Our security scanning is implemented at multiple stages to ensure comprehensive vulnerability detection before images are published.

## Scanning Stages

### 1. Pre-Push Scanning (build-images.yml)

**When:** During image build, before pushing to registry
**What:** Quick Trivy scan for CRITICAL and HIGH vulnerabilities
**Action:** Blocks push if vulnerabilities found

```yaml
Build Image (amd64) → Trivy Scan → Pass? → Push Multi-Platform Image
                                     ↓
                                    Fail → Block Push
```

### 2. Comprehensive Scanning (security-scan.yml)

**When:** 
- After successful build workflow completion
- On pull requests
- Daily scheduled scans
- Manual trigger

**Scanners:**
- **Trivy**: Full vulnerability scan (OS, libraries, secrets, misconfigurations)
- **Snyk**: Dependency analysis and vulnerability database
- **Grype**: Additional vulnerability detection
- **Hadolint**: Dockerfile best practices
- **Syft**: SBOM generation (SPDX and CycloneDX)

### 3. Continuous Monitoring

**When:** Daily at 2 AM UTC
**What:** Re-scan all published images for new vulnerabilities
**Action:** Create issues/alerts for new vulnerabilities

## Workflow Integration

```mermaid
graph TD
    A[Pull Request] --> B[Build Images]
    B --> C[Pre-Push Trivy Scan]
    C --> D{Pass?}
    D -->|Yes| E[Build Multi-Platform]
    D -->|No| F[Block & Report]
    E --> G[Comprehensive Security Scan]
    
    H[Merge to Main] --> I[Build Images]
    I --> J[Pre-Push Trivy Scan]
    J --> K{Pass?}
    K -->|Yes| L[Push to Registry]
    K -->|No| M[Block Push]
    L --> N[Comprehensive Security Scan]
    
    O[Daily Schedule] --> P[Security Scan All Images]
```

## Security Gates

### Build Pipeline Gates

1. **Dockerfile Linting**: Hadolint checks during build
2. **Pre-Push Scan**: Trivy blocks HIGH/CRITICAL before registry push
3. **SARIF Upload**: All results to GitHub Security tab

### Pull Request Gates

- Security scan results posted as PR comments
- SARIF results visible in Security tab
- Build blocked if critical vulnerabilities found

### Production Gates

- Only images passing all scans reach Docker Hub
- Daily monitoring for new vulnerabilities
- Automated SBOM generation for compliance

## Configuration

### Severity Thresholds

- **Block Build**: CRITICAL, HIGH
- **Warning**: MEDIUM
- **Info Only**: LOW, UNKNOWN

### Scanner Settings

**Trivy (Pre-Push)**

```yaml
severity: CRITICAL,HIGH
exit-code: 1  # Fail on findings
format: sarif
```

**Trivy (Comprehensive)**

```yaml
severity: CRITICAL,HIGH,MEDIUM,LOW
vuln-type: os,library,secret,config
format: sarif,json,table
```

**Hadolint**

```yaml
ignore:
  - DL3008  # apt-get version pinning
  - DL3009  # apt-get lists deletion
format: sarif
```

## SBOM Generation

Each image build generates:
- SPDX JSON format SBOM
- CycloneDX JSON format SBOM
- 30-day artifact retention
- Future: Attestation signing with Cosign

## Reporting

### GitHub Integration

- SARIF results in Security tab
- PR comments with scan summaries
- Workflow artifacts for detailed reports

### Monitoring

- Daily vulnerability scans
- Security badge updates

## Manual Scanning

### Scan Specific Image

```bash
# Trigger workflow manually
gh workflow run security-scan.yml -f image=titaniumlabs/alpine:3.22.1
```

### Local Scanning

```bash
# Using Trivy locally
trivy image titaniumlabs/alpine:3.22.1

# Using Grype locally
grype titaniumlabs/alpine:3.22.1

# Generate SBOM locally
syft titaniumlabs/alpine:3.22.1 -o spdx-json
```

## Security Exceptions

Managed in `.github/security-policy.yml`:
- Accepted vulnerabilities with justification
- Expiration dates for exceptions
- Allowed packages despite vulnerabilities

## Future Enhancements

- [ ] Cosign signing for images
- [ ] In-toto attestations
- [ ] Automated issue creation for vulnerabilities
- [ ] Slack/email notifications
- [ ] Dependency update automation
- [ ] Security scorecard integration
