#!/bin/bash

# Simple network status

SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [ -n "$SSID" ]; then

    echo "WiFi: $SSID"

else

    echo "Ethernet"

fi
