#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing and configuring Nix..."

# --- 1) Install Nix (multi-user / daemon) if missing ---
if ! command -v nix >/dev/null 2>&1; then
  echo "    Installing Nix (multi-user)..."
  sh <(curl -L https://nixos.org/nix/install) --daemon
else
  echo "    Nix already installed"
fi

# --- 2) Load Nix into THIS shell (so we can use it immediately) ---
# Try the standard daemon profile first, then fallbacks.
if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -r /etc/profile.d/nix.sh ]; then
  # shellcheck disable=SC1091
  . /etc/profile.d/nix.sh
elif [ -r "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Double-check nix is now on PATH
if ! command -v nix >/dev/null 2>&1; then
  echo "!! Nix not found on PATH after install. Start a NEW login session or run:  source /etc/profile"
  exit 1
fi

# --- 3) Enable nix-command & flakes permanently (daemon or single-user) ---
NIX_CONF_DIR="/etc/nix"
NIX_CONF_FILE="$NIX_CONF_DIR/nix.conf"
LINE="experimental-features = nix-command flakes"

echo "    Enabling experimental features (nix-command, flakes)..."
if [ -w "$NIX_CONF_FILE" ] 2>/dev/null; then
  if ! grep -q "^experimental-features" "$NIX_CONF_FILE" 2>/dev/null; then
    echo "$LINE" | sudo tee -a "$NIX_CONF_FILE" >/dev/null
  elif ! grep -q "nix-command" "$NIX_CONF_FILE" || ! grep -q "flakes" "$NIX_CONF_FILE"; then
    # Replace/merge the line if present but incomplete
    sudo sed -i "s/^experimental-features.*/$LINE/" "$NIX_CONF_FILE"
  fi
else
  # Create the dir/file if needed
  sudo mkdir -p "$NIX_CONF_DIR"
  echo "$LINE" | sudo tee "$NIX_CONF_FILE" >/dev/null
fi

# Restart nix-daemon if present (ignore if not running; single-user has none)
sudo systemctl restart nix-daemon 2>/dev/null || true

# --- 4) Verify Nix works ---
echo "    Nix version: $(nix --version)"

# --- 5) Ensure profile bin directory is on PATH in future shells ---
# Most installs already set this up, but we'll add a safe guard to ~/.profile
USER_PROFILE="$USER_HOME/.profile"
PROFILE_LINE='[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"'

if ! grep -Fq '.nix-profile/etc/profile.d/nix.sh' "$USER_PROFILE" 2>/dev/null; then
  echo "    Adding Nix PATH hook to ~/.profile"
  echo "$PROFILE_LINE" >> "$USER_PROFILE"
  chown "$USER_NAME":"$USER_NAME" "$USER_PROFILE"
fi

echo "    Nix installed and configured successfully"
