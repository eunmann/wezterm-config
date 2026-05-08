#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WEZTERM_APP_ID="org.wezfurlong.wezterm"

echo "==> Ensuring Flatpak + Flathub and installing WezTerm..."

# Install flatpak if missing
if ! command -v flatpak >/dev/null 2>&1; then
  if need_sudo; then
    sudo apt install -y flatpak
  else
    apt install -y flatpak
  fi
fi

# Add Flathub if missing
if ! flatpak remotes | awk '{print $1}' | grep -qx flathub; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install WezTerm from Flathub
if ! flatpak list --columns=application 2>/dev/null | grep -qx "$WEZTERM_APP_ID"; then
  flatpak install -y flathub "$WEZTERM_APP_ID"
  echo "    WezTerm installed successfully"
else
  echo "    WezTerm already installed"
fi
