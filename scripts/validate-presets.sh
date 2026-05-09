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
PRESETS_DIR="$BASE_DIR/.claude/presets"

QUIET=false
SINGLE_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --quiet|-q) QUIET=true; shift ;;
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

if [ -n "$SINGLE_FILE" ]; then
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

ALLOWED_STATUS='["maintainer-vouched","community-curated","draft"]'
ALLOWED_DESIGN_STYLE='["terminal","cockpit","vitality","editorial","glass","signal"]'
NAME_PATTERN='^[a-z][a-z0-9-]*$'

pass=0
fail=0
errors=()

validate_one() {
    local file="$1"
    local rel="${file#"$BASE_DIR/"}"
    local errs=()

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
    [ "$(jq -r '.defaults // empty | type' "$file")" = "object" ] || errs+=("defaults must be an object")
    [ "$(jq -r '.outOfScope // empty | type' "$file")" = "array" ] || errs+=("outOfScope must be an array")

    if [ -n "$name" ] && ! [[ "$name" =~ $NAME_PATTERN ]]; then
        errs+=("name '$name' does not match pattern $NAME_PATTERN")
    fi

    if [ -n "$status" ]; then
        case "$status" in
            maintainer-vouched|community-curated|draft) ;;
            *) errs+=("status '$status' not in $ALLOWED_STATUS") ;;
        esac
    fi

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

    if jq -e '.foundation.skills.drop' "$file" >/dev/null 2>&1; then
        local t
        t=$(jq -r '.foundation.skills.drop | type' "$file")
        [ "$t" = "array" ] || errs+=("foundation.skills.drop must be an array")
    fi

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
                done
            fi
        fi
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

for f in "${FILES[@]}"; do
    if validate_one "$f"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        errors+=("$f")
    fi
done

echo ""
if [ "$fail" -eq 0 ]; then
    $QUIET || echo "[OK] $pass preset(s) valid"
    exit 0
else
    echo "[FAIL] $fail preset(s) invalid out of $((pass + fail))"
    exit 1
fi
