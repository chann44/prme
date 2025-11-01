#!/bin/bash
# Release script for prime CLI
# Builds binaries and creates a GitHub release in the homebrew-prme repository
#
# Usage: ./release.sh v1.0.0
# Requires: GitHub CLI (gh) - install with: brew install gh

set -e

# Configuration
BINARY_REPO="chann44/homebrew-prme"  # Repository where binaries will be released
SOURCE_REPO="chann44/prme"           # Source code repository
BINARY_NAME="prime"
OUTPUT_DIR="./dist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $*${NC}"
}

print_error() {
    echo -e "${RED}✗ $*${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

print_step() {
    echo -e "${CYAN}▶ $*${NC}"
}

# Check if version is provided
if [ -z "$1" ]; then
    print_error "Version argument required"
    echo ""
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

VERSION="$1"

# Validate version format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_warning "Version should be in format: v1.0.0"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
print_info "🚀 Prime CLI Release Script"
print_info "Version: ${VERSION}"
print_info "Binary Repository: ${BINARY_REPO}"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed"
    echo ""
    echo "Install with: brew install gh"
    echo "Or visit: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI"
    echo ""
    echo "Run: gh auth login"
    exit 1
fi

print_success "GitHub CLI is authenticated"

# Confirm release
echo ""
print_warning "This will:"
echo "  1. Build binaries for all platforms"
echo "  2. Create release ${VERSION} in ${BINARY_REPO}"
echo "  3. Upload all binaries to the release"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Release cancelled"
    exit 0
fi

echo ""
print_step "Step 1: Cleaning previous builds"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
print_success "Clean complete"

echo ""
print_step "Step 2: Building binaries"
echo ""

# Build flags
LDFLAGS="-s -w -X main.version=${VERSION}"

build_binary() {
    local os=$1
    local arch=$2
    local output_name="${BINARY_NAME}"
    
    if [ "$os" = "windows" ]; then
        output_name="${BINARY_NAME}.exe"
    fi
    
    local output_path="${OUTPUT_DIR}/${BINARY_NAME}_${os}_${arch}"
    mkdir -p "$output_path"
    
    print_info "Building for ${os}/${arch}..."
    GOOS=$os GOARCH=$arch CGO_ENABLED=0 go build -ldflags="${LDFLAGS}" -o "${output_path}/${output_name}" ./cmd/main.go
    
    # Copy templates directory
    if [ -d "templates" ]; then
        cp -r templates "${output_path}/"
    fi
    
    # Copy README if exists
    if [ -f "README.md" ]; then
        cp README.md "${output_path}/"
    fi
    
    # Create archive
    cd "$OUTPUT_DIR"
    if [ "$os" = "windows" ]; then
        zip -r "${BINARY_NAME}_${os}_${arch}.zip" "${BINARY_NAME}_${os}_${arch}" > /dev/null
        rm -rf "${BINARY_NAME}_${os}_${arch}"
    else
        tar -czf "${BINARY_NAME}_${os}_${arch}.tar.gz" "${BINARY_NAME}_${os}_${arch}"
        rm -rf "${BINARY_NAME}_${os}_${arch}"
    fi
    cd - > /dev/null
    
    print_success "Built ${BINARY_NAME}_${os}_${arch}"
}

# Build for all platforms
build_binary "darwin" "amd64"   # Intel Mac
build_binary "darwin" "arm64"   # Apple Silicon
build_binary "linux" "amd64"    # 64-bit Linux
build_binary "linux" "arm64"    # ARM64 Linux
build_binary "windows" "amd64"  # 64-bit Windows

echo ""
print_success "All binaries built successfully"

echo ""
print_step "Step 3: Creating GitHub release"
echo ""

# Check if release already exists
if gh release view "$VERSION" --repo "$BINARY_REPO" &> /dev/null; then
    print_warning "Release ${VERSION} already exists in ${BINARY_REPO}"
    read -p "Delete and recreate? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting existing release..."
        gh release delete "$VERSION" --repo "$BINARY_REPO" --yes
        print_success "Deleted existing release"
    else
        print_info "Release cancelled"
        exit 0
    fi
fi

# Create release notes
RELEASE_NOTES="## Prime CLI ${VERSION}

Installation:

\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/${BINARY_REPO}/main/install.sh | sh
\`\`\`

Or download the binary for your platform below.

### Binaries

- **macOS (Apple Silicon)**: \`${BINARY_NAME}_darwin_arm64.tar.gz\`
- **macOS (Intel)**: \`${BINARY_NAME}_darwin_amd64.tar.gz\`
- **Linux (64-bit)**: \`${BINARY_NAME}_linux_amd64.tar.gz\`
- **Linux (ARM64)**: \`${BINARY_NAME}_linux_arm64.tar.gz\`
- **Windows (64-bit)**: \`${BINARY_NAME}_windows_amd64.zip\`

---

**Source Code**: https://github.com/${SOURCE_REPO}
**Documentation**: https://github.com/${SOURCE_REPO}#readme"

# Create release
print_info "Creating release ${VERSION}..."
gh release create "$VERSION" \
    --repo "$BINARY_REPO" \
    --title "Prime CLI ${VERSION}" \
    --notes "$RELEASE_NOTES"

print_success "Release created"

echo ""
print_step "Step 4: Uploading binaries"
echo ""

# Upload all archives
for file in "${OUTPUT_DIR}"/*.{tar.gz,zip}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        print_info "Uploading ${filename}..."
        gh release upload "$VERSION" "$file" --repo "$BINARY_REPO"
        print_success "Uploaded ${filename}"
    fi
done

echo ""
print_success "🎉 Release ${VERSION} published successfully!"
echo ""
print_info "Release URL: https://github.com/${BINARY_REPO}/releases/tag/${VERSION}"
echo ""
print_info "Users can install with:"
echo ""
echo "  curl -fsSL https://raw.githubusercontent.com/${BINARY_REPO}/main/install.sh | sh"
echo ""
print_info "Or manually download from:"
echo "  https://github.com/${BINARY_REPO}/releases/latest"
echo ""

