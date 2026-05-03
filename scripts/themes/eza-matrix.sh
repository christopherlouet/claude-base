# shellcheck shell=bash
# EZA Matrix Theme
# Source this file in your .zshrc or .bashrc for Matrix-style ls colors
#
# Usage: source /path/to/eza-matrix.sh
#        Or copy the exports to your shell config

# Matrix color palette for eza
# di = directories, fi = files, ln = symlinks, ex = executables
# See: https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md

export EZA_COLORS="\
di=1;38;2;0;255;0:\
fi=38;2;0;143;17:\
ln=38;2;0;255;65:\
ex=1;38;2;0;255;0:\
ur=38;2;0;255;0:\
uw=38;2;204;255;0:\
ux=1;38;2;0;255;0:\
ue=1;38;2;0;255;0:\
gr=38;2;0;143;17:\
gw=38;2;204;255;0:\
gx=38;2;0;255;0:\
tr=38;2;0;143;17:\
tw=38;2;204;255;0:\
tx=38;2;0;255;0:\
su=38;2;255;0;0:\
sf=38;2;255;0;0:\
xa=38;2;0;143;17:\
sn=38;2;0;255;65:\
sb=38;2;0;255;65:\
df=38;2;0;255;0:\
ds=38;2;0;255;65:\
uu=38;2;0;255;0:\
uR=38;2;255;0;0:\
un=38;2;204;255;0:\
gu=38;2;0;255;0:\
gR=38;2;255;0;0:\
gn=38;2;204;255;0:\
lc=38;2;255;0;0:\
lm=38;2;255;0;0:\
ga=38;2;0;255;0:\
gm=38;2;204;255;0:\
gd=38;2;255;0;0:\
gv=38;2;0;255;65:\
gt=38;2;0;143;17:\
gi=38;2;0;143;17:\
gc=38;2;204;255;0:\
Gm=38;2;0;255;0:\
Go=38;2;0;143;17:\
Gc=38;2;204;255;0:\
Gd=38;2;0;143;17:\
xx=38;2;0;143;17:\
da=38;2;0;255;65:\
in=38;2;0;255;65:\
bl=38;2;0;255;65:\
hd=1;4;38;2;0;255;0:\
lp=38;2;0;255;65:\
cc=38;2;255;0;0"

# File type colors (by extension)
export EZA_COLORS="$EZA_COLORS:\
*.md=38;2;0;255;65:\
*.txt=38;2;0;143;17:\
*.json=38;2;204;255;0:\
*.yaml=38;2;204;255;0:\
*.yml=38;2;204;255;0:\
*.toml=38;2;204;255;0:\
*.xml=38;2;204;255;0:\
*.html=38;2;0;255;65:\
*.css=38;2;0;255;65:\
*.js=38;2;0;255;0:\
*.ts=38;2;0;255;0:\
*.tsx=38;2;0;255;0:\
*.jsx=38;2;0;255;0:\
*.py=38;2;0;255;0:\
*.rb=38;2;0;255;0:\
*.go=38;2;0;255;0:\
*.rs=38;2;0;255;0:\
*.sh=1;38;2;0;255;0:\
*.bash=1;38;2;0;255;0:\
*.zsh=1;38;2;0;255;0:\
*.fish=1;38;2;0;255;0:\
*.vim=38;2;0;255;65:\
*.lua=38;2;0;255;65:\
*.sql=38;2;204;255;0:\
*.log=38;2;0;143;17:\
*.tmp=38;2;0;143;17:\
*.bak=38;2;0;143;17:\
*.swp=38;2;0;143;17:\
*.git=38;2;0;143;17:\
*.gitignore=38;2;0;143;17:\
*.dockerignore=38;2;0;143;17:\
*.env=38;2;255;0;0:\
*.env.*=38;2;255;0;0:\
*.lock=38;2;0;143;17:\
*.jpg=38;2;0;255;65:\
*.jpeg=38;2;0;255;65:\
*.png=38;2;0;255;65:\
*.gif=38;2;0;255;65:\
*.svg=38;2;0;255;65:\
*.ico=38;2;0;255;65:\
*.webp=38;2;0;255;65:\
*.mp3=38;2;204;255;0:\
*.mp4=38;2;204;255;0:\
*.mkv=38;2;204;255;0:\
*.avi=38;2;204;255;0:\
*.mov=38;2;204;255;0:\
*.zip=38;2;255;0;0:\
*.tar=38;2;255;0;0:\
*.gz=38;2;255;0;0:\
*.7z=38;2;255;0;0:\
*.rar=38;2;255;0;0:\
*.pdf=38;2;255;0;0:\
*.doc=38;2;0;255;65:\
*.docx=38;2;0;255;65"

# Aliases for matrix-style listing
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza -T --icons --level=2'
alias l='eza -l --icons --group-directories-first'
