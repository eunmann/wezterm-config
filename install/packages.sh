#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "==> Installing required packages (apt)..."
if need_sudo; then
  sudo apt update -y
  sudo apt install -y zsh unzip curl git xclip jq make gcc ripgrep fd-find
else
  apt update -y
  apt install -y zsh unzip curl git xclip jq make gcc ripgrep fd-find
fi

echo "    Packages installed successfully"
