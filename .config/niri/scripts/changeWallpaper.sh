#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
    rofi -e "No such directory: $WALLPAPER_DIR"
    exit 1
fi

generate_rofi_list() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f -printf "%f\n"
}

SELECTED_BASENAME=$(generate_rofi_list | rofi -dmenu -i -p "Choose wallpaper")

if [ -z "$SELECTED_BASENAME" ]; then
    exit 1
fi

FULL_PATH="$WALLPAPER_DIR/$SELECTED_BASENAME"

MODE=$(printf "light\ndark\n" | rofi -dmenu -i -p "Matugen mode")

if [ -z "$MODE" ]; then
    exit 1
fi

ln -sf "$FULL_PATH" ~/.cache/current_wallpaper

matugen image "$FULL_PATH" --mode "$MODE" --json hex

# Apply wallpaper using swaybg
killall swaybg 2>/dev/null
swaybg -i ~/.cache/current_wallpaper >/dev/null 2>&1 &
