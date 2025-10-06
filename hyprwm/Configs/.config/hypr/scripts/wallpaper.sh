#!/bin/bash

# This script manages wallpapers using swww

# Directory where wallpapers are stored
# The user should update this path to their wallpapers directory
WALL_DIR="$HOME/.config/hypr/wallpapers"

# swww options
SWWW_OPTS="--transition-type any --transition-fps 60"

# Check if swww is running, if not, initialize it
if ! pgrep -x swww-daemon > /dev/null; then
    swww init
fi

# Function to set a wallpaper
set_wallpaper() {
    local wallpaper_path=$1
    if [ -f "$wallpaper_path" ]; then
        swww img "$wallpaper_path" $SWWW_OPTS
    else
        echo "Wallpaper not found: $wallpaper_path" >&2
        exit 1
    fi
}

# Function to get all wallpapers from the directory
get_wallpapers() {
    find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort
}

# Main logic
case "$1" in
    init)
        # Set a random wallpaper on init
        mapfile -t wallpapers < <(get_wallpapers)
        if [ ${#wallpapers[@]} -gt 0 ]; then
            random_wallpaper=${wallpapers[RANDOM % ${#wallpapers[@]}]}
            set_wallpaper "$random_wallpaper"
        else
            echo "No wallpapers found in $WALL_DIR" >&2
            exit 1
        fi
        ;;
    next)
        mapfile -t wallpapers < <(get_wallpapers)
        if [ ${#wallpapers[@]} -eq 0 ]; then
            echo "No wallpapers found in $WALL_DIR" >&2
            exit 1
        fi

        current_wallpaper=$(swww query | grep -oP 'image: \K"[^"]+"' | tr -d '"' | head -n 1)

        current_index=-1
        for i in "${!wallpapers[@]}"; do
            if [[ "${wallpapers[$i]}" == "$current_wallpaper" ]]; then
                current_index=$i
                break
            fi
        done

        if [ $current_index -ne -1 ]; then
            next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
            set_wallpaper "${wallpapers[next_index]}"
        else
            # if current wallpaper not found, set the first one
            set_wallpaper "${wallpapers[0]}"
        fi
        ;;
    prev)
        mapfile -t wallpapers < <(get_wallpapers)
        if [ ${#wallpapers[@]} -eq 0 ]; then
            echo "No wallpapers found in $WALL_DIR" >&2
            exit 1
        fi

        current_wallpaper=$(swww query | grep -oP 'image: \K"[^"]+"' | tr -d '"' | head -n 1)

        current_index=-1
        for i in "${!wallpapers[@]}"; do
            if [[ "${wallpapers[$i]}" == "$current_wallpaper" ]]; then
                current_index=$i
                break
            fi
        done

        if [ $current_index -ne -1 ]; then
            prev_index=$(( (current_index - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
            set_wallpaper "${wallpapers[prev_index]}"
        else
            # if current wallpaper not found, set the first one
            set_wallpaper "${wallpapers[0]}"
        fi
        ;;
    *)
        echo "Usage: $0 {init|next|prev}"
        exit 1
esac