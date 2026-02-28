#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

FONT_NAME="SauceCodePro Nerd Font"
FONT_DEST_DIR="/usr/local/share/fonts/NerdFonts"

echo "==> Installing ${FONT_NAME} system-wide to ${FONT_DEST_DIR}..."

# Get latest nerd-fonts release tag
LATEST_TAG="$(curl -fsSL 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' | jq -r '.tag_name')"
echo "    Latest nerd-fonts release: $LATEST_TAG"
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
echo "    Installed ${FONT_NAME} to ${FONT_DEST_DIR}"
