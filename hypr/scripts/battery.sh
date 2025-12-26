#!/bin/bash

# battery.sh: Daemon to monitor battery status and send notifications.
# Depends on 'acpi' for battery information and 'paplay' for sound.

# --- Configuration ---
LOW_THRESHOLD=20
CRITICAL_THRESHOLD=10
SLEEP_INTERVAL=1 # Check every 5 seconds for responsiveness

# --- Sound Files ---
SND_PLUGGED_IN="/usr/share/sounds/freedesktop/stereo/device-added.oga"
SND_PLUGGED_OUT="/usr/share/sounds/freedesktop/stereo/device-removed.oga"
SND_LOW_BATTERY="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"

# --- Initial State ---
# Check for acpi existence at the start
if ! command -v acpi &> /dev/null; then
    notify-send "Battery Script Error" "Please install 'acpi' to use this script." -u critical
    exit 1
fi

PREV_STATUS=$(acpi -b | awk -F'[,:%]' '{print $2}' | tr -d ' ')
NOTIFIED_LEVEL=0 # 0=none, 1=low, 2=critical

# --- Main Loop ---
while true; do
    BATTERY_INFO=$(acpi -b)
    # Exit gracefully if no battery is found (e.g., on a desktop)
    if [ -z "$BATTERY_INFO" ]; then
        exit 0
    fi

    STATUS=$(echo "$BATTERY_INFO" | awk -F'[,:%]' '{print $2}' | tr -d ' ')
    CAPACITY=$(echo "$BATTERY_INFO" | awk -F'[,:%]' '{print $3}' | tr -d ' ')

    # 1. Check for plug/unplug events (state change)
    if [ "$STATUS" != "$PREV_STATUS" ]; then
        if [[ "$STATUS" == "Charging" || "$STATUS" == "Full" ]]; then
            notify-send "Power Plugged In" "Device is charging." -i ac-adapter -u low -c system
            [ -f "$SND_PLUGGED_IN" ] && paplay "$SND_PLUGGED_IN" &
        elif [ "$STATUS" == "Discharging" ]; then
            notify-send "Power Unplugged" "Running on battery." -i battery-good -u low -c system
            [ -f "$SND_PLUGGED_OUT" ] && paplay "$SND_PLUGGED_OUT" &
        fi
        # Reset notification level on any status change
        NOTIFIED_LEVEL=0 
        # IMPORTANT: Update the status
        PREV_STATUS=$STATUS
    fi

    # 2. Check for low battery levels while discharging
    if [ "$STATUS" == "Discharging" ]; then
        if [ "$CAPACITY" -le "$CRITICAL_THRESHOLD" ] && [ "$NOTIFIED_LEVEL" -lt 2 ]; then
            notify-send "Critically Low Battery" "Battery at ${CAPACITY}%. System may shut down soon." -u critical -i battery-empty -c system
            [ -f "$SND_LOW_BATTERY" ] && paplay "$SND_LOW_BATTERY" &
            NOTIFIED_LEVEL=2
        elif [ "$CAPACITY" -le "$LOW_THRESHOLD" ] && [ "$NOTIFIED_LEVEL" -lt 1 ]; then
            notify-send "Low Battery" "Battery at ${CAPACITY}%. Please connect charger." -u normal -i battery-caution -c system
            [ -f "$SND_LOW_BATTERY" ] && paplay "$SND_LOW_BATTERY" &
            NOTIFIED_LEVEL=1
        fi
    fi
    
    # 3. Reset notification flag if battery is charged above the low threshold
    if [ "$STATUS" != "Discharging" ] || [ "$CAPACITY" -gt "$LOW_THRESHOLD" ]; then
        NOTIFIED_LEVEL=0
    fi

    sleep "$SLEEP_INTERVAL"
done
