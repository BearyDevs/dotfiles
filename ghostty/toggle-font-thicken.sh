#!/bin/bash

# Manual toggle script for font-thicken
CONFIG_FILE="$HOME/.config/ghostty/config"

# Check current state
if grep -q "^font-thicken = true" "$CONFIG_FILE"; then
    # Currently enabled, disable it
    sed -i.bak 's/^font-thicken = true/font-thicken = false/' "$CONFIG_FILE"
    echo "✓ Font thickening DISABLED"
elif grep -q "^font-thicken = false" "$CONFIG_FILE"; then
    # Currently disabled, enable it
    sed -i.bak 's/^font-thicken = false/font-thicken = true/' "$CONFIG_FILE"
    echo "✓ Font thickening ENABLED"
else
    echo "⚠ font-thicken setting not found in config"
    exit 1
fi

# Reload Ghostty config
osascript -e 'tell application "System Events" to keystroke "r" using command down' 2>/dev/null
echo "✓ Config reloaded"
