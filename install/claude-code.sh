#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing Claude Code (native binary)..."

if command -v claude >/dev/null 2>&1; then
  echo "    Claude Code already installed: $(claude --version 2>/dev/null || echo 'unknown version')"
  echo "    To update, run: claude update"
  exit 0
fi

# Install using the official installer (installs to ~/.local/bin/claude)
echo "    Running official installer..."
curl -fsSL https://claude.ai/install.sh | bash

echo "    Claude Code installed successfully"
