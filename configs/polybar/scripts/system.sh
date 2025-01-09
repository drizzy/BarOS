#!/bin/env bash

##
# Author : Willow P. (drizzy)
# Github : @drizzy
#
# Script - System
##

rofi_theme_path="$HOME/.config/rofi/themes"

show_icon() {

  echo "󰢚"

}

system_menu() {
  
  options="󰐥 Poweroff\n󰑓 Reboot\n󰍃 Log out"
  
  selected=$(echo -e "$options" | rofi -theme "$rofi_theme_path/home.rasi" -dmenu)

  case "$selected" in
    "󰐥 Poweroff")
      systemctl poweroff
      ;;
    "󰑓 Reboot")
      systemctl reboot
      ;;
    "󰍃 Log out")
      bspc quit
      ;;
    *)
      echo "Invalid option: $selected" >&2
      exit 1
      ;;
  esac
}

"$@"