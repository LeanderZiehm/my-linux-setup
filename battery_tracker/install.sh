#!/usr/bin/env bash
set -e

SERVICE_NAME="battery-tracker"
INSTALL_DIR="$HOME/.local/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"

echo "▶ Installing battery reporter..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$SYSTEMD_DIR"

cp battery_tracker.sh "$INSTALL_DIR/$SERVICE_NAME.sh"
chmod +x "$INSTALL_DIR/$SERVICE_NAME.sh"

SERVICE_FILE="$SYSTEMD_DIR/$SERVICE_NAME.service"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Battery Level Reporter

[Service]
ExecStart=$INSTALL_DIR/$SERVICE_NAME.sh
Restart=always
RestartSec=120

[Install]
WantedBy=default.target
EOF

echo "▶ Reloading systemd user daemon..."
systemctl --user daemon-reexec

echo "▶ Enabling service..."
systemctl --user enable "$SERVICE_NAME.service"

echo "▶ Starting service..."
systemctl --user restart "$SERVICE_NAME.service"

echo "✅ Battery reporter installed and running!"
echo "   Check status with:"
echo "   systemctl --user status $SERVICE_NAME.service"
