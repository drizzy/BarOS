#!/bin/env bash

##
# Author : Willow P. (drizzy)
# Github : @drizzy
#
# Script - Detect battery
##

BATTERY=$(ls /sys/class/power_supply/BAT* | head -n 1 | sed 's|/sys/class/power_supply/||')

ADAPTER=$(ls /sys/class/power_supply/AC* /sys/class/power_supply/ADP* | head -n 1 | sed 's|/sys/class/power_supply/||')

export BATTERY
export ADAPTER