#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

echo "========================================"
echo "  Development Tools Setup"
echo "========================================"
echo

# Run installation modules
"$INSTALL_DIR/go.sh"
echo

"$INSTALL_DIR/neovim.sh"
echo

"$INSTALL_DIR/nvim-config.sh"
echo

"$INSTALL_DIR/claude-code.sh"
echo

"$INSTALL_DIR/nvm.sh"
echo

"$INSTALL_DIR/devstart.sh"
echo

echo "========================================"
echo "  Development tools installation complete!"
echo "========================================"
echo
echo "Installed versions:"
echo
echo "  Go          $(go version 2>/dev/null | awk '{print $3}' || echo 'not found')"
echo "  Neovim      $(nvim --version 2>/dev/null | head -n1 | awk '{print $2}' || echo 'not found')"
echo "  Claude Code $(claude --version 2>/dev/null || echo 'not found')"
echo "  NVM         $(bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && echo v$(nvm --version)' 2>/dev/null || echo 'not found')"
echo "  Node        $(bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && node --version' 2>/dev/null || echo 'not found')"
echo
echo "Next steps:"
echo "   Start a new terminal session to ensure PATH is updated"
echo
