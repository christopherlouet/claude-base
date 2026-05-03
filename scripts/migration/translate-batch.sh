#!/usr/bin/env bash
# =============================================================================
# translate-batch.sh — main runner for the FR->EN migration.
#
# Per pending file:
#   1. Save source (FR) to a temp file
#   2. Build prompt from template + glossary + blacklist + source
#   3. Call `claude --print` (or simulate in --dry-run)
#   4. Write output to disk (overwrite source)
#   5. Validate via validate-translation.sh (skipped in --dry-run)
#   6. If valid: mark-done in state, optionally git commit
#   7. If invalid: restore source, log warning, continue
#
# Usage:
#   translate-batch.sh --tier <N> [options]
#
# Options:
#   --tier <N>            REQUIRED — 1, 2, 3, or 4
#   --inventory <file>    default: specs/migration-fr-en/inventory.json
#   --state <file>        default: specs/migration-fr-en/state-tier-N.json
#   --root <dir>          repo root for resolving file paths (default: repo root)
#   --dry-run             skip claude call, prepend "DRY-RUN" marker, skip validators
#   --limit <N>           process at most N files (0 = unlimited)
#   --no-commit           don't git commit after each file (testing)
#   --no-validate         skip validators (debug only)
#   --max-retries <N>     retries on validation failure (default 1)
#   -h, --help
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT_DEFAULT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPEC_DIR_DEFAULT="$REPO_ROOT_DEFAULT/specs/migration-fr-en"

TIER=""
INVENTORY=""
STATE=""
ROOT=""
DRY_RUN=false
LIMIT=0
NO_COMMIT=false
NO_VALIDATE=false
MAX_RETRIES=1
PRINT_PROMPT=""
VERIFY=false

show_help() {
    head -33 "$0" | tail -32 | sed 's|^#||; s|^ ||'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier) TIER="$2"; shift 2 ;;
        --inventory) INVENTORY="$2"; shift 2 ;;
        --state) STATE="$2"; shift 2 ;;
        --root) ROOT="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --limit) LIMIT="$2"; shift 2 ;;
        --no-commit) NO_COMMIT=true; shift ;;
        --no-validate) NO_VALIDATE=true; shift ;;
        --max-retries) MAX_RETRIES="$2"; shift 2 ;;
        --print-prompt) PRINT_PROMPT="$2"; shift 2 ;;
        --verify) VERIFY=true; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

# -----------------------------------------------------------------------------
# --print-prompt mode: render prompt for a single file and exit. No state, no
# claude call, no validation. Useful for inspecting / iterating the prompt.
# -----------------------------------------------------------------------------
if [[ -n "$PRINT_PROMPT" ]]; then
    PROMPT_TEMPLATE="$SCRIPT_DIR/translate-prompt.md"
    GLOSSARY="$REPO_ROOT_DEFAULT/specs/migration-fr-en/glossary.yaml"
    BLACKLIST="$REPO_ROOT_DEFAULT/specs/migration-fr-en/blacklist.txt"
    BUILD_PROMPT="$SCRIPT_DIR/build-prompt.py"

    [[ -f "$PROMPT_TEMPLATE" ]] || { echo "Prompt template missing: $PROMPT_TEMPLATE" >&2; exit 2; }
    [[ -f "$GLOSSARY" ]] || { echo "Glossary missing: $GLOSSARY" >&2; exit 2; }
    [[ -f "$BLACKLIST" ]] || { echo "Blacklist missing: $BLACKLIST" >&2; exit 2; }
    [[ -x "$BUILD_PROMPT" ]] || { echo "build-prompt.py missing: $BUILD_PROMPT" >&2; exit 2; }

    # Resolve the file relative to repo root if not absolute
    if [[ "$PRINT_PROMPT" == /* ]]; then
        abs_file="$PRINT_PROMPT"
    else
        abs_file="$REPO_ROOT_DEFAULT/$PRINT_PROMPT"
    fi
    [[ -f "$abs_file" ]] || { echo "File not found: $abs_file" >&2; exit 2; }

    "$BUILD_PROMPT" \
        --template "$PROMPT_TEMPLATE" \
        --file-path "$PRINT_PROMPT" \
        --content "$abs_file" \
        --glossary "$GLOSSARY" \
        --blacklist "$BLACKLIST"
    exit 0
fi

# -----------------------------------------------------------------------------
# Pre-flight
# -----------------------------------------------------------------------------
[[ -z "$TIER" ]] && { echo "--tier is required" >&2; exit 2; }
case "$TIER" in 1|2|3|4|5|6|7|8) ;; *) echo "--tier must be 1-6 (got: $TIER)" >&2; exit 2 ;; esac

ROOT="${ROOT:-$REPO_ROOT_DEFAULT}"
INVENTORY="${INVENTORY:-$SPEC_DIR_DEFAULT/inventory.json}"
STATE="${STATE:-$SPEC_DIR_DEFAULT/state-tier-$TIER.json}"

[[ -f "$INVENTORY" ]] || { echo "Inventory not found: $INVENTORY" >&2; exit 2; }

PROMPT_TEMPLATE="$SCRIPT_DIR/translate-prompt.md"
GLOSSARY="$SPEC_DIR_DEFAULT/glossary.yaml"
BLACKLIST="$SPEC_DIR_DEFAULT/blacklist.txt"
BUILD_PROMPT="$SCRIPT_DIR/build-prompt.py"
VALIDATOR="$SCRIPT_DIR/validate-translation.sh"
CHECK_GLOSSARY="$SCRIPT_DIR/check-glossary.sh"
RECOVERY="$SCRIPT_DIR/recovery.sh"

[[ -f "$PROMPT_TEMPLATE" ]] || { echo "Prompt template missing: $PROMPT_TEMPLATE" >&2; exit 2; }
[[ -f "$GLOSSARY" ]] || { echo "Glossary missing: $GLOSSARY" >&2; exit 2; }
[[ -f "$BLACKLIST" ]] || { echo "Blacklist missing: $BLACKLIST" >&2; exit 2; }
[[ -x "$BUILD_PROMPT" ]] || { echo "build-prompt.py missing or not executable: $BUILD_PROMPT" >&2; exit 2; }
[[ -x "$VALIDATOR" ]] || { echo "validate-translation.sh missing: $VALIDATOR" >&2; exit 2; }
[[ -x "$RECOVERY" ]] || { echo "recovery.sh missing: $RECOVERY" >&2; exit 2; }

if ! $DRY_RUN; then
    command -v claude >/dev/null 2>&1 || { echo "claude CLI not found in PATH" >&2; exit 2; }
fi
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }

# -----------------------------------------------------------------------------
# Safety guards
# -----------------------------------------------------------------------------
# Guard 1: --dry-run implies --no-commit (never commit dry-run markers).
if $DRY_RUN; then
    NO_COMMIT=true
fi

# Guard 2: --dry-run on the script's own repo would write into real files.
# Refuse unless --root explicitly points outside the script's git tree.
if $DRY_RUN; then
    script_repo=$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel 2>/dev/null || echo "")
    target_repo=$(cd "$ROOT" && git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [[ -n "$script_repo" && "$script_repo" == "$target_repo" ]]; then
        echo "REFUSING: --dry-run targeting the script's own git tree would modify real files." >&2
        echo "Use --root <other-dir> for dry-run, or remove --dry-run for the real translation." >&2
        exit 2
    fi
fi

# -----------------------------------------------------------------------------
# --verify mode: re-run cross-file glossary drift check on all draft files.
# No translation, no claude call. Pure batch validation.
# -----------------------------------------------------------------------------
if $VERIFY; then
    [[ -f "$STATE" ]] || { echo "State not found: $STATE (cannot verify)" >&2; exit 2; }

    drafts=$(jq -r '[.files[] | select(.status == "draft") | .path] | .[]' "$STATE" 2>/dev/null || true)
    draft_count=0
    [[ -n "$drafts" ]] && draft_count=$(echo "$drafts" | wc -l)

    if [[ $draft_count -eq 0 ]]; then
        echo "[verify] Tier $TIER: no draft files, nothing to verify."
        exit 0
    fi

    echo "[verify] Tier $TIER: $draft_count draft file(s) to check"

    # Cross-file glossary drift on all draft files (gathered into a tempdir of symlinks)
    tmpd=$(mktemp -d)
    trap 'rm -rf "$tmpd"' EXIT
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        # Copy (not symlink — find -type f does not follow symlinks by default,
        # and check-glossary.sh uses plain find).
        safe_name=$(echo "$f" | tr '/' '_')
        if [[ -f "$ROOT/$f" ]]; then
            cp "$ROOT/$f" "$tmpd/$safe_name"
        fi
    done <<< "$drafts"

    fails=0
    if "$CHECK_GLOSSARY" --glossary "$GLOSSARY" --dir "$tmpd" --detect-drift; then
        echo "[verify] Cross-file glossary check: OK"
    else
        echo "[verify] Cross-file glossary check: FAIL"
        fails=$((fails + 1))
    fi

    # Per-file structure check (length sanity etc.) using src=dst is a no-op,
    # so skip per-file structure here. The runner already ran it during
    # translation. --verify is best for cross-file checks that need the
    # complete picture.

    if [[ $fails -gt 0 ]]; then
        echo "[verify] $draft_count files checked, $fails failure(s)"
        exit 1
    fi

    echo "[verify] $draft_count files checked, all OK"
    exit 0
fi

# -----------------------------------------------------------------------------
# Init or resume state
# -----------------------------------------------------------------------------
if [[ ! -f "$STATE" ]]; then
    echo "[batch] Initializing state for tier $TIER"
    "$RECOVERY" init --tier "$TIER" --inventory "$INVENTORY" --state "$STATE" --root "$ROOT"
fi

mapfile -t pending_files < <("$RECOVERY" list-pending --state "$STATE")
total_pending=${#pending_files[@]}
total_in_state=$(jq '.files | length' "$STATE")

echo "[batch] Tier $TIER — $total_pending pending of $total_in_state total"

if [[ $total_pending -eq 0 ]]; then
    echo "[batch] Nothing to do, all files already translated."
    exit 0
fi

# -----------------------------------------------------------------------------
# Translate one file
# -----------------------------------------------------------------------------
translate_one() {
    local rel_path="$1"
    local idx="$2"
    local total="$3"
    local abs_path="$ROOT/$rel_path"

    echo "[$idx/$total] $rel_path"

    if [[ ! -f "$abs_path" ]]; then
        echo "  WARN: source file missing, skipping"
        return 1
    fi

    local backup
    backup=$(mktemp)
    cp "$abs_path" "$backup"

    local attempt=0
    local success=false

    while [[ $attempt -le $MAX_RETRIES ]]; do
        attempt=$((attempt + 1))

        if $DRY_RUN; then
            # Dry-run: prepend marker and original content
            {
                echo "<!-- DRY-RUN translation -->"
                cat "$backup"
            } > "$abs_path"
        else
            # Build prompt and call claude
            local prompt_file
            prompt_file=$(mktemp)
            "$BUILD_PROMPT" \
                --template "$PROMPT_TEMPLATE" \
                --file-path "$rel_path" \
                --content "$backup" \
                --glossary "$GLOSSARY" \
                --blacklist "$BLACKLIST" > "$prompt_file"

            local claude_flags="${CLAUDE_FLAGS:---print}"
            local out_file
            out_file=$(mktemp)
            local claude_status=0
            # shellcheck disable=SC2086
            claude $claude_flags < "$prompt_file" > "$out_file" 2>/dev/null || claude_status=$?
            rm -f "$prompt_file"

            if [[ $claude_status -ne 0 || ! -s "$out_file" ]]; then
                echo "  WARN: claude call failed (status=$claude_status, attempt $attempt)"
                rm -f "$out_file"
                continue
            fi

            mv "$out_file" "$abs_path"
        fi

        if $NO_VALIDATE || $DRY_RUN; then
            success=true
            break
        fi

        if "$VALIDATOR" --src "$backup" --dst "$abs_path" 2>&1 | sed 's/^/  /'; then
            success=true
            break
        fi

        echo "  WARN: validation failed, attempt $attempt"
        cp "$backup" "$abs_path"
    done

    if ! $success; then
        echo "  FAIL: giving up on $rel_path after $MAX_RETRIES retries"
        cp "$backup" "$abs_path"
        rm -f "$backup"
        return 1
    fi

    rm -f "$backup"

    # Mark done in state
    "$RECOVERY" mark-done --state "$STATE" --file "$rel_path"

    # Commit (unless --no-commit)
    if ! $NO_COMMIT; then
        ( cd "$ROOT" && git add "$rel_path" "$STATE" 2>/dev/null && \
          git commit --quiet -m "feat(migration): translate $rel_path (tier $TIER)" 2>/dev/null ) \
            || echo "  NOTE: git commit skipped (clean tree or hook block)"
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Main loop
# -----------------------------------------------------------------------------
processed=0
failed=0
idx=0
for rel_path in "${pending_files[@]}"; do
    idx=$((idx + 1))
    if [[ $LIMIT -gt 0 && $processed -ge $LIMIT ]]; then
        echo "[batch] Reached --limit $LIMIT, stopping"
        break
    fi

    if translate_one "$rel_path" "$idx" "$total_pending"; then
        processed=$((processed + 1))
    else
        failed=$((failed + 1))
    fi
done

echo "[batch] Done: $processed processed, $failed failed"

[[ $failed -eq 0 ]] && exit 0 || exit 1
