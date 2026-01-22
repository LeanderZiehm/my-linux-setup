#!/usr/bin/env bash

set -e

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <URL to mark.sh>"
    exit 1
fi

MARK_URL="$1"

# Determine XDG data directory fallback
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
MARK_DIR="$XDG_DATA_HOME/mark"
MARK_SCRIPT="$MARK_DIR/mark.sh"

# Create directory if it doesn't exist
mkdir -p "$MARK_DIR"

# Download mark.sh
echo "Downloading mark script from $MARK_URL..."
curl -fsSL "$MARK_URL" -o "$MARK_SCRIPT"

# Make it executable
chmod +x "$MARK_SCRIPT"

# Detect shell and rc file
SHELL_NAME="$(basename "$SHELL")"
RC_FILE=""

case "$SHELL_NAME" in
    bash)
        RC_FILE="$HOME/.bashrc"
        ;;
    zsh)
        RC_FILE="$HOME/.zshrc"
        ;;
    *)
        echo "Unsupported shell $SHELL_NAME. You may need to add the alias manually."
        ;;
esac

# Add alias if rc file exists
if [ -n "$RC_FILE" ]; then
    if ! grep -q 'alias mark=' "$RC_FILE"; then
        echo "alias mark='. \"$MARK_SCRIPT\"'" >> "$RC_FILE"
        echo "Alias added to $RC_FILE. Restart your shell or run 'source $RC_FILE'"
    fi
fi

echo "Installation complete! Use 'mark' to mark current directory and 'mark jump' to jump."
