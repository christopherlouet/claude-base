# Terminal Themes Collection

Complete visual theme collection for the terminal: prompt (Starship), file listing (eza/ls), and **GNOME Terminal** (Ubuntu).

## Available themes

| Theme | Description | Vibe |
|-------|-------------|----------|
| `matrix` | Green on black, hacker style | "Wake up, Neo..." |
| `cyberpunk` | Neon pink & cyan, futuristic | Night City vibes |
| `dracula` | Dark theme with purple accents | Classic and elegant |
| `catppuccin` | Soft pastel colors | Easy on the eyes |
| `nord` | Arctic blue tones | Calm and focused |
| `gruvbox` | Warm retro colors | Excellent contrast |
| `tokyo-night` | Inspired by Tokyo lights | Modern and sleek |

## Components of a theme

Each theme includes 3 files:

| File | Target | Usage |
|---------|-------|-------|
| `starship-themes/<theme>.toml` | Starship prompt | Command line |
| `eza-<theme>.sh` | eza (modern) | File listing with icons |
| `ls-<theme>.sh` | ls (native) | Standard file listing |

## Quick install

### 0. GNOME Terminal (Ubuntu)

```bash
# Interactive mode (recommended)
./install-gnome-terminal-theme.sh

# Install a specific theme (creates a new profile)
./install-gnome-terminal-theme.sh dracula

# Apply to the default profile
./install-gnome-terminal-theme.sh -d tokyo-night

# Install ALL themes at once
./install-gnome-terminal-theme.sh --all

# List available themes
./install-gnome-terminal-theme.sh --list
```

After installation, switch profile via: **Right click → Profiles → [Theme]**

### 1. Starship (prompt)

```bash
# Interactive mode
./install-starship-theme.sh

# Or directly
./install-starship-theme.sh matrix
```

### 2. Complete configuration (Matrix example)

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Starship prompt
eval "$(starship init zsh)"  # or bash

# File colors (choose eza OR ls)
source /path/to/scripts/themes/eza-matrix.sh
# or
source /path/to/scripts/themes/ls-matrix.sh
```

Then reload:

```bash
source ~/.zshrc
```

## Files per theme

### Matrix
```bash
source eza-matrix.sh   # or ls-matrix.sh
```
- Folders: Bright green (#00ff00)
- Code files: Bright green
- Config: Yellow-green (#ccff00)
- Archives/.env: Red (#ff0000)

### Cyberpunk
```bash
source eza-cyberpunk.sh   # or ls-cyberpunk.sh
```
- Folders: Neon pink (#ff00ff)
- Code files: Neon green (#39ff14)
- Symlinks: Cyan (#00ffff)
- Archives/.env: Neon red (#ff0040)

### Dracula
```bash
source eza-dracula.sh   # or ls-dracula.sh
```
- Folders: Purple (#bd93f9)
- Code files: Yellow/Cyan
- HTML/CSS: Pink (#ff79c6)
- Archives/.env: Red (#ff5555)

### Catppuccin (Mocha)
```bash
source eza-catppuccin.sh   # or ls-catppuccin.sh
```
- Folders: Lavender (#b4befe)
- Code files: Blue/Yellow
- Symlinks: Teal (#94e2d5)
- Archives/.env: Red (#f38ba8)

### Nord
```bash
source eza-nord.sh   # or ls-nord.sh
```
- Folders: Frost blue (#81a1c1)
- Code files: Yellow/Cyan
- Executables: Green (#a3be8c)
- Archives/.env: Red (#bf616a)

### Gruvbox
```bash
source eza-gruvbox.sh   # or ls-gruvbox.sh
```
- Folders: Yellow (#fabd2f)
- Code files: Blue/Aqua
- Executables: Green (#b8bb26)
- Archives/.env: Red (#fb4934)

### Tokyo Night
```bash
source eza-tokyo-night.sh   # or ls-tokyo-night.sh
```
- Folders: Blue (#7aa2f7)
- Code files: Yellow/Blue
- Symlinks: Cyan (#7dcfff)
- Archives/.env: Red (#f7768e)

## Included aliases

The eza files include these aliases:

| Alias | Command |
|-------|----------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -l --icons --git` |
| `la` | `eza -la --icons --git` |
| `lt` | `eza -T --level=2` (tree view) |
| `l` | `eza -l --icons` |

The ls files include:

| Alias | Command |
|-------|----------|
| `ls` | `ls --color=auto` |
| `ll` | `ls -lah --color=auto` |
| `la` | `ls -A --color=auto` |
| `l` | `ls -lh --color=auto` |

## Prerequisites

- **Starship**: The script will install it automatically if missing
- **eza**: `apt install eza` or `brew install eza` (optional, for eza-*.sh)
- **Nerd Font**: Recommended for the icons
  - [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads)
  - [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)

## Starship installation

```bash
# Linux / macOS
curl -sS https://starship.rs/install.sh | sh

# macOS with Homebrew
brew install starship

# Arch Linux
pacman -S starship

# Ubuntu/Debian
apt install starship
```

## eza installation

```bash
# Ubuntu/Debian (22.04+)
apt install eza

# macOS
brew install eza

# Arch Linux
pacman -S eza

# Cargo
cargo install eza
```

## Restore configuration

The Starship script automatically creates a backup:

```bash
# List backups
ls ~/.config/starship.toml.backup.*

# Restore
cp ~/.config/starship.toml.backup.YYYYMMDD_HHMMSS ~/.config/starship.toml
```

## Resources

- [Starship](https://starship.rs/config/)
- [eza](https://github.com/eza-community/eza)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [Dracula](https://draculatheme.com/)
- [Nord](https://www.nordtheme.com/)
- [Gruvbox](https://github.com/morhetz/gruvbox)
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme)
