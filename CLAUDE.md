# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains personal configuration files for WezTerm terminal emulator and zsh shell customization. It includes a modular installation system to set up a complete development environment on Debian/Ubuntu systems.

## Installation

**Complete installation (recommended):**
```bash
./install-all.sh
```

This runs terminal setup, development tools (Nix), Node.js environment, and Docker installation in the correct order.

**Or install components separately:**
- `./install.sh` - Terminal setup (WezTerm + Zsh)
- `./install-nix.sh` - Development tools (Nix + Neovim + Go)
- `./install-node.sh` - Node.js environment (nvm + Node 22 + Claude Code)
- `./install/docker.sh` - Docker container platform

All scripts orchestrate their respective modules in the correct order. For selective installation, individual modules can be run from `install/` directory.

## Repository Structure

**Configuration Files:**
- `.wezterm.lua` - WezTerm configuration with Tokyo Night theme, font settings, keybindings, and git status integration
- `.zshrc` - Zsh configuration with history settings, custom prompt, and WezTerm integration via user-vars

**Installation System:**
- `install-all.sh` - Master installation script that runs everything in order (4 phases)
- `install.sh` - Terminal setup (WezTerm + Zsh)
- `install-nix.sh` - Development tools (Nix + packages)
- `install-node.sh` - Node.js environment (nvm + Node + Claude Code)
- `install/helpers.sh` - Common helper functions (`need_sudo`, `get_user_info`)
- `install/packages.sh` - Installs required apt packages (zsh, git, curl, unzip, xclip)
- `install/flatpak-wezterm.sh` - Installs Flatpak, adds Flathub, and installs WezTerm
- `install/fonts.sh` - Downloads and installs SauceCodePro Nerd Font system-wide
- `install/zsh-setup.sh` - Sets zsh as the default shell in /etc/shells
- `install/dotfiles.sh` - Copies .zshrc and .wezterm.lua to user home directory with backups
- `install/nix.sh` - Installs Nix package manager (multi-user/daemon), enables experimental features
- `install/nix-packages.sh` - Installs Neovim and Go via Nix profile
- `install/nvm.sh` - Installs nvm (Node Version Manager) and configures .zshrc
- `install/node.sh` - Installs Node.js 22 via nvm
- `install/claude-code.sh` - Installs Claude Code CLI globally via npm
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

## Nix Package Management

The Nix installation (`install/nix.sh`) sets up:
- Multi-user/daemon mode installation
- Experimental features enabled: `nix-command` and `flakes`
- PATH configuration in `~/.profile` for persistent access
- System-wide configuration in `/etc/nix/nix.conf`

Nix packages are installed to the user profile (persistent across sessions):
```bash
nix profile install nixpkgs#<package>   # Install a package
nix profile list                         # List installed packages
nix profile upgrade '.*'                 # Upgrade all packages
nix search nixpkgs <query>               # Search for packages
```

The `install/nix-packages.sh` module installs Neovim and Go, which become available in `~/.nix-profile/bin/`.

## Node.js/nvm Management

The Node.js installation (`install/nvm.sh`) sets up:
- nvm (Node Version Manager) installed in `~/.nvm`
- nvm initialization added to `~/.zshrc` for automatic loading
- PATH configuration for accessing nvm and installed Node versions

Node.js management via nvm:
```bash
nvm install 22                # Install Node.js 22 (done by install/node.sh)
nvm use 22                    # Switch to Node.js 22
nvm alias default 22          # Set Node.js 22 as default
nvm list                      # List installed Node versions
nvm install node              # Install latest Node.js version
```

The `install/claude-code.sh` module installs Claude Code CLI globally via npm, making it available in the PATH. Claude Code can be run with:
```bash
claude-code                   # Start Claude Code CLI
claude-code --version         # Check version
```

## Docker

The Docker installation (`install/docker.sh`) sets up:
- Docker Engine using the official Docker installation script
- Docker service enabled and started via systemd
- Current user added to the `docker` group for running Docker without sudo
- **Important**: Logout/login required for docker group membership to take effect

Common Docker commands:
```bash
docker --version              # Check Docker version
docker run hello-world        # Test Docker installation
docker ps                     # List running containers
docker images                 # List downloaded images
docker pull <image>           # Download an image
docker run -it <image> bash   # Run a container interactively
```

After installation, you must log out and log back in (or reboot) for the docker group membership to take effect. Until then, you'll need to use `sudo docker` commands.
