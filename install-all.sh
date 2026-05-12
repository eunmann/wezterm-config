#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  Complete Development Environment Setup"
echo "========================================"
echo
echo "This will install:"
echo "  1. Terminal Setup (WezTerm + Zsh)"
echo "  2. Development Tools (Go + Neovim + Claude Code)"
echo "  3. Docker"
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

"$SCRIPT_DIR/install-devtools.sh"

echo
echo "========================================"
echo "  Phase 2 Complete!"
echo "========================================"
echo

# ======================================
# Phase 3: Docker
# ======================================
echo "========================================"
echo "  PHASE 3: Docker"
echo "========================================"
echo

"$SCRIPT_DIR/install/docker.sh"

echo
echo "========================================"
echo "  Phase 3 Complete!"
echo "========================================"
echo

# ======================================
# Final Summary
# ======================================
echo "========================================"
echo "  Complete Installation Finished!"
echo "========================================"
echo
echo "Installed:"
echo
echo "Terminal Setup:"
echo "  - WezTerm (Flatpak)"
echo "  - SauceCodePro Nerd Font"
echo "  - Zsh as default shell"
echo "  - Custom terminal configurations"
echo
echo "Development Tools:"
echo "  - Go (latest from go.dev)"
echo "  - Neovim (latest from GitHub)"
echo "  - Claude Code (native binary)"
echo "  - NVM + Node LTS"
echo
echo "Container Platform:"
echo "  - Docker"
echo
echo "Next steps:"
echo "   1. Log out and log back in (or reboot) - REQUIRED for docker group to take effect"
echo "   2. Launch WezTerm"
echo "   3. Verify installations:"
echo "      - go version"
echo "      - nvim --version"
echo "      - claude --version"
echo "      - node --version"
echo "      - docker --version"
echo "      - docker run hello-world  (test Docker)"
echo
