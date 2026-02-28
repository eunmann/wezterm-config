# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains personal configuration files for WezTerm terminal emulator and zsh shell customization. It includes a modular installation system to set up a complete development environment on Debian/Ubuntu systems.

## Installation

**Complete installation (recommended):**
```bash
./install-all.sh
```

This runs terminal setup, development tools, and Docker installation in the correct order.

**Or install components separately:**
- `./install.sh` - Terminal setup (WezTerm + Zsh)
- `./install-devtools.sh` - Development tools (Go + Neovim + Claude Code)
- `./install/docker.sh` - Docker container platform

All scripts orchestrate their respective modules in the correct order. For selective installation, individual modules can be run from `install/` directory.

## Repository Structure

**Configuration Files:**
- `.wezterm.lua` - WezTerm configuration with Tokyo Night theme, font settings, keybindings, and git status integration
- `.zshrc` - Zsh configuration with history settings, custom prompt, and WezTerm integration via user-vars

**Installation System:**
- `install-all.sh` - Master installation script that runs everything in order (3 phases)
- `install.sh` - Terminal setup (WezTerm + Zsh)
- `install-devtools.sh` - Development tools (Go + Neovim + Claude Code)
- `install/helpers.sh` - Common helper functions (`need_sudo`, `get_user_info`)
- `install/packages.sh` - Installs required apt packages (zsh, git, curl, unzip, xclip, jq)
- `install/flatpak-wezterm.sh` - Installs Flatpak, adds Flathub, and installs WezTerm
- `install/fonts.sh` - Downloads and installs SauceCodePro Nerd Font system-wide (latest version via GitHub API)
- `install/zsh-setup.sh` - Sets zsh as the default shell in /etc/shells
- `install/dotfiles.sh` - Copies .zshrc and .wezterm.lua to user home directory with backups
- `install/go.sh` - Installs latest Go from go.dev to /usr/local/go
- `install/neovim.sh` - Installs latest Neovim from GitHub releases to /opt/nvim
- `install/claude-code.sh` - Installs Claude Code native binary via official installer
- `install/docker.sh` - Installs Docker using official script, adds user to docker group

## WezTerm Configuration Architecture

The `.wezterm.lua` file uses WezTerm's Lua API:
- Configuration is built using `wezterm.config_builder()`
- Actions are accessed via `wezterm.action` (aliased as `act`)
- Settings use the `config.*` pattern (e.g., `config.color_scheme`, `config.font`)
- Keybindings are defined in the `config.keys` table with `key`, `mods` (modifiers), and `action` fields
- Git status integration via `wezterm.on("user-var-changed", ...)` event handler that displays repo/branch info

## Zsh Configuration Architecture

The `.zshrc` provides:
- **History management**: Shared history across sessions with duplicate removal
- **Git status integration**: `precmd()` hook sends git repo and branch info to WezTerm via `wez_set_user_var()`
  - Uses base64 encoding to send data via OSC 1337 escape sequences
  - `prompt_git_status()` extracts repo name and current branch
- **Minimal prompt**: User@host + directory + command prompt (status displayed in WezTerm's right status bar)

## Installation Module Pattern

All installation modules follow this pattern:
1. Source `helpers.sh` for common functions
2. Use `need_sudo` to determine if sudo is required
3. Use `get_user_info` to get actual user information when run with sudo
4. Provide clear status messages with `==>`
5. Handle idempotency (safe to run multiple times)

The `dotfiles.sh` module creates timestamped backups before overwriting existing files.

## Testing Changes

**WezTerm configuration:**
1. Edit `.wezterm.lua` in the repository
2. Run `install/dotfiles.sh` to copy to `~/.wezterm.lua`
3. Restart WezTerm or create a new window
4. Check for errors in WezTerm's debug overlay (Ctrl+Shift+L by default)

**Zsh configuration:**
1. Edit `.zshrc` in the repository
2. Run `install/dotfiles.sh` to copy to `~/.zshrc`
3. Start a new shell or run `source ~/.zshrc`

## Development Tools

Tools are installed as direct binaries from official sources (no package manager overhead):

**Go** (`install/go.sh`):
- Downloaded from go.dev, installed to `/usr/local/go`
- PATH configured via `~/.profile`
- Idempotent: skips if installed version matches latest
- Update by re-running the script

**Neovim** (`install/neovim.sh`):
- Downloaded from GitHub releases, installed to `/opt/nvim`
- Symlinked to `/usr/local/bin/nvim`
- Idempotent: skips if installed version matches latest
- Update by re-running the script

**Claude Code** (`install/claude-code.sh`):
- Native binary installed via official installer to `~/.local/bin/claude`
- Self-updating: run `claude update`

## Docker

The Docker installation (`install/docker.sh`) sets up:
- Docker Engine using the official Docker installation script
- Docker service enabled and started via systemd
- Current user added to the `docker` group for running Docker without sudo
- **Important**: Logout/login required for docker group membership to take effect

After installation, you must log out and log back in (or reboot) for the docker group membership to take effect. Until then, you'll need to use `sudo docker` commands.
