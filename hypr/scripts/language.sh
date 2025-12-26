#!/bin/bash
# language.sh: Switches keyboard layout and sends a notification.
# Depends on 'jq' for parsing Hyprland's JSON output.

REPLACE_ID=9999

# Check if jq is installed
if ! command -v jq &> /dev/null;
then
    notify-send "Layout Switch Error" "'jq' is not installed. Please install it." -u critical
    exit 1
fi

# Get the name of the main keyboard (the one with "main": true)
KEYBOARD_NAME=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name')

# If no main keyboard is found, fall back to the first one in the list
if [ -z "$KEYBOARD_NAME" ]; then
    KEYBOARD_NAME=$(hyprctl devices -j | jq -r '.keyboards[0].name')
fi

# If still no keyboard found, exit with an error
if [ -z "$KEYBOARD_NAME" ]; then
    notify-send "Layout Switch Error" "Could not find a keyboard to control." -u critical
    exit 1
fi

# Switch layout for the found device
hyprctl switchxkblayout "$KEYBOARD_NAME" next >/dev/null

# Wait a moment for the change to apply
sleep 0.1

# Get the new layout name
LAYOUT_NAME=$(hyprctl devices -j | jq -r ".keyboards[] | select(.name == \"$KEYBOARD_NAME\") | .active_keymap")

if [ -z "$LAYOUT_NAME" ]; then
    notify-send "Layout Switch Error" "Could not determine the new keyboard layout." -u critical
    exit 1
fi

# Send the new one
notify-send "Layout" "$LAYOUT_NAME" -r "$REPLACE_ID" -h string:x-canonical-private-synchronous:volume-notif -u low -c system
