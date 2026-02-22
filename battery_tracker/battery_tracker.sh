#!/usr/bin/env bash

BAT0="/sys/class/power_supply/BAT0"
BAT1="/sys/class/power_supply/BAT1"

TOTAL_ENERGY_NOW=0
TOTAL_ENERGY_FULL=0

BAT0_STATUS="unknown"
BAT1_STATUS="unknown"

if [[ -d "$BAT0" ]]; then
    BAT0_NOW=$(cat "$BAT0/energy_now")
    BAT0_FULL=$(cat "$BAT0/energy_full")
    BAT0_STATUS=$(cat "$BAT0/status")
    TOTAL_ENERGY_NOW=$((TOTAL_ENERGY_NOW + BAT0_NOW))
    TOTAL_ENERGY_FULL=$((TOTAL_ENERGY_FULL + BAT0_FULL))
else
    echo "✖ BAT0 not found"
fi

if [[ -d "$BAT1" ]]; then
    BAT1_NOW=$(cat "$BAT1/energy_now")
    BAT1_FULL=$(cat "$BAT1/energy_full")
    BAT1_STATUS=$(cat "$BAT1/status")
    TOTAL_ENERGY_NOW=$((TOTAL_ENERGY_NOW + BAT1_NOW))
    TOTAL_ENERGY_FULL=$((TOTAL_ENERGY_FULL + BAT1_FULL))
else
    echo "✖ BAT1 not found"
fi

TOTAL_PERCENT=$((100 * TOTAL_ENERGY_NOW / TOTAL_ENERGY_FULL))

curl -X POST \
  https://tracker-api.leanderziehm.com/json \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  --data-binary @- <<EOF
{
  "text": "battery-test",
  "body": {
    "total_energy_now": $TOTAL_ENERGY_NOW,
    "total_energy_full": $TOTAL_ENERGY_FULL,
    "bat0_status": "$BAT0_STATUS",
    "bat1_status": "$BAT1_STATUS",
    "total_percent": $TOTAL_PERCENT
  }
}
EOF
