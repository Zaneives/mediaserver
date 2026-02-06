#!/usr/bin/env bash
set -e

USER_NAME="media"
KIOSK_URL="http://mediaserver:7575"
AUTOSTART_DIR="/home/${USER_NAME}/.config/autostart"

echo "Setting up Firefox kiosk mode for user: ${USER_NAME}"

# Ensure autostart directory exists
sudo -u "$USER_NAME" mkdir -p "$AUTOSTART_DIR"

echo "Creating Firefox kiosk autostart entry..."

sudo -u "$USER_NAME" tee "${AUTOSTART_DIR}/firefox-kiosk.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Firefox Kiosk
Comment=Launch Firefox in kiosk mode
Exec=firefox --kiosk ${KIOSK_URL}
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

echo "Firefox kiosk autostart configured."
echo "Firefox will launch automatically on login."
