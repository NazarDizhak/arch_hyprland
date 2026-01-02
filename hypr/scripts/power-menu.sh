#!/bin/bash

options="Performance
Balanced
Power Saver"

# Use dedicated config and style files to ensure the menu is not affected
# by the global wofi configuration. This is the most stable method.
chosen=$(echo -e "$options" | wofi \
    --dmenu \
    --conf /home/yopsa_matb/.config/wofi/config-power \
    --style /home/yopsa_matb/.config/wofi/style-power.css
)

case "$chosen" in
    "Performance")
        powerprofilesctl set performance
        ;;
    "Balanced")
        powerprofilesctl set balanced
        ;;
    "Power Saver")
        powerprofilesctl set power-saver
        ;;
esac