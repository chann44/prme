# 🚀 Release Guide for Prime CLI

This guide explains how to create releases for the Prime CLI using GoReleaser.

## Prerequisites

1. **Install GoReleaser** (for local testing):
   ```bash
   brew install goreleaser
   ```

2. **Create Homebrew Tap Repository** (one-time setup):
   - Go to GitHub and create a new repository named `homebrew-prime`
   - Clone it locally:
     ```bash
     git clone https://github.com/chann44/homebrew-prime.git
     cd homebrew-prime
     mkdir Formula
     git add Formula
     git commit -m "Initialize Formula directory"
     git push
     ```

## Creating a Release

### Method 1: Automatic Release (Recommended)

Simply push a git tag, and GitHub Actions will handle everything:

```bash
# Make sure your changes are committed
git add .
git commit -m "feat: add new features"

# Create and push a tag
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin main
git push origin v0.1.0
```

That's it! GitHub Actions will automatically:
- Build binaries for all platforms (macOS, Linux, Windows)
- Create a GitHub release with binaries
- Update the Homebrew formula in your tap repository

### Method 2: Manual Release (for testing)

Test the release process locally before pushing:

```bash
# Set your GitHub token
export GITHUB_TOKEN="your_github_personal_access_token"

# Create a snapshot (doesn't publish)
goreleaser release --snapshot --clean

# Or do a full release
git tag -a v0.1.0 -m "Release v0.1.0"
goreleaser release --clean
```

## Release Checklist

Before creating a release:

- [ ] Update version numbers if needed
- [ ] Test the CLI thoroughly
- [ ] Update CHANGELOG or release notes
- [ ] Commit all changes
- [ ] Create a git tag with proper version (v0.1.0, v1.0.0, etc.)
- [ ] Push the tag
- [ ] Verify the GitHub Actions workflow completes successfully
- [ ] Check that binaries are uploaded to GitHub Releases
- [ ] Test Homebrew installation: `brew tap chann44/prime && brew install prime`

## Versioning

Follow [Semantic Versioning](https://semver.org/):

- **v1.0.0** - Major release (breaking changes)
- **v0.1.0** - Minor release (new features, backward compatible)
- **v0.0.1** - Patch release (bug fixes)

Add `-alpha`, `-beta`, or `-rc` suffix for pre-releases:
- **v0.1.0-alpha**
- **v0.1.0-beta.1**
- **v1.0.0-rc.1**

## GitHub Personal Access Token

To create a GitHub token:

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name: "GoReleaser for Prime"
4. Select scopes:
   - `repo` (full control of private repositories)
   - `write:packages` (if publishing packages)
5. Click "Generate token"
6. Copy the token and store it securely

Add to your environment:
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

For GitHub Actions, the `GITHUB_TOKEN` is automatically provided (no need to add secrets).

## Troubleshooting

### Homebrew formula not updating

1. Check that `homebrew-prime` repository exists
2. Verify the repository name in `.goreleaser.yml` is correct
3. Ensure the GitHub token has proper permissions
4. Check GitHub Actions logs for errors

### Build failures

1. Make sure `go.mod` and `go.sum` are up to date: `go mod tidy`
2. Test local build: `go build -o prime cmd/main.go`
3. Check `.goreleaser.yml` syntax

### Release notes not generated

- Make sure you have at least 2 tags for changelog generation
- Use conventional commit messages: `feat:`, `fix:`, `docs:`, etc.

## Testing Releases Locally

Before pushing a tag, test the build process:

```bash
# Install GoReleaser
brew install goreleaser

# Create a snapshot release (doesn't publish)
goreleaser release --snapshot --clean

# Check the dist/ directory
ls -la dist/

# Test the binary
./dist/prime_darwin_arm64/prime
```

## After Release

Once the release is published:

1. **Test Homebrew Installation**:
   ```bash
   brew tap chann44/prime
   brew install prime
   prime --version
   ```

2. **Announce the Release**:
   - Share on social media
   - Update documentation
   - Notify users

3. **Monitor Issues**:
   - Check for bug reports
   - Respond to user feedback

## What Gets Built

GoReleaser will create binaries for:

- **macOS**: Intel (amd64) and Apple Silicon (arm64)
- **Linux**: amd64, arm64, arm
- **Windows**: amd64

Each platform gets:
- Compressed archive (.tar.gz or .zip)
- Checksum file
- Homebrew formula (macOS/Linux only)

## File Structure After Release

```
dist/
├── checksums.txt
├── prime_0.1.0_Darwin_arm64.tar.gz
├── prime_0.1.0_Darwin_x86_64.tar.gz
├── prime_0.1.0_Linux_arm64.tar.gz
├── prime_0.1.0_Linux_x86_64.tar.gz
├── prime_0.1.0_Windows_x86_64.zip
└── ...
```

## Resources

- [GoReleaser Documentation](https://goreleaser.com/)
- [Semantic Versioning](https://semver.org/)
- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

