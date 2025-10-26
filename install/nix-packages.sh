#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing packages via Nix..."

# Load Nix into the current shell
if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -r /etc/profile.d/nix.sh ]; then
  # shellcheck disable=SC1091
  . /etc/profile.d/nix.sh
elif [ -r "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Verify nix is available
if ! command -v nix >/dev/null 2>&1; then
  echo "!! Nix not found. Please run install/nix.sh first."
  exit 1
fi

# Install Neovim and Go into user profile (permanent)
echo "    Installing Neovim and Go..."
nix profile install nixpkgs#neovim nixpkgs#go

# Verify installations
echo "    Verifying installed binaries:"
if command -v nvim >/dev/null 2>&1; then
  echo "      - nvim: $(nvim --version | head -n1)"
else
  echo "      !! nvim not found (may need new shell)"
fi

if command -v go >/dev/null 2>&1; then
  echo "      - go: $(go version)"
else
  echo "      !! go not found (may need new shell)"
fi

echo "    Packages installed successfully"
