#!/usr/bin/env bash
# =============================================================================
# validate-presets.sh
# =============================================================================
# Validates every preset JSON manifest under .claude/presets/ against the
# format described in specs/presets/spec.md.
#
# Checks performed (jq-based):
#   - Required fields present: name, displayName, description, status,
#     appliesToTypes, defaults, outOfScope
#   - status is one of: maintainer-vouched | community-curated | draft
#   - name matches /^[a-z][a-z0-9-]*$/ (stack-specific, lowercase, hyphens)
#   - appliesToTypes is a non-empty array
#   - defaults has the 5 expected boolean / string fields
#   - foundation.skills.drop (if present) is an array of strings
#   - foundation.skills.keep (if present) is a non-empty array of strings
#   - foundation.skills.drop and foundation.skills.keep are mutually exclusive
#     (XOR): a preset may declare at most one of the two
#   - marketplacePlugins (if present) is an array; each entry has id +
#     rationale + optional booleans
#
# Usage:
#   bash scripts/validate-presets.sh                # validate all presets
#   bash scripts/validate-presets.sh path/to/x.json # validate one file
#   bash scripts/validate-presets.sh --quiet        # only print errors
#
# Exit codes:
#   0 — all valid
#   1 — at least one preset failed validation
#   2 — usage / setup error (jq missing, no presets dir)
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# PRESETS_DIR is overridable (VALIDATE_PRESETS_DIR) so the pin-lockstep guard can
# be exercised against a fixture tree in tests — mirrors curation-watch.sh's
# --presets-dir seam. Production/default resolves to the shipped presets.
PRESETS_DIR="${VALIDATE_PRESETS_DIR:-$BASE_DIR/.claude/presets}"

# Bundle registry — single source of truth for module name validity
# (module_exists: [a-z0-9-] syntax guard + bundle file existence).
# shellcheck source=scripts/lib/modules.sh
source "$SCRIPT_DIR/lib/modules.sh"
# Command/agent catalog filter SSOT (domain resolution, floor, unknown names).
# shellcheck source=scripts/lib/catalog-filter.sh
source "$SCRIPT_DIR/lib/catalog-filter.sh"

QUIET=false
SINGLE_FILE=""
REGISTRY_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --quiet|-q) QUIET=true; shift ;;
        --registry)
            REGISTRY_FILE="${2:-}"
            [ -n "$REGISTRY_FILE" ] || { echo "Error: --registry requires a file path" >&2; exit 2; }
            shift 2
            ;;
        --help|-h)
            sed -nE 's/^# ?//p' "$0" | sed -nE '/^validate-presets/,/^Exit/p'
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
        *)
            SINGLE_FILE="$1"
            shift
            ;;
    esac
done

command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 2; }

# --registry is its own mode; combining it with a positional preset file would
# silently drop one of the two from validation — reject the ambiguity.
if [ -n "$REGISTRY_FILE" ] && [ -n "$SINGLE_FILE" ]; then
    echo "[ERROR] --registry cannot be combined with a positional preset file" >&2
    exit 2
fi

if [ -n "$REGISTRY_FILE" ]; then
    # registry-only mode: validate the canonicalVendor registry, no presets.
    FILES=()
elif [ -n "$SINGLE_FILE" ]; then
    if [ ! -f "$SINGLE_FILE" ]; then
        echo "[ERROR] file not found: $SINGLE_FILE" >&2
        exit 2
    fi
    FILES=("$SINGLE_FILE")
else
    [ -d "$PRESETS_DIR" ] || { echo "[ERROR] presets dir not found: $PRESETS_DIR" >&2; exit 2; }
    mapfile -t FILES < <(find "$PRESETS_DIR" -maxdepth 2 -name "*.json" -type f | sort)
    if [ "${#FILES[@]}" -eq 0 ]; then
        $QUIET || echo "[INFO] no preset .json files found under $PRESETS_DIR"
        exit 0
    fi
fi

ALLOWED_STATUS='["maintainer-vouched","community-curated","vendor-pointer","draft"]'
ALLOWED_CATEGORIES='["web-frontend","api-backend","mobile-desktop","game-interactive-media","data-database","infra-devops","cli-automation","other-generic"]'
ALLOWED_DESIGN_STYLE='["terminal","cockpit","vitality","editorial","glass","signal"]'
NAME_PATTERN='^[a-z][a-z0-9-]*$'

# EF-005 — a pinned reference must be immutable. This is a deliberately
# CONSERVATIVE shape guard: a tag and a branch are indistinguishable from the
# string alone (both are just refs), so this only rejects the universal floating
# aliases (latest/HEAD/main/master…), case-insensitively. Ambiguous names like
# `release-2.x` pass here — they MIGHT be a tag — and are resolved authoritatively
# (tag vs branch) by the gh-resolving trust scorer in Slice 2/3. Trying to also
# reject "branch-shaped" names rejects legitimate tags (`release-1.0.0`,
# `fix-2.3.1`), so we don't. A tag or commit SHA passes here.
_is_floating_ref() {
    case "${1,,}" in
        ""|latest|head|main|master|develop|trunk|stable|edge|next|nightly|canary|default|current|tip|wip) return 0 ;;
        *) return 1 ;;
    esac
}

# ISO date (YYYY-MM-DD) shape guard for lastVerified fields. Month is bounded
# 01-12 and day 01-31; it does NOT validate day-of-month against the month, so
# e.g. 2026-02-30 still passes — it is a cheap shape/typo guard, not a calendar.
_is_iso_date() {
    [[ "$1" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]
}

pass=0
fail=0
errors=()

# _catalog_filter_findings <file> <catalog> — validate foundation.<catalog>
# (commands|agents) drop/keep filter. Echoes findings one per line, prefixed
# "E:" (fatal error) or "W:" (non-fatal warning); the caller routes them.
# Delegates domain/floor/unknown logic to lib/catalog-filter.sh (SSOT).
_catalog_filter_findings() {
    local file="$1" catalog="$2"
    local root="$BASE_DIR/.claude/$catalog"

    local has_drop has_keep
    has_drop=$(jq -r "(.foundation.${catalog})? // {} | if type==\"object\" and has(\"drop\") then \"yes\" else \"no\" end" "$file")
    has_keep=$(jq -r "(.foundation.${catalog})? // {} | if type==\"object\" and has(\"keep\") then \"yes\" else \"no\" end" "$file")
    [ "$has_drop" = "no" ] && [ "$has_keep" = "no" ] && return 0

    # XOR — drop and keep are mutually exclusive.
    if [ "$has_drop" = "yes" ] && [ "$has_keep" = "yes" ]; then
        echo "E:foundation.${catalog}.drop and foundation.${catalog}.keep are mutually exclusive — use one or the other, not both"
    fi

    # Type checks; establish the active mode (a valid single-mode array).
    local mode=""
    if [ "$has_drop" = "yes" ]; then
        if [ "$(jq -r "(.foundation.${catalog}.drop)? // null | type" "$file")" != "array" ]; then
            echo "E:foundation.${catalog}.drop must be an array"
        else
            mode="drop"
        fi
    fi
    if [ "$has_keep" = "yes" ]; then
        if [ "$(jq -r "(.foundation.${catalog}.keep)? // null | type" "$file")" != "array" ]; then
            echo "E:foundation.${catalog}.keep must be an array"
        elif [ "$(jq -r "(.foundation.${catalog}.keep)? // [] | length" "$file")" -eq 0 ]; then
            echo "E:foundation.${catalog}.keep must be a non-empty array"
        else
            if [ "$(jq -r "[(.foundation.${catalog}.keep)?[]? | select(type!=\"string\")] | length" "$file")" -ne 0 ]; then
                echo "E:foundation.${catalog}.keep entries must be strings"
            fi
            [ -z "$mode" ] && mode="keep"
        fi
    fi
    [ -n "$mode" ] || return 0

    # Collect entries of the active mode (parsing delegated to the lib SSOT).
    local entries=() e
    while IFS= read -r e; do
        [ -z "$e" ] && continue
        entries+=("$e")
    done < <(cf_filter_entries "$file" "$catalog" "$mode")

    # EF-111 — the protected floor cannot be excluded.
    local v
    while IFS= read -r v; do
        [ -z "$v" ] && continue
        echo "E:foundation.${catalog}.${mode} cannot exclude the protected floor: $v (the work domain + assistant/assistant-auto are mandatory, EF-111)"
    done < <(catalog_floor_violations "$catalog" "$root" "$mode" ${entries[@]+"${entries[@]}"})

    # Module boundary (EF-406) — the catalog filter governs the CORE only; every
    # module-owned item is out of its jurisdiction. Two forms:
    #   domain:<m>  → reject when <m> is a horizontal module (a whole domain).
    #   <item-name> → reject when the item is owned by ANY module, including a
    #                 cross-domain thematic one (dev-flutter, ops-proxmox…) whose
    #                 domain is NOT itself a module. Use defaultModules instead.
    local owned_items
    owned_items="$(module_owned_item_names "$catalog")"
    for e in ${entries[@]+"${entries[@]}"}; do
        case "$e" in
            domain:*)
                local edom="${e#domain:}"
                if module_exists "$edom"; then
                    echo "E:foundation.${catalog} must not target the '$edom' domain — it is an installable module; use defaultModules instead (see specs/thematic-modules)"
                fi
                ;;
            *)
                if printf '%s\n' "$owned_items" | grep -qxF -- "$e"; then
                    local owner
                    owner="$(module_of_item "$catalog" "$e")"
                    echo "E:foundation.${catalog} must not target '$e' — it is owned by the '${owner:-unknown}' module; use defaultModules instead (see specs/thematic-modules)"
                fi
                ;;
        esac
    done

    # Unknown names — non-fatal warning (install ignores them).
    local u
    while IFS= read -r u; do
        [ -z "$u" ] && continue
        echo "W:foundation.${catalog}: '$u' matches no known command/agent or domain (typo? ignored at install)"
    done < <(catalog_unknown_entries "$catalog" "$root" ${entries[@]+"${entries[@]}"})
}

validate_one() {
    local file="$1"
    local rel="${file#"$BASE_DIR/"}"
    local errs=()
    local warns=()

    if ! jq -e . "$file" >/dev/null 2>&1; then
        errs+=("invalid JSON syntax")
        printf '%s\n' "${errs[@]}"
        return 1
    fi

    local name status types
    name=$(jq -r '.name // empty' "$file")
    status=$(jq -r '.status // empty' "$file")
    types=$(jq -r '.appliesToTypes // empty | type' "$file")

    [ -n "$name" ] || errs+=("missing required field: name")
    [ -n "$status" ] || errs+=("missing required field: status")
    [ -n "$(jq -r '.displayName // empty' "$file")" ] || errs+=("missing required field: displayName")
    [ -n "$(jq -r '.description // empty' "$file")" ] || errs+=("missing required field: description")
    [ "$types" = "array" ] || errs+=("appliesToTypes must be a non-empty array")
    # defaults is required for all tiers EXCEPT vendor-pointer
    # (spec: presets-vendor-pointer-tier EF-004 — vendor-pointer presets
    # inherit foundation defaults; declaring overrides is forbidden)
    if [ "$status" != "vendor-pointer" ]; then
        [ "$(jq -r '.defaults // empty | type' "$file")" = "object" ] || errs+=("defaults must be an object")
    fi
    [ "$(jq -r '.outOfScope // empty | type' "$file")" = "array" ] || errs+=("outOfScope must be an array")

    if [ -n "$name" ] && ! [[ "$name" =~ $NAME_PATTERN ]]; then
        errs+=("name '$name' does not match pattern $NAME_PATTERN")
    fi

    if [ -n "$status" ]; then
        case "$status" in
            maintainer-vouched|community-curated|vendor-pointer|draft) ;;
            *) errs+=("status '$status' not in $ALLOWED_STATUS") ;;
        esac
    fi

    # defaults shape checks — skipped for vendor-pointer tier which
    # inherits foundation defaults and forbids the field entirely (EF-004)
    if [ "$status" != "vendor-pointer" ]; then
        local style
        style=$(jq -r '.defaults.designStyle // empty' "$file")
        if [ -n "$style" ]; then
            case "$style" in
                terminal|cockpit|vitality|editorial|glass|signal) ;;
                *) errs+=("defaults.designStyle '$style' not in $ALLOWED_DESIGN_STYLE") ;;
            esac
        fi

        for k in ci hooks mcp docker; do
            local v
            v=$(jq -r ".defaults.$k | type" "$file")
            [ "$v" = "boolean" ] || errs+=("defaults.$k must be boolean (got $v)")
        done
    fi

    # XOR: foundation.skills.drop and foundation.skills.keep are mutually
    # exclusive. A preset may declare at most one of the two.
    local has_drop has_keep
    has_drop=$(jq -r 'if .foundation.skills | has("drop") then "yes" else "no" end' "$file")
    has_keep=$(jq -r 'if .foundation.skills | has("keep") then "yes" else "no" end' "$file")
    if [ "$has_drop" = "yes" ] && [ "$has_keep" = "yes" ]; then
        errs+=("foundation.skills.drop and foundation.skills.keep are mutually exclusive — use one or the other, not both")
    fi

    if [ "$has_drop" = "yes" ]; then
        local t
        t=$(jq -r '.foundation.skills.drop | type' "$file")
        [ "$t" = "array" ] || errs+=("foundation.skills.drop must be an array")
    fi

    # foundation.skills.keep: if present, must be a non-empty array of strings.
    if [ "$has_keep" = "yes" ]; then
        local kt klen
        kt=$(jq -r '.foundation.skills.keep | type' "$file")
        if [ "$kt" != "array" ]; then
            errs+=("foundation.skills.keep must be an array")
        else
            klen=$(jq -r '.foundation.skills.keep | length' "$file")
            [ "$klen" -gt 0 ] || errs+=("foundation.skills.keep must be a non-empty array")
            # Each entry must be a non-empty string.
            if [ "$klen" -gt 0 ]; then
                local ki
                for ki in $(seq 0 $((klen - 1))); do
                    local kentry
                    kentry=$(jq -r ".foundation.skills.keep[$ki] | type" "$file")
                    [ "$kentry" = "string" ] || errs+=("foundation.skills.keep[$ki] must be a string")
                done
            fi
        fi
    fi

    # foundation.commands / foundation.agents catalog filters (US-2).
    # The helper echoes E:/W:-prefixed findings; route them to errs/warns.
    local cf_line
    while IFS= read -r cf_line; do
        case "$cf_line" in
            E:*) errs+=("${cf_line#E:}") ;;
            W:*) warns+=("${cf_line#W:}") ;;
            # Fail loud: any unexpected line is surfaced as an error rather than
            # silently swallowed (a validator must never hide output).
            *)   errs+=("internal: unexpected catalog-filter output: $cf_line") ;;
        esac
    done < <(_catalog_filter_findings "$file" commands; _catalog_filter_findings "$file" agents)

    if jq -e '.marketplacePlugins' "$file" >/dev/null 2>&1; then
        local t
        t=$(jq -r '.marketplacePlugins | type' "$file")
        if [ "$t" != "array" ]; then
            errs+=("marketplacePlugins must be an array")
        else
            local n
            n=$(jq -r '.marketplacePlugins | length' "$file")
            # Guard the loop: BSD seq (macOS) iterates `0\n-1` for `seq 0 -1`
            # whereas GNU seq returns empty. Skip when no plugins.
            if [ "$n" -gt 0 ]; then
                local i
                for i in $(seq 0 $((n - 1))); do
                    local pid prat
                    pid=$(jq -r ".marketplacePlugins[$i].id // empty" "$file")
                    prat=$(jq -r ".marketplacePlugins[$i].rationale // empty" "$file")
                    [ -n "$pid" ] || errs+=("marketplacePlugins[$i].id missing")
                    [ -n "$prat" ] || errs+=("marketplacePlugins[$i].rationale missing")
                done
            fi
        fi
    fi

    # detect: optional data-driven detection rule. See
    # specs/presets-detection-and-e2e/spec.md for the schema:
    #   - combinator: "allOf" | "anyOf" (optional, default "anyOf")
    #   - files: array of strings (file names or simple globs), optional
    #   - depFiles: array of {path, contains}, optional
    # Constraint: (files | length) + (depFiles | length) MUST be > 0.
    if jq -e '.detect' "$file" >/dev/null 2>&1; then
        local dt
        dt=$(jq -r '.detect | type' "$file")
        if [ "$dt" != "object" ]; then
            errs+=("detect must be an object")
        else
            local dcomb
            dcomb=$(jq -r '.detect.combinator // "anyOf"' "$file")
            case "$dcomb" in
                allOf|anyOf) ;;
                *) errs+=("detect.combinator '$dcomb' must be 'allOf' or 'anyOf'") ;;
            esac

            local dfiles_n ddeps_n
            dfiles_n=$(jq -r '(.detect.files // []) | length' "$file")
            ddeps_n=$(jq -r '(.detect.depFiles // []) | length' "$file")

            if [ "$dfiles_n" = "0" ] && [ "$ddeps_n" = "0" ]; then
                errs+=("detect must declare at least one signal (files or depFiles)")
            fi

            # Each files[i] must be a non-empty string.
            if [ "$dfiles_n" -gt 0 ]; then
                local idx
                for idx in $(seq 0 $((dfiles_n - 1))); do
                    local fname
                    fname=$(jq -r ".detect.files[$idx] // empty" "$file")
                    [ -n "$fname" ] || errs+=("detect.files[$idx] must be a non-empty string")
                done
            fi

            # Each depFiles[i] must have non-empty path and contains.
            if [ "$ddeps_n" -gt 0 ]; then
                local di
                for di in $(seq 0 $((ddeps_n - 1))); do
                    local dpath dcontains
                    dpath=$(jq -r ".detect.depFiles[$di].path // empty" "$file")
                    dcontains=$(jq -r ".detect.depFiles[$di].contains // empty" "$file")
                    [ -n "$dpath" ] || errs+=("detect.depFiles[$di].path missing")
                    [ -n "$dcontains" ] || errs+=("detect.depFiles[$di].contains missing")
                done
            fi
        fi
    fi

    # recommendedVendorSkills: optional; if present, must be an array; each
    # entry must have id, url, rationale, condition.
    if jq -e '.recommendedVendorSkills' "$file" >/dev/null 2>&1; then
        local t
        t=$(jq -r '.recommendedVendorSkills | type' "$file")
        if [ "$t" != "array" ]; then
            errs+=("recommendedVendorSkills must be an array")
        else
            local n
            n=$(jq -r '.recommendedVendorSkills | length' "$file")
            if [ "$n" -gt 0 ]; then
                local i
                for i in $(seq 0 $((n - 1))); do
                    local rid rurl rrat rcond
                    rid=$(jq -r ".recommendedVendorSkills[$i].id // empty" "$file")
                    rurl=$(jq -r ".recommendedVendorSkills[$i].url // empty" "$file")
                    rrat=$(jq -r ".recommendedVendorSkills[$i].rationale // empty" "$file")
                    rcond=$(jq -r ".recommendedVendorSkills[$i].condition // empty" "$file")
                    [ -n "$rid" ] || errs+=("recommendedVendorSkills[$i].id missing")
                    [ -n "$rurl" ] || errs+=("recommendedVendorSkills[$i].url missing")
                    [ -n "$rrat" ] || errs+=("recommendedVendorSkills[$i].rationale missing")
                    [ -n "$rcond" ] || errs+=("recommendedVendorSkills[$i].condition missing")

                    # Curation-engine fields (specs/marketplace-curation-engine,
                    # Slice 1): every recommendation is pinned, trust-tracked,
                    # provenance-disclosed and dated.
                    local rpin rtrack rprov rverif
                    rpin=$(jq -r ".recommendedVendorSkills[$i].pinnedRef // empty" "$file")
                    rtrack=$(jq -r ".recommendedVendorSkills[$i].trustTrack // empty" "$file")
                    rprov=$(jq -r ".recommendedVendorSkills[$i].provenance // empty" "$file")
                    rverif=$(jq -r ".recommendedVendorSkills[$i].lastVerified // empty" "$file")
                    # EF-005: pinned to an immutable tag/SHA — no floating refs.
                    if [ -z "$rpin" ]; then
                        errs+=("recommendedVendorSkills[$i].pinnedRef missing (EF-005: pin to a tag or commit SHA)")
                    elif _is_floating_ref "$rpin"; then
                        errs+=("recommendedVendorSkills[$i].pinnedRef '$rpin' is a floating ref — pin to a tag or commit SHA (EF-005)")
                    fi
                    # EF-003: two trust tracks.
                    case "$rtrack" in
                        authority|community) ;;
                        "") errs+=("recommendedVendorSkills[$i].trustTrack missing (EF-003: authority|community)") ;;
                        *) errs+=("recommendedVendorSkills[$i].trustTrack '$rtrack' must be 'authority' or 'community' (EF-003)") ;;
                    esac
                    # EF-008: publisher provenance disclosed.
                    [ -n "$rprov" ] || errs+=("recommendedVendorSkills[$i].provenance missing (EF-008)")
                    # lastVerified ISO date (YYYY-MM-DD).
                    if [ -z "$rverif" ]; then
                        errs+=("recommendedVendorSkills[$i].lastVerified missing")
                    elif ! _is_iso_date "$rverif"; then
                        errs+=("recommendedVendorSkills[$i].lastVerified '$rverif' must be an ISO date (YYYY-MM-DD)")
                    fi
                done
            fi
        fi
    fi

    # ------------------------------------------------------------------
    # vendor-pointer tier rules
    # spec: specs/presets-vendor-pointer-tier/spec.md
    # ------------------------------------------------------------------
    if [ "$status" = "vendor-pointer" ]; then
        # EF-003: recommendedVendorSkills MUST be present, non-empty
        local vp_vendors_n
        vp_vendors_n=$(jq -r '.recommendedVendorSkills // [] | length' "$file")
        [ "$vp_vendors_n" -ge 1 ] || errs+=("vendor-pointer preset requires recommendedVendorSkills[] with >=1 entry (EF-003)")

        # EF-004: marketplacePlugins MUST be absent or empty
        local vp_mp_n
        vp_mp_n=$(jq -r '.marketplacePlugins // [] | length' "$file")
        [ "$vp_mp_n" -eq 0 ] || errs+=("vendor-pointer preset MUST NOT declare marketplacePlugins (EF-004)")

        # EF-004: foundation.skills.keep/drop MUST be absent or empty
        local vp_keep_n vp_drop_n
        vp_keep_n=$(jq -r '.foundation.skills.keep // [] | length' "$file")
        [ "$vp_keep_n" -eq 0 ] || errs+=("vendor-pointer preset MUST NOT declare foundation.skills.keep (EF-004)")
        vp_drop_n=$(jq -r '.foundation.skills.drop // [] | length' "$file")
        [ "$vp_drop_n" -eq 0 ] || errs+=("vendor-pointer preset MUST NOT declare foundation.skills.drop (EF-004)")

        # EF-105 tier rule: command/agent filters are likewise forbidden — a
        # vendor-pointer preset inherits the full foundation catalog.
        local vp_cat vp_m vp_n
        for vp_cat in commands agents; do
            for vp_m in keep drop; do
                vp_n=$(jq -r "(.foundation.${vp_cat}.${vp_m})? // [] | length" "$file")
                [ "$vp_n" -eq 0 ] || errs+=("vendor-pointer preset MUST NOT declare foundation.${vp_cat}.${vp_m} (EF-105 tier rule)")
            done
        done

        # EF-004: defaults MUST be absent (foundation defaults inherited)
        local vp_has_defaults
        vp_has_defaults=$(jq -r 'if has("defaults") then "yes" else "no" end' "$file")
        [ "$vp_has_defaults" = "no" ] || errs+=("vendor-pointer preset MUST NOT declare defaults (EF-004)")

        # EF-005: detect MUST contain exactly 1 signal entry
        #   (files[1] XOR depFiles[1])
        local vp_files_n vp_deps_n vp_total
        vp_files_n=$(jq -r '.detect.files // [] | length' "$file")
        vp_deps_n=$(jq -r '.detect.depFiles // [] | length' "$file")
        vp_total=$((vp_files_n + vp_deps_n))
        [ "$vp_total" -eq 1 ] || errs+=("vendor-pointer preset detect MUST contain exactly 1 signal entry (got $vp_total: files=$vp_files_n + depFiles=$vp_deps_n) (EF-005)")
    fi

    # ------------------------------------------------------------------
    # defaultModules[] — US-5 (EF-210)
    # Optional array of known module names (biz, legal, growth).
    # - If present, must be an array.
    # - Each entry must be a known module name (from scripts/lib/modules/).
    # - MUST NOT appear on vendor-pointer tier (EF-210).
    # ------------------------------------------------------------------
    if jq -e '.defaultModules' "$file" >/dev/null 2>&1; then
        # EF-210: forbidden on vendor-pointer tier
        if [ "$status" = "vendor-pointer" ]; then
            errs+=("vendor-pointer preset MUST NOT declare defaultModules (EF-210)")
        fi

        local dm_type
        dm_type=$(jq -r '.defaultModules | type' "$file")
        if [ "$dm_type" != "array" ]; then
            errs+=("defaultModules must be an array (got $dm_type)")
        else
            local dm_n
            dm_n=$(jq -r '.defaultModules | length' "$file")
            if [ "$dm_n" -gt 0 ]; then
                local di dmval
                for di in $(seq 0 $((dm_n - 1))); do
                    dmval=$(jq -r ".defaultModules[$di]" "$file")
                    # module_exists (lib/modules.sh) is the single source
                    # of truth: [a-z0-9-] syntax guard (rejects
                    # traversal-shaped names like './biz') + bundle file
                    # existence.
                    if ! module_exists "$dmval"; then
                        errs+=("defaultModules[$di] '$dmval' is not a known module name")
                    fi
                done
                # Duplicates would flow verbatim into foundation.json
                # (write_foundation_manifest does not dedup).
                local dm_dups
                dm_dups=$(jq -r '.defaultModules | group_by(.) | map(select(length > 1) | .[0]) | join(", ")' "$file")
                if [ -n "$dm_dups" ]; then
                    errs+=("defaultModules contains duplicate entries: $dm_dups")
                fi
            fi
        fi
    fi

    # ------------------------------------------------------------------
    # categories[] strict-enum validation
    # spec: specs/preset-category-prompt/spec.md EF-006
    # When present, each entry MUST be one of the 8 locked slugs.
    # Empty array is allowed (treated as field-absent).
    # ------------------------------------------------------------------
    if jq -e '.categories' "$file" >/dev/null 2>&1; then
        local cat_type
        cat_type=$(jq -r '.categories | type' "$file")
        if [ "$cat_type" != "array" ]; then
            errs+=("categories must be an array (got $cat_type)")
        else
            local cat_n
            cat_n=$(jq -r '.categories | length' "$file")
            # Guard: empty array → skip the loop (treated as field-absent).
            # Required for macOS BSD seq compatibility (GNU `seq 0 -1` is
            # empty, BSD `seq 0 -1` outputs "0\n-1" — would iterate and
            # falsely reject the empty-array case).
            if [ "$cat_n" -gt 0 ]; then
                local ci cval
                for ci in $(seq 0 $((cat_n - 1))); do
                    cval=$(jq -r ".categories[$ci]" "$file")
                    if ! echo "$ALLOWED_CATEGORIES" | jq -e ". | index(\"$cval\")" >/dev/null 2>&1; then
                        errs+=("categories[$ci] '$cval' not in $ALLOWED_CATEGORIES (EF-006)")
                    fi
                done
            fi
        fi
    fi

    # Non-fatal warnings (e.g. unknown command/agent names) — surfaced but
    # never flip the exit status.
    if [ "${#warns[@]}" -gt 0 ]; then
        echo "[WARN]  $rel"
        local w
        for w in "${warns[@]}"; do
            echo "        - $w"
        done
    fi

    if [ "${#errs[@]}" -eq 0 ]; then
        $QUIET || echo "[OK]    $rel"
        return 0
    else
        echo "[FAIL]  $rel"
        for e in "${errs[@]}"; do
            echo "        - $e"
        done
        return 1
    fi
}

# validate_registry <file> — validate a .claude/curation/registry.json
# canonicalVendor registry (specs/marketplace-curation-engine, EF-001). Each
# record names a graduatable foundation skill and its pinned, trust-tracked,
# provenance-disclosed canonical vendor.
validate_registry() {
    local file="$1"
    local rel; rel="$(basename "$file")"
    local errs=()

    if ! jq empty "$file" >/dev/null 2>&1; then
        echo "[FAIL]  $rel"
        echo "        - invalid JSON syntax"
        return 1
    fi

    if [ "$(jq -r '.records | type' "$file" 2>/dev/null)" != "array" ]; then
        echo "[FAIL]  $rel"
        echo "        - records must be an array"
        return 1
    fi

    local n; n=$(jq -r '.records | length' "$file")
    if [ "$n" -gt 0 ]; then
        local i
        for i in $(seq 0 $((n - 1))); do
            local fs vid vurl pin track verdict prov neut verif st
            fs=$(jq -r ".records[$i].foundationSkill // empty" "$file")
            vid=$(jq -r ".records[$i].vendorId // empty" "$file")
            vurl=$(jq -r ".records[$i].vendorUrl // empty" "$file")
            pin=$(jq -r ".records[$i].pinnedRef // empty" "$file")
            track=$(jq -r ".records[$i].trustTrack // empty" "$file")
            verdict=$(jq -r ".records[$i].trustVerdict // empty" "$file")
            prov=$(jq -r ".records[$i].provenance // empty" "$file")
            neut=$(jq -r ".records[$i].adviceNeutrality // empty" "$file")
            verif=$(jq -r ".records[$i].lastVerified // empty" "$file")
            st=$(jq -r ".records[$i].status // empty" "$file")

            [ -n "$fs" ] || errs+=("records[$i].foundationSkill missing")
            [ -n "$vid" ] || errs+=("records[$i].vendorId missing")
            [ -n "$vurl" ] || errs+=("records[$i].vendorUrl missing")
            if [ -z "$pin" ]; then
                errs+=("records[$i].pinnedRef missing (EF-005)")
            elif _is_floating_ref "$pin"; then
                errs+=("records[$i].pinnedRef '$pin' is a floating ref — pin to a tag or commit SHA (EF-005)")
            fi
            case "$track" in
                authority|community) ;;
                "") errs+=("records[$i].trustTrack missing (EF-003)") ;;
                *) errs+=("records[$i].trustTrack '$track' must be 'authority' or 'community' (EF-003)") ;;
            esac
            case "$verdict" in
                pass|flag|fail) ;;
                "") errs+=("records[$i].trustVerdict missing") ;;
                *) errs+=("records[$i].trustVerdict '$verdict' must be 'pass', 'flag' or 'fail'") ;;
            esac
            [ -n "$prov" ] || errs+=("records[$i].provenance missing (EF-008)")
            case "$neut" in
                pass|flag) ;;
                "") errs+=("records[$i].adviceNeutrality missing (EF-008)") ;;
                *) errs+=("records[$i].adviceNeutrality '$neut' must be 'pass' or 'flag'") ;;
            esac
            if [ -z "$verif" ]; then
                errs+=("records[$i].lastVerified missing")
            elif ! _is_iso_date "$verif"; then
                errs+=("records[$i].lastVerified '$verif' must be an ISO date (YYYY-MM-DD)")
            fi
            case "$st" in
                candidate|graduating|graduated) ;;
                "") errs+=("records[$i].status missing") ;;
                *) errs+=("records[$i].status '$st' must be 'candidate', 'graduating' or 'graduated'") ;;
            esac
        done
    fi

    if [ "${#errs[@]}" -eq 0 ]; then
        $QUIET || echo "[OK]    $rel (registry, $n record(s))"
        return 0
    else
        echo "[FAIL]  $rel"
        local e
        for e in "${errs[@]}"; do
            echo "        - $e"
        done
        return 1
    fi
}

# Registry-only mode (--registry <file>): validate just the registry and exit.
# (--registry + a positional file is already rejected during arg handling.)
if [ -n "$REGISTRY_FILE" ]; then
    if [ ! -f "$REGISTRY_FILE" ]; then
        echo "[ERROR] registry not found: $REGISTRY_FILE" >&2
        exit 2
    fi
    if validate_registry "$REGISTRY_FILE"; then
        echo ""
        $QUIET || echo "[OK] registry valid"
        exit 0
    else
        echo ""
        echo "[FAIL] registry invalid"
        exit 1
    fi
fi

# EF-005 lockstep — a repo tracked in more than one place (registry records
# and/or preset recommendedVendorSkills) must carry a SINGLE pinnedRef
# everywhere. The nightly watcher (scripts/curation-watch.sh) dedups drift
# targets by (repoRoot, pinnedRef); a repo pinned to two different refs
# therefore splits into two permanent, never-clearing drift rows in every
# digest. This guard fails fast on such a divergence so a partial re-pin
# (registry bumped, preset copy forgotten — the exact cause of the #427
# duplicate rows) can never be committed. repoRoot = owner/repo (first two
# path segments), mirroring curation-watch.sh:_repo_root; non-github
# marketplace URLs are skipped (the watcher cannot dedup them either).
validate_pin_lockstep() {
    local registry="$1"; shift
    # reporoot → owner/repo for a github repo (the watcher's dedup key). mktkey →
    # a normalised full marketplace path (scheme/query/fragment/trailing-slash
    # stripped) so a non-github plugin URL (claude.com/plugins/<x>) is a stable
    # key too — the registry (vendorUrl) and a preset copy (url) share it, so a
    # marketplace plugin pinned to divergent refs is caught, without collapsing
    # distinct plugins to a common owner/repo prefix.
    local rr='def reporoot:(sub("^https?://github\\.com/";""))|if test("://") then empty else . end|(split("?")[0])|(split("#")[0])|split("/")|select(length>=2 and (.[0]|length>0) and (.[1]|length>0))|.[0:2]|join("/");def mktkey:(sub("^https?://";""))|(split("?")[0])|(split("#")[0])|sub("/$";"");def is_marketplace:test("^https?://")and(test("github\\.com")|not);'
    local pairs
    pairs=$(
        {
            [ -f "$registry" ] && jq -r "$rr"'.records[]? | .pinnedRef as $p | ([ (.vendorId|reporoot), ((.vendorUrl // .vendorId // "")|select(is_marketplace)|mktkey) ] | unique[]) | "\(.)\t\($p)"' "$registry" 2>/dev/null
            local f
            for f in "$@"; do
                [ -f "$f" ] || continue
                jq -r "$rr"'.recommendedVendorSkills[]? | .pinnedRef as $p | ([ ((.url // .id)|reporoot), ((.url // .id // "")|select(is_marketplace)|mktkey) ] | unique[]) | "\(.)\t\($p)"' "$f" 2>/dev/null
            done
        } | grep -v '^[[:space:]]*$' | sort -u
    )
    local dup_roots
    dup_roots=$(printf '%s\n' "$pairs" | cut -f1 | sort | uniq -d)
    if [ -z "$dup_roots" ]; then
        $QUIET || echo "[OK]    pin lockstep (one ref per repo across registry + presets)"
        return 0
    fi
    echo "[FAIL]  pin lockstep — a repo is pinned to divergent refs (EF-005):"
    local r
    while IFS= read -r r; do
        [ -n "$r" ] || continue
        echo "        - $r pinned to:"
        printf '%s\n' "$pairs" | awk -F'\t' -v root="$r" '$1==root {print "            " $2}'
    done <<< "$dup_roots"
    return 1
}

for f in "${FILES[@]}"; do
    if validate_one "$f"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        errors+=("$f")
    fi
done

# Full-dir run also validates the shipped canonicalVendor registry, when present,
# and enforces registry<->preset pin lockstep across the whole set.
registry_fail=0
lockstep_fail=0
if [ -z "$SINGLE_FILE" ]; then
    DEFAULT_REGISTRY="$BASE_DIR/.claude/curation/registry.json"
    if [ -f "$DEFAULT_REGISTRY" ]; then
        validate_registry "$DEFAULT_REGISTRY" || registry_fail=1
    fi
    validate_pin_lockstep "$DEFAULT_REGISTRY" "${FILES[@]}" || lockstep_fail=1
fi

echo ""
if [ "$fail" -eq 0 ] && [ "$registry_fail" -eq 0 ] && [ "$lockstep_fail" -eq 0 ]; then
    $QUIET || echo "[OK] $pass preset(s) valid"
    exit 0
else
    [ "$fail" -gt 0 ] && echo "[FAIL] $fail preset(s) invalid out of $((pass + fail))"
    [ "$registry_fail" -gt 0 ] && echo "[FAIL] registry invalid"
    [ "$lockstep_fail" -gt 0 ] && echo "[FAIL] pin lockstep violated"
    exit 1
fi
