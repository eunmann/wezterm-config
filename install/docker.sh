#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

get_user_info

echo "==> Installing Docker..."

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
  echo "    Docker already installed"
  docker --version
else
  echo "    Downloading Docker installation script..."
  TMP_DOCKER="$(mktemp --suffix=-get-docker.sh)"
  curl -fsSL https://get.docker.com -o "$TMP_DOCKER"

  echo "    Running Docker installation script..."
  sudo sh "$TMP_DOCKER"

  rm -f "$TMP_DOCKER"
  echo "    Docker installed successfully"
  docker --version
fi

# Add user to docker group to run Docker without sudo
if groups "$USER_NAME" | grep -q '\bdocker\b'; then
  echo "    User $USER_NAME already in docker group"
else
  echo "    Adding $USER_NAME to docker group..."
  sudo usermod -aG docker "$USER_NAME"
  echo "    User added to docker group (requires logout to take effect)"
fi

# Ensure Docker service is enabled and running
echo "    Ensuring Docker service is enabled and running..."
sudo systemctl enable docker
sudo systemctl start docker

echo "    Docker installation complete"
