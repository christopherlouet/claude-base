#!/usr/bin/env bash

# =============================================================================
# claude-base — one-liner installer
# =============================================================================
# Clones the foundation to ~/.local/share/claude-base and symlinks the
# dispatcher into ~/.local/bin/claude-base so users can run `claude-base
# init`, `claude-base update`, etc. from any directory.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash -s -- --target ~/tools/claude-base
#
# Flags:
#   --target DIR    Install to DIR instead of ~/.local/share/claude-base
#   --bin DIR       Symlink the dispatcher into DIR instead of ~/.local/bin
#   --update        Update an existing install (git pull instead of clone)
#   --dry-run       Print actions without performing them
#   --help          Show this help
#
# This script:
#   - Refuses to run as root (refuses sudo)
#   - Performs no system-level modifications
#   - Does NOT modify your shell rc files (the symlink lives in ~/.local/bin
#     which most modern distros put on PATH automatically; if not, the
#     instructions are printed at the end)
#   - Requires git
# =============================================================================

set -eu

REPO_URL="https://github.com/christopherlouet/claude-base.git"
DEFAULT_TARGET="$HOME/.local/share/claude-base"
DEFAULT_BIN="$HOME/.local/bin"

TARGET_DIR=""
BIN_DIR=""
UPDATE=false
DRY_RUN=false

show_help() {
    cat <<'EOF'
claude-base — one-liner installer

USAGE
    curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
    bash install.sh [OPTIONS]

OPTIONS
    --target DIR    Install to DIR instead of ~/.local/share/claude-base
    --bin DIR       Symlink the dispatcher into DIR instead of ~/.local/bin
    --update        Update an existing install (git pull instead of clone)
    --dry-run, -n   Print actions without performing them
    --help, -h      Show this help

This script:
    - Refuses to run as root (refuses sudo)
    - Performs no system-level modifications
    - Does NOT modify your shell rc files (the symlink lives in ~/.local/bin
      which most modern distros put on PATH automatically; if not, the
      instructions are printed at the end)
    - Requires git
EOF
}

err() {
    printf "[ERROR] %s\n" "$*" >&2
    exit 1
}

info() {
    printf "[INFO] %s\n" "$*"
}

run() {
    if $DRY_RUN; then
        printf "[DRY-RUN] %s\n" "$*"
    else
        # eval is intentional here: callers pass a single string with
        # quoted paths (e.g. `run "git clone \"$REPO\" \"$TARGET\""`) for
        # readable call sites. Paths in this script come from $HOME, $TARGET_DIR
        # and $BIN_DIR — all controlled inputs, no untrusted data.
        # shellcheck disable=SC2294
        eval "$@"
    fi
}

while [ $# -gt 0 ]; do
    case "$1" in
        --target)
            [ -z "${2:-}" ] && err "--target requires a path"
            TARGET_DIR="$2"
            shift 2
            ;;
        --bin)
            [ -z "${2:-}" ] && err "--bin requires a path"
            BIN_DIR="$2"
            shift 2
            ;;
        --update)
            UPDATE=true
            shift
            ;;
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            err "Unknown option: $1 (use --help for usage)"
            ;;
    esac
done

TARGET_DIR="${TARGET_DIR:-$DEFAULT_TARGET}"
BIN_DIR="${BIN_DIR:-$DEFAULT_BIN}"

# ---- Pre-flight checks ----

if [ "$(id -u)" -eq 0 ]; then
    err "Do not run this installer as root. Run as your normal user; the installer modifies only ~/."
fi

if ! command -v git >/dev/null 2>&1; then
    err "git is required but not installed. Install it first (e.g. apt install git, brew install git)."
fi

# ---- Install or update ----

if [ -d "$TARGET_DIR/.git" ]; then
    if $UPDATE; then
        info "Updating existing install at $TARGET_DIR"
        run "git -C \"$TARGET_DIR\" pull --ff-only"
    else
        info "claude-base already installed at $TARGET_DIR"
        info "Use --update to pull the latest changes, or --target to install to a different path."
        exit 0
    fi
elif [ -e "$TARGET_DIR" ]; then
    err "$TARGET_DIR exists but is not a git repository. Refusing to overwrite."
else
    info "Cloning $REPO_URL into $TARGET_DIR"
    run "git clone --depth 1 \"$REPO_URL\" \"$TARGET_DIR\""
fi

# ---- Symlink the dispatcher ----

DISPATCHER_SRC="$TARGET_DIR/bin/claude-base"
DISPATCHER_LINK="$BIN_DIR/claude-base"

if ! $DRY_RUN && [ ! -x "$DISPATCHER_SRC" ]; then
    err "Dispatcher missing or not executable at $DISPATCHER_SRC. The clone may be incomplete."
fi

run "mkdir -p \"$BIN_DIR\""

if [ -L "$DISPATCHER_LINK" ] || [ -e "$DISPATCHER_LINK" ]; then
    info "Replacing existing $DISPATCHER_LINK"
    run "rm -f \"$DISPATCHER_LINK\""
fi

run "ln -s \"$DISPATCHER_SRC\" \"$DISPATCHER_LINK\""
info "Linked $DISPATCHER_LINK → $DISPATCHER_SRC"

# ---- Final advice ----

cat <<EOF

claude-base installed.

Next steps:
  1. Make sure $BIN_DIR is on your PATH. Most modern Linux distros and
     macOS put it there automatically. If 'which claude-base' shows
     nothing after opening a new shell, add this to your shell rc file:

         export PATH="$BIN_DIR:\$PATH"

  2. Verify the install:

         claude-base version
         claude-base help

  3. Initialize a project:

         claude-base init --preset fastapi ./my-api
         claude-base init --preset nextjs   ./my-web-app
         claude-base init --simple          ./my-other-project

  4. Update later:

         claude-base update ./my-project
         # or to update the foundation itself:
         curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash -s -- --update

EOF
