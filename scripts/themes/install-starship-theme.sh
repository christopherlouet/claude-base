#!/usr/bin/env bash
#
# install-starship-theme.sh
# Installs Starship and applies a terminal theme
#
# Usage:
#   ./install-starship-theme.sh [theme]
#   ./install-starship-theme.sh --list
#   ./install-starship-theme.sh --interactive
#
# Available themes:
#   matrix, cyberpunk, dracula, catppuccin, nord, gruvbox, tokyo-night

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/starship-themes"
STARSHIP_CONFIG="${HOME}/.config/starship.toml"

# Colors for display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# List of available themes
AVAILABLE_THEMES=("matrix" "cyberpunk" "dracula" "catppuccin" "nord" "gruvbox" "tokyo-night")

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════════╗
  ║   ███████╗████████╗ █████╗ ██████╗ ███████╗██╗  ██╗██╗██████╗    ║
  ║   ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║  ██║██║██╔══██╗   ║
  ║   ███████╗   ██║   ███████║██████╔╝███████╗███████║██║██████╔╝   ║
  ║   ╚════██║   ██║   ██╔══██║██╔══██╗╚════██║██╔══██║██║██╔═══╝    ║
  ║   ███████║   ██║   ██║  ██║██║  ██║███████║██║  ██║██║██║        ║
  ║   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ║
  ║                     THEME INSTALLER                               ║
  ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_theme_preview() {
    local theme=$1
    case $theme in
        matrix)
            echo -e "${GREEN}"
            echo "  ┌─────────────────────────────────────┐"
            echo "  │  ${BOLD}MATRIX${NC}${GREEN} - Green on black, hacker style │"
            echo "  │  ❯ ~/projects/app ${NC}${GREEN}on main [+]       │"
            echo "  │  Wake up, Neo...                    │"
            echo "  └─────────────────────────────────────┘"
            echo -e "${NC}"
            ;;
        cyberpunk)
            echo -e "${MAGENTA}"
            echo "  ┌─────────────────────────────────────┐"
            echo "  │  ${BOLD}CYBERPUNK${NC}${MAGENTA} - Neon pink & cyan        │"
            echo "  │  ${CYAN}◈${MAGENTA} ~/projects/app ${CYAN}⟫${MAGENTA} main ${CYAN}⚡${MAGENTA}         │"
            echo "  │  Night City vibes                   │"
            echo "  └─────────────────────────────────────┘"
            echo -e "${NC}"
            ;;
        dracula)
            echo -e "${MAGENTA}"
            echo "  ┌─────────────────────────────────────┐"
            echo "  │  ${BOLD}DRACULA${NC}${MAGENTA} - Purple accents, dark bg   │"
            echo "  │  λ ~/projects/app on main          │"
            echo "  │  Popular dark theme                 │"
            echo "  └─────────────────────────────────────┘"
            echo -e "${NC}"
            ;;
        catppuccin)
            echo -e "${YELLOW}"
            echo "  ┌─────────────────────────────────────┐"
            echo "  │  ${BOLD}CATPPUCCIN${NC}${YELLOW} - Soft pastels           │"
            echo "  │  ○ ~/projects/app  main           │"
            echo "  │  Easy on the eyes                   │"
            echo "  └─────────────────────────────────────┘"
            echo -e "${NC}"
            ;;
        nord)
            echo -e "${BLUE}"
            echo "  ┌─────────────────────────────────────┐"
            echo "  │  ${BOLD}NORD${NC}${BLUE} - Cool Arctic blue tones       │"
            echo "  │  ➜ ~/projects/app git:(main)       │"
            echo "  │  Calm and focused                   │"
            echo "  └─────────────────────────────────────┘"
            echo -e "${NC}"
            ;;
        gruvbox)
            echo -e "${YELLOW}"
            echo "  ┌─────────────────────────────────────┐"
            echo "  │  ${BOLD}GRUVBOX${NC}${YELLOW} - Retro warm colors         │"
            echo "  │  ❱ ~/projects/app (main)           │"
            echo "  │  Excellent contrast                 │"
            echo "  └─────────────────────────────────────┘"
            echo -e "${NC}"
            ;;
        tokyo-night)
            echo -e "${BLUE}"
            echo "  ┌─────────────────────────────────────┐"
            echo "  │  ${BOLD}TOKYO NIGHT${NC}${BLUE} - City lights vibes     │"
            echo "  │  ▸ ~/projects/app ${MAGENTA}⎇${BLUE} main            │"
            echo "  │  Modern and sleek                   │"
            echo "  └─────────────────────────────────────┘"
            echo -e "${NC}"
            ;;
    esac
}

list_themes() {
    echo -e "\n${BOLD}Available themes:${NC}\n"
    for theme in "${AVAILABLE_THEMES[@]}"; do
        print_theme_preview "$theme"
    done
}

check_starship() {
    if command -v starship &> /dev/null; then
        echo -e "${GREEN}✓${NC} Starship is installed ($(starship --version))"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Starship is not installed"
        return 1
    fi
}

install_starship() {
    echo -e "${BLUE}►${NC} Installing Starship..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install starship
        else
            local tmp_installer
            tmp_installer="$(mktemp)"
            curl -sS https://starship.rs/install.sh -o "$tmp_installer"
            sh "$tmp_installer"
            rm -f "$tmp_installer"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        local tmp_installer
        tmp_installer="$(mktemp)"
        curl -sS https://starship.rs/install.sh -o "$tmp_installer"
        sh "$tmp_installer"
        rm -f "$tmp_installer"
    else
        echo -e "${RED}✗${NC} Unsupported OS. Install manually: https://starship.rs"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} Starship installed successfully!"
}

configure_shell() {
    local shell_rc=""
    local init_cmd='eval "$(starship init bash)"'

    # Detect the shell
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
        init_cmd='eval "$(starship init zsh)"'
    elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
        init_cmd='eval "$(starship init bash)"'
    elif [[ "$SHELL" == *"fish"* ]]; then
        shell_rc="$HOME/.config/fish/config.fish"
        init_cmd='starship init fish | source'
    fi

    if [[ -n "$shell_rc" ]] && [[ -f "$shell_rc" ]]; then
        if ! grep -q "starship init" "$shell_rc" 2>/dev/null; then
            echo -e "${BLUE}►${NC} Configuring shell ($shell_rc)..."
            echo "" >> "$shell_rc"
            echo "# Starship prompt" >> "$shell_rc"
            echo "$init_cmd" >> "$shell_rc"
            echo -e "${GREEN}✓${NC} Shell configured!"
        else
            echo -e "${GREEN}✓${NC} Shell already configured for Starship"
        fi
    fi
}

apply_theme() {
    local theme=$1
    local theme_file="$THEMES_DIR/${theme}.toml"

    if [[ ! -f "$theme_file" ]]; then
        echo -e "${RED}✗${NC} Theme '$theme' not found: $theme_file"
        exit 1
    fi

    # Create the config directory if needed
    mkdir -p "$(dirname "$STARSHIP_CONFIG")"

    # Back up the old config if it exists
    if [[ -f "$STARSHIP_CONFIG" ]]; then
        local backup
        backup="${STARSHIP_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$STARSHIP_CONFIG" "$backup"
        echo -e "${BLUE}►${NC} Backup created: $backup"
    fi

    # Copy the new theme
    cp "$theme_file" "$STARSHIP_CONFIG"
    echo -e "${GREEN}✓${NC} Theme '$theme' applied!"

    print_theme_preview "$theme"

    echo -e "\n${YELLOW}⚡${NC} Restart your terminal or run: ${BOLD}source ~/.bashrc${NC} (or ~/.zshrc)"
}

interactive_mode() {
    print_banner

    echo -e "${BOLD}Select a theme:${NC}\n"

    local i=1
    for theme in "${AVAILABLE_THEMES[@]}"; do
        echo -e "  ${CYAN}$i)${NC} $theme"
        ((i++))
    done
    echo -e "  ${CYAN}0)${NC} Cancel"

    echo ""
    read -p "Your choice [1-${#AVAILABLE_THEMES[@]}]: " choice

    if [[ "$choice" == "0" ]]; then
        echo "Cancelled."
        exit 0
    fi

    if [[ "$choice" -ge 1 && "$choice" -le "${#AVAILABLE_THEMES[@]}" ]]; then
        local selected_theme="${AVAILABLE_THEMES[$((choice-1))]}"
        echo ""
        print_theme_preview "$selected_theme"
        echo ""
        read -p "Apply theme '$selected_theme'? [Y/n]: " confirm

        if [[ "$confirm" != "n" && "$confirm" != "N" ]]; then
            # Check / install Starship
            if ! check_starship; then
                read -p "Install Starship? [Y/n]: " install_confirm
                if [[ "$install_confirm" != "n" && "$install_confirm" != "N" ]]; then
                    install_starship
                    configure_shell
                else
                    echo "Installation cancelled."
                    exit 0
                fi
            fi

            apply_theme "$selected_theme"
        fi
    else
        echo -e "${RED}Invalid choice${NC}"
        exit 1
    fi
}

show_help() {
    echo "Usage: $0 [OPTIONS] [THEME]"
    echo ""
    echo "Options:"
    echo "  -h, --help         Show this help"
    echo "  -l, --list         List available themes"
    echo "  -i, --interactive  Interactive mode (default if no theme)"
    echo ""
    echo "Available themes:"
    for theme in "${AVAILABLE_THEMES[@]}"; do
        echo "  - $theme"
    done
    echo ""
    echo "Examples:"
    echo "  $0 matrix          Apply the Matrix theme"
    echo "  $0 --list          See all themes"
    echo "  $0                 Interactive mode"
}

# Main
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            ;;
        -l|--list)
            list_themes
            ;;
        -i|--interactive|"")
            interactive_mode
            ;;
        *)
            # Check whether it is a valid theme
            local theme="$1"
            local valid=false
            for t in "${AVAILABLE_THEMES[@]}"; do
                if [[ "$t" == "$theme" ]]; then
                    valid=true
                    break
                fi
            done

            if $valid; then
                print_banner
                if ! check_starship; then
                    read -p "Install Starship? [Y/n]: " install_confirm
                    if [[ "$install_confirm" != "n" && "$install_confirm" != "N" ]]; then
                        install_starship
                        configure_shell
                    else
                        echo "Starship is required to apply the theme."
                        exit 1
                    fi
                fi
                apply_theme "$theme"
            else
                echo -e "${RED}Unknown theme: $theme${NC}"
                echo "Available themes: ${AVAILABLE_THEMES[*]}"
                exit 1
            fi
            ;;
    esac
}

main "$@"
