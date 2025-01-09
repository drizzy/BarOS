#!/bin/env bash

##
 #
 # Author : Willow P. (drizzy)
 # Github : @drizzy
 #
 # Script - Volume
 ##

COLOR_VOLUME="DFAF8F"
COLOR_VOLUME_MUTED="95A5A6"

get_volume() {
    local output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [ -z "$output" ]; then
        echo "0"
    else
        echo "$output" | awk '{printf "%.0f", $2 * 100}'
    fi
}

is_muted() {
    local output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [ -z "$output" ]; then
        echo ""
    else
        echo "$output" | grep -q '[MUTED]' && echo "󰝟 Muted" || echo ""
    fi
}

volume_icon() {
    local volume=$(get_volume)
    local muted=$(is_muted)

    if ! [[ "$volume" =~ ^[0-9]+$ ]]; then
        volume=0
    fi

    if [ -n "$muted" ]; then
        echo "%{F$COLOR_VOLUME_MUTED}$muted"
    elif [ "$volume" -eq 0 ]; then
        echo "%{F$COLOR_VOLUME}  $volume%"
    elif [ "$volume" -lt 50 ]; then
        echo "%{F$COLOR_VOLUME}  $volume%"
    else
        echo "%{F$COLOR_VOLUME}  $volume%"
    fi
}

case "$1" in
    up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    *)
        volume_icon
        ;;
esac
