#!/usr/bin/env bash

MARKS_FILE="$HOME/marks.csv"
touch "$MARKS_FILE"

add_mark() {
    local path timestamp
    path="$(pwd)"
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "\"$path\",\"$timestamp\"" >> "$MARKS_FILE"
    echo "Marked: $path at $timestamp"
}

fuzzy_search() {
    local query="$1"
    awk -F',' -v q="$query" '{ gsub(/^"|"$/, "", $1); if (tolower($1) ~ tolower(q)) print $1 }' "$MARKS_FILE"
}

jump_mark() {
    local query="$1"
    local matches selected path

    matches=$(fuzzy_search "$query")

    if [ -z "$matches" ]; then
        echo "No matches found for '$query'" >&2
        return 1
    fi

    if [ "$(echo "$matches" | wc -l)" -eq 1 ]; then
        selected="$matches"
    else
        echo "Multiple matches found:"
        echo "$matches" | nl
        read -rp "Select a number: " choice
        selected=$(echo "$matches" | sed -n "${choice}p")
    fi

    path="$selected"
    cd "$path" || return 1
}

# Main logic
if [ "$1" == "jump" ]; then
    shift
    read -rp "Search: " query
    jump_mark "$query"
else
    add_mark
fi
