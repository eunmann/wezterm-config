#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

echo "========================================"
echo "  WezTerm + Zsh Development Setup"
echo "========================================"
echo

# Run installation modules
"$INSTALL_DIR/packages.sh"
echo

"$INSTALL_DIR/wezterm.sh"
echo

"$INSTALL_DIR/fonts.sh"
echo

"$INSTALL_DIR/zsh-setup.sh"
echo

"$INSTALL_DIR/dotfiles.sh"
echo

echo "========================================"
echo "✅ Installation complete!"
echo "========================================"
echo
echo "Installed:"
echo "  • WezTerm (apt)"
echo "  • SauceCodePro Nerd Font (system-wide)"
echo "  • zsh as default shell"
echo "  • ~/.zshrc with git status integration"
echo "  • ~/.wezterm.lua with theme and keybindings"
echo
echo "👉 Next steps:"
echo "   1. Restart WezTerm (or start it if not running)"
echo "   2. If still in bash, run: exec zsh"
echo
