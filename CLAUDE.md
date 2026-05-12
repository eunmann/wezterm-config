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
- `./install-devtools.sh` - Development tools (Go + Neovim + kickstart.nvim + Claude Code + NVM/Node)
- `./install/docker.sh` - Docker container platform

All scripts orchestrate their respective modules in the correct order. For selective installation, individual modules can be run from `install/` directory.

## Repository Structure

**Configuration Files:**
- `.wezterm.lua` - WezTerm configuration with Tokyo Night theme, font settings, keybindings, and git status integration
- `.zshrc` - Zsh configuration with history settings, custom prompt, and WezTerm integration via user-vars
- `devstart` - Dev session launcher: opens nvim + claude split in WezTerm (installed to `~/.local/bin` by `install/devstart.sh`)

**Installation System:**
- `install-all.sh` - Master installation script that runs everything in order (3 phases)
- `install.sh` - Terminal setup (WezTerm + Zsh)
- `install-devtools.sh` - Development tools (Go + Neovim + Claude Code)
- `install/helpers.sh` - Common helper functions (`need_sudo`, `get_user_info`, `install_dotfile`)
- `install/packages.sh` - Installs required apt packages (zsh, git, curl, unzip, xclip, jq, make, gcc, ripgrep, fd-find)
- `install/wezterm.sh` - Adds WezTerm apt repository and installs WezTerm via deb package
- `install/fonts.sh` - Downloads and installs SauceCodePro Nerd Font system-wide (latest version via GitHub API)
- `install/zsh-setup.sh` - Sets zsh as the default shell in /etc/shells
- `install/dotfiles.sh` - Copies .zshrc and .wezterm.lua to user home directory with backups
- `install/zshrc.sh` - Installs/updates only .zshrc (focused module, used by `dotfiles.sh`)
- `install/go.sh` - Installs latest Go from go.dev to /usr/local/go
- `install/neovim.sh` - Installs latest Neovim from GitHub releases to /opt/nvim
- `install/nvim-config.sh` - Clones eunmann/kickstart.nvim to ~/.config/nvim
- `install/claude-code.sh` - Installs Claude Code native binary via official installer
- `install/nvm.sh` - Installs NVM (Node Version Manager) and latest LTS Node
- `install/devstart.sh` - Installs devstart script to `~/.local/bin`
- `install/docker.sh` - Installs Docker using official script, adds user to docker group

## WezTerm Configuration Architecture

The `.wezterm.lua` file uses WezTerm's Lua API:
- Configuration is built using `wezterm.config_builder()`
- Actions are accessed via `wezterm.action` (aliased as `act`)
- Settings use the `config.*` pattern (e.g., `config.color_scheme`, `config.font`)
- Keybindings are defined in the `config.keys` table with `key`, `mods` (modifiers), and `action` fields. Custom bindings use `SUPER` (CMD on macOS, WIN on Windows/Linux) to avoid conflicts with terminal apps (nvim, zsh) and OS bindings. We rely on wezterm's built-in `CTRL+SHIFT` defaults for tabs (`T`/`W`/`1..9`), tab nav (`CTRL+TAB`/`CTRL+SHIFT+TAB`), command palette (`P`), search (`F`), copy mode (`X`), and quick select (`Space`).
- There is no leader key. All pane operations use `SUPER` directly: `SUPER+|` splits right, `SUPER+_` splits down, `SUPER+hjkl` navigates, `SUPER+z` zooms, `SUPER+x` closes, `SUPER+r` enters a `resize_pane` key table where bare `hjkl` resizes. Font size is `SUPER+`/`-`/`=`/`0`.
- Right status bar composes multiple sources via the `update-status` event. Because `window:set_right_status` *replaces* the right area, individual sources cannot write directly: the `git_status` user-var from zsh is cached into a module-level variable (in the `user-var-changed` handler) and the actual rendering happens in `update-status`, where git + hostname + time are concatenated and written in one call. Adding a new source means: cache it like git, then concatenate it inside `render_right_status`.
- Tab titles are customised by the `format-tab-title` event, which shows `[index] process — cwd_basename` plus a `●` marker on inactive tabs with unseen output
- Hyperlink rules extend (not replace) `wezterm.default_hyperlink_rules()` so the built-in URL detectors keep working; a custom rule turns `owner/repo#1234` into a clickable GitHub link
- Cross-platform: `wezterm.target_triple` is checked to set up a `wsl_domains` entry + `default_domain` on Windows (launches into WSL Ubuntu via the `WSL:Ubuntu` domain so new tabs/panes inherit the WSL cwd via OSC 7); on macOS/Linux WezTerm uses the user's login shell. The same file is installed to `~/.wezterm.lua` on macOS/Linux and to `C:\Users\<user>\.wezterm.lua` on Windows.

## Zsh Configuration Architecture

The `.zshrc` provides:
- **PATH**: prepends `~/.local/bin` (where the Claude Code binary lives) and `/usr/local/go/bin` then dedupes via `typeset -U path PATH`
- **NVM**: sources `$NVM_DIR/nvm.sh` and bash_completion (silently skipped if NVM isn't installed)
- **History management**: shared history across sessions, duplicate removal (`SHARE_HISTORY`, `HIST_IGNORE_ALL_DUPS`, etc.), 10k entries
- **Completion**: `compinit` for tab completion
- **Minimal prompt**: `user@host ~/path %` — git/host/time render in WezTerm's right status bar instead of in the prompt
- **WezTerm integration** (only active when `$TERM_PROGRAM == WezTerm`):
  - `_wez_precmd` hook emits OSC 7 (cwd reporting, so new wezterm tabs inherit the cwd), and OSC 1337 user-vars for `git_status` (`"repo (branch)"`) and `prog` (reset to `zsh` between commands)
  - `_wez_preexec` hook updates `prog` to the running command name; this works around the WSL quirk where wezterm sees `wslhost.exe` instead of the real foreground process
  - `wez_set_user_var` helper base64-encodes the value into the OSC 1337 SetUserVar sequence

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

**Neovim Config** (`install/nvim-config.sh`):
- Clones `eunmann/kickstart.nvim` (fork of nvim-lua/kickstart.nvim) to `~/.config/nvim`
- Idempotent: if already cloned from the same repo, runs `git pull --ff-only` to update
- Backs up any existing non-matching config with a timestamped suffix
- Handles sudo: clones as the real user via `sudo -u`
- First `nvim` launch auto-installs plugins via `vim.pack` (requires Neovim 0.12+ and internet)
- System dependencies (in `packages.sh`): make, gcc (treesitter compilation), ripgrep, fd-find (Telescope)
- Custom plugins in `lua/custom/plugins/`: copilot, diffview, render-markdown, spectre
- Update config: re-run the script or `cd ~/.config/nvim && git pull`

**Claude Code** (`install/claude-code.sh`):
- Native binary installed via official installer to `~/.local/bin/claude`
- Self-updating: run `claude update`

**NVM + Node** (`install/nvm.sh`):
- NVM installed from GitHub via official installer to `~/.nvm`
- Latest LTS Node installed and set as default via `nvm alias default lts/*`
- Idempotent: skips if installed NVM version matches latest and Node is present
- Shell integration sourced in `.zshrc` (NVM is a shell function, not a binary)
- Handles sudo: runs installer as the real user via `sudo -u` when invoked under sudo
- Update NVM by re-running the script; update Node with `nvm install --lts`

## Docker

The Docker installation (`install/docker.sh`) sets up:
- Docker Engine using the official Docker installation script
- Docker service enabled and started via systemd
- Current user added to the `docker` group for running Docker without sudo
- **Important**: Logout/login required for docker group membership to take effect

After installation, you must log out and log back in (or reboot) for the docker group membership to take effect. Until then, you'll need to use `sudo docker` commands.
