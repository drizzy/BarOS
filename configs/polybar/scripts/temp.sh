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

TEMP=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon3/temp1_input)
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
