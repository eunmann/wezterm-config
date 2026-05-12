#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing Neovim configuration (kickstart.nvim)..."

NVIM_CONFIG="$USER_HOME/.config/nvim"
REPO_URL="https://github.com/eunmann/kickstart.nvim.git"

# Run a command as the real user (handles running under sudo)
as_user() {
  if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    sudo -u "$USER_NAME" -- "$@"
  else
    "$@"
  fi
}

# If ~/.config/nvim exists, check if it's already our repo
if [ -d "$NVIM_CONFIG/.git" ]; then
  REMOTE="$(git -C "$NVIM_CONFIG" remote get-url origin 2>/dev/null || echo "")"
  if [[ "$REMOTE" == *"eunmann/kickstart.nvim"* ]]; then
    echo "    Config already installed, pulling latest..."
    if as_user git -C "$NVIM_CONFIG" pull --ff-only 2>/dev/null; then
      echo "    Config up to date"
    else
      echo "    WARNING: git pull failed — local changes or upstream divergence"
      echo "    To update manually: cd $NVIM_CONFIG && git stash && git pull && git stash pop"
    fi
    exit 0
  fi
fi

# Back up any existing config
if [ -d "$NVIM_CONFIG" ]; then
  BACKUP="$NVIM_CONFIG.bak.$(date +%Y%m%d-%H%M%S)"
  echo "    Backing up existing config to $BACKUP"
  mv "$NVIM_CONFIG" "$BACKUP"
fi

# Ensure ~/.config exists with correct ownership
as_user mkdir -p "$USER_HOME/.config"

# Clone the config
echo "    Cloning eunmann/kickstart.nvim to $NVIM_CONFIG..."
as_user git clone "$REPO_URL" "$NVIM_CONFIG"

echo "    Neovim configuration installed"
echo "    First launch of nvim will auto-install plugins (requires internet)"
