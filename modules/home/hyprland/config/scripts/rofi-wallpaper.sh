#!/usr/bin/env bash

# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/harmonix/wallpapers"
SYMLINK_PATH="$WALLPAPER_DIR/wallpaper"

# Supported image extensions
VALID_EXTS="png|jpg|jpeg|webp"

# Check if directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory $WALLPAPER_DIR does not exist."
    exit 1
fi

# 1. List wallpapers and select via Rofi
# Note: The grep filter safely excludes your extensionless symlink from the Rofi list
SELECTED_WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f | grep -E "\.(${VALID_EXTS})$" | rofi -dmenu -i -show-icons -p "Select Wallpaper:")

# Exit if no selection was made (e.g., user pressed Esc)
if [ -z "$SELECTED_WALLPAPER" ]; then
    exit 0
fi

# 2. Update the symlink on the fly
ln -sf "$SELECTED_WALLPAPER" "$SYMLINK_PATH"

# 3. Update hyprpaper via IPC using the SYMLINK
# We must unload the symlink path first so Hyprpaper clears the old image from memory
hyprctl hyprpaper unload "$SYMLINK_PATH"
hyprctl hyprpaper preload "$SYMLINK_PATH"
hyprctl hyprpaper wallpaper ",$SYMLINK_PATH"
hyprctl hyprpaper unload unused

# 4. Generate color palette with matugen using the SYMLINK
matugen image "$SYMLINK_PATH" -m smart --prefer less-saturation

# 5. Notify success
notify-send "Wallpaper Updated" "Applied $(basename "$SELECTED_WALLPAPER") via symlink"
