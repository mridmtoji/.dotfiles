#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_WALL="$HOME/.cache/current_wallpaper"

SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.mp4' \) \
  | vicinae dmenu -p "Choose wallpaper:")

[ -z "$SELECTED" ] && exit 0

EXT="${SELECTED##*.}"
EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

if [ "$EXT_LOWER" = "mp4" ]; then
  pkill mpvpaper 2>/dev/null
  
  mpvpaper -o "no-audio loop" ALL "$SELECTED" &
  
  ln -sf "$SELECTED" "$CACHE_WALL"
else
  MODE=$(printf "light\ndark\n" | vicinae dmenu -p "Mode:")
  [ -z "$MODE" ] && exit 0
  
  ln -sf "$SELECTED" "$CACHE_WALL"
  matugen image "$SELECTED" --mode "$MODE"
  
  pkill mpvpaper 2>/dev/null
  
  awww img --transition-duration 1 "$CACHE_WALL" &
fi
