<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

# Google Cloud CLI Hardened Images

Security-hardened Google Cloud CLI container images implementing enterprise security best practices for cloud operations and CI/CD pipelines.

## Available Versions

- [`537`, `537.0`, `537.0.0`, `latest`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/gcloud/537.0.0/Dockerfile)

## Quick Start

```bash
# Use latest version (537.0.0)
docker pull titaniumlabs/gcloud:latest
docker run --rm -it titaniumlabs/gcloud:latest version

# Use with service account key
docker run --rm -it \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  titaniumlabs/gcloud:latest auth list

# Use in CI/CD pipeline
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/service-account.json \
  titaniumlabs/gcloud:537.0.0 \
  storage cp ./build/* gs://my-bucket/

# Interactive gcloud shell
docker run --rm -it \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  --entrypoint sh titaniumlabs/gcloud:latest
```

## What's Hardened

### System Security

- Non-root execution (UID/GID 1001)
- Rocky Linux 10 hardened base image
- Minimal package footprint
- Secure file permissions (restrictive umask 077)
- No setuid/setgid binaries
- Essential Google Cloud tools only

### Network Security

- TLS certificate validation enforced
- Secure credential handling
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

- Official Google Cloud SDK with cryptographic verification
- Multi-stage security hardened build
- Container image signing ready
- Transparent build process
- Minimal dependencies

## Available Tools

### Core Google Cloud Tools

- **gcloud v537.0.0**: Official Google Cloud command-line interface
- **gsutil v5.35**: Google Cloud Storage utility
- **bq v2.1.22**: BigQuery command-line tool
- **gcloud-crc32c v1.0.0**: CRC32C validation utility

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

All Google Cloud CLI hardened images meet:

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
- Restricted command set (Google Cloud tools only)
- Proper user/group configuration
- Session security controls
- Secure credential handling

#### Supply Chain (High Priority)

- Verified Google Cloud SDK download
- Multi-stage build with security validation
- Minimal dependencies
- Container image attestation ready
- Transparent build process

## Enterprise Features

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Deploy to Google Cloud Storage
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/workspace \
      -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/service-account.json \
      -w /workspace \
      titaniumlabs/gcloud:537.0.0 \
      storage cp -r ./build/* gs://my-bucket/
```

```yaml
# GitLab CI example
deploy:
  image: titaniumlabs/gcloud:537.0.0
  script:
    - gcloud version
    - gcloud storage cp -r ./dist/* gs://my-bucket/
  only:
    - main
```

### Google Cloud Operations

```bash
# Secure Cloud Storage operations
docker run --rm -it \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/gcloud:537.0.0 \
  storage ls gs://my-bucket/

# Compute Engine management
docker run --rm \
  -v $PWD/configs:/configs:ro \
  -e GOOGLE_APPLICATION_CREDENTIALS=/configs/service-account.json \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/gcloud:537.0.0 \
  compute instances list --project=my-project

# BigQuery operations
docker run --rm \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/gcloud:537.0.0 \
  bq query "SELECT * FROM dataset.table LIMIT 10"
```

### Debugging and Troubleshooting

```bash
# Secure debugging session
docker run --rm -it \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/gcloud:537.0.0 \
  logging logs list

# Configuration validation
docker run --rm \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/gcloud:537.0.0 \
  auth list
```

### Multi-Project Management

```bash
# Switch between projects securely
docker run --rm -it \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  --user 1001:1001 \
  titaniumlabs/gcloud:537.0.0 \
  config set project production-project

# Cross-project resource management
docker run --rm \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/gcloud:537.0.0 \
  --project=staging-project compute instances list
```

## Building Locally

```bash
# Clone repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images

# Build specific version
./scripts/build-images.sh --filter gcloud --version 537.0.0

# Build all gcloud versions
./scripts/build-images.sh --filter gcloud

# Run security validation
docker run --rm titaniumlabs/gcloud:537.0.0 version
docker run --rm titaniumlabs/gcloud:537.0.0 id
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOME` | `/home/appuser` | User home directory |
| `CLOUDSDK_CONFIG` | `$HOME/.config/gcloud` | Google Cloud config directory |
| `GOOGLE_APPLICATION_CREDENTIALS` | (none) | Service account key file path |
| `CLOUDSDK_PYTHON` | `/usr/bin/python3` | Python interpreter for gcloud |
| `PATH` | `/usr/local/bin:/usr/bin:/bin` | Executable search path |
| `SHELL` | `/bin/bash` | Default shell |

### Volume Mounts

```bash
# Recommended volume mounts
docker run --rm -it \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \  # gcloud config (read-only)
  -v $PWD:/workspace:ro \                                # Workspace files (read-only)
  -v /tmp:/tmp \                                         # Temporary files
  --user 1001:1001 \
  titaniumlabs/gcloud:537.0.0
```

### Security Contexts

```yaml
# Recommended security context for Kubernetes Jobs
apiVersion: batch/v1
kind: Job
metadata:
  name: gcloud-job
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
        fsGroup: 1001
      containers:
      - name: gcloud
        image: titaniumlabs/gcloud:537.0.0
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        env:
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /var/secrets/service-account.json
        volumeMounts:
        - name: service-account
          mountPath: /var/secrets
          readOnly: true
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: service-account
        secret:
          secretName: gcloud-service-account
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
  -e GOOGLE_APPLICATION_CREDENTIALS=/workspace/service-account.json \
  -v $PWD:/workspace:ro \
  titaniumlabs/gcloud:537.0.0
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
