#!/usr/bin/env bash

set -e

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root (sudo)."
  exit 1
fi

ENV_FILE="../.env"

if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
else
  echo "can't find .env file"
  exit 1
fi

USERNAME="media"
# Ask for the username to add to docker group
#read -rp "Enter the username to allow docker without sudo: " USERNAME
#if ! id "$USERNAME" &>/dev/null; then
#  echo "❌ User '$USERNAME' does not exist."
#  exit 1
#fi

echo "Using data path: $ARRPATH"

# Create directories
mkdir -p "$ARRPATH"/{torrents,media}/{movies,tv,books}

# Ownership
# chown -R "${PUID:-1000}:${PGID:-1000}" "$ARRPATH" config
chown -R $PUID:$PGID "$ARRPATH"

echo "Folder structure created and permissions applied"


# Installing Docker and Docker Compose

echo "=== Installing Docker and Docker Compose ==="

. /etc/os-release

if [[ "$ID" == "linuxmint" ]]; then
  UBUNTU_CODENAME="$UBUNTU_CODENAME"
elif [[ "$ID" == "ubuntu" ]]; then
  UBUNTU_CODENAME="$VERSION_CODENAME"
else
  echo "Unsupported distro"
  exit 1
fi

echo "Using Ubuntu base: $UBUNTU_CODENAME"

# Update packages
echo "Updating package lists..."
apt update -y

# Prereqs
sudo apt install -y ca-certificates curl gnupg

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Force Ubuntu (pulled Ubuntu codename from os-release file)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

# Install Docker Engine & CLI
echo "Installing Docker Engine & CLI..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
