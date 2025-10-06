# Dotfiles Configuration

This repository contains the configuration files for various tools used in a Hyprland-based desktop environment on Arch Linux. The goal of this guide is to provide a clear and concise overview of the configuration, making it accessible for both experienced users and newcomers.

## Hyprland

Hyprland is a dynamic tiling Wayland compositor that offers a modern and highly customizable user experience.

### Configuration Files

The main configuration for Hyprland is located at `~/.config/hypr/hyprland.conf`. This file sources several other files to keep the configuration organized:

- `hypr/hyprland.conf`: The main entry point for Hyprland's configuration.
- `hypr/animations.conf`: Manages all animation settings.
- `hypr/keybindings.conf`: Defines custom keybindings and shortcuts.
- `hypr/windowrules.conf`: Sets rules for specific application windows.
- `hypr/themes/`: Contains theme-specific settings, including colors and styles.
- `hypr/monitors.conf`: User-defined monitor settings.
- `hypr/userprefs.conf`: For user-specific overrides and preferences.

## Waybar

Waybar is a highly customizable Wayland bar for Sway and other Wayland compositors. It is used here as the main status bar.

### Configuration Files

Waybar's configuration is split into a few key files:

- `waybar/config.jsonc`: The main configuration file that defines the modules and their behavior.
- `waybar/style.css`: The primary stylesheet for Waybar's appearance.
- `waybar/theme.css`: A separate stylesheet for theme-specific styling.

## Rofi

Rofi is a versatile application launcher, window switcher, and dmenu replacement. It is used for various interactive menus in this setup.

### Configuration Files

Rofi is configured and themed using `.rasi` files. The main theme file is:

- `rofi/theme.rasi`: Sets the overall color scheme and layout properties.

Other `.rasi` files are used for specific menus:

- `rofi/clipboard.rasi`: For the clipboard history manager.
- `rofi/notification.rasi`: For displaying notifications.
- `rofi/quickapps.rasi`: For a quick application launcher.
- `rofi/selector.rasi`: A generic selector script.
- `rofi/wallbash.rasi`: For themeing based on wallpaper colors.