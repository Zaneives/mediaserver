#!/usr/bin/env bash

set -e

echo "=== Installing XFCE, LightDM, Firefox, and Avahi ==="

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root (sudo)."
  exit 1
fi

# Update package lists
echo "Updating package lists..."
apt update -y

# Install XFCE desktop
echo "Installing XFCE desktop environment..."
apt install -y xfce4 xfce4-goodies

# Install LightDM display manager
echo "Installing LightDM..."
apt install -y lightdm

# Install Firefox for kiosk dashboard
echo "Installing Firefox..."
apt install -y firefox

# Install Avahi for hostname/mDNS support
echo "Installing Avahi-daemon..."
apt install -y avahi-daemon

# Optional: useful X utilities
apt install -y x11-xserver-utils

# Enable graphical target (boot into desktop)
echo "Enabling graphical target..."
systemctl set-default graphical.target

# Enable and start Avahi daemon
echo "Enabling and starting Avahi-daemon..."
systemctl enable avahi-daemon
systemctl start avahi-daemon

echo
echo "✅ Installation complete!"
echo "Reboot the system to start XFCE, LightDM, and Avahi (hostname resolution)."
echo "After reboot, you should see the LightDM login screen."