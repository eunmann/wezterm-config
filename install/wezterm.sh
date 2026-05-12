#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "==> Installing WezTerm (apt)..."

# Check if already installed
if command -v wezterm >/dev/null 2>&1; then
  CURRENT="$(wezterm --version 2>/dev/null | awk '{print $2}' || echo "unknown")"
  echo "    WezTerm already installed ($CURRENT)"
  echo "    To update, run: sudo apt update && sudo apt upgrade wezterm"
  exit 0
fi

# Add GPG key and apt repository
echo "    Adding WezTerm apt repository..."
if need_sudo; then
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
  sudo apt update -y
  sudo apt install -y wezterm
else
  curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list >/dev/null
  chmod 644 /usr/share/keyrings/wezterm-fury.gpg
  apt update -y
  apt install -y wezterm
fi

echo "    WezTerm installed: $(wezterm --version 2>/dev/null || echo 'unknown')"
