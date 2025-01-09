#!/bin/env bash

##
# Author : Willow P. (drizzy)
# Github : @drizzy
#
# Script - Wifi
##

rofi_theme_path="$HOME/.config/rofi/themes"

get_wifi_icon() {
    local signal="$1"
    if [ "$signal" -ge 75 ]; then
        echo "󰤨"
    elif [ "$signal" -ge 50 ]; then
        echo "󰤢"
    elif [ "$signal" -ge 25 ]; then
        echo "󰤟"
    else
        echo "󰤯"
    fi
}

wifi_signal() {
    wifi_info=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes:')
    if [ -n "$wifi_info" ]; then
        ssid=$(echo "$wifi_info" | cut -d':' -f2)
        signal=$(echo "$wifi_info" | cut -d':' -f3)
        icon=$(get_wifi_icon "$signal")
        if [ ${#ssid} -gt 2 ]; then
            ssid="${ssid:0:2}+"
        fi
        echo "$icon $ssid"
    else
        echo "%{F#BF616A}󰖪 Off"
    fi
}

wifi_list() {

        networks=$(nmcli -t -f SSID,SECURITY,SIGNAL dev wifi | awk -F: '
        function get_icon(signal) {
            if (signal >= 75) return "󰤨";
            else if (signal >= 50) return "󰤢";
            else if (signal >= 25) return "󰤟";
            else return "󰤯";
        }
        {
            ssid = $1;
            security = $2;
            signal = $3;
            
            if (security == "") {
                print get_icon(signal) " " ssid;
            } else {
                print get_icon(signal) " " ssid " (" security ")";
            }
        }')

        networks_with_status=$(echo "$networks" | while read -r line; do
            ssid=$(echo "$line" | awk -F"(" '{print $1}' | cut -d' ' -f2-)
            status=""

            if nmcli connection show --active | grep -q "$ssid"; then
                status="Connected"
            elif nmcli connection show | grep -q "$ssid"; then
                status="Saved"
            else
                status="Available"
            fi

            if [ -n "$status" ]; then
                echo "$line [$status]"
            else
                echo "$line"
            fi
        done)

        selected=$(echo -e "$networks_with_status" | rofi -theme "$rofi_theme_path/wifi.rasi" -dmenu -p "Wi-Fi:")

        if [ -n "$selected" ]; then
            ssid=$(echo "$selected" | awk -F"(" '{print $1}' | cut -d' ' -f2-)
            security=$(echo "$selected" | awk -F"(" '{print $2}' | tr -d ')')

            if nmcli connection show --active | grep -q "$ssid"; then
                notify-send "Wi-Fi" "You are already connected to $ssid"
                return
            elif nmcli connection show | grep -q "$ssid"; then
                nmcli connection up "$ssid" || notify-send "Error" "Could not connect to $ssid"
                return
            fi

            if [[ -n "$security" ]]; then
                password=$(rofi -theme "$rofi_theme_path/wifi-connect.rasi" -dmenu -p "$ssid" -password)
                if [ -n "$password" ]; then
                    nmcli dev wifi connect "$ssid" password "$password" || notify-send "Error" "Could not connect to $ssid"
                else
                    notify-send "Canceled" "No password entered."
                fi
            else
                nmcli dev wifi connect "$ssid" || notify-send "Error" "Could not connect to $ssid"
            fi
        fi

}

"$@"