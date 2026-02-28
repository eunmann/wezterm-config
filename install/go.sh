#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing latest Go from go.dev..."

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  GOARCH="amd64" ;;
  aarch64) GOARCH="arm64" ;;
  *) echo "!! Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Query latest stable version
LATEST="$(curl -fsSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version')"
echo "    Latest version: $LATEST"

# Check if already installed and up to date
if command -v go >/dev/null 2>&1; then
  CURRENT="$(go version | awk '{print $3}')"
  if [ "$CURRENT" = "$LATEST" ]; then
    echo "    Go is already up to date ($CURRENT)"
    exit 0
  fi
  echo "    Upgrading from $CURRENT to $LATEST"
fi

# Download and extract
TARBALL="${LATEST}.linux-${GOARCH}.tar.gz"
URL="https://go.dev/dl/${TARBALL}"
echo "    Downloading $URL..."
TMP_TAR="$(mktemp --suffix=.tar.gz)"
curl -fsSL "$URL" -o "$TMP_TAR"

# Install to /usr/local/go (remove old install first, per Go docs)
echo "    Installing to /usr/local/go..."
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$TMP_TAR"
rm -f "$TMP_TAR"

# Ensure /usr/local/go/bin is on PATH via ~/.profile
PROFILE="$USER_HOME/.profile"
PATH_LINE='export PATH="/usr/local/go/bin:$PATH"'
if ! grep -Fq '/usr/local/go/bin' "$PROFILE" 2>/dev/null; then
  echo "    Adding Go to PATH in ~/.profile"
  echo "$PATH_LINE" >> "$PROFILE"
  chown "$USER_NAME":"$USER_NAME" "$PROFILE"
fi

# Verify
export PATH="/usr/local/go/bin:$PATH"
echo "    Installed: $(go version)"
