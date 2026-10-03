#!/usr/bin/env bats

# =============================================================================
# Facts about third-party tools that were measured dead, and must not come back.
#
# The 2026-10-03 supply audit (each fact checked against the tool's own repo,
# registry or source) found the foundation teaching tools and flags that no
# longer exist. This is NOT a staleness detector — it cannot see the next dead
# API. It pins the ones already found, each with the measurement that killed it,
# so a copy-paste from an old example cannot quietly restore them.
# Scope: what ships and what the docs teach (.claude/, docs/). History records
# (CHANGELOG, specs/, eval findings) may still name them.
# =============================================================================

load 'test_helper'

# pattern<TAB>why it is dead. Fixed strings (grep -F).
DEAD_FACTS="FID <	INP replaced FID as a Core Web Vital in March 2024
FID/INP	INP replaced FID as a Core Web Vital in March 2024
| FID |	INP replaced FID as a Core Web Vital in March 2024
create-lucia	never published on npm; Lucia itself was deprecated in March 2025
Lucia v3	Lucia was deprecated in March 2025 (lucia-auth/lucia README)
wkhtmltopdf	wkhtmltopdf/wkhtmltopdf is archived
markdown-pdf	unmaintained; use pandoc or a headless browser
schedule_interval	removed in Airflow 3 (use schedule)
airflow.operators.python	moved to airflow.providers.standard in Airflow 3
npm install -g firecrawl 	the CLI package is firecrawl-cli
firecrawl extract	the Firecrawl CLI has no extract command (agent replaced it)
no vendor-published Cypress skill	cypress-io/ai-toolkit ships Cypress skills (v1.4.0)
Playwright remains MIT	microsoft/playwright is Apache-2.0
GOOGLE_PLAY_JSON_KEY	fastlane supply reads SUPPLY_JSON_KEY_DATA
APP_STORE_CONNECT_API_KEY:	fastlane reads APP_STORE_CONNECT_API_KEY_KEY_ID / _ISSUER_ID / _KEY"

# _scan DIR... — print every dead fact found under the dirs, with its reason.
_scan() {
    local pattern why found
    while IFS='	' read -r pattern why; do
        [ -n "$pattern" ] || continue
        found=$(grep -rnF -- "$pattern" "$@" 2>/dev/null || true)
        [ -z "$found" ] || printf '[%s]\n%s\n' "$why" "$found"
    done <<EOF
$DEAD_FACTS
EOF
}

@test "no dead third-party fact ships in .claude/ or docs/" {
    run _scan "$BASE_DIR/.claude" "$BASE_DIR/docs"
    [ -z "$output" ] || { echo "dead facts found:" >&2; echo "$output" >&2; false; }
}

@test "the scan is not vacuous: it reports a planted dead fact, with its reason" {
    mkdir -p "$BATS_TEST_TMPDIR/tree"
    printf 'with DAG(schedule_interval="@daily"):\n' > "$BATS_TEST_TMPDIR/tree/dag.md"
    run _scan "$BATS_TEST_TMPDIR/tree"
    [[ "$output" == *"removed in Airflow 3"* ]] || false
    [[ "$output" == *"dag.md:1:"* ]] || false
}
