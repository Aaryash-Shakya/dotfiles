#!/bin/bash

BAT=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo "N/A")

STATUS=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo "Unknown")

if [ "$STATUS" = "Charging" ]; then

    echo "$BAT% ⚡"

else

    echo "$BAT%"

fi
