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

# A shipped rule/skill/command that tells the user to run `scripts/<x>.sh` is a
# dead reference downstream unless that script also ships. (The substance gate's
# detector was referenced by verification/tdd-enforcement/qa-review but lived only
# in the foundation repo — this guards that class of gap generally.)
@test "manifest: ships every scripts/*.sh referenced by a shipped rule/skill/command" {
    [ -f "$MANIFEST" ]

    local missing=()
    while IFS= read -r entry; do
        case "$entry" in
            .claude/rules/*|.claude/skills/*|.claude/commands/*|.claude/agents/*) ;;
            *) continue ;;
        esac
        local src="${entry%%:*}"           # strip any SRC:DST remap
        local target="$REPO_ROOT/$src"
        [ -e "$target" ] || continue
        while IFS= read -r ref; do
            [ -z "$ref" ] && continue
            if ! grep -qE "^${ref}([[:space:]]|$|:)" "$MANIFEST"; then
                missing+=("$src references $ref (not in manifest)")
            fi
        done < <(grep -rhoE 'scripts/[a-zA-Z0-9_/-]+\.sh' "$target" 2>/dev/null | sort -u)
    done < "$MANIFEST"

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Scripts referenced by a shipped rule/skill/command but missing from minimal-manifest.txt:" >&2
        printf '  - %s\n' "${missing[@]}" >&2
        return 1
    fi
}

# The docs must teach every hook that actually runs: a settings.json hook absent
# from docs/reference/hooks-reference.md is invisible to users auditing their
# own guardrail net (base-integrity-check.sh drifted out exactly this way —
# 2026-07-11 analysis). Underscore-prefixed helpers are sourced libs, not hooks.
@test "docs: hooks-reference.md documents every scripts/hooks/*.sh wired in settings.json" {
    local docfile="$REPO_ROOT/docs/reference/hooks-reference.md"
    [ -f "$SETTINGS" ]
    [ -f "$docfile" ]

    local missing=()
    while IFS= read -r hook_path; do
        [ -z "$hook_path" ] && continue
        local base; base=$(basename "$hook_path" .sh)
        case "$base" in _*) continue ;; esac
        # The doc uses display names ("Bash-write guard"), so match the hook
        # name case-insensitively with '-' or ' ' between words.
        local pattern; pattern=$(printf '%s' "$base" | sed 's/-/[ -]/g')
        if ! grep -qiE "$pattern" "$docfile"; then
            missing+=("$base")
        fi
    done < <(grep -oE 'scripts/hooks/[a-zA-Z0-9_-]+\.sh' "$SETTINGS" | sort -u)

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Hooks wired in settings.json but absent from hooks-reference.md:" >&2
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

@test "manifest: ships every sibling _*.sh helper that a manifest hook sources" {
    [ -f "$MANIFEST" ]

    # For each hook .sh listed in the manifest, find sibling helper files it
    # sources (source/. lines mentioning a _<name>.sh) and assert each helper is
    # itself in the manifest. Generic guard so a new sourced helper cannot drift
    # out of the minimal export (the _hook-helpers.sh case, generalised).
    local missing=()
    while IFS= read -r manifest_path; do
        case "$manifest_path" in
            scripts/hooks/*.sh) ;;
            *) continue ;;
        esac
        local hook_file="$REPO_ROOT/$manifest_path"
        [ -f "$hook_file" ] || continue
        while IFS= read -r helper; do
            [ -z "$helper" ] && continue
            if ! grep -qE "^scripts/hooks/${helper}([[:space:]]|$|:)" "$MANIFEST"; then
                missing+=("$manifest_path sources $helper (not in manifest)")
            fi
        done < <(grep -hoE '(source|\.)[[:space:]]+[^#]*/(_[a-zA-Z0-9-]+\.sh)' "$hook_file" 2>/dev/null \
            | grep -oE '_[a-zA-Z0-9-]+\.sh' | sort -u)
    done < "$MANIFEST"

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Sourced helpers missing from minimal-manifest.txt:" >&2
        printf '  - %s\n' "${missing[@]}" >&2
        return 1
    fi
}
