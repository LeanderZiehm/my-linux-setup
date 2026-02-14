#!/usr/bin/env bash
set -euo pipefail

API_URL="https://llm.leanderziehm.com/chat/auto"

# Default system prompt
DEFAULT_SYSTEM_PROMPT="You are a helpful assistant. Provide clear, concise, and accurate answers."

# Require at least the message argument
if [ $# -lt 1 ]; then
  echo "Usage of llm cli add mandetory message and optional system_prompt as second argument: \"message\" [system_prompt]"
  exit 1
fi

MESSAGE="$1"
SYSTEM_PROMPT="${2:-$DEFAULT_SYSTEM_PROMPT}"

# Minimal JSON escaping
json_escape() {
  printf '%s' "$1" | sed \
    -e 's/\\/\\\\/g' \
    -e 's/"/\\"/g' \
    -e ':a;N;$!ba;s/\n/\\n/g'
}

ESCAPED_MESSAGE=$(json_escape "$MESSAGE")
ESCAPED_SYSTEM=$(json_escape "$SYSTEM_PROMPT")

# Call the LM API
RESPONSE=$(curl -sS -X POST "$API_URL" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"$ESCAPED_MESSAGE\",
    \"system_prompt\": \"$ESCAPED_SYSTEM\"
  }")

# Extract the response
ANSWER=$(printf '%s' "$RESPONSE" | sed -n '
  s/.*"message"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p
')

[ -z "$ANSWER" ] && ANSWER=$(printf '%s' "$RESPONSE" | sed -n '
  s/.*"response"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p
')

# Unescape common JSON sequences
ANSWER=$(printf '%s' "$ANSWER" | sed \
  -e 's/\\"/"/g' \
  -e 's/\\\\/\\/g' \
  -e 's/\\n/\n/g')

# Print
echo "$ANSWER"

# Copy to clipboard (Wayland/X11)
if command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$ANSWER" | wl-copy
elif command -v xclip >/dev/null 2>&1; then
  printf '%s' "$ANSWER" | xclip -selection clipboard
fi
