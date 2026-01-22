#!/usr/bin/env bash

MARKS_FILE="$HOME/marks.csv"
touch "$MARKS_FILE"

# Add the current directory with timestamp
add_mark() {
    local path timestamp
    path="$(pwd)"
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "\"$path\",\"$timestamp\"" >> "$MARKS_FILE"
    echo "Marked: $path at $timestamp"
}

# Simple fuzzy search by query
fuzzy_search() {
    local query="$1"
    awk -F',' -v q="$query" '{ gsub(/^"|"$/, "", $1); if (tolower($1) ~ tolower(q)) print $1 }' "$MARKS_FILE"
}

# Jump to a fuzzy match (prompts if multiple)
jump_mark() {
    local query matches selected path

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

# List all stored marks
list_marks() {
    if [ ! -s "$MARKS_FILE" ]; then
        echo "No marks stored yet."
        return
    fi
    awk -F',' '{gsub(/^"|"$/,"",$1); print $1 "  (" $2 ")"}' "$MARKS_FILE"
}

# FZF select and jump, deduplicated and sorted by recency/frequency
fzf_jump() {
    if ! command -v fzf &>/dev/null; then
        echo "fzf not found. Install it to use this feature." >&2
        return 1
    fi

    if [ ! -s "$MARKS_FILE" ]; then
        echo "No marks stored yet."
        return 1
    fi

    # Prepare list: deduplicate paths, count frequency, get latest timestamp
    local tmp
    tmp=$(mktemp)

    awk -F',' '{
        gsub(/^"|"$/,"",$1);
        path=$1;
        time=$2;
        count[path]++;
        if (time > last[path]) last[path]=time;
    } END {
        for(p in count) print count[p] "\t" last[p] "\t" p;
    }' "$MARKS_FILE" > "$tmp"

    # Sort: first by recency (desc), then frequency (desc)
    # -k2: timestamp descending, -k1: frequency descending
    local path
    path=$(sort -r -k2,2 -k1,1 -t$'\t' "$tmp" | awk -F'\t' '{print $3}' | fzf --prompt="Select mark: ")

    rm -f "$tmp"

    [ -n "$path" ] && cd "$path"
}

# Main logic
case "$1" in
    jump)
        shift
        if [ $# -gt 0 ]; then
            jump_mark "$*"
        else
            read -rp "Search: " query
            jump_mark "$query"
        fi
        ;;
    ls)
        list_marks
        ;;
    fzf)
        fzf_jump
        ;;
    *)
        add_mark
        ;;
esac
