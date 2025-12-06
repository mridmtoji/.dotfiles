#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_WALL="$HOME/.cache/current_wallpaper"

SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.gif' \) \
  | walker --dmenu "Choose wallpaper:")

[ -z "$SELECTED" ] && exit 0

MODE=$(printf "light\ndark\n" | walker --dmenu "Matugen mode:")
[ -z "$MODE" ] && exit 0

ln -sf "$SELECTED" "$CACHE_WALL"

matugen image "$SELECTED" --mode "$MODE"

# pkill awww 2>/dev/null

awww img "$CACHE_WALL" &
