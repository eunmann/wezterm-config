#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

FONT_NAME="SauceCodePro Nerd Font"
FONT_DEST_DIR="/usr/local/share/fonts/NerdFonts"

VERSION_FILE="$FONT_DEST_DIR/.nerd-fonts-version"

echo "==> Installing ${FONT_NAME} system-wide to ${FONT_DEST_DIR}..."

# Get latest nerd-fonts release tag
LATEST_TAG="$(curl -fsSL 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' | jq -r '.tag_name')"
echo "    Latest nerd-fonts release: $LATEST_TAG"

# Check if already installed and up to date
if [[ -f "$VERSION_FILE" ]] && [[ "$(cat "$VERSION_FILE")" == "$LATEST_TAG" ]]; then
  echo "    Fonts already up to date ($LATEST_TAG)"
  exit 0
fi

FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${LATEST_TAG}/SourceCodePro.zip"

if need_sudo; then
  sudo mkdir -p "$FONT_DEST_DIR"
else
  mkdir -p "$FONT_DEST_DIR"
fi

TMP_ZIP="$(mktemp --suffix=.zip)"
curl -fsSL "$FONT_ZIP_URL" -o "$TMP_ZIP"

if need_sudo; then
  sudo unzip -o "$TMP_ZIP" -d "$FONT_DEST_DIR" >/dev/null
  sudo fc-cache -fv "$FONT_DEST_DIR" >/dev/null
else
  unzip -o "$TMP_ZIP" -d "$FONT_DEST_DIR" >/dev/null
  fc-cache -fv "$FONT_DEST_DIR" >/dev/null
fi

rm -f "$TMP_ZIP"

# Record installed version for idempotency
if need_sudo; then
  echo "$LATEST_TAG" | sudo tee "$VERSION_FILE" >/dev/null
else
  echo "$LATEST_TAG" > "$VERSION_FILE"
fi

echo "    Installed ${FONT_NAME} $LATEST_TAG to ${FONT_DEST_DIR}"
