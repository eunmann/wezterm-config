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
echo "Installed:"
echo "  - Go (latest, /usr/local/go)"
echo "  - Neovim (latest, /opt/nvim) + kickstart.nvim config (~/.config/nvim)"
echo "  - Claude Code (native binary, ~/.local/bin)"
echo "  - NVM + Node LTS (~/.nvm)"
echo "  - devstart (nvim + claude split, ~/.local/bin)"
echo
echo "Next steps:"
echo "   1. Start a new terminal session to ensure PATH is updated"
echo "   2. Verify with: go version && nvim --version && claude --version && node --version"
echo
