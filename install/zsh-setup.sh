#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Setting zsh as default shell..."

ZSH_PATH="$(command -v zsh)"

# Ensure /etc/shells contains zsh
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
  if need_sudo; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  else
    echo "$ZSH_PATH" | tee -a /etc/shells >/dev/null
  fi
  echo "    Added $ZSH_PATH to /etc/shells"
fi

# Change login shell for the user
if [ "$(getent passwd "$USER_NAME" | cut -d: -f7)" != "$ZSH_PATH" ]; then
  chsh -s "$ZSH_PATH" "$USER_NAME"
  echo "    Set zsh as default shell for $USER_NAME"
else
  echo "    zsh already the default shell"
fi
