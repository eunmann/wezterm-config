#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  Complete Development Environment Setup"
echo "========================================"
echo
echo "This will install:"
echo "  1. Terminal Setup (WezTerm + Zsh)"
echo "  2. Development Tools (Nix + Neovim + Go)"
echo "  3. Node.js Environment (nvm + Node 22 + Claude Code)"
echo "  4. Docker"
echo
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Installation cancelled."
  exit 0
fi
echo

# ======================================
# Phase 1: Terminal Setup
# ======================================
echo "========================================"
echo "  PHASE 1: Terminal Setup"
echo "========================================"
echo

"$SCRIPT_DIR/install.sh"

echo
echo "========================================"
echo "  Phase 1 Complete!"
echo "========================================"
echo

# ======================================
# Phase 2: Development Tools
# ======================================
echo "========================================"
echo "  PHASE 2: Development Tools"
echo "========================================"
echo

"$SCRIPT_DIR/install-nix.sh"

echo
echo "========================================"
echo "  Phase 2 Complete!"
echo "========================================"
echo

# ======================================
# Phase 3: Node.js Environment
# ======================================
echo "========================================"
echo "  PHASE 3: Node.js Environment"
echo "========================================"
echo

"$SCRIPT_DIR/install-node.sh"

echo
echo "========================================"
echo "  Phase 3 Complete!"
echo "========================================"
echo

# ======================================
# Phase 4: Docker
# ======================================
echo "========================================"
echo "  PHASE 4: Docker"
echo "========================================"
echo

"$SCRIPT_DIR/install/docker.sh"

echo
echo "========================================"
echo "  Phase 4 Complete!"
echo "========================================"
echo

# ======================================
# Final Summary
# ======================================
echo "========================================"
echo "🎉 Complete Installation Finished!"
echo "========================================"
echo
echo "Installed:"
echo
echo "Terminal Setup:"
echo "  ✓ WezTerm (Flatpak)"
echo "  ✓ SauceCodePro Nerd Font"
echo "  ✓ Zsh as default shell"
echo "  ✓ Custom terminal configurations"
echo
echo "Development Tools:"
echo "  ✓ Nix package manager"
echo "  ✓ Neovim"
echo "  ✓ Go"
echo
echo "Node.js Environment:"
echo "  ✓ nvm (Node Version Manager)"
echo "  ✓ Node.js 22"
echo "  ✓ npm"
echo "  ✓ Claude Code CLI"
echo
echo "Container Platform:"
echo "  ✓ Docker"
echo
echo "👉 Next steps:"
echo "   1. Log out and log back in (or reboot) - REQUIRED for docker group to take effect"
echo "   2. Launch WezTerm"
echo "   3. Verify installations:"
echo "      - nvim --version"
echo "      - go version"
echo "      - nix --version"
echo "      - node --version"
echo "      - claude-code --version"
echo "      - docker --version"
echo "      - docker run hello-world  (test Docker)"
echo
