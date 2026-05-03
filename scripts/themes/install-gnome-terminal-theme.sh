#!/bin/bash
# =============================================================================
# install-gnome-terminal-theme.sh
# Configures color themes for GNOME Terminal (Ubuntu)
# =============================================================================

set -e

# Colors for display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# dconf path for GNOME Terminal
DCONF_PROFILE_BASE="/org/gnome/terminal/legacy/profiles:/"

# =============================================================================
# Theme definitions (16-color palettes)
# Format: background, foreground, then 16-color palette
# =============================================================================

declare -A THEMES

# Matrix - Green on black, classic hacker look
THEMES[matrix_name]="Matrix"
THEMES[matrix_bg]="#0D0D0D"
THEMES[matrix_fg]="#00FF00"
THEMES[matrix_cursor]="#00FF00"
THEMES[matrix_palette]="['#0D0D0D', '#FF0000', '#00FF00', '#CCFF00', '#003300', '#00FF00', '#00CCCC', '#00FF00', '#003300', '#FF0000', '#00FF00', '#CCFF00', '#00FF00', '#00FF00', '#00FFFF', '#FFFFFF']"

# Cyberpunk - Neon pink and cyan, futuristic aesthetics
THEMES[cyberpunk_name]="Cyberpunk"
THEMES[cyberpunk_bg]="#0A0A1A"
THEMES[cyberpunk_fg]="#FFFFFF"
THEMES[cyberpunk_cursor]="#FF00FF"
THEMES[cyberpunk_palette]="['#0A0A1A', '#FF0040', '#39FF14', '#FFFF00', '#00BFFF', '#FF00FF', '#00FFFF', '#FFFFFF', '#1A1A2E', '#FF0040', '#39FF14', '#FFFF00', '#00BFFF', '#FF00FF', '#00FFFF', '#FFFFFF']"

# Dracula - Popular dark theme with purple accents
THEMES[dracula_name]="Dracula"
THEMES[dracula_bg]="#282A36"
THEMES[dracula_fg]="#F8F8F2"
THEMES[dracula_cursor]="#F8F8F2"
THEMES[dracula_palette]="['#21222C', '#FF5555', '#50FA7B', '#F1FA8C', '#BD93F9', '#FF79C6', '#8BE9FD', '#F8F8F2', '#6272A4', '#FF6E6E', '#69FF94', '#FFFFA5', '#D6ACFF', '#FF92DF', '#A4FFFF', '#FFFFFF']"

# Catppuccin Mocha - Soft pastel colors, easy on the eyes
THEMES[catppuccin_name]="Catppuccin Mocha"
THEMES[catppuccin_bg]="#1E1E2E"
THEMES[catppuccin_fg]="#CDD6F4"
THEMES[catppuccin_cursor]="#F5E0DC"
THEMES[catppuccin_palette]="['#45475A', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#BAC2DE', '#585B70', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#A6ADC8']"

# Nord - Cool blue tones from the Arctic
THEMES[nord_name]="Nord"
THEMES[nord_bg]="#2E3440"
THEMES[nord_fg]="#D8DEE9"
THEMES[nord_cursor]="#D8DEE9"
THEMES[nord_palette]="['#3B4252', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#88C0D0', '#E5E9F0', '#4C566A', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#8FBCBB', '#ECEFF4']"

# Gruvbox - Retro warm colors with excellent contrast
THEMES[gruvbox_name]="Gruvbox Dark"
THEMES[gruvbox_bg]="#282828"
THEMES[gruvbox_fg]="#EBDBB2"
THEMES[gruvbox_cursor]="#EBDBB2"
THEMES[gruvbox_palette]="['#282828', '#CC241D', '#98971A', '#D79921', '#458588', '#B16286', '#689D6A', '#A89984', '#928374', '#FB4934', '#B8BB26', '#FABD2F', '#83A598', '#D3869B', '#8EC07C', '#EBDBB2']"

# Tokyo Night - Dark theme inspired by Tokyo city lights
THEMES[tokyo-night_name]="Tokyo Night"
THEMES[tokyo-night_bg]="#1A1B26"
THEMES[tokyo-night_fg]="#A9B1D6"
THEMES[tokyo-night_cursor]="#C0CAF5"
THEMES[tokyo-night_palette]="['#15161E', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#A9B1D6', '#414868', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#C0CAF5']"

# =============================================================================
# Functions
# =============================================================================

print_header() {
    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║     GNOME Terminal Theme Installer - Claude Socle          ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_theme_preview() {
    local theme=$1
    case $theme in
        matrix)
            echo -e "  ${GREEN}██${NC} Matrix - ${GREEN}Green on black${NC}, classic hacker look"
            ;;
        cyberpunk)
            echo -e "  ${MAGENTA}██${NC} Cyberpunk - ${MAGENTA}Neon pink${NC} and ${CYAN}cyan${NC}, futuristic"
            ;;
        dracula)
            echo -e "  ${MAGENTA}██${NC} Dracula - Dark theme with ${MAGENTA}purple${NC} accents"
            ;;
        catppuccin)
            echo -e "  ${MAGENTA}██${NC} Catppuccin - Soft ${MAGENTA}pastel${NC} colors, easy on eyes"
            ;;
        nord)
            echo -e "  ${CYAN}██${NC} Nord - Cool ${CYAN}blue${NC} tones from the Arctic"
            ;;
        gruvbox)
            echo -e "  ${YELLOW}██${NC} Gruvbox - Retro ${YELLOW}warm${NC} colors, excellent contrast"
            ;;
        tokyo-night)
            echo -e "  ${CYAN}██${NC} Tokyo Night - ${CYAN}Blue${NC} theme, Tokyo city lights"
            ;;
    esac
}

check_dependencies() {
    if ! command -v dconf &> /dev/null; then
        echo -e "${RED}Error: dconf is not installed${NC}"
        echo "Install it with: sudo apt install dconf-cli"
        exit 1
    fi

    # Check that GNOME Terminal is installed
    if ! command -v gnome-terminal &> /dev/null; then
        echo -e "${RED}Error: GNOME Terminal is not installed${NC}"
        exit 1
    fi
}

get_default_profile() {
    dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'"
}

get_profile_list() {
    dconf read /org/gnome/terminal/legacy/profiles:/list
}

generate_uuid() {
    cat /proc/sys/kernel/random/uuid
}

create_new_profile() {
    local theme_key=$1
    local profile_name="${THEMES[${theme_key}_name]}"
    local new_uuid
    new_uuid=$(generate_uuid)

    echo -e "${CYAN}Creating profile '${profile_name}'...${NC}"

    # Get the current profile list
    local current_list
    current_list=$(dconf read /org/gnome/terminal/legacy/profiles:/list)

    if [[ -z "$current_list" || "$current_list" == "@as []" ]]; then
        # No profile, create the list
        dconf write /org/gnome/terminal/legacy/profiles:/list "['$new_uuid']"
    else
        # Append to the existing list
        local new_list
        new_list=$(echo "$current_list" | sed "s/]$/, '$new_uuid']/")
        dconf write /org/gnome/terminal/legacy/profiles:/list "$new_list"
    fi

    # Configure the new profile
    local profile_path="${DCONF_PROFILE_BASE}:${new_uuid}/"

    dconf write "${profile_path}visible-name" "'${profile_name}'"
    dconf write "${profile_path}use-theme-colors" "false"
    dconf write "${profile_path}background-color" "'${THEMES[${theme_key}_bg]}'"
    dconf write "${profile_path}foreground-color" "'${THEMES[${theme_key}_fg]}'"
    dconf write "${profile_path}cursor-background-color" "'${THEMES[${theme_key}_cursor]}'"
    dconf write "${profile_path}cursor-foreground-color" "'${THEMES[${theme_key}_bg]}'"
    dconf write "${profile_path}cursor-colors-set" "true"
    dconf write "${profile_path}palette" "${THEMES[${theme_key}_palette]}"
    dconf write "${profile_path}bold-is-bright" "true"
    dconf write "${profile_path}use-theme-transparency" "false"

    echo "$new_uuid"
}

apply_to_default_profile() {
    local theme_key=$1
    local default_uuid
    default_uuid=$(get_default_profile)

    if [[ -z "$default_uuid" ]]; then
        echo -e "${YELLOW}No default profile found, creating a new profile...${NC}"
        create_new_profile "$theme_key"
        return
    fi

    echo -e "${CYAN}Applying to default profile...${NC}"

    local profile_path="${DCONF_PROFILE_BASE}:${default_uuid}/"

    dconf write "${profile_path}use-theme-colors" "false"
    dconf write "${profile_path}background-color" "'${THEMES[${theme_key}_bg]}'"
    dconf write "${profile_path}foreground-color" "'${THEMES[${theme_key}_fg]}'"
    dconf write "${profile_path}cursor-background-color" "'${THEMES[${theme_key}_cursor]}'"
    dconf write "${profile_path}cursor-foreground-color" "'${THEMES[${theme_key}_bg]}'"
    dconf write "${profile_path}cursor-colors-set" "true"
    dconf write "${profile_path}palette" "${THEMES[${theme_key}_palette]}"
    dconf write "${profile_path}bold-is-bright" "true"
}

list_themes() {
    echo -e "${BOLD}Available themes:${NC}\n"
    echo -e "  ${BOLD}1)${NC}"; print_theme_preview "matrix"
    echo -e "  ${BOLD}2)${NC}"; print_theme_preview "cyberpunk"
    echo -e "  ${BOLD}3)${NC}"; print_theme_preview "dracula"
    echo -e "  ${BOLD}4)${NC}"; print_theme_preview "catppuccin"
    echo -e "  ${BOLD}5)${NC}"; print_theme_preview "nord"
    echo -e "  ${BOLD}6)${NC}"; print_theme_preview "gruvbox"
    echo -e "  ${BOLD}7)${NC}"; print_theme_preview "tokyo-night"
    echo ""
}

theme_number_to_key() {
    case $1 in
        1) echo "matrix" ;;
        2) echo "cyberpunk" ;;
        3) echo "dracula" ;;
        4) echo "catppuccin" ;;
        5) echo "nord" ;;
        6) echo "gruvbox" ;;
        7) echo "tokyo-night" ;;
        *) echo "" ;;
    esac
}

theme_name_to_key() {
    local name
    name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $name in
        matrix|cyberpunk|dracula|catppuccin|nord|gruvbox|tokyo-night)
            echo "$name"
            ;;
        "tokyo night"|"tokyonight")
            echo "tokyo-night"
            ;;
        *)
            echo ""
            ;;
    esac
}

install_all_themes() {
    echo -e "${CYAN}Installing all themes...${NC}\n"

    for theme in matrix cyberpunk dracula catppuccin nord gruvbox tokyo-night; do
        local uuid
        uuid=$(create_new_profile "$theme")
        echo -e "  ${GREEN}✓${NC} ${THEMES[${theme}_name]} installed (profile: ${uuid:0:8}...)"
    done

    echo -e "\n${GREEN}${BOLD}All themes have been installed!${NC}"
    echo -e "Open ${BOLD}GNOME Terminal → Preferences${NC} to switch profile."
}

show_usage() {
    echo "Usage: $0 [OPTIONS] [THEME]"
    echo ""
    echo "Options:"
    echo "  -l, --list          List available themes"
    echo "  -a, --all           Install all themes as profiles"
    echo "  -d, --default       Apply to the default profile (instead of creating one)"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Themes: matrix, cyberpunk, dracula, catppuccin, nord, gruvbox, tokyo-night"
    echo ""
    echo "Examples:"
    echo "  $0                  Interactive mode"
    echo "  $0 dracula          Create a Dracula profile"
    echo "  $0 -d nord          Apply Nord to the default profile"
    echo "  $0 --all            Install all themes"
}

# =============================================================================
# Main
# =============================================================================

main() {
    local apply_default=false
    local theme_key=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--list)
                list_themes
                exit 0
                ;;
            -a|--all)
                check_dependencies
                print_header
                install_all_themes
                exit 0
                ;;
            -d|--default)
                apply_default=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
            *)
                theme_key=$(theme_name_to_key "$1")
                if [[ -z "$theme_key" ]]; then
                    echo -e "${RED}Unknown theme: $1${NC}"
                    list_themes
                    exit 1
                fi
                shift
                ;;
        esac
    done

    check_dependencies
    print_header

    # Interactive mode if no theme specified
    if [[ -z "$theme_key" ]]; then
        list_themes

        echo -e "${BOLD}Options:${NC}"
        echo "  a) Install all themes"
        echo "  q) Quit"
        echo ""
        read -p "Pick a theme (1-7, a, or q): " choice

        case $choice in
            [1-7])
                theme_key=$(theme_number_to_key "$choice")
                ;;
            a|A)
                install_all_themes
                exit 0
                ;;
            q|Q)
                echo "Cancelled."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                exit 1
                ;;
        esac

        echo ""
        read -p "Apply to the default profile? (y/N): " apply_choice
        if [[ "$apply_choice" =~ ^[oOyY]$ ]]; then
            apply_default=true
        fi
    fi

    # Apply the theme
    echo ""
    if [[ "$apply_default" == true ]]; then
        apply_to_default_profile "$theme_key"
    else
        create_new_profile "$theme_key"
    fi

    echo -e "\n${GREEN}${BOLD}✓ Theme ${THEMES[${theme_key}_name]} installed!${NC}"
    echo ""
    echo -e "To see the change:"
    echo -e "  • ${BOLD}New terminal${NC}: Open a new tab/window"
    echo -e "  • ${BOLD}Switch profile${NC}: Right-click → Profiles → ${THEMES[${theme_key}_name]}"
    echo ""
}

main "$@"
