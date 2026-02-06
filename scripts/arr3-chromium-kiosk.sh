#!/usr/bin/env bash
set -e

USER_NAME="media"
KIOSK_URL="http://mediaserver:7575"
AUTOSTART_DIR="/home/${USER_NAME}/.config/autostart"

echo "Installing Chromium..."
sudo apt update
sudo apt install -y chromium-browser

echo "Creating XFCE autostart directory..."
sudo -u "$USER_NAME" mkdir -p "$AUTOSTART_DIR"

echo "Creating Chromium kiosk autostart entry..."

sudo -u "$USER_NAME" tee "${AUTOSTART_DIR}/chromium-kiosk.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Chromium Kiosk
Exec=chromium-browser --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --incognito ${KIOSK_URL}
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

echo "Kiosk setup complete."
echo "Chromium will auto-launch on login."