#!/bin/bash

# Deploy script for Linux - Ziglets Multi-platform Release
# This script builds Ziglets for multiple Linux targets and creates release artifacts
# 
# Usage: ./deploy-linux.sh [tag_name]
# 
# Prerequisites:
# - Zig compiler installed and available in PATH
# - Git repository with proper tags
# - Write permissions to create artifacts directory

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ARTIFACTS_DIR="${PROJECT_ROOT}/artifacts"
BUILD_DIR="${PROJECT_ROOT}/zig-out"

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're on a tagged commit
check_tag() {
    local tag_name="$1"
    
    # Check if we're on a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Check if the tag exists
    if ! git tag -l | grep -q "^${tag_name}$"; then
        print_error "Tag '${tag_name}' does not exist"
        exit 1
    fi
    
    # Check if we're currently on the tagged commit
    local current_commit=$(git rev-parse HEAD)
    local tag_commit=$(git rev-parse "${tag_name}")
    
    if [ "${current_commit}" != "${tag_commit}" ]; then
        print_error "Current commit is not the tagged commit for '${tag_name}'"
        print_error "Current: ${current_commit}"
        print_error "Tagged:  ${tag_commit}"
        exit 1
    fi
    
    print_success "Validated tag '${tag_name}' matches current commit"
}

# Function to validate semantic versioning tag format
validate_semver_tag() {
    local tag="$1"
    
    # Check if tag follows v*.*.* format (semantic versioning)
    if [[ ! $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Tag '${tag}' does not follow semantic versioning format (vMAJOR.MINOR.PATCH)"
        print_error "Expected format: v1.0.0, v2.1.3, etc."
        exit 1
    fi
    
    print_success "Tag '${tag}' follows semantic versioning format"
}

# Function to build for a specific target
build_target() {
    local target="$1"
    local output_name="$2"
    
    print_info "Building for target: ${target}"
    
    # Clean previous build
    rm -rf "${BUILD_DIR}"
    
    # Build for the specific target
    if ! zig build -Dtarget="${target}" -Doptimize=ReleaseFast; then
        print_error "Failed to build for target: ${target}"
        return 1
    fi
    
    # Create target-specific artifact directory
    local target_dir="${ARTIFACTS_DIR}/${target}"
    mkdir -p "${target_dir}"
    
    # Copy binary to artifacts directory
    if [ -f "${BUILD_DIR}/bin/ziglets" ]; then
        cp "${BUILD_DIR}/bin/ziglets" "${target_dir}/${output_name}"
        print_success "Built ${output_name} for ${target}"
    else
        print_error "Binary not found for target: ${target}"
        return 1
    fi
    
    # Create compressed archive
    cd "${ARTIFACTS_DIR}"
    tar -czf "${output_name}-${target}.tar.gz" -C "${target}" "${output_name}"
    print_success "Created archive: ${output_name}-${target}.tar.gz"
    cd "${PROJECT_ROOT}"
}

# Main deployment function
deploy() {
    local tag_name="${1:-}"
    
    # If no tag provided, try to get current tag
    if [ -z "${tag_name}" ]; then
        tag_name=$(git describe --tags --exact-match 2>/dev/null || echo "")
        if [ -z "${tag_name}" ]; then
            print_error "No tag specified and current commit is not tagged"
            print_error "Usage: $0 [tag_name]"
            exit 1
        fi
    fi
    
    print_info "Starting deployment for tag: ${tag_name}"
    
    # Validate tag format and commit
    validate_semver_tag "${tag_name}"
    check_tag "${tag_name}"
    
    # Extract version from tag (remove 'v' prefix)
    local version="${tag_name#v}"
    local output_name="ziglets-${version}"
    
    # Change to project root
    cd "${PROJECT_ROOT}"
    
    # Clean and create artifacts directory
    rm -rf "${ARTIFACTS_DIR}"
    mkdir -p "${ARTIFACTS_DIR}"
    
    print_info "Building Ziglets version ${version} for multiple Linux targets"
    
    # Define target platforms for Linux
    local targets=(
        "x86_64-linux-gnu"
        "x86_64-linux-musl"
        "aarch64-linux-gnu"
        "aarch64-linux-musl"
    )
    
    # Build for each target
    local failed_builds=()
    for target in "${targets[@]}"; do
        if ! build_target "${target}" "${output_name}"; then
            failed_builds+=("${target}")
            print_warning "Failed to build for ${target}, continuing with other targets"
        fi
    done
    
    # Report results
    if [ ${#failed_builds[@]} -eq 0 ]; then
        print_success "All Linux targets built successfully!"
    else
        print_warning "Some builds failed: ${failed_builds[*]}"
        print_warning "Successful builds are available in: ${ARTIFACTS_DIR}"
    fi
    
    # Create checksums for all artifacts
    cd "${ARTIFACTS_DIR}"
    if ls *.tar.gz 1> /dev/null 2>&1; then
        sha256sum *.tar.gz > checksums.txt
        print_success "Created checksums.txt"
    fi
    
    print_success "Deployment completed for tag: ${tag_name}"
    print_info "Artifacts available in: ${ARTIFACTS_DIR}"
    
    # List created artifacts
    print_info "Created artifacts:"
    ls -la "${ARTIFACTS_DIR}"
}

# Script entry point
main() {
    print_info "Ziglets Linux Deployment Script"
    print_info "Project: $(basename "${PROJECT_ROOT}")"
    print_info "Script: $0"
    print_info "Arguments: $*"
    
    # Check prerequisites
    if ! command -v zig &> /dev/null; then
        print_error "Zig compiler not found in PATH"
        exit 1
    fi
    
    print_info "Using Zig: $(zig version)"
    
    # Start deployment
    deploy "$@"
}

# Run main function with all arguments
main "$@"
