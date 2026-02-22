#!/usr/bin/env bash
set -e

# Install Arch build dependencies
sudo pacman -S --needed base-devel dbus dbus-glib glib2

# Install venv dependencies
uv sync  # or pip install -r requirements.txt