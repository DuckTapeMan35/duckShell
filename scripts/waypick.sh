#!/bin/bash

pick_color() {
    color=$(hyprpicker -a | grep -oE '#[0-9A-Fa-f]{6}') # Pick color with hyprpicker
    color=$(echo "$color" | tr -d '[:space:]') # Remove spaces
    printf "%s" "$color"   # Output to stdout
    echo -n "$color" | wl-copy  # Copy to clipboard
    notify-send "Color Copied" "Color $color copied to clipboard" -t 3000 -a "WayPick" -u normal
}

pick_color
