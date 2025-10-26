#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

echo "========================================"
echo "  Node.js Development Setup"
echo "========================================"
echo

# Run Node.js installation modules
"$INSTALL_DIR/nvm.sh"
echo

"$INSTALL_DIR/node.sh"
echo

"$INSTALL_DIR/claude-code.sh"
echo

echo "========================================"
echo "✅ Node.js setup complete!"
echo "========================================"
echo
echo "Installed:"
echo "  • nvm (Node Version Manager)"
echo "  • Node.js 22"
echo "  • npm (with Node.js)"
echo "  • Claude Code CLI"
echo
echo "👉 Next steps:"
echo "   1. Start a new terminal session (or run: exec zsh)"
echo "   2. Verify installations:"
echo "      - node --version"
echo "      - npm --version"
echo "      - claude-code --version"
echo "   3. Start using Claude Code: claude-code"
echo
