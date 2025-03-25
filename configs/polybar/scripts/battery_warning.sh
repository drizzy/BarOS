#!/bin/env bash

##
 #
 # Author : Willow P. (drizzy)
 # Github : @drizzy
 #
 # Script - Battery warning
 ##

BATTERY=$(ls /sys/class/power_supply/ | grep -i BAT | head -n 1)

if [ -z "$BATTERY" ]; then
    echo "No battery found."
    exit 1
fi

BATTERY_LEVEL=$(cat /sys/class/power_supply/${BATTERY}/capacity 2>/dev/null)

if [ -z "$BATTERY_LEVEL" ]; then
    echo "Error: Could not get battery level."
    exit 1
fi

LOW_BATTERY_THRESHOLD=20

LAST_BATTERY_FILE="/tmp/last_battery_level.txt"

if [ ! -f "$LAST_BATTERY_FILE" ]; then
    echo "$BATTERY_LEVEL" > "$LAST_BATTERY_FILE"
fi

LAST_BATTERY_LEVEL=$(cat "$LAST_BATTERY_FILE")

BATTERY_STATUS=$(cat /sys/class/power_supply/${BATTERY}/status)

if [ "$BATTERY_STATUS" != "Charging" ] && [ "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD" ] && [ "$BATTERY_LEVEL" -ne "$LAST_BATTERY_LEVEL" ]; then
    notify-send -u critical "Low battery!" "The battery is at ${BATTERY_LEVEL}%. Connect to a power source."
    echo "$BATTERY_LEVEL" > "$LAST_BATTERY_FILE"
elif [ "$BATTERY_STATUS" != "Charging" ] && [ "$BATTERY_LEVEL" -gt "$LOW_BATTERY_THRESHOLD" ] && [ "$BATTERY_LEVEL" -ne "$LAST_BATTERY_LEVEL" ]; then
    echo "$BATTERY_LEVEL" > "$LAST_BATTERY_FILE" 
fi