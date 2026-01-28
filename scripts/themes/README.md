# Terminal Themes Collection

Collection de thèmes visuels complets pour le terminal : prompt (Starship), listing de fichiers (eza/ls), et **GNOME Terminal** (Ubuntu).

## Thèmes disponibles

| Thème | Description | Ambiance |
|-------|-------------|----------|
| `matrix` | Vert sur noir, style hacker | "Wake up, Neo..." |
| `cyberpunk` | Neon pink & cyan, futuriste | Night City vibes |
| `dracula` | Thème sombre avec accents violets | Classique et elegant |
| `catppuccin` | Couleurs pastels douces | Facile pour les yeux |
| `nord` | Tons bleus arctiques | Calme et concentre |
| `gruvbox` | Couleurs chaudes retro | Excellent contraste |
| `tokyo-night` | Inspire des lumieres de Tokyo | Moderne et sleek |

## Composants d'un theme

Chaque theme inclut 3 fichiers :

| Fichier | Cible | Usage |
|---------|-------|-------|
| `starship-themes/<theme>.toml` | Prompt Starship | Ligne de commande |
| `eza-<theme>.sh` | eza (moderne) | Listing fichiers avec icones |
| `ls-<theme>.sh` | ls (natif) | Listing fichiers standard |

## Installation rapide

### 0. GNOME Terminal (Ubuntu)

```bash
# Mode interactif (recommandé)
./install-gnome-terminal-theme.sh

# Installer un thème spécifique (crée un nouveau profil)
./install-gnome-terminal-theme.sh dracula

# Appliquer au profil par défaut
./install-gnome-terminal-theme.sh -d tokyo-night

# Installer TOUS les thèmes d'un coup
./install-gnome-terminal-theme.sh --all

# Lister les thèmes disponibles
./install-gnome-terminal-theme.sh --list
```

Après installation, change de profil via: **Clic droit → Profils → [Thème]**

### 1. Starship (prompt)

```bash
# Mode interactif
./install-starship-theme.sh

# Ou directement
./install-starship-theme.sh matrix
```

### 2. Configuration complete (exemple Matrix)

Ajoutez a votre `~/.zshrc` ou `~/.bashrc` :

```bash
# Starship prompt
eval "$(starship init zsh)"  # ou bash

# Couleurs fichiers (choisir eza OU ls)
source /chemin/vers/scripts/themes/eza-matrix.sh
# ou
source /chemin/vers/scripts/themes/ls-matrix.sh
```

Puis rechargez :

```bash
source ~/.zshrc
```

## Fichiers par theme

### Matrix
```bash
source eza-matrix.sh   # ou ls-matrix.sh
```
- Dossiers : Vert vif (#00ff00)
- Fichiers code : Vert vif
- Config : Jaune-vert (#ccff00)
- Archives/.env : Rouge (#ff0000)

### Cyberpunk
```bash
source eza-cyberpunk.sh   # ou ls-cyberpunk.sh
```
- Dossiers : Rose neon (#ff00ff)
- Fichiers code : Vert neon (#39ff14)
- Symlinks : Cyan (#00ffff)
- Archives/.env : Rouge neon (#ff0040)

### Dracula
```bash
source eza-dracula.sh   # ou ls-dracula.sh
```
- Dossiers : Violet (#bd93f9)
- Fichiers code : Jaune/Cyan
- HTML/CSS : Rose (#ff79c6)
- Archives/.env : Rouge (#ff5555)

### Catppuccin (Mocha)
```bash
source eza-catppuccin.sh   # ou ls-catppuccin.sh
```
- Dossiers : Lavande (#b4befe)
- Fichiers code : Bleu/Jaune
- Symlinks : Teal (#94e2d5)
- Archives/.env : Rouge (#f38ba8)

### Nord
```bash
source eza-nord.sh   # ou ls-nord.sh
```
- Dossiers : Bleu frost (#81a1c1)
- Fichiers code : Jaune/Cyan
- Executables : Vert (#a3be8c)
- Archives/.env : Rouge (#bf616a)

### Gruvbox
```bash
source eza-gruvbox.sh   # ou ls-gruvbox.sh
```
- Dossiers : Jaune (#fabd2f)
- Fichiers code : Bleu/Aqua
- Executables : Vert (#b8bb26)
- Archives/.env : Rouge (#fb4934)

### Tokyo Night
```bash
source eza-tokyo-night.sh   # ou ls-tokyo-night.sh
```
- Dossiers : Bleu (#7aa2f7)
- Fichiers code : Jaune/Bleu
- Symlinks : Cyan (#7dcfff)
- Archives/.env : Rouge (#f7768e)

## Aliases inclus

Les fichiers eza incluent ces aliases :

| Alias | Commande |
|-------|----------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -l --icons --git` |
| `la` | `eza -la --icons --git` |
| `lt` | `eza -T --level=2` (arborescence) |
| `l` | `eza -l --icons` |

Les fichiers ls incluent :

| Alias | Commande |
|-------|----------|
| `ls` | `ls --color=auto` |
| `ll` | `ls -lah --color=auto` |
| `la` | `ls -A --color=auto` |
| `l` | `ls -lh --color=auto` |

## Prerequis

- **Starship** : Le script l'installera automatiquement si absent
- **eza** : `apt install eza` ou `brew install eza` (optionnel, pour eza-*.sh)
- **Nerd Font** : Recommandee pour les icones
  - [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads)
  - [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)

## Installation Starship

```bash
# Linux / macOS
curl -sS https://starship.rs/install.sh | sh

# macOS avec Homebrew
brew install starship

# Arch Linux
pacman -S starship

# Ubuntu/Debian
apt install starship
```

## Installation eza

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

## Restaurer la configuration

Le script Starship cree automatiquement une backup :

```bash
# Lister les backups
ls ~/.config/starship.toml.backup.*

# Restaurer
cp ~/.config/starship.toml.backup.YYYYMMDD_HHMMSS ~/.config/starship.toml
```

## Ressources

- [Starship](https://starship.rs/config/)
- [eza](https://github.com/eza-community/eza)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [Dracula](https://draculatheme.com/)
- [Nord](https://www.nordtheme.com/)
- [Gruvbox](https://github.com/morhetz/gruvbox)
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme)
