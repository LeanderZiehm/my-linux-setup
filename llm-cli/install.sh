#!/usr/bin/env bash
set -euo pipefail

BASHRC="$HOME/.bashrc"

# Hardcoded mapping: script filename → alias name
declare -A ALIASES=(
    ["llm.sh"]="llm"
    ["generate_readme.sh"]="generate_readme"
)

for SCRIPT_NAME in "${!ALIASES[@]}"; do
    ALIAS_NAME="${ALIASES[$SCRIPT_NAME]}"
    SCRIPT_PATH="$(realpath "$SCRIPT_NAME")"
    ALIAS_CMD="alias $ALIAS_NAME='bash $SCRIPT_PATH'"

    if grep -Fxq "$ALIAS_CMD" "$BASHRC"; then
        echo "Alias '$SCRIPT_NAME' already exists in $BASHRC"
    else
        echo "$ALIAS_CMD" >> "$BASHRC"
        echo "Alias '$SCRIPT_NAME' added to $BASHRC"
    fi
done

echo "Done. Run 'source $BASHRC' to activate the aliases."
