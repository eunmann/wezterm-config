#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

echo "========================================"
echo "  Nix Package Manager Setup"
echo "========================================"
echo

# Run Nix installation modules
"$INSTALL_DIR/nix.sh"
echo

"$INSTALL_DIR/nix-packages.sh"
echo

echo "========================================"
echo "✅ Nix installation complete!"
echo "========================================"
echo
echo "Installed:"
echo "  • Nix package manager (multi-user/daemon mode)"
echo "  • Experimental features enabled (nix-command, flakes)"
echo "  • Neovim (via Nix)"
echo "  • Go (via Nix)"
echo
echo "👉 Next steps:"
echo "   1. Start a new terminal session to ensure PATH is updated"
echo "   2. Verify with: nvim --version && go version"
echo "   3. Update packages with: nix profile upgrade '.*'"
echo "   4. Search for packages with: nix search nixpkgs <package>"
echo
