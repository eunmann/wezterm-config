# wezterm-config

Personal WezTerm and Zsh configuration with modular installation system.

## Quick Start

**Complete installation (recommended):**
```bash
./install-all.sh
```

This installs everything:
- WezTerm (via Flatpak) + SauceCodePro Nerd Font
- Zsh as default shell + custom configurations
- Go (latest from go.dev)
- Neovim (latest from GitHub)
- Claude Code (native binary)
- Docker

**Or install components separately:**

Terminal setup only:
```bash
./install.sh
```

Development tools only (Go + Neovim + Claude Code):
```bash
./install-devtools.sh
```

Docker only:
```bash
./install/docker.sh
```

## Modular Installation

**Terminal setup modules:**
```bash
./install/packages.sh          # Install apt packages
./install/flatpak-wezterm.sh   # Install WezTerm
./install/fonts.sh             # Install Nerd Fonts
./install/zsh-setup.sh         # Set zsh as default shell
./install/dotfiles.sh          # Copy config files to ~
```

**Development tools modules:**
```bash
./install/go.sh                # Install latest Go from go.dev
./install/neovim.sh            # Install latest Neovim from GitHub
./install/claude-code.sh       # Install Claude Code native binary
```

**Container platform:**
```bash
./install/docker.sh            # Install Docker and add user to docker group
```

## Features

**WezTerm:**
- Tokyo Night color scheme
- SauceCodePro Nerd Font
- Alt+{ / Alt+} tab navigation
- Git repository/branch display in right status bar

**Zsh:**
- Shared history across sessions
- Git branch integration with WezTerm
- Minimal prompt (git info shown in terminal status bar)

## Configuration Files

- `.wezterm.lua` - WezTerm configuration
- `.zshrc` - Zsh configuration

Edit these files in the repository, then run `./install/dotfiles.sh` to copy them to your home directory. Existing files are automatically backed up with timestamps.
