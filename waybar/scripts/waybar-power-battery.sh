#!/bin/bash

if ! command -v jq &> /dev/null;
then
    printf '{"text": "ERR", "tooltip": "jq is not installed"}\n'
    exit 1
fi

if ! command -v powerprofilesctl &> /dev/null;
then
    printf '{"text": "ERR", "tooltip": "powerprofilesctl not found"}\n'
    exit 1
fi

if ! command -v acpi &> /dev/null;
then
    printf '{"text": "ERR", "tooltip": "acpi not found"}\n'
    exit 1
fi

battery_info=$(acpi -b)
if [ -z "$battery_info" ];
then
    printf '{"text": "NO-BATT", "tooltip": "No battery found"}\n'
    exit 0
fi

capacity=$(echo "$battery_info" | grep -oP '[0-9]+(?=%)')
status=$(echo "$battery_info" | awk -F'[,:%]' '{print $2}' | tr -d ' ')

if [ -z "$capacity" ];
then
    printf '{"text": "ERR", "tooltip": "Could not parse battery capacity"}\n'
    exit 1
fi

profile=$(powerprofilesctl get)
time_remaining=$(echo "$battery_info" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]')

# Set icon based on status and capacity
if [ "$status" = "Charging" ] || [ "$status" = "Full" ];
then
    icon=""
else
    if [ "$capacity" -gt 90 ];
then
        icon="󰁹"
    elif [ "$capacity" -gt 80 ];
then
        icon="󰂂"
    elif [ "$capacity" -gt 70 ];
then
        icon="󰂁"
    elif [ "$capacity" -gt 60 ];
then
        icon="󰂀"
    elif [ "$capacity" -gt 50 ];
then
        icon="󰁿"
    elif [ "$capacity" -gt 40 ];
then
        icon="󰁾"
    elif [ "$capacity" -gt 30 ];
then
        icon="󰁽"
    elif [ "$capacity" -gt 20 ];
then
        icon="󰁼"
    elif [ "$capacity" -gt 10 ];
then
        icon="󰁻"
    else
        icon="󰁺"
    fi
fi

# Prepare variables for jq
text="$icon $capacity%"
class="$profile"
line1="Battery: $capacity% ($status)"
line2=""
if [ -n "$time_remaining" ];
then
    line2="Time: $time_remaining"
fi
line3="Profile: $profile"

# Use jq to safely construct the JSON, building the tooltip inside jq
jq -n -c \
  --arg text "$text" \
  --arg class "$class" \
  --arg line1 "$line1" \
  --arg line2 "$line2" \
  --arg line3 "$line3" \
  '{text: $text, class: $class, tooltip: ($line1 + "\n" + $line2 + "\n" + $line3 | sub("\n\n"; "\n"))}'
