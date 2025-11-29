#!/bin/bash

PRESET_DIR="$HOME/.config/sunsetr/presets"
PRESETS=$(find "$PRESET_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

ACTIVE=$(sunsetr preset active | awk '{print $3}')
MENU=$(echo "$PRESETS" | sed "s/^$ACTIVE$/  $ACTIVE/")

if [ -z "$PRESETS" ]; then
    rofi -e "No sunsetr presets found!"
    exit 1
fi

CHOSEN=$(echo "$MENU" | rofi -dmenu -p "Sunsetr Preset" | sed 's/^  //')

[ -z "$CHOSEN" ] && exit 0

sunsetr preset "$CHOSEN"
notify-send "Sunsetr" "Switched to preset: $CHOSEN"
