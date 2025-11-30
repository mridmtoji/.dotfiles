#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_WALL="$HOME/.cache/current_wallpaper"
FOOT_COLORS_JSON="$HOME/.cache/foot_colors.json"

# Choose wallpaper
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) \
  | rofi -dmenu -i -p "Choose wallpaper:")

[ -z "$SELECTED" ] && exit 0

# Choose mode
MODE=$(printf "light\ndark\n" | rofi -dmenu -i -p "Matugen mode:")
[ -z "$MODE" ] && exit 0

ln -sf "$SELECTED" "$CACHE_WALL"

# Generate color scheme
matugen image "$SELECTED" --mode "$MODE" --json hex > "$FOOT_COLORS_JSON"

# Read colors
FG=$(jq -r '.terminal.foreground' "$FOOT_COLORS_JSON" | sed 's/^#//')
BG=$(jq -r '.terminal.background' "$FOOT_COLORS_JSON" | sed 's/^#//')

# Convert #rrggbb -> rgb:rr/gg/bb
FG_RGB="rgb:${FG:0:2}/${FG:2:2}/${FG:4:2}"
BG_RGB="rgb:${BG:0:2}/${BG:2:2}/${BG:4:2}"

# Apply to all terminals
for pts in /dev/pts/[0-9]*; do
  [ -w "$pts" ] || continue
  printf "\e]10;%s\a" "$FG_RGB" > "$pts"   # Foreground
  printf "\e]11;%s\a" "$BG_RGB" > "$pts"   # Background

  # Apply 16-color palette if available
  for i in $(seq 0 15); do
    COLOR=$(jq -r ".terminal.colors[$i]" "$FOOT_COLORS_JSON" | sed 's/^#//')
    [ "$COLOR" != "null" ] || continue
    COLOR_RGB="rgb:${COLOR:0:2}/${COLOR:2:2}/${COLOR:4:2}"
    printf "\e]4;%d;%s\a" "$i" "$COLOR_RGB" > "$pts"
  done
done

# Set wallpaper via swaybg
killall swaybg 2>/dev/null
swaybg -i "$CACHE_WALL" >/dev/null 2>&1 &
