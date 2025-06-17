#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_LIST_FILE="$SCRIPT_DIR/pkgs.lst"

if [[ ! -f "$PKG_LIST_FILE" ]]; then
    echo "Error: Package list file not found at $PKG_LIST_FILE"
    exit 1
fi

if command -v yay >/dev/null 2>&1; then
    PKG_MANAGER="yay"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
else
    echo "Error: Neither yay nor pacman found"
    exit 1
fi

echo "Using package manager: $PKG_MANAGER"

echo "Updating mirrorlist with fastest servers from India..."
if command -v reflector >/dev/null 2>&1; then
    sudo reflector --country India --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    echo "Mirrorlist updated successfully"
else
    echo "Installing reflector..."
    sudo pacman -S --needed --noconfirm reflector
    echo "Updating mirrorlist with fastest servers from India..."
    sudo reflector --country India --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    echo "Mirrorlist updated successfully"
fi

packages=()
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    package=$(echo "$line" | sed 's/[[:space:]]*#.*//' | sed 's/[[:space:]]*$//')
    [[ -z "$package" ]] && continue

    if [[ "$package" == *"|"* ]]; then
        package=$(echo "$package" | cut -d'|' -f1)
    fi

    packages+=("$package")
done < "$PKG_LIST_FILE"

echo "Found ${#packages[@]} packages to install"

if [[ ${#packages[@]} -eq 0 ]]; then
    echo "No packages to install"
    exit 0
fi

echo "Updating system..."
case "$PKG_MANAGER" in
    "yay")
        yay -Syu --noconfirm
        ;;
    "pacman")
        sudo pacman -Syu --noconfirm
        ;;
esac

echo "Installing packages..."
case "$PKG_MANAGER" in
    "yay")
        yay -S --needed --noconfirm "${packages[@]}"
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        ;;
esac

echo "Installation completed!"
