# Build System Documentation

The Titanium Labs Hardened Images project includes a sophisticated automated build system that discovers, builds, and deploys container images with proper tagging and security validation.

## Overview

The build system consists of three main components:

1. **Local Build Script** (`scripts/build-images.sh`) - Command-line tool for local development
2. **GitHub Actions Workflows** - Automated CI/CD pipelines
3. **Security Integration** - Vulnerability scanning, SBOM generation, and image signing

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Build System Architecture                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│         ┌─────────────────┐    ┌─────────────────┐          │
│         │ Image Discovery │    │  Local Build    │          │
│         │ • Base Images   │───▶│  • Parallel     │          │
│         │ • App Images    │    │  • Sequential   │          │
│         │ • Auto-tagging  │    │  • Filtering    │          │
│         └─────────────────┘    └─────────────────┘          │
│                  │                       │                  │
│                  ▼                       ▼                  │
│         ┌─────────────────┐    ┌─────────────────┐          │
│         │  Security Scan  │    │  Registry Push  │          │
│         │  • Trivy        │    │  • Docker Hub   │          │
│         │  • SBOM Gen     │    │  • Signing      │          │
│         │  • Signing      │    │  • Attestation  │          │
│         └─────────────────┘    └─────────────────┘          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Image Discovery and Tagging Strategy

### Automatic Image Discovery

The build system automatically discovers images by scanning the `images/` directory structure:

```
images/
├── base_images/           # Base operating system images
│   └── rockylinux/
│       └── 10/
│           └── Dockerfile → titaniumlabs/rockylinux:10
│
└── postgres/              # Application images
    └── 16/
        └── Dockerfile → titaniumlabs/postgres:16
```

### Tagging Convention

| Image Type | Directory Pattern | Tag Format | Example |
|------------|------------------|------------|---------|
| Base Images | `base_images/OS/VERSION/` | `titaniumlabs/OS:VERSION` | `titaniumlabs/rockylinux:10` |
| App Images | `APP/VERSION/` | `titaniumlabs/APP:VERSION` | `titaniumlabs/postgres:16` |

## Local Build Script

### Usage

```bash
# Basic usage
./scripts/build-images.sh [OPTIONS]

# Common examples
./scripts/build-images.sh                    # Build all images locally
./scripts/build-images.sh --push             # Build and push to Docker Hub
./scripts/build-images.sh --filter postgres  # Build only PostgreSQL images
./scripts/build-images.sh --dry-run          # Preview what would be built
```

### Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `--registry REGISTRY` | Container registry URL | `--registry docker.io` |
| `--organization ORG` | Organization name | `--organization titaniumlabs` |
| `--push` | Push images to registry | `--push` |
| `--no-parallel` | Build sequentially | `--no-parallel` |
| `--filter PATTERN` | Filter images by pattern | `--filter postgres` |
| `--dry-run` | Show what would be built | `--dry-run` |
| `--rebuild` | Force rebuild without cache | `--rebuild` |
| `-v, --verbose` | Enable verbose output | `-v` |
| `-h, --help` | Show help message | `-h` |

### Examples

#### Build All Images Locally
```bash
./scripts/build-images.sh
```

#### Build and Push to Docker Hub
```bash
./scripts/build-images.sh --push --registry docker.io
```

#### Build Only PostgreSQL Images
```bash
./scripts/build-images.sh --filter postgres
```

#### Preview Build Plan
```bash
./scripts/build-images.sh --dry-run
```

### Build Process Flow

1. **Environment Setup**
   - Validate Docker installation
   - Create build log directories
   - Configure registry settings

2. **Image Discovery**
   - Scan `images/` directory for Dockerfiles
   - Parse directory structure for tagging
   - Apply filters if specified

3. **Build Execution**
   - Parallel or sequential building
   - Comprehensive logging
   - Error handling and reporting

4. **Post-Build Actions**
   - Push to registry (if enabled)
   - Generate build reports
   - Clean up temporary files

### Build Logs and Reporting

The build system generates comprehensive logs and reports:

```
build-logs/
├── build-all-20250816-120000.log          # Main build log
├── build-rockylinux-20250816-120000.log   # Individual image logs
├── build-postgres-20250816-120000.log     # Individual image logs
└── build-report-20250816-120000.md        # Markdown report
```

## Advanced Configuration

### Custom Registries

```bash
# Use custom registry
./scripts/build-images.sh \
  --registry custom.registry.com \
  --organization myorg \
  --push
```

### Filtering Images

```bash
# Build only specific patterns
./scripts/build-images.sh --filter "postgres|nginx"
./scripts/build-images.sh --filter "rockylinux"
```

## Troubleshooting

### Common Issues

#### Build Failures

1. **Docker daemon not running**
```bash
sudo systemctl start docker
```

2. **Permission denied**
```bash
sudo usermod -aG docker $USER
# Logout and login again
```

3. **Registry authentication**
```bash
docker login docker.io
```

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
./scripts/build-images.sh --verbose --dry-run
```

### Log Analysis

Check build logs for specific errors:

```bash
# View main build log
tail -f build-logs/build-all-*.log

# Check specific image build
tail -f build-logs/build-postgres-*.log
```

## Best Practices

1. **Use dry-run first** - Always preview builds before execution
2. **Filter during development** - Build only changed images
3. **Monitor disk space** - Docker images can consume significant space
4. **Clean up regularly** - Remove unused images and containers

### Security

1. **Regular updates** - Keep base images updated
2. **Vulnerability monitoring** - Review daily scan reports
3. **Access control** - Limit who can push to registries
4. **Audit trails** - Maintain build and deployment logs

## Performance Optimization

### Parallel Builds

The build system supports parallel execution:

```bash
# Default: parallel builds enabled
./scripts/build-images.sh

# Force sequential builds
./scripts/build-images.sh --no-parallel
```

### Docker Cache

Optimize build times with proper caching:

```dockerfile
# Good: Copy package files first
COPY package*.json ./
RUN npm install

# Then copy source code
COPY . .
```

### Registry Configuration

For faster builds, use local registry caching:

```bash
# Start local registry cache
docker run -d -p 5000:5000 --name registry registry:2

# Configure Docker daemon
echo '{"registry-mirrors": ["http://localhost:5000"]}' | sudo tee /etc/docker/daemon.json
```

## Monitoring and Metrics

### Build Metrics

The system tracks important build metrics:

- **Build Success Rate** - Percentage of successful builds
- **Build Duration** - Time taken for each image
- **Image Sizes** - Track size optimization
- **Security Scores** - Vulnerability counts and trends
