#!/usr/bin/env bash
# =============================================================================
# Orchestrator : build the demo image, record the asciinema cast, render GIF.
#
# Pre-requisites (one-time install) :
#   - docker
#   - asciinema   (pip install --user asciinema)
#   - agg         (cargo install --git https://github.com/asciinema/agg)
#
# Run :
#   bash website/demo/record.sh
#
# Output :
#   website/static/img/60-second-tour.cast   ← asciinema source (commit this)
#   website/static/img/60-second-tour.gif    ← README embed
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEMO_DIR="$REPO_ROOT/website/demo"
OUT_DIR="$REPO_ROOT/website/static/img"
CAST="$OUT_DIR/60-second-tour.cast"
GIF="$OUT_DIR/60-second-tour.gif"
IMAGE_TAG="claude-base-demo:latest"

mkdir -p "$OUT_DIR"

# -----------------------------------------------------------------------------
# 1. Sanity checks
# -----------------------------------------------------------------------------
for tool in docker asciinema agg; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "[FAIL] missing tool: $tool" >&2
        case "$tool" in
            asciinema) echo "  install: pip install --user asciinema" >&2 ;;
            agg)       echo "  install: cargo install --git https://github.com/asciinema/agg" >&2 ;;
            docker)    echo "  install: see https://docs.docker.com/engine/install/" >&2 ;;
        esac
        exit 2
    fi
done

if [ ! -d "$HOME/.claude" ]; then
    echo "[FAIL] $HOME/.claude not found — Claude Code must be authenticated on this host" >&2
    echo "       run 'claude login' first to set up the OAuth token" >&2
    exit 2
fi

if [ ! -f "$HOME/.claude.json" ]; then
    echo "[WARN] $HOME/.claude.json not found — Claude may not have run yet on this host" >&2
fi

# -----------------------------------------------------------------------------
# 2. Build the demo image
# -----------------------------------------------------------------------------
echo "[INFO] Building $IMAGE_TAG ..."
docker build -t "$IMAGE_TAG" -f "$DEMO_DIR/Dockerfile.demo" "$DEMO_DIR"

# -----------------------------------------------------------------------------
# 3. Record the asciinema cast
# -----------------------------------------------------------------------------
echo "[INFO] Recording $CAST ..."
# Remove old cast so asciinema doesn't refuse to overwrite.
rm -f "$CAST"

# Stage the host's Claude auth into a writable temp copy. Slash commands
# (e.g. /assistant) need to write back to ~/.claude.json — read-only mount
# would error with EROFS. The temp copy isolates the container's writes from
# the host's session state.
AUTH_TMP="$(mktemp -d)"
trap 'rm -rf "$AUTH_TMP"' EXIT
cp -r "$HOME/.claude/" "$AUTH_TMP/claude/"
cp    "$HOME/.claude.json"     "$AUTH_TMP/claude.json"
chmod -R u+w "$AUTH_TMP"

# `--overwrite` would mid-run prompt ; we just rm above to keep this quiet.
# The temp auth copy is read-write inside the container ; the host's real
# ~/.claude / ~/.claude.json are never touched by the recording.
asciinema rec "$CAST" \
    --idle-time-limit 5 \
    --title "claude-base — quick tour" \
    --command "docker run --rm -i \
        -v $AUTH_TMP/claude:/home/demo/.claude:rw \
        -v $AUTH_TMP/claude.json:/home/demo/.claude.json:rw \
        -e TERM=xterm-256color \
        $IMAGE_TAG \
        /usr/local/bin/scenario"

# -----------------------------------------------------------------------------
# 4. Render the GIF (sped up x1.5 for the README embed — compresses the
#    inevitable Claude API wait in Step 4 without making the readable steps
#    feel rushed thanks to their generous source pauses).
# -----------------------------------------------------------------------------
echo "[INFO] Rendering $GIF ..."
agg --speed 1.5 --theme monokai --font-size 18 "$CAST" "$GIF"

# -----------------------------------------------------------------------------
# 5. Summary
# -----------------------------------------------------------------------------
echo ""
echo "[OK] Recording complete."
echo "     Cast: $CAST  ($(du -h "$CAST" | cut -f1))"
echo "     GIF : $GIF  ($(du -h "$GIF" | cut -f1))"
echo ""
echo "Next steps :"
echo "  1. Review : asciinema play $CAST"
echo "  2. If satisfactory : embed in README.md via the GIF (commit both files)"
echo "  3. Optional : upload to asciinema.org with 'asciinema upload $CAST'"
