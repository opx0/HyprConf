#!/usr/bin/env bash
#|---/ /+------------------------------------------+---/ /|#
#|--/ /-| Automated Theme Downloader and Installer |--/ /-|#
#|-/ /--| Uses themepatcher.sh to install themes   |-/ /--|#
#|/ /---+------------------------------------------+/ /---|#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
scrDir=$(dirname "$(realpath "$0")")
themesFile="${scrDir}/themes.lst"
themePatcher="${scrDir}/themepatcher.sh"

# Print colored output
print_msg() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Check if required files exist
check_dependencies() {
    if [[ ! -f "$themesFile" ]]; then
        print_msg "$RED" "Error: themes.lst not found at $themesFile"
        exit 1
    fi
    
    if [[ ! -f "$themePatcher" ]]; then
        print_msg "$RED" "Error: themepatcher.sh not found at $themePatcher"
        exit 1
    fi
    
    if [[ ! -x "$themePatcher" ]]; then
        print_msg "$YELLOW" "Making themepatcher.sh executable..."
        chmod +x "$themePatcher"
    fi
}

# Display available themes
show_themes() {
    print_msg "$CYAN" "Available themes:"
    echo
    local index=1
    while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            # Extract theme name (between first set of quotes)
            theme_name=$(echo "$line" | sed 's/^"\([^"]*\)".*/\1/')
            printf "%2d. %s\n" "$index" "$theme_name"
            ((index++))
        fi
    done < "$themesFile"
    echo
}

# Get theme info by index or name
get_theme_info() {
    local input="$1"
    local index=1
    
    while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            # Extract theme name and URL
            theme_name=$(echo "$line" | sed 's/^"\([^"]*\)".*/\1/')
            theme_url=$(echo "$line" | sed 's/^"[^"]*"[[:space:]]*"\([^"]*\)".*/\1/')
            
            # Check if input matches index or theme name
            if [[ "$input" == "$index" ]] || [[ "$input" == "$theme_name" ]]; then
                echo "$theme_name|$theme_url"
                return 0
            fi
            ((index++))
        fi
    done < "$themesFile"
    
    return 1
}

# Install theme
install_theme() {
    local theme_name="$1"
    local theme_url="$2"
    local skip_caching="$3"
    
    print_msg "$BLUE" "Installing theme: $theme_name"
    print_msg "$BLUE" "From: $theme_url"
    echo
    
    # Prepare arguments for themepatcher.sh
    local args=("$theme_name" "$theme_url")
    [[ "$skip_caching" == "true" ]] && args+=("--skipcaching")
    args+=("true") # verbose mode
    
    # Run themepatcher.sh
    if "$themePatcher" "${args[@]}"; then
        print_msg "$GREEN" "✓ Theme '$theme_name' installed successfully!"
        return 0
    else
        print_msg "$RED" "✗ Failed to install theme '$theme_name'"
        return 1
    fi
}

# Interactive theme selection
interactive_mode() {
    show_themes
    
    while true; do
        echo -n "Select theme (number or name): "
        read -r selection
        
        if [[ -z "$selection" ]]; then
            print_msg "$YELLOW" "Please enter a theme number or name."
            continue
        fi
        
        theme_info=$(get_theme_info "$selection")
        if [[ $? -eq 0 ]]; then
            IFS='|' read -r theme_name theme_url <<< "$theme_info"
            
            echo
            print_msg "$CYAN" "Selected: $theme_name"
            echo -n "Install this theme? (y/N): "
            read -r confirm
            
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                install_theme "$theme_name" "$theme_url"
                break
            else
                print_msg "$YELLOW" "Installation cancelled."
                break
            fi
        else
            print_msg "$RED" "Invalid selection. Please try again."
        fi
    done
}

# Install all themes
install_all_themes() {
    local skip_caching="$1"
    local failed_themes=()
    local successful_themes=()
    
    print_msg "$CYAN" "Installing all available themes..."
    echo
    
    while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            theme_name=$(echo "$line" | sed 's/^"\([^"]*\)".*/\1/')
            theme_url=$(echo "$line" | sed 's/^"[^"]*"[[:space:]]*"\([^"]*\)".*/\1/')
            
            if install_theme "$theme_name" "$theme_url" "$skip_caching"; then
                successful_themes+=("$theme_name")
            else
                failed_themes+=("$theme_name")
            fi
            echo
        fi
    done < "$themesFile"
    
    # Summary
    print_msg "$CYAN" "Installation Summary:"
    print_msg "$GREEN" "✓ Successfully installed: ${#successful_themes[@]} themes"
    if [[ ${#failed_themes[@]} -gt 0 ]]; then
        print_msg "$RED" "✗ Failed to install: ${#failed_themes[@]} themes"
        for theme in "${failed_themes[@]}"; do
            print_msg "$RED" "  - $theme"
        done
    fi
}

# Show help
show_help() {
    cat << EOF
Theme Installer - Automated theme downloader and installer

Usage:
    $0 [OPTIONS] [THEME]

Options:
    -h, --help          Show this help message
    -l, --list          List available themes
    -a, --all           Install all available themes
    -s, --skip-cache    Skip wallpaper caching (faster installation)
    -i, --interactive   Interactive theme selection (default if no theme specified)

Arguments:
    THEME              Theme name or number to install

Examples:
    $0                          # Interactive mode
    $0 -i                       # Interactive mode
    $0 "Catppuccin Mocha"       # Install specific theme by name
    $0 1                        # Install theme by number
    $0 -a                       # Install all themes
    $0 -s "Tokyo Night"         # Install theme without caching wallpapers

EOF
}

# Main function
main() {
    local skip_caching="false"
    local install_all="false"
    local interactive="false"
    local list_only="false"
    local theme_input=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                list_only="true"
                shift
                ;;
            -a|--all)
                install_all="true"
                shift
                ;;
            -s|--skip-cache)
                skip_caching="true"
                shift
                ;;
            -i|--interactive)
                interactive="true"
                shift
                ;;
            -*)
                print_msg "$RED" "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                theme_input="$1"
                shift
                ;;
        esac
    done
    
    # Check dependencies
    check_dependencies
    
    # Handle list only
    if [[ "$list_only" == "true" ]]; then
        show_themes
        exit 0
    fi
    
    # Handle install all
    if [[ "$install_all" == "true" ]]; then
        install_all_themes "$skip_caching"
        exit 0
    fi
    
    # Handle specific theme installation
    if [[ -n "$theme_input" ]]; then
        theme_info=$(get_theme_info "$theme_input")
        if [[ $? -eq 0 ]]; then
            IFS='|' read -r theme_name theme_url <<< "$theme_info"
            install_theme "$theme_name" "$theme_url" "$skip_caching"
        else
            print_msg "$RED" "Theme '$theme_input' not found."
            print_msg "$YELLOW" "Use '$0 -l' to see available themes."
            exit 1
        fi
        exit 0
    fi
    
    # Default to interactive mode
    interactive_mode
}

# Run main function with all arguments
main "$@"
