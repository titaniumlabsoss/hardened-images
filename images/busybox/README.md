<p align="center">
    <img width="400px" height=auto src="https://raw.githubusercontent.com/titaniumlabsoss/hardened-images/refs/heads/main/assets/titanium-labs-logo.png" alt="Titanium Labs Logo" />
</p>

# BusyBox Hardened Images

Security-hardened BusyBox container images implementing DISA STIG controls, CIS benchmarks, and enterprise security best practices for minimal utility containers and init containers.

## Available Versions

- [`1`, `1.37`, `1.37.0`, `latest`](https://github.com/titaniumlabsoss/hardened-images/blob/main/images/busybox/1.37.0/Dockerfile)

## Quick Start

```bash
# Use latest version (1.37.0)
docker pull titaniumlabs/busybox:latest
docker run --rm -it titaniumlabs/busybox:latest

# Use specific version
docker pull titaniumlabs/busybox:1.37.0
docker run --rm -it titaniumlabs/busybox:1.37.0

# Use as init container
docker run --rm titaniumlabs/busybox:1.37.0 sh -c "echo 'Init complete'"

# Use as debug container
kubectl run debug --rm -it --image=titaniumlabs/busybox:1.37.0 -- sh
```

## What's Hardened

### System Security

- Non-root execution (UID/GID 1001)
- Scratch-based minimal footprint
- No package managers or development tools
- Secure file permissions (restrictive umask 077)
- No setuid/setgid binaries
- Essential utilities only (406 commands)

### Network Security

- Network tools intentionally excluded for security
- No SSH, FTP, or web servers
- No network diagnostic tools (ping, traceroute)
- Clean network namespace isolation
- Minimal attack surface for network-based exploits

### Container Security

- Built from scratch base image (zero OS footprint)
- Read-only root filesystem compatible
- Security context optimized
- Capability dropping supported
- No privilege escalation paths

### Supply Chain Security

- Official BusyBox 1.37.0 source verification
- Multi-stage security hardened build
- Container image signing ready
- Minimal dependencies
- Transparent build process

## Available Commands

### Essential 406 BusyBox Commands

**Core Utilities:** `cat`, `cp`, `mv`, `rm`, `ls`, `mkdir`, `rmdir`, `chmod`, `chown`, `ln`, `pwd`, `echo`, `env`, `id`, `whoami`, `basename`, `dirname`

**Text Processing:** `grep`, `egrep`, `fgrep`, `sed`, `sort`, `uniq`, `head`, `tail`, `cut`, `tr`, `wc`, `find`, `xargs`, `awk`

**System Management:** `ps`, `kill`, `killall`, `top`, `free`, `df`, `du`, `mount`, `umount`, `sync`

**Archive/Compression:** `tar`, `gzip`, `gunzip`, `bzip2`, `bunzip2`, `bzcat`

**Shell Environment:** `sh`, `ash`, `test`, `true`, `false`, `sleep`, `timeout`, `nohup`

**File System:** `stat`, `touch`, `mknod`, `mkfifo`, `readlink`, `realpath`

**Text Editors:** `vi`, `ed` (minimal editing capabilities)

**Utilities:** `date`, `cal`, `bc`, `seq`, `yes`, `tee`, `watch`, `time`

### Excluded for Security

**Network Tools:** `wget`, `ping`, `telnet`, `ftp`, `ssh`, `nc`, `netstat`  
**System Administration:** `su`, `sudo`, `passwd`, `adduser`, `deluser`  
**Dangerous Tools:** `dd` (for safety), network services, development tools

## Compliance Standards

All BusyBox hardened images meet:

- **DISA STIG**: Container security implementation guide controls
- **CIS Benchmarks**: Center for Internet Security container benchmarks
- **NIST 800-190**: Container security guidelines
- **NIST 800-53**: National Institute of Standards cybersecurity framework
- **Common Criteria**: Enterprise security requirements

### Security Controls Implemented

#### Container Security (High Priority)

- Non-privileged user execution (UID 1001)
- Scratch-based minimal attack surface
- No privilege escalation mechanisms
- Secure file permissions throughout
- Read-only filesystem compatibility

#### Access Control (Medium Priority)

- No administrative tools or user management
- No network access tools
- Restricted command set (essential utilities only)
- Proper user/group configuration
- Session security controls

#### Supply Chain (High Priority)

- Verified source download with SHA256 checksums
- Multi-stage build with security validation
- Minimal dependencies
- Container image attestation ready
- Transparent build process

## Enterprise Features

### Container Orchestration

```yaml
# Kubernetes init container example
apiVersion: v1
kind: Pod
spec:
  initContainers:
  - name: init-setup
    image: titaniumlabs/busybox:1.37.0
    command: ['sh', '-c', 'echo "Initializing..." && sleep 2']
    securityContext:
      runAsNonRoot: true
      runAsUser: 1001
      runAsGroup: 1001
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
    resources:
      requests:
        memory: "16Mi"
        cpu: "10m"
      limits:
        memory: "32Mi"
        cpu: "50m"
```

### Debug and Troubleshooting

```bash
# Secure debugging pod
kubectl run debug-pod --rm -it \
  --image=titaniumlabs/busybox:1.37.0 \
  --restart=Never \
  --overrides='
{
  "spec": {
    "securityContext": {
      "runAsNonRoot": true,
      "runAsUser": 1001
    },
    "containers": [{
      "name": "debug",
      "image": "titaniumlabs/busybox:1.37.0",
      "stdin": true,
      "tty": true,
      "securityContext": {
        "allowPrivilegeEscalation": false,
        "readOnlyRootFilesystem": true,
        "capabilities": {"drop": ["ALL"]}
      }
    }]
  }
}' -- sh
```

### File Operations and Data Processing

```bash
# Secure file backup
docker run --rm \
  -v /host/data:/data:ro \
  -v /host/backup:/backup \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  titaniumlabs/busybox:1.37.0 \
  tar czf /backup/data-$(date +%Y%m%d).tar.gz -C /data .

# Log processing
docker run --rm \
  -v /host/logs:/logs:ro \
  --user 1001:1001 \
  --read-only \
  titaniumlabs/busybox:1.37.0 \
  sh -c "grep ERROR /logs/*.log | sort | uniq -c"
```

## Building Locally

```bash
# Clone repository
git clone https://github.com/titaniumlabsoss/hardened-images.git
cd hardened-images
./scripts/build-images.sh --filter busybox

# Run security validation
docker run --rm titaniumlabs/busybox:1.37.0 id
docker run --rm titaniumlabs/busybox:1.37.0 find / -perm -4000 2>/dev/null
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `USER` | `busybox` | Non-root user name |
| `HOME` | `/tmp` | User home directory |
| `PATH` | `/bin:/sbin` | Executable search path |
| `SHELL` | `/bin/sh` | Default shell |
| `TZ` | `UTC` | Timezone |

### Security Contexts

```yaml
# Recommended security context for Kubernetes
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 1001
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

```bash
# Recommended Docker security options
docker run --rm \
  --user 1001:1001 \
  --read-only \
  --security-opt no-new-privileges \
  --cap-drop ALL \
  --network none \
  titaniumlabs/busybox:1.37.0
```

## Image Variants

| Tag | Description | Size | Commands | Architecture |
|-----|-------------|------|----------|--------------|
| `1.37.0` | Latest stable release | 10.5MB | 406 | amd64, arm64 |
| `latest` | Points to 1.37.0 | 10.5MB | 406 | amd64, arm64 |

## Performance & Resource Usage

- **Memory footprint**: ~2MB RAM
- **CPU usage**: Minimal (single-threaded utilities)
- **Storage**: 10.5MB image size
- **Startup time**: <100ms
- **Security scanning**: Zero critical/high CVEs

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
