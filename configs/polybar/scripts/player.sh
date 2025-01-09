#!/bin/env bash

##
 #
 # Author : Willow P. (drizzy)
 # Github : @drizzy
 #
 # Script - Player
 ##

title_color="#D08770"
artist_color="#A3BE8C"
button_color="#81A1C1"

prev_title=""
prev_artist=""
scroll_offset=0
max_length=13
scroll_speed=0.3
padding="     "

while true; do
 
  status=$(playerctl status 2>/dev/null)

  if [[ -z "$status" || "$status" == "Stopped" ]]; then
    text="󰝚 No track playing"
    echo "%{F#F5C542}  ${text}%{F-}"
  else
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)

    if [[ "$title" != "$prev_title" || "$artist" != "$prev_artist" ]]; then
      scroll_offset=0
      prev_title="$title"
      prev_artist="$artist"
    fi

    display_text="${title} - ${artist}${padding}${title} - ${artist}"
    display_length=$(( ${#title} + ${#artist} + 3 ))

    if [[ $scroll_offset -ge $((display_length + ${#padding})) ]]; then
      scroll_offset=0
    fi

    scrolling="${display_text:scroll_offset:max_length}"
    scroll_offset=$((scroll_offset + 1))

    title_end_index=$((${#title} < max_length ? ${#title} : max_length))
    current_title="${scrolling:0:title_end_index}"
    remaining_length=$((max_length - ${#current_title}))

    if [[ $remaining_length -gt 0 ]]; then
      current_artist="${scrolling:title_end_index:remaining_length}"
    else
      current_artist=""
    fi

    colored_title="%{F$title_color}${current_title}%{F-}"
    colored_artist="%{F$artist_color}${current_artist}%{F-}"

    if [[ "$status" == "Playing" ]]; then
      play_pause_button="󰏤"
      play_pause_action="playerctl pause"
    else
      play_pause_button="󰐊"
      play_pause_action="playerctl play"
    fi

    echo "%{A1:playerctl previous:}%{F$button_color} 󰒮%{F-}%{A} \
%{A1:$play_pause_action:}%{F$button_color}$play_pause_button%{F-}%{A} \
%{A1:playerctl next:}%{F$button_color}󰒭%{F-}%{A} $colored_title $colored_artist"

  fi

  sleep $scroll_speed
done
