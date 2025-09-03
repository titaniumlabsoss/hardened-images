<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

# kubectl Hardened Images

Security-hardened kubectl + kustomize container images implementing enterprise security best practices for Kubernetes command-line operations and CI/CD pipelines.

## Available Versions

- [`1`, `1.34`, `1.34.0`, `latest`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/kubectl/1.34.0/Dockerfile)
- [`1.33`, `1.33.4`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/kubectl/1.33.4/Dockerfile)
- [`1.33.3`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/kubectl/1.33.3/Dockerfile)

## Quick Start

```bash
# Use latest version (1.34.0)
docker pull titaniumlabs/kubectl:latest
docker run --rm -it -v ~/.kube:/home/kubectl/.kube:ro titaniumlabs/kubectl:latest version

# Use specific version
docker pull titaniumlabs/kubectl:1.33.3
docker run --rm -it -v ~/.kube:/home/kubectl/.kube:ro titaniumlabs/kubectl:1.33.3 get pods

# Use in CI/CD pipeline
docker run --rm -v $PWD:/workspace -w /workspace \
  -v ~/.kube:/home/kubectl/.kube:ro \
  titaniumlabs/kubectl:1.34.0 apply -f deployment.yaml

# Interactive kubectl shell
docker run --rm -it -v ~/.kube:/home/kubectl/.kube:ro \
  --entrypoint sh titaniumlabs/kubectl:1.34.0
```

## What's Hardened

### System Security

- Non-root execution (UID/GID 1001)
- Rocky Linux 10 hardened base image
- Minimal package footprint
- Secure file permissions (restrictive umask 077)
- No setuid/setgid binaries
- Essential Kubernetes tools only

### Network Security

- TLS certificate validation enforced
- Secure kubectl configuration handling
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

- Official kubectl binary with SHA256 verification
- Cryptographic signature validation
- Multi-stage security hardened build
- Container image signing ready
- Transparent build process

## Available Tools

### Core Kubernetes Tools

- **kubectl v1.34.0**: Official Kubernetes command-line tool
- **kustomize**: Kubernetes native configuration management
- **SHA256 verification**: Cryptographic integrity validation

### Included Utilities

**File Operations:** Standard Linux file utilities for manifest processing  
**Text Processing:** `grep`, `sed`, `sort`, `cut`, `awk` for YAML/JSON manipulation  
**Archive Tools:** `tar`, `gzip` for backup and deployment operations  
**Shell Environment:** `bash`, `sh` for scripting and automation

### Excluded for Security

**Development Tools:** Compilers, interpreters, package managers  
**Network Debugging:** `ping`, `telnet`, `netstat`, `ss`  
**System Administration:** `su`, `sudo`, `systemctl`  
**Dangerous Tools:** System modification utilities

## Compliance Standards

All kubectl hardened images meet:

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
- Restricted command set (Kubernetes tools only)
- Proper user/group configuration
- Session security controls
- Secure kubectl configuration handling

#### Supply Chain (High Priority)

- Verified kubectl binary download with SHA256 checksums
- Cryptographic signature validation
- Multi-stage build with security validation
- Minimal dependencies
- Container image attestation ready
- Transparent build process

## Enterprise Features

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Deploy to Kubernetes
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/workspace \
      -v ${{ runner.temp }}/kubeconfig:/home/kubectl/.kube:ro \
      -w /workspace \
      titaniumlabs/kubectl:1.34.0 \
      apply -f k8s/
```

```yaml
# GitLab CI example
deploy:
  image: titaniumlabs/kubectl:1.34.0
  script:
    - kubectl version --client
    - kubectl apply -f deployment/
  only:
    - main
```

### Kubernetes Operations

```bash
# Secure cluster operations
docker run --rm -it \
  -v ~/.kube:/home/kubectl/.kube:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/kubectl:1.34.0 \
  get pods --all-namespaces

# Resource management
docker run --rm \
  -v $PWD/manifests:/manifests:ro \
  -v ~/.kube:/home/kubectl/.kube:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/kubectl:1.34.0 \
  apply -f /manifests/

# Configuration management with Kustomize
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.kube:/home/kubectl/.kube:ro \
  --user 1001:1001 \
  -w /workspace \
  titaniumlabs/kubectl:1.34.0 \
  sh -c "kustomize build overlays/production | kubectl apply -f -"
```

### Debugging and Troubleshooting

```bash
# Secure debugging session
docker run --rm -it \
  -v ~/.kube:/home/kubectl/.kube:ro \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/kubectl:1.34.0 \
  describe pod problematic-pod

# Log analysis
docker run --rm \
  -v ~/.kube:/home/kubectl/.kube:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/kubectl:1.34.0 \
  logs -f deployment/app --tail=100
```

### Multi-Cluster Management

```bash
# Switch between clusters securely
docker run --rm -it \
  -v ~/.kube:/home/kubectl/.kube \
  --user 1001:1001 \
  titaniumlabs/kubectl:1.34.0 \
  config use-context production

# Cross-cluster resource comparison
docker run --rm \
  -v ~/.kube:/home/kubectl/.kube:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/kubectl:1.34.0 \
  sh -c "kubectl --context staging get pods -o yaml > /tmp/staging.yaml && kubectl --context production get pods -o yaml > /tmp/production.yaml"
```

## Building Locally

```bash
# Clone repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images

# Build specific version
./scripts/build-images.sh --filter kubectl --version 1.34.0

# Build all kubectl versions
./scripts/build-images.sh --filter kubectl

# Run security validation
docker run --rm titaniumlabs/kubectl:1.34.0 version --client
docker run --rm titaniumlabs/kubectl:1.34.0 id
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOME` | `/home/kubectl` | User home directory |
| `KUBECONFIG` | `$HOME/.kube/config` | Kubernetes config file path |
| `PATH` | `/usr/local/bin:/usr/bin:/bin` | Executable search path |
| `SHELL` | `/bin/bash` | Default shell |

### Volume Mounts

```bash
# Recommended volume mounts
docker run --rm -it \
  -v ~/.kube:/home/kubectl/.kube:ro \      # Kubernetes config (read-only)
  -v $PWD:/workspace:ro \                  # Workspace files (read-only)
  -v /tmp:/tmp \                           # Temporary files
  --user 1001:1001 \
  titaniumlabs/kubectl:1.34.0
```

### Security Contexts

```yaml
# Recommended security context for Kubernetes Jobs
apiVersion: batch/v1
kind: Job
metadata:
  name: kubectl-job
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
        fsGroup: 1001
      containers:
      - name: kubectl
        image: titaniumlabs/kubectl:1.34.0
        securityContext:
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        volumeMounts:
        - name: kubeconfig
          mountPath: /home/kubectl/.kube
          readOnly: true
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: kubeconfig
        secret:
          secretName: kubeconfig
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
  -v ~/.kube:/home/kubectl/.kube:ro \
  titaniumlabs/kubectl:1.34.0
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
