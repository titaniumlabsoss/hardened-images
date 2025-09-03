<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

# AWS CLI Hardened Images

Security-hardened AWS CLI container images implementing enterprise security best practices for cloud operations and CI/CD pipelines.

## Available Versions

- [`2`, `2.28`, `2.28.23`, `latest`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/aws-cli/2.28.23/Dockerfile)

## Quick Start

```bash
# Use latest version (2.28.23)
docker pull titaniumlabs/aws-cli:latest
docker run --rm -it -v ~/.aws:/home/appuser/.aws:ro titaniumlabs/aws-cli:latest --version

# Use with AWS credentials
docker run --rm -it \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION \
  titaniumlabs/aws-cli:latest s3 ls

# Use in CI/CD pipeline
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION \
  titaniumlabs/aws-cli:2.28.23 \
  s3 sync ./dist/ s3://my-bucket/

# Interactive AWS CLI shell
docker run --rm -it \
  -v ~/.aws:/home/appuser/.aws:ro \
  --entrypoint sh titaniumlabs/aws-cli:latest
```

## What's Hardened

### System Security

- Non-root execution (UID/GID 1001)
- Rocky Linux 10 hardened base image
- Minimal package footprint
- Secure file permissions (restrictive umask 077)
- No setuid/setgid binaries
- Essential AWS tools only

### Network Security

- TLS certificate validation enforced
- Secure AWS credential handling
- No unnecessary network tools
- Clean network namespace isolation
- Minimal attack surface for network-based exploits

### Container Security

- Hardened Rocky Linux base with security patches
- Read-only root filesystem compatible
- Security context optimized
- Capability dropping supported
- No privilege escalation paths

### Supply Chain Security

- Official AWS CLI binary with cryptographic verification
- Multi-stage security hardened build
- Container image signing ready
- Transparent build process
- Minimal dependencies

## Available Tools

### Core AWS Tools

- **aws-cli v2.28.23**: Official AWS command-line interface
- **Cryptographic verification**: Binary integrity validation

### Included Utilities

**File Operations:** Standard Linux file utilities for configuration processing  
**Text Processing:** `grep`, `sed`, `sort`, `cut`, `awk` for JSON/YAML manipulation  
**Archive Tools:** `tar`, `gzip` for backup and deployment operations  
**Shell Environment:** `bash`, `sh` for scripting and automation

### Excluded for Security

**Development Tools:** Compilers, interpreters, package managers  
**Network Debugging:** `ping`, `telnet`, `netstat`, `ss`  
**System Administration:** `su`, `sudo`, `systemctl`  
**Dangerous Tools:** System modification utilities

## Compliance Standards

All AWS CLI hardened images meet:

- **DISA STIG**: Container security implementation guide controls
- **CIS Benchmarks**: Center for Internet Security container benchmarks
- **NIST 800-190**: Container security guidelines
- **NIST 800-53**: National Institute of Standards cybersecurity framework
- **Common Criteria**: Enterprise security requirements

### Security Controls Implemented

#### Container Security (High Priority)

- Non-privileged user execution (UID 1001)
- Hardened Rocky Linux base with security updates
- No privilege escalation mechanisms
- Secure file permissions throughout
- Read-only filesystem compatibility

#### Access Control (Medium Priority)

- No administrative tools or user management
- Restricted command set (AWS tools only)
- Proper user/group configuration
- Session security controls
- Secure AWS credential handling

#### Supply Chain (High Priority)

- Verified AWS CLI binary download
- Multi-stage build with security validation
- Minimal dependencies
- Container image attestation ready
- Transparent build process

## Enterprise Features

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Deploy to S3
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/workspace \
      -e AWS_ACCESS_KEY_ID=${{ secrets.AWS_ACCESS_KEY_ID }} \
      -e AWS_SECRET_ACCESS_KEY=${{ secrets.AWS_SECRET_ACCESS_KEY }} \
      -e AWS_DEFAULT_REGION=us-east-1 \
      -w /workspace \
      titaniumlabs/aws-cli:2.28.23 \
      s3 sync ./build/ s3://my-bucket/
```

```yaml
# GitLab CI example
deploy:
  image: titaniumlabs/aws-cli:2.28.23
  script:
    - aws --version
    - aws s3 sync ./dist/ s3://my-bucket/
  only:
    - main
```

### AWS Operations

```bash
# Secure S3 operations
docker run --rm -it \
  -v ~/.aws:/home/appuser/.aws:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/aws-cli:2.28.23 \
  s3 ls s3://my-bucket/

# Resource management
docker run --rm \
  -v $PWD/configs:/configs:ro \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/aws-cli:2.28.23 \
  cloudformation deploy --template-file /configs/template.yaml

# EC2 instance management
docker run --rm \
  -v ~/.aws:/home/appuser/.aws:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/aws-cli:2.28.23 \
  ec2 describe-instances --region us-east-1
```

### Debugging and Troubleshooting

```bash
# Secure debugging session
docker run --rm -it \
  -v ~/.aws:/home/appuser/.aws:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/aws-cli:2.28.23 \
  logs describe-log-groups

# Configuration validation
docker run --rm \
  -v ~/.aws:/home/appuser/.aws:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/aws-cli:2.28.23 \
  sts get-caller-identity
```

### Multi-Account Management

```bash
# Switch between AWS profiles securely
docker run --rm -it \
  -v ~/.aws:/home/appuser/.aws:ro \
  --user 1001:1001 \
  titaniumlabs/aws-cli:2.28.23 \
  --profile production sts get-caller-identity

# Cross-account resource management
docker run --rm \
  -v ~/.aws:/home/appuser/.aws:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/aws-cli:2.28.23 \
  --profile staging s3 ls
```

## Building Locally

```bash
# Clone repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images

# Build specific version
./scripts/build-images.sh --filter aws-cli --version 2.28.23

# Build all aws-cli versions
./scripts/build-images.sh --filter aws-cli

# Run security validation
docker run --rm titaniumlabs/aws-cli:2.28.23 --version
docker run --rm titaniumlabs/aws-cli:2.28.23 id
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOME` | `/home/appuser` | User home directory |
| `AWS_CONFIG_FILE` | `$HOME/.aws/config` | AWS config file path |
| `AWS_SHARED_CREDENTIALS_FILE` | `$HOME/.aws/credentials` | AWS credentials file path |
| `PATH` | `/usr/local/bin:/usr/bin:/bin` | Executable search path |
| `SHELL` | `/bin/bash` | Default shell |

### Volume Mounts

```bash
# Recommended volume mounts
docker run --rm -it \
  -v ~/.aws:/home/appuser/.aws:ro \        # AWS config (read-only)
  -v $PWD:/workspace:ro \                  # Workspace files (read-only)
  -v /tmp:/tmp \                           # Temporary files
  --user 1001:1001 \
  titaniumlabs/aws-cli:2.28.23
```

### Security Contexts

```yaml
# Recommended security context for Kubernetes Jobs
apiVersion: batch/v1
kind: Job
metadata:
  name: aws-cli-job
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
        fsGroup: 1001
      containers:
      - name: aws-cli
        image: titaniumlabs/aws-cli:2.28.23
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        env:
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: aws-credentials
              key: access-key-id
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: aws-credentials
              key: secret-access-key
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: tmp
        emptyDir: {}
```

```bash
# Recommended Docker security options
docker run --rm \
  --user 1001:1001 \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,nodev \
  --security-opt no-new-privileges \
  --cap-drop ALL \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION \
  titaniumlabs/aws-cli:2.28.23
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
