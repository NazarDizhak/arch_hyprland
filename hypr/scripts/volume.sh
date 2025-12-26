#!/bin/bash

# volume.sh: Control volume, play feedback sound, and show notification.

SOUND_FILE="/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
REPLACE_ID=9999

send_notification() {
    # Get volume and mute status
    volume=$(pamixer --get-volume)
    mute=$(pamixer --get-mute)

    local notification_summary=""
    local progress_value=""
    local notification_category="system" # All system messages go to this category

    # Handle Muted State
    if [[ "$mute" == "true" ]]; then
        notify-send "Volume: Muted" -i audio-volume-muted -r "$REPLACE_ID" -u low -c "$notification_category"
        return
    fi

    # Set a hard cap at 150 for display purposes
    if (( volume > 150 )); then
        volume=150
    fi

    # Logic to determine summary and progress bar value and custom hint
    local volume_state="normal" # Default volume state

    if (( volume > 100 )); then
        notification_summary="Volume"
        # Scale the 101-150 range to a 0-100 value for the progress bar
        progress_value=$(( (volume - 100) * 100 / 50 ))
        notification_category="system-boosted" # Boosted volume uses 'boosted' state
    else
        notification_summary="Volume"
        progress_value=$volume
	notification_category="system"
    fi

    # Send the notification
    notify-send "$notification_summary: ${volume}%" \
        -i audio-volume-high \
        -r "$REPLACE_ID" \
        -h int:value:"$progress_value" \
	-h string:x-canonical-private-synchronous:volume-notif \
        -u low \
        -c "$notification_category"
}

case "$1" in
    up)
        current_volume=$(pamixer --get-volume)
        new_volume=$((current_volume + 5))
        if [ "$new_volume" -gt 150 ]; then
            new_volume=150
        fi
        pamixer --allow-boost --set-volume $new_volume
        send_notification
        [ -f "$SOUND_FILE" ] && paplay "$SOUND_FILE" &
        ;;
    down)
        # Calculate new volume and use set-volume with allow-boost to prevent jumping
        current_volume=$(pamixer --get-volume)
        new_volume=$((current_volume - 5))
        pamixer --allow-boost --set-volume $new_volume
        send_notification
        [ -f "$SOUND_FILE" ] && paplay "$SOUND_FILE" &
        ;;
    mute)
        pamixer -t
        send_notification
        [ -f "$SOUND_FILE" ] && paplay "$SOUND_FILE" &
        ;;
esac
