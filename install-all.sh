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
echo "Installed versions:"
echo
echo "  WezTerm     $(wezterm --version 2>/dev/null | awk '{print $2}' || echo 'unknown')"
echo "  Go          $(go version 2>/dev/null | awk '{print $3}' || echo 'not found')"
echo "  Neovim      $(nvim --version 2>/dev/null | head -n1 | awk '{print $2}' || echo 'not found')"
echo "  Claude Code $(claude --version 2>/dev/null || echo 'not found')"
echo "  NVM         $(bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && echo v$(nvm --version)' 2>/dev/null || echo 'not found')"
echo "  Node        $(bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && node --version' 2>/dev/null || echo 'not found')"
echo "  Docker      $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',' || echo 'not found')"
echo
echo "Next steps:"
echo "   1. Log out and log back in (or reboot) — REQUIRED for docker group to take effect"
echo "   2. Launch WezTerm"
echo
