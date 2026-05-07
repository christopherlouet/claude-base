#!/usr/bin/env bats

# =============================================================================
# Drift guard: every scripts/hooks/*.sh referenced by the source
# .claude/settings.json must be shipped by scripts/lib/minimal-manifest.txt.
#
# Without this guard, a minimal-mode install ends up with a settings.json
# pointing at hook scripts that do not exist on disk — the situation that
# left claude-i18n-migration with only prompt-context.sh while settings.json
# referenced 6 other hooks.
# =============================================================================

load 'test_helper'

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
SETTINGS="$REPO_ROOT/.claude/settings.json"
MANIFEST="$REPO_ROOT/scripts/lib/minimal-manifest.txt"

@test "manifest: ships every scripts/hooks/*.sh referenced by settings.json" {
    [ -f "$SETTINGS" ]
    [ -f "$MANIFEST" ]

    local missing=()
    while IFS= read -r hook_path; do
        [ -z "$hook_path" ] && continue
        if ! grep -qE "^${hook_path}([[:space:]]|$|:)" "$MANIFEST"; then
            missing+=("$hook_path")
        fi
    done < <(grep -oE 'scripts/hooks/[a-zA-Z0-9_-]+\.sh' "$SETTINGS" | sort -u)

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing from minimal-manifest.txt:" >&2
        printf '  - %s\n' "${missing[@]}" >&2
        return 1
    fi
}

@test "manifest: ships _hook-helpers.sh whenever a sourcing hook is shipped" {
    [ -f "$MANIFEST" ]

    local sourcing_hooks
    sourcing_hooks=$(grep -lE 'source[[:space:]]+.*_hook-helpers\.sh' \
        "$REPO_ROOT/scripts/hooks/"*.sh 2>/dev/null | xargs -n1 basename | sort -u)

    local needs_helper=false
    while IFS= read -r hook_basename; do
        [ -z "$hook_basename" ] && continue
        if grep -qE "^scripts/hooks/${hook_basename}([[:space:]]|$|:)" "$MANIFEST"; then
            needs_helper=true
            break
        fi
    done <<< "$sourcing_hooks"

    if $needs_helper; then
        if ! grep -qE '^scripts/hooks/_hook-helpers\.sh([[:space:]]|$|:)' "$MANIFEST"; then
            echo "Manifest ships a hook that sources _hook-helpers.sh but does not ship the helper itself" >&2
            return 1
        fi
    fi
}
