#!/usr/bin/env bash
# Verify the development environment is correctly set up and check for updates.
# Read-only — never installs or modifies anything.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0 FAIL=0 WARN=0

pass() { ((PASS++)); printf "  ${GREEN}✓${NC} %s\n" "$1"; }
fail() { ((FAIL++)); printf "  ${RED}✗${NC} %s\n" "$1"; }
warn() { ((WARN++)); printf "  ${YELLOW}!${NC} %s\n" "$1"; }
info() { printf "    %s\n" "$1"; }
section() { printf "\n${BOLD}── %s${NC}\n" "$1"; }

# ── Variables filled by checks, used across sections ─────────────────────
GO_CURRENT="" NVIM_CURRENT="" WEZTERM_VER=""

# =========================================================================
section "APT Packages"
# =========================================================================
for pkg in zsh git curl unzip xclip jq; do
  if dpkg -s "$pkg" &>/dev/null; then
    pass "$pkg"
  else
    fail "$pkg not installed"
  fi
done

# =========================================================================
section "Shell"
# =========================================================================
USER_NAME="${SUDO_USER:-$USER}"
USER_SHELL="$(getent passwd "$USER_NAME" | cut -d: -f7)"

if [[ "$USER_SHELL" == *zsh* ]]; then
  pass "zsh is default shell for $USER_NAME"
else
  fail "default shell is $USER_SHELL (expected zsh)"
fi

ZSH_PATH="$(command -v zsh 2>/dev/null || true)"
if [[ -n "$ZSH_PATH" ]] && grep -qxF "$ZSH_PATH" /etc/shells 2>/dev/null; then
  pass "$ZSH_PATH listed in /etc/shells"
else
  fail "zsh not in /etc/shells"
fi

# =========================================================================
section "WezTerm (Flatpak)"
# =========================================================================
if command -v flatpak &>/dev/null; then
  if flatpak list --columns=application 2>/dev/null | grep -qx "org.wezfurlong.wezterm"; then
    WEZTERM_VER="$(flatpak list --columns=application,version 2>/dev/null | awk -F'\t' '/org.wezfurlong.wezterm/{print $2}')"
    pass "WezTerm installed ($WEZTERM_VER)"
  else
    fail "WezTerm not installed via Flatpak"
  fi
else
  fail "flatpak not installed"
fi

# =========================================================================
section "Fonts"
# =========================================================================
if fc-list 2>/dev/null | grep -i "SauceCodePro Nerd Font" >/dev/null 2>&1; then
  pass "SauceCodePro Nerd Font installed"
else
  fail "SauceCodePro Nerd Font not found (fc-list)"
fi

# =========================================================================
section "Dotfiles"
# =========================================================================
for dotfile in .zshrc .wezterm.lua; do
  if [[ ! -f "$HOME/$dotfile" ]]; then
    fail "~/$dotfile missing"
  elif diff -q "$SCRIPT_DIR/$dotfile" "$HOME/$dotfile" &>/dev/null; then
    pass "~/$dotfile in sync with repo"
  else
    warn "~/$dotfile differs from repo (run install/dotfiles.sh to update)"
  fi
done

if [[ -f "$HOME/.local/bin/devstart" ]]; then
  if diff -q "$SCRIPT_DIR/devstart" "$HOME/.local/bin/devstart" &>/dev/null; then
    pass "devstart installed and in sync"
  else
    warn "devstart installed but differs from repo"
  fi
  OWNER="$(stat -c '%U' "$HOME/.local/bin/devstart" 2>/dev/null || true)"
  if [[ "$OWNER" == "$USER_NAME" ]]; then
    pass "devstart owned by $USER_NAME"
  else
    fail "devstart owned by $OWNER (expected $USER_NAME)"
  fi
else
  fail "devstart not installed (~/.local/bin/devstart)"
fi

# =========================================================================
section "PATH"
# =========================================================================
if echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  pass "~/.local/bin in PATH"
else
  fail "~/.local/bin not in PATH"
fi

if echo "$PATH" | tr ':' '\n' | grep -qx "/usr/local/go/bin"; then
  pass "/usr/local/go/bin in PATH"
elif [[ -d /usr/local/go/bin ]]; then
  fail "/usr/local/go/bin exists but not in PATH (start a new shell or source ~/.zshrc)"
else
  info "/usr/local/go/bin not present (Go not installed)"
fi

# =========================================================================
section "Go"
# =========================================================================
if command -v go &>/dev/null; then
  GO_CURRENT="$(go version | awk '{print $3}')"
  pass "Go $GO_CURRENT"
elif [[ -x /usr/local/go/bin/go ]]; then
  GO_CURRENT="$(/usr/local/go/bin/go version | awk '{print $3}')"
  fail "Go $GO_CURRENT installed but not on PATH"
else
  fail "Go not installed"
fi

# =========================================================================
section "Neovim"
# =========================================================================
if command -v nvim &>/dev/null; then
  NVIM_CURRENT="$(nvim --version | head -n1 | awk '{print $2}')"
  pass "Neovim $NVIM_CURRENT"
  if [[ -L /usr/local/bin/nvim ]]; then
    pass "/usr/local/bin/nvim symlink exists"
  else
    warn "/usr/local/bin/nvim is not a symlink"
  fi
else
  fail "Neovim not installed"
fi

# =========================================================================
section "Claude Code"
# =========================================================================
if command -v claude &>/dev/null; then
  CC_VER="$(claude --version 2>/dev/null || echo 'unknown')"
  pass "Claude Code $CC_VER"
else
  fail "Claude Code not installed"
fi

# =========================================================================
section "Docker"
# =========================================================================
if command -v docker &>/dev/null; then
  DOCKER_VER="$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')"
  pass "Docker $DOCKER_VER"
else
  fail "Docker not installed"
fi

if groups "$USER_NAME" 2>/dev/null | grep -q '\bdocker\b'; then
  pass "$USER_NAME in docker group"
else
  fail "$USER_NAME not in docker group"
fi

if systemctl is-active docker &>/dev/null; then
  pass "Docker service running"
else
  warn "Docker service not running"
fi

# =========================================================================
section "Available Updates"
# =========================================================================
if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
  warn "curl/jq not available — skipping update checks"
else
  # Go
  GO_LATEST="$(curl -fsSL --connect-timeout 5 'https://go.dev/dl/?mode=json' 2>/dev/null \
    | jq -r '.[0].version' 2>/dev/null || true)"
  if [[ -n "$GO_LATEST" && -n "$GO_CURRENT" ]]; then
    if [[ "$GO_CURRENT" == "$GO_LATEST" ]]; then
      pass "Go up to date ($GO_LATEST)"
    else
      warn "Go update: $GO_CURRENT → $GO_LATEST"
    fi
  elif [[ -n "$GO_LATEST" ]]; then
    info "Latest Go: $GO_LATEST (not installed locally)"
  fi

  # Neovim
  NVIM_LATEST="$(curl -fsSL --connect-timeout 5 'https://api.github.com/repos/neovim/neovim/releases/latest' 2>/dev/null \
    | jq -r '.tag_name' 2>/dev/null || true)"
  if [[ -n "$NVIM_LATEST" && -n "$NVIM_CURRENT" ]]; then
    if [[ "$NVIM_CURRENT" == "$NVIM_LATEST" ]]; then
      pass "Neovim up to date ($NVIM_LATEST)"
    else
      warn "Neovim update: $NVIM_CURRENT → $NVIM_LATEST"
    fi
  elif [[ -n "$NVIM_LATEST" ]]; then
    info "Latest Neovim: $NVIM_LATEST (not installed locally)"
  fi

  # Nerd Fonts
  FONT_LATEST="$(curl -fsSL --connect-timeout 5 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' 2>/dev/null \
    | jq -r '.tag_name' 2>/dev/null || true)"
  FONT_VERSION_FILE="/usr/local/share/fonts/NerdFonts/.nerd-fonts-version"
  FONT_CURRENT="$(cat "$FONT_VERSION_FILE" 2>/dev/null || true)"
  if [[ -n "$FONT_LATEST" && -n "$FONT_CURRENT" ]]; then
    if [[ "$FONT_CURRENT" == "$FONT_LATEST" ]]; then
      pass "Nerd Fonts up to date ($FONT_LATEST)"
    else
      warn "Nerd Fonts update: $FONT_CURRENT → $FONT_LATEST"
    fi
  elif [[ -n "$FONT_LATEST" ]]; then
    info "Latest Nerd Fonts: $FONT_LATEST (no local version marker)"
  fi

  # WezTerm Flatpak
  if command -v flatpak &>/dev/null; then
    WEZTERM_UPDATE="$(flatpak remote-ls --updates 2>/dev/null | grep -i wezterm || true)"
    if [[ -n "$WEZTERM_UPDATE" ]]; then
      warn "WezTerm flatpak update available"
    elif [[ -n "$WEZTERM_VER" ]]; then
      pass "WezTerm flatpak up to date ($WEZTERM_VER)"
    fi
  fi
fi

# =========================================================================
section "Repo Health"
# =========================================================================
if [[ -f "$SCRIPT_DIR/get-docker.sh" ]]; then
  warn "get-docker.sh is committed but unused (install/docker.sh downloads its own copy)"
fi

if grep -q 'Alt+' "$SCRIPT_DIR/README.md" 2>/dev/null; then
  warn "README.md references Alt+ keybindings — .wezterm.lua uses SUPER"
fi

if ! grep -q 'devstart' "$SCRIPT_DIR/README.md" 2>/dev/null; then
  warn "README.md does not mention devstart"
fi

# Check install script bugs
NVIM_SCRIPT="$SCRIPT_DIR/install/neovim.sh"
if grep -q 'CURRENT="v\$(' "$NVIM_SCRIPT" 2>/dev/null; then
  warn "install/neovim.sh has double-v prefix bug (vv0.x.x) — version check never matches"
fi

FLATPAK_SCRIPT="$SCRIPT_DIR/install/flatpak-wezterm.sh"
if grep -q "flatpak list.*'{print \$1}'" "$FLATPAK_SCRIPT" 2>/dev/null; then
  warn "install/flatpak-wezterm.sh checks wrong flatpak column — idempotency broken"
fi

DEVSTART_SCRIPT="$SCRIPT_DIR/install/devstart.sh"
if ! grep -q 'chown' "$DEVSTART_SCRIPT" 2>/dev/null; then
  warn "install/devstart.sh missing chown — creates root-owned files under sudo"
fi

FONTS_SCRIPT="$SCRIPT_DIR/install/fonts.sh"
if ! grep -q 'already\|exit 0\|up to date' "$FONTS_SCRIPT" 2>/dev/null; then
  warn "install/fonts.sh has no idempotency check — always re-downloads"
fi

GO_SCRIPT="$SCRIPT_DIR/install/go.sh"
if ! grep -q 'sha256\|checksum' "$GO_SCRIPT" 2>/dev/null; then
  info "install/go.sh does not verify download checksums"
fi

NEOVIM_SCRIPT="$SCRIPT_DIR/install/neovim.sh"
if ! grep -q 'sha256\|checksum' "$NEOVIM_SCRIPT" 2>/dev/null; then
  info "install/neovim.sh does not verify download checksums"
fi

# =========================================================================
# Summary
# =========================================================================
printf "\n========================================\n"
printf "  ${GREEN}%d passed${NC}  ${RED}%d failed${NC}  ${YELLOW}%d warnings${NC}\n" "$PASS" "$FAIL" "$WARN"
printf "========================================\n"

if ((FAIL > 0)); then
  exit 1
fi
