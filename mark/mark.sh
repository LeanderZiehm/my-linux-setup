#!/usr/bin/env bash

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
MARK_DIR="$XDG_DATA_HOME/mark"
MARKS_FILE="$MARK_DIR/marks.csv"
touch "$MARKS_FILE"

# Add the current directory with timestamp and event type "marked"
add_mark() {
    local path timestamp
    path="$(pwd)"
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "\"$path\",\"$timestamp\",\"marked\"" >> "$MARKS_FILE"
    echo "Marked: $path at $timestamp"
}

# Jump to a fuzzy match (prompts if multiple), records event "selected"
jump_mark() {
    local query matches selected path
    matches=$(awk -F',' -v q="$query" '{gsub(/^"|"$/,"",$1); if(tolower($1) ~ tolower(q)) print $1}' "$MARKS_FILE")
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

    # Record the selection event
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "\"$path\",\"$timestamp\",\"selected\"" >> "$MARKS_FILE"

    cd "$path" || return 1
}

# List all stored marks
list_marks() {
    if [ ! -s "$MARKS_FILE" ]; then
        echo "No marks stored yet."
        return
    fi
    awk -F',' '{gsub(/^"|"$/,"",$1); print $1 "  (" $2 ", " $3 ")"}' "$MARKS_FILE"
}

# FZF select and jump, sorted by recency & frequency with event weighting
fzf_jump() {
    if ! command -v fzf &>/dev/null; then
        echo "fzf not found. Install it to use this feature." >&2
        return 1
    fi
    if [ ! -s "$MARKS_FILE" ]; then
        echo "No marks stored yet."
        return 1
    fi

    local tmp
    tmp=$(mktemp)

    # Prepare table: path, count_marked, count_selected, latest_marked, latest_selected
    awk -F',' '{
        gsub(/^"|"$/,"",$1);
        path=$1;
        time=$2;
        event=$3;
        if(event=="marked") {count_marked[path]++; if(time>latest_marked[path]) latest_marked[path]=time}
        else if(event=="selected") {count_selected[path]++; if(time>latest_selected[path]) latest_selected[path]=time}
        # Build unique paths
        all_paths[path]=1
    } END {
        for(p in all_paths) {
            cm = count_marked[p]+0
            cs = count_selected[p]+0
            lm = latest_marked[p] ? latest_marked[p] : "1970-01-01 00:00:00"
            ls = latest_selected[p] ? latest_selected[p] : "1970-01-01 00:00:00"
            print cs "\t" ls "\t" cm "\t" lm "\t" p
        }
    }' "$MARKS_FILE" > "$tmp"

    # Sort: latest selected first, then selected frequency, then latest marked, then marked frequency
    local path
    path=$(sort -r -k2,2 -k1,1 -k4,4 -k3,3 -t$'\t' "$tmp" | awk -F'\t' '{print $5}' | fzf --prompt="Select mark: ")

    rm -f "$tmp"

    if [ -n "$path" ]; then
        # Record selected event
        echo "\"$path\",\"$(date '+%Y-%m-%d %H:%M:%S')\",\"selected\"" >> "$MARKS_FILE"
        cd "$path"
    fi
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
