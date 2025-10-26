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
- Nix package manager (multi-user/daemon mode)
- Neovim and Go (via Nix)
- nvm, Node.js 22, and Claude Code CLI
- Docker

**Or install components separately:**

Terminal setup only:
```bash
./install.sh
```

Development tools only (Nix):
```bash
./install-nix.sh
```

Node.js environment only:
```bash
./install-node.sh
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

**Nix setup modules:**
```bash
./install/nix.sh               # Install and configure Nix
./install/nix-packages.sh      # Install Neovim and Go via Nix
```

**Node.js setup modules:**
```bash
./install/nvm.sh               # Install nvm (Node Version Manager)
./install/node.sh              # Install Node.js 22 via nvm
./install/claude-code.sh       # Install Claude Code CLI via npm
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
