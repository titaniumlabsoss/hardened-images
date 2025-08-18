#!/bin/bash
# Build All Hardened Images Script
# Automatically discovers and builds all container images with proper tagging

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="$PROJECT_ROOT/images"
REGISTRY="${REGISTRY:-docker.io}"
ORGANIZATION="${ORGANIZATION:-titaniumlabs}"
PUSH="${PUSH:-false}"
PARALLEL="${PARALLEL:-true}"
BUILD_LOGS_DIR="${BUILD_LOGS_DIR:-$PROJECT_ROOT/build-logs}"
TIMESTAMP=$(date -u +"%Y%m%d")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    mkdir -p "$BUILD_LOGS_DIR" 2>/dev/null || true
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$BUILD_LOGS_DIR/build-all-${TIMESTAMP}.log"
}

log_success() {
    mkdir -p "$BUILD_LOGS_DIR" 2>/dev/null || true
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$BUILD_LOGS_DIR/build-all-${TIMESTAMP}.log"
}

log_warning() {
    mkdir -p "$BUILD_LOGS_DIR" 2>/dev/null || true
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$BUILD_LOGS_DIR/build-all-${TIMESTAMP}.log"
}

log_error() {
    mkdir -p "$BUILD_LOGS_DIR" 2>/dev/null || true
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$BUILD_LOGS_DIR/build-all-${TIMESTAMP}.log"
}

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build all hardened container images with automatic discovery and tagging

OPTIONS:
    --registry REGISTRY    Container registry (default: $REGISTRY)
    --organization ORG     Organization name (default: $ORGANIZATION)
    --push                 Push images to registry after building
    --no-parallel          Build images sequentially instead of parallel
    --filter PATTERN       Only build images matching pattern
    --dry-run              Show what would be built without executing
    --rebuild              Force rebuild without cache
    -v, --verbose          Enable verbose output
    -h, --help             Show this help message

TAGGING STRATEGY:
    Base Images:    $ORGANIZATION/OS:VERSION
                   (e.g., titaniumlabs/rockylinux:24.04)

    App Images:     $ORGANIZATION/APP:VERSION (Rocky-based)
                   $ORGANIZATION/APP:VERSION-minimal (Alpine-based)
                   (e.g., titaniumlabs/postgres:16, titaniumlabs/postgres:16-minimal)

EXAMPLES:
    $0                                        # Build all images locally
    $0 --push                                 # Build and push all images
    $0 --filter postgres                      # Only build postgres images
    $0 --registry docker.io --push            # Push to Docker Hub
    $0 --dry-run                              # Preview what would be built

EOF
}

# Parse command line arguments
parse_args() {
    FILTER=""
    DRY_RUN=false
    REBUILD=false
    VERBOSE=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --registry)
                REGISTRY="$2"
                shift 2
                ;;
            --organization)
                ORGANIZATION="$2"
                shift 2
                ;;
            --push)
                PUSH=true
                shift
                ;;
            --no-parallel)
                PARALLEL=false
                shift
                ;;
            --filter)
                FILTER="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --rebuild)
                REBUILD=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                log_error "Unexpected argument: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Setup build environment
setup_build_environment() {
    log_info "Setting up build environment..."

    mkdir -p "$BUILD_LOGS_DIR"

    # Check prerequisites
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        exit 1
    fi

    log_success "Build environment ready"
    log_info "Registry: $REGISTRY"
    log_info "Organization: $ORGANIZATION"
    log_info "Push images: $PUSH"
    log_info "Parallel builds: $PARALLEL"
    log_info "Build logs: $BUILD_LOGS_DIR"
}

# Discover base images
discover_base_images() {
    [[ "$DRY_RUN" != "true" ]] && log_info "Discovering base images..." >&2

    local base_images=()

    # Find all base image Dockerfiles
    while IFS= read -r -d '' dockerfile; do
        local image_dir
        image_dir=$(dirname "$dockerfile")
        local relative_path
        relative_path=$(python3 -c "import os; print(os.path.relpath('$image_dir', '$IMAGES_DIR'))")

        # Parse base image path: base_images/OS/VERSION
        if [[ "$relative_path" =~ ^base_images/([^/]+)/([^/]+)$ ]]; then
            local os="${BASH_REMATCH[1]}"
            local version="${BASH_REMATCH[2]}"
            local tag="$ORGANIZATION/$os:$version"

            base_images+=("$image_dir|$tag")
            [[ "$DRY_RUN" != "true" ]] && log_info "Found base image: $os:$version -> $tag" >&2
        fi
    done < <(find "$IMAGES_DIR/base_images" -name "Dockerfile" -print0 2>/dev/null || true)

    printf '%s\n' "${base_images[@]}"
}

# Discover application images
discover_app_images() {
    [[ "$DRY_RUN" != "true" ]] && log_info "Discovering application images..." >&2

    local app_images=()

    # Find all app image Dockerfiles (excluding base_images)
    while IFS= read -r -d '' dockerfile; do
        local image_dir
        image_dir=$(dirname "$dockerfile")
        local relative_path
        relative_path=$(python3 -c "import os; print(os.path.relpath('$image_dir', '$IMAGES_DIR'))")

        # Skip base_images
        if [[ "$relative_path" =~ ^base_images/ ]]; then
            continue
        fi

        # Parse app image path: APP/VERSION/OS
        if [[ "$relative_path" =~ ^([^/]+)/([^/]+)/([^/]+)$ ]]; then
            local app="${BASH_REMATCH[1]}"
            local version="${BASH_REMATCH[2]}"
            local os="${BASH_REMATCH[3]}"

            local tag
            if [[ "$os" == "alpine" ]]; then
                tag="$ORGANIZATION/$app:$version-minimal"
            else
                tag="$ORGANIZATION/$app:$version"
            fi

            app_images+=("$image_dir|$tag")
            [[ "$DRY_RUN" != "true" ]] && log_info "Found app image: $app/$version/$os -> $tag" >&2
        fi
    done < <(find "$IMAGES_DIR" -name "Dockerfile" -not -path "*/base_images/*" -print0 2>/dev/null || true)

    if [[ ${#app_images[@]} -gt 0 ]]; then
        printf '%s\n' "${app_images[@]}"
    fi
}

# Build single image
build_image() {
    local build_spec="$1"
    local image_dir="${build_spec%|*}"
    local tag="${build_spec#*|}"
    local image_name
    image_name=$(basename "$tag")

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would build $tag from $image_dir"
        return 0
    fi

    log_info "Building image: $tag"

    local build_log="$BUILD_LOGS_DIR/build-${image_name//\//-}-${TIMESTAMP}.log"
    local build_cmd="docker build"

    # Add build arguments
    if [[ "$REBUILD" == "true" ]]; then
        build_cmd="$build_cmd --no-cache"
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        build_cmd="$build_cmd --progress=plain"
    fi

    build_cmd="$build_cmd -t $tag"

    # Add registry tag if pushing
    if [[ "$PUSH" == "true" && "$REGISTRY" != "" ]]; then
        local registry_tag="$REGISTRY/${tag#*/}"
        build_cmd="$build_cmd -t $registry_tag"
    fi

    build_cmd="$build_cmd $image_dir"

    log_info "Executing: $build_cmd"

    # Execute build
    if eval "$build_cmd" 2>&1 | tee "$build_log"; then
        log_success "Built image: $tag"

        # Push if requested
        if [[ "$PUSH" == "true" ]]; then
            local push_tag="$tag"
            if [[ "$REGISTRY" != "" ]]; then
                push_tag="$REGISTRY/${tag#*/}"
            fi

            log_info "Pushing image: $push_tag"
            if docker push "$push_tag" 2>&1 | tee -a "$build_log"; then
                log_success "Pushed image: $push_tag"
            else
                log_error "Failed to push image: $push_tag"
                return 1
            fi
        fi

        return 0
    else
        log_error "Failed to build image: $tag"
        log_error "Build log: $build_log"
        return 1
    fi
}

# Build images in parallel
build_parallel() {
    local images=("$@")
    local pids=()
    local results=()

    log_info "Building ${#images[@]} images in parallel..."

    # Start all builds
    for image_spec in "${images[@]}"; do
        build_image "$image_spec" &
        pids+=($!)
        results+=(0)
    done

    # Wait for all builds to complete
    local failed=0
    for i in "${!pids[@]}"; do
        local pid="${pids[$i]}"
        if wait "$pid"; then
            results[$i]=0
        else
            results[$i]=1
            ((failed++))
        fi
    done

    return $failed
}

# Build images sequentially
build_sequential() {
    local images=("$@")
    local failed=0

    log_info "Building ${#images[@]} images sequentially..."

    for image_spec in "${images[@]}"; do
        if ! build_image "$image_spec"; then
            ((failed++))
        fi
    done

    return $failed
}

# Generate build report
generate_build_report() {
    local total_images="$1"
    local failed_builds="$2"
    local successful_builds=$((total_images - failed_builds))

    local report_file="$BUILD_LOGS_DIR/build-report-${TIMESTAMP}.md"

    cat > "$report_file" << EOF
# Build Report

**Generated**: $(date -u)
**Total Images**: $total_images
**Successful**: $successful_builds
**Failed**: $failed_builds
**Success Rate**: $(( successful_builds * 100 / total_images ))%

## Configuration

- **Registry**: $REGISTRY
- **Organization**: $ORGANIZATION
- **Push Images**: $PUSH
- **Parallel Builds**: $PARALLEL
- **Filter**: ${FILTER:-none}

## Build Results

$(if [[ $failed_builds -eq 0 ]]; then
    echo "All images built successfully!"
else
    echo "$failed_builds image(s) failed to build"
fi)

## Build Logs

Build logs are available in: \`$BUILD_LOGS_DIR\`

## Next Steps

$(if [[ $failed_builds -eq 0 ]]; then
    echo "- All images are ready for deployment"
    echo "- Consider running security scans on built images"
    echo "- Update image documentation if needed"
else
    echo "- Review failed build logs for errors"
    echo "- Fix any build issues and retry"
    echo "- Check Dockerfile syntax and dependencies"
fi)

---

**Titanium Labs Hardened Images** | Build System v1.0
EOF
    log_success "Build report generated: $report_file"
}

# Main build function
main() {
    parse_args "$@"
    setup_build_environment

    log_info "Starting automated image discovery and build process"

    # Discover all images
    local base_images=() app_images=() all_images=()

    # Read base images into array
    while IFS= read -r image; do
        [[ -n "$image" ]] && base_images+=("$image")
    done < <(discover_base_images)

    # Read app images into array
    while IFS= read -r image; do
        [[ -n "$image" ]] && app_images+=("$image")
    done < <(discover_app_images)

    # Combine all images, handling empty arrays safely
    all_images=()
    if [[ ${#base_images[@]} -gt 0 ]]; then
        all_images+=("${base_images[@]}")
    fi
    if [[ ${#app_images[@]} -gt 0 ]]; then
        all_images+=("${app_images[@]}")
    fi

    # Apply filter if specified
    if [[ -n "$FILTER" ]]; then
        local filtered_images=()
        for image_spec in "${all_images[@]}"; do
            local tag="${image_spec#*|}"
            if [[ "$tag" =~ $FILTER ]]; then
                filtered_images+=("$image_spec")
            fi
        done
        if [[ ${#filtered_images[@]} -gt 0 ]]; then
            all_images=("${filtered_images[@]}")
        else
            all_images=()
        fi
        log_info "Filtered to ${#all_images[@]} images matching: $FILTER"
    fi

    if [[ ${#all_images[@]} -eq 0 ]]; then
        log_warning "No images found to build"
        exit 0
    fi

    log_info "Found ${#all_images[@]} images to build"

    # Build images
    local failed_builds=0
    if [[ "$PARALLEL" == "true" && ${#all_images[@]} -gt 1 && "$DRY_RUN" != "true" ]]; then
        build_parallel "${all_images[@]}" || failed_builds=$?
    else
        build_sequential "${all_images[@]}" || failed_builds=$?
    fi

    # Generate build report (skip for dry-run)
    if [[ "$DRY_RUN" != "true" ]]; then
        generate_build_report "${#all_images[@]}" "$failed_builds"
    fi

    if [[ $failed_builds -eq 0 ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_success "Dry-run completed successfully!"
        else
            log_success "All images built successfully!"
        fi
        exit 0
    else
        log_error "$failed_builds image(s) failed to build"
        exit 1
    fi
}

# Run main function
main "$@"
