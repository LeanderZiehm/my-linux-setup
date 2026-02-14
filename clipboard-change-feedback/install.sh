#!/bin/bash

# --- CONFIG ---
PYTHON_SCRIPT="$(pwd)/clipboard-changed-manager.py"
SERVICE_NAME="clipboard-feedback.service"
USER_NAME="$USER"

# --- CHECKS ---
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "Error: Python script not found at $PYTHON_SCRIPT"
    exit 1
fi

# --- CREATE USER SYSTEMD SERVICE FILE ---
SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

SERVICE_FILE="$SERVICE_DIR/$SERVICE_NAME"

echo "Creating systemd user service file at $SERVICE_FILE..."
cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=Clipboard Feedback Manager
After=default.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $PYTHON_SCRIPT
Restart=always
WorkingDirectory=$(dirname "$PYTHON_SCRIPT")

[Install]
WantedBy=default.target
EOL

# --- RELOAD SYSTEMD, ENABLE, AND START ---
echo "Reloading user systemd daemon..."
systemctl --user daemon-reload

echo "Starting service..."
systemctl --user start $SERVICE_NAME

echo "Enabling service to start on login..."
systemctl --user enable $SERVICE_NAME

echo "Done! Service status:"
systemctl --user status $SERVICE_NAME --no-pager



# systemctl --user restart $SERVICE_NAME
# systemctl --user restart clipboard-feedback.service
