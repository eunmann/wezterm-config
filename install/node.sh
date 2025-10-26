#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

NODE_VERSION="22"

echo "==> Installing Node.js ${NODE_VERSION}..."

# Load nvm
export NVM_DIR="$USER_HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
else
  echo "!! nvm not found. Please run install/nvm.sh first."
  exit 1
fi

# Install Node 22
echo "    Installing Node ${NODE_VERSION} via nvm..."
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"
nvm alias default "$NODE_VERSION"

# Verify installation
echo "    Node version: $(node --version)"
echo "    npm version: $(npm --version)"

echo "    Node.js ${NODE_VERSION} installed successfully"
