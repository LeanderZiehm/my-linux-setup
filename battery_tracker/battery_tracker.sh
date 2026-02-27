#!/usr/bin/env bash

BAT0="/sys/class/power_supply/BAT0"
BAT1="/sys/class/power_supply/BAT1"

TOTAL_ENERGY_NOW=0
TOTAL_ENERGY_FULL=0

BAT0_STATUS=""
BAT1_STATUS=""
BAT_STATUS="unknown"

read_battery() {
    local BAT_PATH="$1"
    local BAT_NAME="$2"

    if [[ -d "$BAT_PATH" ]]; then
        local NOW FULL STATUS

        NOW=$(<"$BAT_PATH/energy_now")
        FULL=$(<"$BAT_PATH/energy_full")
        STATUS=$(<"$BAT_PATH/status")

        # create BAT0_NOW, BAT0_FULL, etc.
        printf -v "${BAT_NAME}_NOW" '%s' "$NOW"
        printf -v "${BAT_NAME}_FULL" '%s' "$FULL"
        printf -v "${BAT_NAME}_STATUS" '%s' "$STATUS"

        # use the explicit variable names in arithmetic
        TOTAL_ENERGY_NOW=$((TOTAL_ENERGY_NOW + ${BAT_NAME}_NOW))
        TOTAL_ENERGY_FULL=$((TOTAL_ENERGY_FULL + ${BAT_NAME}_FULL))
    fi
}

read_battery "$BAT0" BAT0
read_battery "$BAT1" BAT1

# normalize status
BAT0_STATUS="${BAT0_STATUS,,}"
BAT1_STATUS="${BAT1_STATUS,,}"

if [[ "$BAT0_STATUS" == "discharging" || "$BAT1_STATUS" == "discharging" ]]; then
    BAT_STATUS="discharging"
elif [[ "$BAT0_STATUS" == "charging" || "$BAT1_STATUS" == "charging" ]]; then
    BAT_STATUS="charging"
fi

if [[ "$TOTAL_ENERGY_FULL" -gt 0 ]]; then
    TOTAL_PERCENT=$((100 * TOTAL_ENERGY_NOW / TOTAL_ENERGY_FULL))
else
    echo "✖ No batteries detected"
    exit 1
fi

curl -X POST \
  https://tracker-api.leanderziehm.com/json \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  --data-binary @- <<EOF
{
  "text": "battery(arch2)",
  "body": {
    "status": "$BAT_STATUS",
    "percent": $TOTAL_PERCENT
  }
}
EOF