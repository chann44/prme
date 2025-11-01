#!/bin/bash
# Build script for prime CLI
# Creates binaries for multiple platforms

set -e

VERSION="${VERSION:-v1.0.0}"
OUTPUT_DIR="./dist"
BINARY_NAME="prime"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Building ${BINARY_NAME} ${VERSION}${NC}\n"

# Clean and create output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Build flags
LDFLAGS="-s -w -X main.version=${VERSION}"

# Build for different platforms
build_binary() {
    local os=$1
    local arch=$2
    local output_name="${BINARY_NAME}"
    
    if [ "$os" = "windows" ]; then
        output_name="${BINARY_NAME}.exe"
    fi
    
    local output_path="${OUTPUT_DIR}/${BINARY_NAME}_${os}_${arch}"
    mkdir -p "$output_path"
    
    echo -e "${BLUE}Building for ${os}/${arch}...${NC}"
    GOOS=$os GOARCH=$arch go build -ldflags="${LDFLAGS}" -o "${output_path}/${output_name}" ./cmd/main.go
    
    # Copy templates directory
    cp -r templates "${output_path}/"
    
    # Create archive
    cd "$OUTPUT_DIR"
    if [ "$os" = "windows" ]; then
        zip -r "${BINARY_NAME}_${os}_${arch}.zip" "${BINARY_NAME}_${os}_${arch}" > /dev/null
    else
        tar -czf "${BINARY_NAME}_${os}_${arch}.tar.gz" "${BINARY_NAME}_${os}_${arch}"
    fi
    cd - > /dev/null
    
    echo -e "${GREEN}✓ Built ${BINARY_NAME}_${os}_${arch}${NC}"
}

# Build for common platforms
echo "Building binaries..."
echo ""

# macOS
build_binary "darwin" "amd64"   # Intel Mac
build_binary "darwin" "arm64"   # Apple Silicon

# Linux
build_binary "linux" "amd64"    # 64-bit Linux
build_binary "linux" "arm64"    # ARM64 Linux (Raspberry Pi, etc)

# Windows
build_binary "windows" "amd64"  # 64-bit Windows

echo ""
echo -e "${GREEN}✓ Build complete!${NC}"
echo ""
echo "Binaries are in the ${OUTPUT_DIR} directory:"
ls -lh "${OUTPUT_DIR}"/*.{tar.gz,zip} 2>/dev/null || true
echo ""
echo "To upload to GitHub Releases:"
echo "1. Create a new release: gh release create ${VERSION}"
echo "2. Upload binaries: gh release upload ${VERSION} ${OUTPUT_DIR}/*.tar.gz ${OUTPUT_DIR}/*.zip"

