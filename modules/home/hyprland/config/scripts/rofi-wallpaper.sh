#!/usr/bin/env bash

# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/harmonix/wallpapers"

# Supported image extensions
VALID_EXTS="png|jpg|jpeg|webp"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory $WALLPAPER_DIR does not exist."
    exit 1
fi

# 1. List wallpapers and select via Rofi
SELECTED_WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f | grep -E "\.(${VALID_EXTS})$" | rofi -dmenu -i -show-icons -p "Select Wallpaper:")

# Exit if no selection was made (e.g., user pressed Esc)
if [ -z "$SELECTED_WALLPAPER" ]; then
    exit 0
fi

echo $SELECTED_WALLPAPER

# 2. Update hyprpaper via IPC
hyprctl hyprpaper preload "$SELECTED_WALLPAPER"
hyprctl hyprpaper wallpaper ",$SELECTED_WALLPAPER"
hyprctl hyprpaper unload unused

# 3. Generate color palette with matugen
matugen image "$SELECTED_WALLPAPER" -m smart --prefer less-saturation

# 4. Notify success
notify-send "Wallpaper Updated" "Applied $(basename "$SELECTED_WALLPAPER")"
