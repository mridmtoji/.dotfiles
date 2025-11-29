#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_WALL="$HOME/.cache/current_wallpaper"

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

if [ -f "$CACHE_WALL" ] && [ "$(readlink -f "$CACHE_WALL")" = "$(readlink -f "$FULL_PATH")" ]; then
    matugen image "$FULL_PATH" --mode "$MODE" --json hex
    exit 0
fi

ln -sf "$FULL_PATH" "$CACHE_WALL"

matugen image "$FULL_PATH" --mode "$MODE" --json hex

killall swaybg 2>/dev/null
swaybg -i "$CACHE_WALL" >/dev/null 2>&1 &
