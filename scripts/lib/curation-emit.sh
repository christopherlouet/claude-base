#!/usr/bin/env bash
# =============================================================================
# curation-emit.sh — OPT-IN, flag-gated GitHub emission for the curation engine
# (Slice 3b, specs/marketplace-curation-engine). Sourced by curation-watch.sh.
#
# The nightly watch is silent by default (it only writes a digest). Emission is
# wired by the deploy bot via explicit flags, and implements the spec's "mix"
# output contract (clarification 1):
#   --emit-issue : ONE propose-only GitHub issue carrying the digest (the human
#                  approves; nothing is auto-applied). Only when there are
#                  findings (no-noise contract).
#   --emit-pr    : a single draft PR re-pinning low-risk DRIFT (a newer ref that
#                  re-passes BOTH the trust scorer AND the pin-time safety screen
#                  — EF-006 / US-4 / T303). A drift whose new content FAILS the
#                  safety screen is DEMOTED to propose-only (it stays in the
#                  issue digest, never auto-drafted).
#
# Every path is FAIL-SAFE (EF-012): a missing tool, a dirty tree, or a gh/git
# failure logs a warning and returns cleanly — it never aborts the watch run and
# never leaves a half-applied change unreported.
# =============================================================================

_EMIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_EMIT_DIR/curation-common.sh"
# shellcheck source=scripts/lib/curation-safety.sh
source "$_EMIT_DIR/curation-safety.sh"

# _curation_gh_repo — resolve the owner/repo `gh` should target, so emission does
# NOT depend on the caller's CWD (the deploy bot runs from / via systemd, where
# `gh` cannot infer a repo → every create silently failed). Order: CURATION_GH_REPO
# override, else the origin remote of this checkout. Empty on failure (caller
# falls back to no -R, preserving the old behaviour).
_curation_gh_repo() {
    if [ -n "${CURATION_GH_REPO:-}" ]; then printf '%s' "$CURATION_GH_REPO"; return 0; fi
    local url
    url=$(git -C "$_EMIT_DIR" remote get-url origin 2>/dev/null) || return 1
    url="${url%.git}"
    case "$url" in
        *github.com[:/]*) url="${url##*github.com}"; printf '%s' "${url#[:/]}" ;;
        *) return 1 ;;
    esac
}

# emit_issue <title> <body-file> — open ONE propose-only issue. Fail-safe.
emit_issue() {
    local title="$1" body_file="$2"
    command -v gh >/dev/null 2>&1 || { curation_warn "gh not found; skipping issue"; return 0; }
    [ -f "$body_file" ] || { curation_warn "issue body missing: $body_file"; return 0; }
    local repo; repo=$(_curation_gh_repo) || repo=""
    local -a rflag; rflag=()
    [ -n "$repo" ] && rflag=(-R "$repo")
    if gh issue create ${rflag[@]+"${rflag[@]}"} --title "$title" --body-file "$body_file" --label curation >/dev/null 2>&1; then
        return 0
    fi
    # Retry without the label — a repo may not have the 'curation' label yet.
    gh issue create ${rflag[@]+"${rflag[@]}"} --title "$title" --body-file "$body_file" >/dev/null 2>&1 \
        || curation_warn "gh issue create failed"
    return 0
}

# _repin_apply <registry> <presets-dir> <repoRoot> <newRef> <now> — re-pin every
# registry record and preset recommendation whose repo-root matches, in place.
_repin_apply() {
    local registry="$1" presets_dir="$2" subj="$3" cur="$4" now="$5" tmp f
    if [ -f "$registry" ]; then
        if tmp=$(mktemp "$(dirname "$registry")/.repin.XXXXXX" 2>/dev/null) \
            && jq --arg s "$subj" --arg ref "$cur" --arg now "$now" \
                '.records |= map(if (.vendorId | split("/")[0:2] | join("/")) == $s
                                 then .pinnedRef = $ref | .lastVerified = $now else . end)' \
                "$registry" > "$tmp" 2>/dev/null; then
            mv "$tmp" "$registry"
        else
            [ -n "${tmp:-}" ] && rm -f "$tmp"
        fi
    fi
    for f in "$presets_dir"/*.json; do
        [ -f "$f" ] || continue
        # Match the SAME repo-root semantics the registry uses (owner/repo,
        # exact) — a substring `contains` would re-pin unrelated entries whose
        # url/id merely contains "owner/repo" as a fragment.
        if tmp=$(mktemp "$presets_dir/.repin.XXXXXX" 2>/dev/null) \
            && jq --arg s "$subj" --arg ref "$cur" --arg now "$now" \
                'def root($x): ($x | sub("^https?://github.com/"; "") | split("?")[0] | split("#")[0] | split("/") | .[0:2] | join("/"));
                 (.recommendedVendorSkills[]? | select(root(.url // .id // "") == $s))
                   |= (.pinnedRef = $ref | .lastVerified = $now)' \
                "$f" > "$tmp" 2>/dev/null; then
            mv "$tmp" "$f"
        else
            [ -n "${tmp:-}" ] && rm -f "$tmp"
        fi
    done
}

# _repin_pr_body <safe-findings-json> <now> — the draft-PR description.
_repin_pr_body() {
    printf 'Automated re-pin of drifted vendor skills (curation engine, %s).\n\n' "$2"
    printf 'Each entry below re-passed the **trust scorer** AND the **pin-time safety screen** (EF-006).\n'
    printf 'The safety screen re-opens on every drift; any drift whose new content failed the screen was **demoted to propose-only** and is NOT in this PR.\n\n'
    printf '| Subject | Old pin | New ref |\n|---|---|---|\n'
    printf '%s' "$1" | jq -r '.[] | "| \(.subject) | \(.pinnedRef) | \(.currentRef) |"'
    printf '\n_Draft — a maintainer must review (re-confirm the safety screen) before merge._\n'
}

# _subpaths_for_repo <owner/repo> <registry> <presets-dir> — echo the '+'-joined,
# deduped union of subpaths (the part after owner/repo) for every registry record
# and preset recommendation whose repo-root matches. Empty when the skill sits at
# the repo root. Lets the pin-time safety screen scope to the skill's subpath
# instead of scanning the whole monorepo (#384 false-truncation fix).
_subpaths_for_repo() {
    local want="$1" registry="$2" presets_dir="$3" id owner rest repo sub acc="" f
    {
        [ -f "$registry" ] && jq -r '.records[].vendorId // empty' "$registry" 2>/dev/null
        for f in "$presets_dir"/*.json; do
            [ -f "$f" ] || continue
            jq -r '.recommendedVendorSkills[]? | (.id // .url) // empty' "$f" 2>/dev/null
        done
    } | {
        while IFS= read -r id; do
            [ -n "$id" ] || continue
            case "$id" in
                https://github.com/*) id="${id#https://github.com/}" ;;
                http://github.com/*)  id="${id#http://github.com/}" ;;
                *://*) continue ;;
            esac
            id="${id%%[?#]*}"; id="${id%/}"
            owner="${id%%/*}"; rest="${id#*/}"
            [ "$owner" != "$rest" ] || continue
            repo="${rest%%/*}"
            [ "$owner/$repo" = "$want" ] || continue
            sub="${rest#*/}"
            [ "$sub" = "$rest" ] && continue           # no subpath (root skill)
            case "$sub" in tree/*) sub="${sub#tree/*/}" ;; esac   # drop /tree/<branch>/
            [ -n "$sub" ] && acc+="${sub}+"
        done
        # split on '+', dedup segments, re-join with '+'
        printf '%s' "$acc" | tr '+' '\n' | grep . | sort -u | paste -sd'+' - || true
    }
}

# _skills_for_repo <owner/repo> <registry> — echo the comma-joined, deduped,
# sorted foundation-skill name(s) that pin <owner/repo> in the registry. This is
# the provenance answer to "why is this repo watched" — the digest renders it so
# a row like `anthropics/claude-code` reads as serving `dev-frontend-design`
# rather than an unexplained repo. Empty when the repo is reached ONLY via a
# preset recommendation (those carry no foundation-skill name).
_skills_for_repo() {
    local want="$1" registry="$2"
    [ -f "$registry" ] || return 0
    jq -r --arg want "$want" '
        .records[]
        | select((.vendorId | split("/")[0:2] | join("/")) == $want)
        | .foundationSkill // empty' "$registry" 2>/dev/null \
        | grep . | sort -u | paste -sd',' - || true
}

# emit_repin_pr <surfaced-findings> <registry> <presets-dir> <draft-bool> <now>
# Echoes a JSON summary {drafted:[subjects], demoted:[findings], branch?}.
emit_repin_pr() {
    local findings="$1" registry="$2" presets_dir="$3" draft="$4" now="$5"
    local repins n
    repins=$(printf '%s' "$findings" | jq -c '[.[] | select(.type == "drift" and .proposedAction == "re-pin")]')
    n=$(printf '%s' "$repins" | jq 'length')
    [ "$n" -gt 0 ] || { echo '{"drafted":[],"demoted":[]}'; return 0; }

    # Pin-time safety gate (T303): only a drift whose NEW ref passes the content
    # screen may auto-draft; the rest are demoted to propose-only.
    local safe='[]' demoted='[]' f subj cur screen sv
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        subj=$(printf '%s' "$f" | jq -r '.subject')
        cur=$(printf '%s' "$f" | jq -r '.currentRef')
        # Scope the screen to the skill's subpath(s) — a subpath skill in a big
        # monorepo must not be judged by the whole repo's exec surface (#384).
        local subp; subp=$(_subpaths_for_repo "$subj" "$registry" "$presets_dir")
        screen=$(curation_safety_screen "$subj" "$cur" "$subp")
        sv=$(printf '%s' "$screen" | jq -r '.verdict')
        if [ "$sv" = "pass" ]; then
            safe=$(jq -cn --argjson a "$safe" --argjson f "$f" '$a + [$f]')
        else
            demoted=$(jq -cn --argjson a "$demoted" --argjson f "$f" --argjson s "$screen" '$a + [$f + {safety:$s}]')
        fi
    done < <(printf '%s' "$repins" | jq -c '.[]')

    local n_safe; n_safe=$(printf '%s' "$safe" | jq 'length')
    if [ "$n_safe" -eq 0 ]; then
        jq -cn --argjson d "$demoted" '{drafted:[], demoted:$d}'
        return 0
    fi

    # Guard the maintainer's tree: only proceed on a clean git checkout (the bot
    # always runs on one). Any deviation → no PR, reported.
    command -v git >/dev/null 2>&1 || { curation_warn "git not found; re-pin PR skipped"; jq -cn --argjson d "$demoted" '{drafted:[], demoted:$d, skipped:"no-git"}'; return 0; }
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { curation_warn "not a git repo; re-pin PR skipped"; jq -cn --argjson d "$demoted" '{drafted:[], demoted:$d, skipped:"no-repo"}'; return 0; }
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        curation_warn "working tree not clean; re-pin PR skipped"
        jq -cn --argjson d "$demoted" '{drafted:[], demoted:$d, skipped:"dirty-tree"}'
        return 0
    fi

    # Remember the starting branch so we never strand the invoker on the bot
    # branch (every exit path below restores it).
    local orig; orig=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    _restore_branch() { [ -n "$orig" ] && { git switch "$orig" >/dev/null 2>&1 || git checkout "$orig" >/dev/null 2>&1; }; }

    local branch="curation/re-pin-$now"
    if ! { git switch -c "$branch" >/dev/null 2>&1 || git checkout -b "$branch" >/dev/null 2>&1; }; then
        curation_warn "could not create branch $branch"
        jq -cn --argjson d "$demoted" '{drafted:[], demoted:$d, skipped:"branch"}'
        return 0
    fi

    while IFS= read -r f; do
        [ -n "$f" ] || continue
        subj=$(printf '%s' "$f" | jq -r '.subject')
        cur=$(printf '%s' "$f" | jq -r '.currentRef')
        _repin_apply "$registry" "$presets_dir" "$subj" "$cur" "$now"
    done < <(printf '%s' "$safe" | jq -c '.[]')

    git add -A >/dev/null 2>&1
    if ! git commit -m "chore(curation): re-pin ${n_safe} drifted vendor skill(s) to latest verified ref" >/dev/null 2>&1; then
        curation_warn "nothing to commit for re-pin"
        _restore_branch
        jq -cn --argjson d "$demoted" '{drafted:[], demoted:$d, skipped:"no-commit"}'
        return 0
    fi
    # A failed push aborts PR creation (no PR against a branch the remote lacks)
    # and restores the original branch — fail safe, leaving only a local branch.
    if ! git push -u origin "$branch" >/dev/null 2>&1; then
        curation_warn "git push failed; re-pin PR not opened"
        _restore_branch
        jq -cn --argjson d "$demoted" '{drafted:[], demoted:$d, skipped:"push"}'
        return 0
    fi

    local body_file; body_file=$(mktemp 2>/dev/null)
    _repin_pr_body "$safe" "$now" > "$body_file"
    local repo; repo=$(_curation_gh_repo) || repo=""
    local args=(pr create)
    [ -n "$repo" ] && args+=(-R "$repo")
    args+=(--title "chore(curation): re-pin ${n_safe} vendor skill(s)" --body-file "$body_file")
    [ "$draft" = "true" ] && args+=(--draft)
    gh "${args[@]}" >/dev/null 2>&1 || curation_warn "gh pr create failed"
    rm -f "$body_file"
    _restore_branch

    jq -cn --argjson s "$safe" --argjson d "$demoted" --arg b "$branch" \
        '{drafted:($s | map(.subject)), demoted:$d, branch:$b}'
    return 0
}
