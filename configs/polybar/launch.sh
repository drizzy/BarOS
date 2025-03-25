#!/bin/env bash

##
 #
 # Author : Willow P. (drizzy)
 # Github : @drizzy
 #
 # Script - Polybar launched
 ##

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bars with a small delay
polybar system --config="$HOME/.config/polybar/config.ini" &
sleep 0.5

polybar workspace --config="$HOME/.config/polybar/config.ini" &
sleep 0.5

polybar player --config="$HOME/.config/polybar/config.ini" &
sleep 0.5

polybar clock --config="$HOME/.config/polybar/config.ini" &
sleep 0.5

polybar sysinfo-bar --config="$HOME/.config/polybar/config.ini" &
sleep 0.5

polybar control-hub --config="$HOME/.config/polybar/config.ini" &

echo "Polybar launched..."