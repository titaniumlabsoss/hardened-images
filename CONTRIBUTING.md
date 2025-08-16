# Contributing Guidelines

Thank you for your interest in contributing to Titanium Labs' Hardened Images project! We welcome contributions from the community to help build more secure container images.

## Ways to Contribute

- **New hardened images** for popular applications
- **Security improvements** to existing images
- **Documentation** enhancements
- **Bug reports** and vulnerability disclosures
- **Feature requests** and discussions
- **Testing** and validation of images

## Getting Started

### Prerequisites

- Docker or Podman installed
- Git for version control
- [Trivy](https://trivy.dev/) for security scanning
- Basic understanding of container security principles

### Development Setup

1. **Fork and clone the repository**
   
```bash
git clone git@github.com:titaniumlabsoss/hardened-images.git
cd hardened-image
```

2. **Create a feature branch**

```bash
git checkout -b feature/add-mongodb-image
```

3. **Set up development tools**

```bash
# Install Trivy for security scanning
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Cosign for image signing (optional)
go install github.com/sigstore/cosign/cmd/cosign@latest
```

## Adding New Images

### Directory Structure

Each image should follow this structure:

```
images/
├── postgres/
│   ├── 16/
│   │   ├── alpine/
│   │   │   ├── Dockerfile
│   │   │   └── docker-entrypoint.sh
│   │   └── ubuntu/
│   │       ├── Dockerfile
│   │       └── docker-entrypoint.sh
│   ├── 15/
│   │   ├── alpine/
│   │   └── ubuntu/
│   ├── README.md
│   ├── docker-compose.example.yml
│   ├── security/
│   │   ├── hardening-checklist.md
│   │   └── cis-benchmark.md
│   └── tests/
│       ├── security-test.sh
│       └── functionality-test.sh
├── nginx/
│   ├── 1.25/
│   │   ├── alpine/
│   │   └── ubuntu/
│   ├── 1.24/
│   └── README.md
└── redis/
    ├── 7.2/
    ├── 7.0/
    └── README.md
```

### Image Requirements

#### Security Requirements (MANDATORY)

- **Non-root execution**: All processes must run as unprivileged user
- **Minimal base**: Use Alpine and/or Ubuntu minimal
- **No package managers**: Remove apk, apt, yum after package installation
- **Read-only filesystem**: Where application supports it
- **Security scanning**: Must pass Trivy scan with no HIGH/CRITICAL CVEs
- **SBOM generation**: Include software bill of materials

#### Documentation Requirements

- **Image README**: Usage instructions and security features
- **Hardening checklist**: Document all security measures applied
- **Example configuration**: docker-compose.yml or Kubernetes manifests

#### Testing Requirements

- **Security tests**: Automated security validation
- **Functionality tests**: Ensure application works correctly
- **Performance baseline**: Basic performance metrics

## Security Review Process

### Before Submitting

1. **Run security scan**

```bash
docker build -t titaniumlabs/myapp:test .
trivy image titaniumlabs/myapp:test
```

2. **Verify hardening**

```bash
# Check user is non-root
docker run --rm titaniumlabs/myapp:test id

# Verify no shell access (should fail)
docker run --rm -it titaniumlabs/myapp:test /bin/sh
```

3. **Test functionality**

```bash
# Run your application tests
./tests/functionality-test.sh
./tests/security-test.sh
```

### Security Checklist

- [ ] Image runs as non-root user
- [ ] No HIGH/CRITICAL vulnerabilities in Trivy scan
- [ ] Package managers removed from final image
- [ ] Unnecessary packages/tools removed
- [ ] Proper file permissions set
- [ ] Health check implemented
- [ ] Security tests pass
- [ ] Documentation complete

## Pull Request Process

### 1. **Before Creating PR**

- Ensure all tests pass
- Update documentation
- Follow commit message conventions
- Rebase on latest main branch

### 2. **PR Description Template**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New hardened image
- [ ] Security improvement to existing image
- [ ] Documentation update
- [ ] Bug fix

## Security Review
- [ ] Trivy scan passes (no HIGH/CRITICAL CVEs)
- [ ] Runs as non-root user
- [ ] Security tests pass
- [ ] Hardening checklist completed

## Testing
- [ ] Functionality tests pass
- [ ] Security tests pass
- [ ] Manual testing completed

## Documentation
- [ ] README updated
- [ ] Hardening checklist completed
- [ ] Example configurations provided
```

### 3. **Review Process**

1. **Automated checks**: CI/CD pipeline runs security scans
2. **Security review**: Titanium Labs team reviews hardening
3. **Code review**: Community and maintainer review
4. **Final approval**: Two approvals required for merge

## Reporting Security Issues

**DO NOT** open public issues for security vulnerabilities.

Instead, email: **security@titaniumlabs.io**

Include:
- Image name and version
- Vulnerability details
- Steps to reproduce
- Potential impact assessment

We aim to respond within 24 hours and provide fixes within 7 days for critical issues.

## Documentation Standards

### README Structure for Images

```markdown
# Application Name

Brief description of the hardened image

## Quick Start
## Security Features
## Configuration
## Environment Variables
## Health Checks
## Troubleshooting
```

### Commit Message Format

```
type(scope): description

Examples:
feat(postgres): add PostgreSQL 16 hardened image
fix(nginx): resolve privilege
```

