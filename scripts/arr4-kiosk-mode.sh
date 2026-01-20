#!/usr/bin/env bash

set -e

HOMARR_URL="http://mediaserver:7575"

echo "=== XFCE Homarr Kiosk Setup ==="

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root (sudo)."
  exit 1
fi

# Ask for the username to auto-login
read -rp "Enter the username to auto-login (e.g. media): " USERNAME

if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' does not exist."
  exit 1
fi

USER_HOME=$(eval echo "~$USERNAME")

echo "Using user: $USERNAME"
echo "Home directory: $USER_HOME"
echo

# -------------------------------
# Enable LightDM auto-login
# -------------------------------
echo "Configuring LightDM auto-login..."

LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

if [ ! -f "$LIGHTDM_CONF" ]; then
  echo "❌ LightDM config not found at $LIGHTDM_CONF"
  echo "Is LightDM installed?"
  exit 1
fi

# Backup once
if [ ! -f "${LIGHTDM_CONF}.bak" ]; then
  cp "$LIGHTDM_CONF" "${LIGHTDM_CONF}.bak"
fi

# Write config
cat > "$LIGHTDM_CONF" <<EOF
[Seat:*]
autologin-user=$USERNAME
autologin-user-timeout=0
EOF

echo "✔ Auto-login enabled"

# -------------------------------
# XFCE autostart entry
# -------------------------------
echo "Creating XFCE autostart entry..."

AUTOSTART_DIR="$USER_HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/homarr.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Homarr
Comment=Media Dashboard
Exec=firefox --kiosk $HOMARR_URL
Icon=firefox
Terminal=false
EOF

chown -R "$USERNAME:$USERNAME" "$AUTOSTART_DIR"

echo "✔ Homarr will auto-start on login"

# -------------------------------
# Desktop shortcut
# -------------------------------
echo "Creating desktop shortcut..."

DESKTOP_DIR="$USER_HOME/Desktop"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/Homarr.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Homarr
Comment=Open Media Dashboard
Exec=firefox --kiosk $HOMARR_URL
Icon=firefox
Terminal=false
EOF

chmod +x "$DESKTOP_DIR/Homarr.desktop"
chown "$USERNAME:$USERNAME" "$DESKTOP_DIR/Homarr.desktop"

echo "✔ Desktop icon created"

echo
echo "=== Setup complete ==="
echo "Reboot to test auto-login and kiosk startup."