#!/bin/bash

# --- CONFIG ---
PYTHON_SCRIPT="$(pwd)/clipboard-change-manager.py"
SERVICE_NAME="clipboard-feedback.service"
USER_NAME="$USER"

# --- DETECT VENV ---
# If a .venv directory exists in the project, use it
VENV_DIR="$(pwd)/.venv"

if [ -d "$VENV_DIR" ]; then
    PYTHON_BIN="$VENV_DIR/bin/python"
else
    PYTHON_BIN="/usr/bin/python3"
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
WorkingDirectory=$(dirname "$PYTHON_SCRIPT")
ExecStart=/bin/bash -c 'source $VENV_DIR/bin/activate && exec python $PYTHON_SCRIPT'
Restart=always

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




BASHRC="$HOME/.bashrc"

# --- ADD ALIASES IF NOT PRESENT ---
if ! grep -Fxq 'alias clipoff="systemctl --user stop clipboard-feedback.service"' "$BASHRC"; then
    echo 'alias clipoff="systemctl --user stop clipboard-feedback.service"' >> "$BASHRC"
    echo "Added clipoff alias to $BASHRC"
fi

if ! grep -Fxq 'alias clipon="systemctl --user start clipboard-feedback.service"' "$BASHRC"; then
    echo 'alias clipon="systemctl --user start clipboard-feedback.service"' >> "$BASHRC"
    echo "Added clipon alias to $BASHRC"
fi
