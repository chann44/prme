#!/bin/bash
# Installation script for prime CLI
# Usage: curl -fsSL https://raw.githubusercontent.com/chann44/homebrew-prme/main/install.sh | sh
#
# You can customize the installation by setting environment variables:
#   INSTALL_DIR - Installation directory (default: /usr/local/bin)
#   VERSION - Specific version to install (default: latest)

set -e

# Configuration
BINARY_REPO="chann44/homebrew-prme"  # Repository hosting the binaries
BINARY_NAME="prime"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION="${VERSION:-latest}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
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

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "darwin";;
        MINGW*|MSYS*|CYGWIN*) echo "windows";;
        *)
            print_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)   echo "amd64";;
        aarch64|arm64)  echo "arm64";;
        armv7l)         echo "arm";;
        *)
            print_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
}

# Get latest version from GitHub
get_latest_version() {
    if [ "$VERSION" != "latest" ]; then
        echo "$VERSION"
        return
    fi
    
    local latest_version
    latest_version=$(curl -fsSL "https://api.github.com/repos/${BINARY_REPO}/releases/latest" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$latest_version" ]; then
        print_error "Could not fetch latest version from GitHub"
        print_info "Please specify a version: VERSION=v1.0.0 curl ... | sh"
        exit 1
    fi
    
    echo "$latest_version"
}

# Download and install binary
install_binary() {
    local os=$1
    local arch=$2
    local version=$3
    local tmp_dir
    tmp_dir=$(mktemp -d)
    
    local filename="${BINARY_NAME}_${os}_${arch}"
    local extension="tar.gz"
    local binary_path="${BINARY_NAME}"
    
    if [ "$os" = "windows" ]; then
        extension="zip"
        binary_path="${BINARY_NAME}.exe"
    fi
    
    local download_url="https://github.com/${BINARY_REPO}/releases/download/${version}/${filename}.${extension}"
    
    print_info "Downloading ${BINARY_NAME} ${version} for ${os}/${arch}..."
    
    # Download
    if ! curl -fsSL "$download_url" -o "${tmp_dir}/archive.${extension}"; then
        print_error "Failed to download from ${download_url}"
        echo ""
        print_info "Please check:"
        print_info "  - Release exists: https://github.com/${BINARY_REPO}/releases/tag/${version}"
        print_info "  - Binary file exists: ${filename}.${extension}"
        echo ""
        rm -rf "$tmp_dir"
        exit 1
    fi
    
    print_success "Downloaded successfully"
    
    # Extract
    print_info "Extracting binary..."
    cd "$tmp_dir"
    
    if [ "$extension" = "tar.gz" ]; then
        tar -xzf "archive.${extension}"
    elif [ "$extension" = "zip" ]; then
        unzip -q "archive.${extension}"
    fi
    
    # Find the binary (it's in a subdirectory)
    local binary_file
    binary_file=$(find . -name "$binary_path" -type f | head -n 1)
    
    if [ -z "$binary_file" ]; then
        print_error "Binary not found in archive"
        rm -rf "$tmp_dir"
        exit 1
    fi
    
    chmod +x "$binary_file"
    
    # Install
    print_info "Installing ${BINARY_NAME} to ${INSTALL_DIR}..."
    
    if [ -w "$INSTALL_DIR" ]; then
        cp "$binary_file" "${INSTALL_DIR}/${BINARY_NAME}"
    else
        print_warning "Requesting sudo privileges to install to ${INSTALL_DIR}"
        sudo cp "$binary_file" "${INSTALL_DIR}/${BINARY_NAME}"
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$tmp_dir"
    
    print_success "${BINARY_NAME} installed successfully!"
}

# Verify installation
verify_installation() {
    if command -v "$BINARY_NAME" &> /dev/null; then
        local installed_version
        installed_version=$("$BINARY_NAME" --version 2>&1 || echo "")
        print_success "Verification: ${BINARY_NAME} is available in PATH"
        if [ -n "$installed_version" ]; then
            print_info "Version: ${installed_version}"
        fi
        echo ""
        print_info "Run '${BINARY_NAME}' to get started! 🚀"
    else
        print_warning "${BINARY_NAME} was installed but not found in PATH"
        echo ""
        print_info "You may need to:"
        print_info "  1. Restart your terminal"
        print_info "  2. Or run: export PATH=\"${INSTALL_DIR}:\$PATH\""
    fi
}

# Main installation
main() {
    echo ""
    print_info "🚀 Prime CLI Installer"
    echo ""
    
    # Check required commands
    for cmd in curl uname; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "Required command not found: $cmd"
            exit 1
        fi
    done
    
    # Detect platform
    local os arch
    os=$(detect_os)
    arch=$(detect_arch)
    print_info "Detected platform: ${os}/${arch}"
    
    # Get version
    local version
    version=$(get_latest_version)
    print_info "Version: ${version}"
    
    # Check if already installed
    if command -v "$BINARY_NAME" &> /dev/null; then
        local current_version
        current_version=$("$BINARY_NAME" --version 2>&1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        
        print_warning "${BINARY_NAME} is already installed"
        if [ "$current_version" != "unknown" ]; then
            print_info "Current version: ${current_version}"
        fi
        echo ""
        read -p "Do you want to reinstall/upgrade to ${version}? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Install
    echo ""
    install_binary "$os" "$arch" "$version"
    
    # Verify
    echo ""
    verify_installation
    
    echo ""
    print_success "🎉 Installation complete!"
    echo ""
    print_info "Documentation: https://github.com/chann44/prme"
    print_info "Report issues: https://github.com/chann44/prme/issues"
    echo ""
}

main
