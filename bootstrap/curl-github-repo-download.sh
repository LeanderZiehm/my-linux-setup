#!/bin/bash

# Step 1: Read GitHub username from environment variable
GH_USER="${GITHUB_USER:-}"

# If not set, ask for it
if [ -z "$GH_USER" ]; then
    read -rp "Enter your GitHub username: " GH_USER
fi

# Step 2: Ask for repository name
read -rp "Enter the repository name: " REPO

# Step 3: Construct URL and download the ZIP
ZIP_URL="https://github.com/$GH_USER/$REPO/archive/refs/heads/main.zip"
ZIP_FILE="$REPO-main.zip"

echo "Downloading $ZIP_URL ..."
curl -L "$ZIP_URL" -o "$ZIP_FILE"

# Step 4: Extract the archive
echo "Extracting $ZIP_FILE ..."
unzip -q "$ZIP_FILE"

# Step 5: Enter the extracted directory
DIR_NAME="$REPO-main"
cd "$DIR_NAME" || exit

echo "Now inside $(pwd)"
