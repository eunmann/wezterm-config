#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

TS="$(date +%Y%m%d-%H%M%S)"

echo "==> Installing dotfiles to $USER_HOME..."

# Install .zshrc
ZSHRC="${USER_HOME}/.zshrc"
if [ -f "$ZSHRC" ]; then
  cp -a "$ZSHRC" "$ZSHRC.bak.$TS"
  echo "    Backed up existing .zshrc to .zshrc.bak.$TS"
fi
cp "$REPO_ROOT/.zshrc" "$ZSHRC"
chown "$USER_NAME":"$USER_NAME" "$ZSHRC"
echo "    Installed .zshrc"

# Install .wezterm.lua
WEZRC="${USER_HOME}/.wezterm.lua"
if [ -f "$WEZRC" ]; then
  cp -a "$WEZRC" "$WEZRC.bak.$TS"
  echo "    Backed up existing .wezterm.lua to .wezterm.lua.bak.$TS"
fi
cp "$REPO_ROOT/.wezterm.lua" "$WEZRC"
chown "$USER_NAME":"$USER_NAME" "$WEZRC"
echo "    Installed .wezterm.lua"
