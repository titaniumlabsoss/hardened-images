# CI/CD Pipelines Documentation

This document provides comprehensive documentation for all GitHub Actions workflows and CI/CD pipelines in the Titanium Labs Hardened Images project.

## Overview

The project implements a multi-pipeline CI/CD strategy focused on security, automation, and reliability:

```
┌─────────────────────────────────────────────────────────────┐
│                     Pipeline Architecture                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│      ┌─────────────────┐    ┌───────────────────┐           │
│      │  Build Pipeline │    │ Security Pipeline │           │
│      │  • Image builds │───▶│  • Vuln scanning  │           │
│      │  • Multi-arch   │    │  • SBOM gen       │           │
│      │  • Registry push│    │  • Image signing  │           │
│      └─────────────────┘    └───────────────────┘           │
│               │                       │                     │
│               ▼                       ▼                     │
│      ┌─────────────────┐    ┌────────────────────┐          │
│      │ Daily Monitoring│    │ Build Verification │          │
│      │  • Daily scans  │    │  • Security tests  │          │
│      │  • Compliance   │    │  • Compliance      │          │
│      │  • Reporting    │    │  • Quality gates   │          │
│      └─────────────────┘    └────────────────────┘          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Pipeline Catalog

| Pipeline | File | Purpose | Triggers |
|----------|------|---------|----------|
| [Build Hardened Images](#build-images-pipeline) | `build-images.yml` | Main build and deployment | Push, PR, Manual |

## Build Images Pipeline

**File**: `.github/workflows/build-images.yml`

### Purpose
Main CI/CD pipeline that automatically discovers, builds, and deploys all container images with proper security validation.

### Required Secrets

| Secret | Purpose | Example |
|--------|---------|---------|
| `REGISTRY_USERNAME` | Registry authentication | `titaniumlabs` |
| `REGISTRY_TOKEN` | Registry access token | `dckr_pat_xxx...` |

#### Workflow Inputs (Manual Dispatch)

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `push_images` | boolean | `false` | Push images to registry |
| `filter` | string | `""` | Filter images to build |
| `rebuild` | boolean | `false` | Force rebuild without cache |

### Usage Examples

#### Manual Workflow Dispatch

1. **Build All Images (No Push)**
```
Workflow: Build All Hardened Images
push_images: false
filter: (empty)
rebuild: false
```

2. **Build and Push PostgreSQL Images**
```
Workflow: Build All Hardened Images
push_images: true
filter: postgres
rebuild: false
```

3. **Force Rebuild All Images**
```
Workflow: Build All Hardened Images
push_images: true
filter: (empty)
rebuild: true
```
