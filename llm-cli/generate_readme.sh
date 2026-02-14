#!/usr/bin/env bash
set -euo pipefail

# depends on jq

API_URL="https://llm.leanderziehm.com/chat/auto"

SYSTEM_PROMPT="You are a helpful assistant that generates a concise README.md based on project files. Include installation, usage, and description. Only put most important information in to not overwelm users."

MAX_FILE_SIZE_KB=200
EXCLUDES=(
  "*/.git/*"
  "*/node_modules/*"
  "*/dist/*"
  "*/build/*"
  "*/.idea/*"
  "*/.vscode/*"
)

# ---- Check dependencies ----
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install with: sudo pacman -S jq"
  exit 1
fi

if ! command -v file >/dev/null 2>&1; then
  echo "Error: file command is required."
  exit 1
fi

# ---- Build file list ----
FIND_ARGS=(-type f)

for pattern in "${EXCLUDES[@]}"; do
  FIND_ARGS+=(-not -path "$pattern")
done

FIND_ARGS+=(-size "-${MAX_FILE_SIZE_KB}k" -print0)

MESSAGE=""

while IFS= read -r -d '' file; do
  # Skip binary files
  if file --mime "$file" | grep -q 'charset=binary'; then
    continue
  fi

  MESSAGE+="# ${file#./}"$'\n'
  MESSAGE+="\`\`\`"$'\n'
  MESSAGE+="$(cat "$file")"$'\n'
  MESSAGE+="\`\`\`"$'\n\n'

done < <(find . "${FIND_ARGS[@]}")

if [[ -z "$MESSAGE" ]]; then
  echo "No valid text files found."
  exit 1
fi

# ---- Build JSON safely with jq ----
JSON=$(jq -n \
  --arg message "$MESSAGE" \
  --arg system_prompt "$SYSTEM_PROMPT" \
  '{message: $message, system_prompt: $system_prompt}')

# ---- Call API with proper error handling ----
HTTP_RESPONSE=$(curl -sS -w "\n%{http_code}" \
  -X POST "$API_URL" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  --data-binary "$JSON")

HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n1)
BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

if [[ "$HTTP_STATUS" -ne 200 ]]; then
  echo "HTTP Error: $HTTP_STATUS"
  echo "$BODY"
  exit 1
fi

# ---- Extract response safely ----
ANSWER=$(printf '%s' "$BODY" | jq -r '
  .message //
  .response //
  .data.message //
  .choices[0].message.content //
  empty
')

if [[ -z "$ANSWER" ]]; then
  echo "Error: Could not extract message from API response."
  echo "$BODY"
  exit 1
fi

# ---- Output ----
echo "$ANSWER"

# ---- Save to README file safely ----
OUTPUT_FILE="README.md"

if [[ -e "$OUTPUT_FILE" ]]; then
  i=1
  while [[ -e "README_${i}.md" ]]; do
    ((i++))
  done
  OUTPUT_FILE="README_${i}.md"
fi

printf '%s\n' "$ANSWER" > "$OUTPUT_FILE"

echo "Saved to $OUTPUT_FILE"
