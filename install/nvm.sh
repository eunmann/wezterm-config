#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing nvm (Node Version Manager)..."

# Check if nvm is already installed
if [ -d "$USER_HOME/.nvm" ]; then
  echo "    nvm already installed"
else
  echo "    Downloading and installing nvm..."
  # Install nvm using the official install script
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

  # Ensure ownership is correct
  chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/.nvm"
fi

# Load nvm into the current shell
export NVM_DIR="$USER_HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify nvm is available
if command -v nvm >/dev/null 2>&1 || type nvm >/dev/null 2>&1; then
  echo "    nvm installed successfully"
  nvm --version 2>/dev/null || echo "    nvm version: $(nvm --version 2>&1 | head -n1)"
else
  echo "!! nvm not found. It may require a new shell session."
fi

# Ensure nvm is loaded in future zsh sessions
ZSHRC="$USER_HOME/.zshrc"
NVM_LINES='
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

if [ -f "$ZSHRC" ] && ! grep -q 'NVM_DIR' "$ZSHRC"; then
  echo "    Adding nvm to .zshrc"
  echo "$NVM_LINES" >> "$ZSHRC"
  chown "$USER_NAME":"$USER_NAME" "$ZSHRC"
fi
