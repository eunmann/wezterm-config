#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing devstart..."

DEST="$USER_HOME/.local/bin/devstart"

mkdir -p "$USER_HOME/.local/bin"
chown "$USER_NAME":"$USER_NAME" "$USER_HOME/.local/bin"
cp "$REPO_ROOT/devstart" "$DEST"
chown "$USER_NAME":"$USER_NAME" "$DEST"
chmod +x "$DEST"

echo "    Installed to $DEST"
echo "    ~/.local/bin is already on PATH via .zshrc"
