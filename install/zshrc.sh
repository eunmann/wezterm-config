#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing .zshrc to $USER_HOME..."
install_dotfile "$REPO_ROOT/.zshrc" "$USER_HOME/.zshrc"
