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
#   --ref TAG       Pin the install to a release tag (default: main tip)
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

# CLAUDE_BASE_REPO_URL overrides the source repo (used by the test suite to
# point at a local fixture repo so clone/update paths run offline).
REPO_URL="${CLAUDE_BASE_REPO_URL:-https://github.com/christopherlouet/claude-base.git}"
DEFAULT_TARGET="$HOME/.local/share/claude-base"
DEFAULT_BIN="$HOME/.local/bin"

TARGET_DIR=""
BIN_DIR=""
REF=""
UPDATE=false
DRY_RUN=false

# Where we record the pinned tag, inside .git so it never shows up in
# `git status` and never collides with tracked files.
PIN_BASENAME=".git/claude-base-ref"

show_help() {
    cat <<'EOF'
claude-base — one-liner installer

USAGE
    curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
    bash install.sh [OPTIONS]

OPTIONS
    --target DIR    Install to DIR instead of ~/.local/share/claude-base
    --bin DIR       Symlink the dispatcher into DIR instead of ~/.local/bin
    --ref TAG       Pin the install to a release tag (e.g. v5.0.0) instead of
                    the moving main tip. A pinned install stays pinned across
                    --update; pass --ref again to move it, or --ref main for latest.
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

# Record (or clear) the pinned tag under .git. A tag pin is written; main/master
# or an empty ref means "track the moving tip", so any stale pin is removed.
record_pin() {
    local ref="$1"
    case "$ref" in
        ""|main|master) rm -f "$TARGET_DIR/$PIN_BASENAME" 2>/dev/null || true ;;
        *) printf '%s\n' "$ref" > "$TARGET_DIR/$PIN_BASENAME" ;;
    esac
}

# Clone the foundation. With a ref, pin to that tag (shallow --branch clone);
# without one, clone the default branch (the historical behavior).
clone_at() {
    local ref="$1"
    if [ -n "$ref" ]; then
        info "Cloning $REPO_URL at $ref into $TARGET_DIR"
        run "git clone --depth 1 --branch \"$ref\" \"$REPO_URL\" \"$TARGET_DIR\""
    else
        info "Cloning $REPO_URL into $TARGET_DIR"
        run "git clone --depth 1 \"$REPO_URL\" \"$TARGET_DIR\""
    fi
    $DRY_RUN || record_pin "$ref"
}

# Update an existing install. A new --ref re-installs at that tag (clean
# re-clone, so the tag ref is present for `git describe`). With no --ref, a
# pinned install is left untouched (tags are immutable) and a non-pinned one
# fast-forwards the tracked branch, exactly as before.
update_install() {
    local pin=""
    [ -f "$TARGET_DIR/$PIN_BASENAME" ] && pin="$(cat "$TARGET_DIR/$PIN_BASENAME")"

    if [ -n "$REF" ]; then
        info "Re-installing $TARGET_DIR at $REF"
        # Clone into a staging dir first and swap only once the clone succeeds,
        # so a bad --ref (typo, missing tag, network blip) can never destroy a
        # working install. Under set -e a failed clone aborts here, before the
        # live dir is ever touched.
        local staging="${TARGET_DIR}.new.$$"
        local live="$TARGET_DIR"
        run "rm -rf \"$staging\""
        TARGET_DIR="$staging"
        clone_at "$REF"
        TARGET_DIR="$live"
        run "rm -rf \"$live\""
        run "mv \"$staging\" \"$live\""
    elif [ -n "$pin" ]; then
        info "Install is pinned to $pin. Pass --ref <tag> to move it, or --ref main for the latest."
    else
        info "Updating existing install at $TARGET_DIR"
        run "git -C \"$TARGET_DIR\" pull --ff-only"
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
        --ref)
            [ -z "${2:-}" ] && err "--ref requires a tag"
            REF="$2"
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
        update_install
    else
        info "claude-base already installed at $TARGET_DIR"
        info "Use --update to pull the latest changes, or --target to install to a different path."
        exit 0
    fi
elif [ -e "$TARGET_DIR" ]; then
    err "$TARGET_DIR exists but is not a git repository. Refusing to overwrite."
else
    clone_at "$REF"
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
