#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing NVM and latest LTS Node..."

NVM_DIR="$USER_HOME/.nvm"

# Run a command as the real user (handles running under sudo)
as_user() {
  if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    sudo -u "$USER_NAME" -- "$@"
  else
    "$@"
  fi
}

# Query latest NVM version from GitHub
LATEST="$(curl -fsSL 'https://api.github.com/repos/nvm-sh/nvm/releases/latest' | jq -r '.tag_name')"
echo "    Latest NVM version: $LATEST"

# Check if already installed and up to date
CURRENT="none"
if [ -d "$NVM_DIR/.git" ]; then
  CURRENT="$(git -C "$NVM_DIR" describe --tags --abbrev=0 2>/dev/null || echo "none")"
fi

if [ "$CURRENT" = "$LATEST" ]; then
  echo "    NVM is already up to date ($CURRENT)"
  if [ -d "$NVM_DIR/versions/node" ] && [ "$(ls -A "$NVM_DIR/versions/node" 2>/dev/null)" ]; then
    echo "    Node already installed"
    exit 0
  fi
  echo "    No Node version found, installing..."
else
  if [ "$CURRENT" != "none" ]; then
    echo "    Upgrading NVM from $CURRENT to $LATEST"
  fi

  # Download and run NVM installer (PROFILE=/dev/null prevents modifying shell configs)
  echo "    Downloading NVM installer..."
  TMP_SCRIPT="$(mktemp)"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$LATEST/install.sh" -o "$TMP_SCRIPT"

  echo "    Installing NVM to $NVM_DIR..."
  as_user env NVM_DIR="$NVM_DIR" PROFILE=/dev/null bash "$TMP_SCRIPT"
  rm -f "$TMP_SCRIPT"
fi

# Install latest LTS Node and set as default
echo "    Installing latest LTS Node..."
as_user bash -c "
  export NVM_DIR=\"$NVM_DIR\"
  . \"\$NVM_DIR/nvm.sh\"
  nvm install --lts
  nvm alias default 'lts/*'
"

# Report versions
echo "    NVM installed: $LATEST"
as_user bash -c "
  export NVM_DIR=\"$NVM_DIR\"
  . \"\$NVM_DIR/nvm.sh\"
  echo \"    Node installed: \$(node --version)\"
  echo \"    npm installed: \$(npm --version)\"
"
