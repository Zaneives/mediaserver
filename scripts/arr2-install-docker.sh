#!/usr/bin/env bash

set -e

echo "=== Installing Docker and Docker Compose ==="

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root (sudo)."
  exit 1
fi

# Ask for the username to add to docker group
read -rp "Enter the username to allow docker without sudo: " USERNAME

if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' does not exist."
  exit 1
fi

# Update packages
echo "Updating package lists..."
apt update -y
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker GPG key
echo "Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "Adding Docker repository..."
ARCH=$(dpkg --print-architecture)
echo \
  "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine & CLI
echo "Installing Docker Engine & CLI..."
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
echo "Adding $USERNAME to docker group..."
usermod -aG docker "$USERNAME"

# Test Docker command
echo
echo "✅ Docker installed!"
echo "User '$USERNAME' added to docker group. Log out and back in (or reboot) for changes to take effect."
echo "After that, you can run 'docker ps' without sudo."

# Optional: enable docker service on boot
systemctl enable docker
systemctl start docker
echo "Docker service enabled to start on boot."
