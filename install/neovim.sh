#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing latest Neovim from GitHub releases..."

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  NVIM_ARCH="linux-x86_64" ;;
  aarch64) NVIM_ARCH="linux-arm64" ;;
  *) echo "!! Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Query latest release tag
LATEST="$(curl -fsSL 'https://api.github.com/repos/neovim/neovim/releases/latest' | jq -r '.tag_name')"
echo "    Latest version: $LATEST"

# Check if already installed and up to date
if command -v nvim >/dev/null 2>&1; then
  CURRENT="$(nvim --version | head -n1 | awk '{print $2}')"
  if [ "$CURRENT" = "$LATEST" ]; then
    echo "    Neovim is already up to date ($CURRENT)"
    exit 0
  fi
  echo "    Upgrading from $CURRENT to $LATEST"
fi

# Download tarball
TARBALL="nvim-${NVIM_ARCH}.tar.gz"
URL="https://github.com/neovim/neovim/releases/download/${LATEST}/${TARBALL}"
echo "    Downloading $URL..."
TMP_TAR="$(mktemp --suffix=.tar.gz)"
curl -fsSL "$URL" -o "$TMP_TAR"

# Extract to /opt/nvim
echo "    Installing to /opt/nvim..."
sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf "$TMP_TAR"
rm -f "$TMP_TAR"

# Symlink to /usr/local/bin
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# Verify
echo "    Installed: $(nvim --version | head -n1)"
