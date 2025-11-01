#!/bin/bash
# Release script using GitHub API (no gh CLI required)
# Usage: ./release-api.sh v1.0.0 YOUR_GITHUB_TOKEN

set -e

# Configuration
BINARY_REPO="chann44/homebrew-prme"
SOURCE_REPO="chann44/prme"
BINARY_NAME="prime"
OUTPUT_DIR="./dist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
print_success() { echo -e "${GREEN}✓ $*${NC}"; }
print_error() { echo -e "${RED}✗ $*${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
print_step() { echo -e "${CYAN}▶ $*${NC}"; }

# Check arguments
if [ -z "$1" ]; then
    print_error "Version argument required"
    echo ""
    echo "Usage: $0 <version> [github_token]"
    echo "Example: $0 v1.0.0 ghp_xxxxx"
    echo ""
    echo "Get token from: https://github.com/settings/tokens"
    echo "Required scopes: repo (full control)"
    exit 1
fi

VERSION="$1"
GITHUB_TOKEN="${2:-${GITHUB_TOKEN}}"

if [ -z "$GITHUB_TOKEN" ]; then
    print_error "GitHub token required"
    echo ""
    echo "Usage: $0 <version> <github_token>"
    echo "Or set: export GITHUB_TOKEN=ghp_xxxxx"
    echo ""
    echo "Create a token at: https://github.com/settings/tokens"
    echo "Required scopes: repo (full control)"
    exit 1
fi

echo ""
print_info "🚀 Prime CLI Release Script (API Mode)"
print_info "Version: ${VERSION}"
print_info "Binary Repository: ${BINARY_REPO}"
echo ""

# Check if binaries exist
if [ ! -d "$OUTPUT_DIR" ]; then
    print_error "Build directory not found: ${OUTPUT_DIR}"
    print_info "Run ./build.sh first"
    exit 1
fi

# Verify binaries exist
binary_count=$(find "$OUTPUT_DIR" -name "*.tar.gz" -o -name "*.zip" | wc -l | xargs)
if [ "$binary_count" -eq 0 ]; then
    print_error "No binaries found in ${OUTPUT_DIR}"
    print_info "Run ./build.sh first"
    exit 1
fi

print_success "Found ${binary_count} binaries"

# Confirm
echo ""
print_warning "This will create release ${VERSION} in ${BINARY_REPO}"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Release cancelled"
    exit 0
fi

echo ""
print_step "Creating GitHub release"

# Create release notes
RELEASE_NOTES="## Prime CLI ${VERSION}

Installation:

\\\`\\\`\\\`bash
curl -fsSL https://raw.githubusercontent.com/${BINARY_REPO}/main/install.sh | sh
\\\`\\\`\\\`

Or download the binary for your platform below.

### Binaries

- **macOS (Apple Silicon)**: \\\`${BINARY_NAME}_darwin_arm64.tar.gz\\\`
- **macOS (Intel)**: \\\`${BINARY_NAME}_darwin_amd64.tar.gz\\\`
- **Linux (64-bit)**: \\\`${BINARY_NAME}_linux_amd64.tar.gz\\\`
- **Linux (ARM64)**: \\\`${BINARY_NAME}_linux_arm64.tar.gz\\\`
- **Windows (64-bit)**: \\\`${BINARY_NAME}_windows_amd64.zip\\\`

---

**Source Code**: https://github.com/${SOURCE_REPO}
**Documentation**: https://github.com/${SOURCE_REPO}#readme"

# Check if release exists
print_info "Checking if release exists..."
RELEASE_CHECK=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${BINARY_REPO}/releases/tags/${VERSION}")

if echo "$RELEASE_CHECK" | grep -q "\"tag_name\""; then
    print_warning "Release ${VERSION} already exists"
    
    # Get release ID
    RELEASE_ID=$(echo "$RELEASE_CHECK" | grep -o '"id": [0-9]*' | head -1 | grep -o '[0-9]*')
    
    read -p "Delete and recreate? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting existing release..."
        curl -s -X DELETE \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            "https://api.github.com/repos/${BINARY_REPO}/releases/${RELEASE_ID}" > /dev/null
        print_success "Deleted existing release"
    else
        print_info "Release cancelled"
        exit 0
    fi
fi

# Create the release
print_info "Creating release ${VERSION}..."
RELEASE_DATA=$(cat <<EOF
{
  "tag_name": "${VERSION}",
  "name": "Prime CLI ${VERSION}",
  "body": $(echo "$RELEASE_NOTES" | jq -Rs .),
  "draft": false,
  "prerelease": false
}
EOF
)

RELEASE_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$RELEASE_DATA" \
    "https://api.github.com/repos/${BINARY_REPO}/releases")

# Check if creation was successful
if echo "$RELEASE_RESPONSE" | grep -q "\"id\""; then
    RELEASE_ID=$(echo "$RELEASE_RESPONSE" | grep -o '"id": [0-9]*' | head -1 | grep -o '[0-9]*')
    UPLOAD_URL=$(echo "$RELEASE_RESPONSE" | grep -o '"upload_url": "[^"]*' | cut -d'"' -f4 | sed 's/{?name,label}//')
    print_success "Release created (ID: ${RELEASE_ID})"
else
    print_error "Failed to create release"
    echo "$RELEASE_RESPONSE" | jq . 2>/dev/null || echo "$RELEASE_RESPONSE"
    exit 1
fi

echo ""
print_step "Uploading binaries"
echo ""

# Upload each binary
for file in "${OUTPUT_DIR}"/*.tar.gz "${OUTPUT_DIR}"/*.zip; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    filename=$(basename "$file")
    print_info "Uploading ${filename}..."
    
    UPLOAD_RESPONSE=$(curl -s -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Content-Type: application/octet-stream" \
        --data-binary "@${file}" \
        "${UPLOAD_URL}?name=${filename}")
    
    if echo "$UPLOAD_RESPONSE" | grep -q "\"browser_download_url\""; then
        print_success "Uploaded ${filename}"
    else
        print_error "Failed to upload ${filename}"
        echo "$UPLOAD_RESPONSE" | jq . 2>/dev/null || echo "$UPLOAD_RESPONSE"
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

