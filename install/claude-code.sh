#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing Claude Code CLI..."

# Load nvm to ensure node/npm are available
export NVM_DIR="$USER_HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
else
  echo "!! nvm not found. Please run install/nvm.sh and install/node.sh first."
  exit 1
fi

# Verify node is available
if ! command -v npm >/dev/null 2>&1; then
  echo "!! npm not found. Please run install/node.sh first."
  exit 1
fi

# Install Claude Code globally
echo "    Installing @anthropic-ai/claude-code globally..."
npm install -g @anthropic-ai/claude-code

# Verify installation
if command -v claude-code >/dev/null 2>&1; then
  echo "    Claude Code installed successfully"
  claude-code --version || echo "    Claude Code is ready"
else
  echo "!! Claude Code not found in PATH. May need new shell session."
fi
