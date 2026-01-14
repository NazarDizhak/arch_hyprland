#!/bin/bash

# This script toggles between workspace 11 (the "pocket" workspace)
# and the previously active workspace.

# Get the current active workspace ID
CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq -r ".id")

# Define the pocket workspace ID
POCKET_WORKSPACE=11

if [ "$CURRENT_WORKSPACE" -eq "$POCKET_WORKSPACE" ]; then
  # If we are currently on the pocket workspace, switch to the previous one.
  hyprctl dispatch workspace previous
else
  # If we are on any other workspace, switch to the pocket workspace.
  hyprctl dispatch workspace "$POCKET_WORKSPACE"
fi
