#!/bin/env bash

##
 #
 # Author : Willow P. (drizzy)
 # Github : @drizzy
 #
 # Script - Temperature
 ##

COLOR_LOW="#A3BE8C"
COLOR_MEDIUM="#EBCB8B"
COLOR_HIGH="#BF616A"

ICON_LOW=""
ICON_MEDIUM=""
ICON_HIGH=""

HWMON_DIR=$(find /sys/class/hwmon/ -type l -exec sh -c 'readlink -f "$1"' _ {} \; | grep "coretemp.0" | xargs basename)

if [ -z "$HWMON_DIR" ]; then
    echo "The hwmon directory for coretemp.0 was not found."
    exit 1
fi

TEMP_FILE=$(ls /sys/class/hwmon/"$HWMON_DIR"/temp*_input | head -n 1)

if [ -z "$TEMP_FILE" ]; then
    echo "Temperature file not found."
    exit 1
fi

TEMP=$(cat "$TEMP_FILE")
TEMP=$((TEMP / 1000))

if [ "$TEMP" -lt 45 ]; then
    ICON="$ICON_LOW"
    COLOR="$COLOR_LOW"
elif [ "$TEMP" -lt 65 ]; then
    ICON="$ICON_MEDIUM"
    COLOR="$COLOR_MEDIUM"
else
    ICON="$ICON_HIGH"
    COLOR="$COLOR_HIGH"
fi

echo "%{F$COLOR}$ICON $TEMP°C%{F-}"