#!/bin/bash

# brightness.sh: Control screen brightness and show notification.

REPLACE_ID=9999

# Function to send a notification
send_notification() {
    # Send the new one
    current_brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    percentage=$((current_brightness * 100 / max_brightness))
    notify-send "Brightness: ${percentage}%" -i display-brightness -r "$REPLACE_ID" -h int:value:"$percentage" -h string:x-canonical-private-synchronous:volume-notif -u low -c system
}

# Main logic
case "$1" in
    up)
        brightnessctl set 10%+
        send_notification
        ;;
    down)
        brightnessctl set 10%-
        send_notification
        ;;
    up-waybar)
        brightnessctl set 1%+
        send_notification
        ;;
    down-waybar)
        brightnessctl set 1%-
        send_notification
        ;;
esac
