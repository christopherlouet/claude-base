#!/usr/bin/env bats

# =============================================================================
# Security rules of a vendor pointer live in a path-scoped RULE, not in the
# pointer skill.
#
# Measured 2026-10-03 (eval/skill-triggering/FINDINGS.md): with the vendor's own
# skills installed, Supabase's fires alone 3/3 and dev-supabase never loads, so
# its "RLS on every public table" and "never expose the service_role key" never
# reached the session. A rule scoped to the tool's files loads whichever skill
# fires. These guards pin that the rules moved, that the pointers no longer
# carry a second copy that could drift, and that the rules ship.
# Self-application: they run on the real tree, no fixtures.
# =============================================================================

load 'test_helper'

RULES_DIR="$BASE_DIR/.claude/rules"
SKILLS_DIR="$BASE_DIR/.claude/skills"
LIB="$BASE_DIR/scripts/lib/selected-set.sh"

# _paths <rule> — the globs of a rule's leading frontmatter, one per line.
_paths() {
    awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit}
         /^  - / {sub(/^  - /,""); gsub(/"/,""); print}' "$1"
}

@test "prisma rule: scoped to Prisma's files and carries the migration and secret rules" {
    local f="$RULES_DIR/prisma.md"
    [ -f "$f" ]
    run _paths "$f"
    [[ "$output" == *"**/schema.prisma"* ]] || false
    [[ "$output" == *"**/prisma/**"* ]] || false
    # The client module (lib/prisma.ts, server/prisma.ts): where the singleton
    # and the select-over-include rules apply, outside schema and migrations.
    [[ "$output" == *"**/*prisma*"* ]] || false
    grep -q 'prisma migrate deploy' "$f"
    grep -qi 'rename' "$f"
    grep -q 'DATABASE_URL' "$f"
    grep -qi 'select.*include' "$f"
}

@test "supabase rule: scoped to Supabase's files and carries RLS and the service_role key" {
    local f="$RULES_DIR/supabase.md"
    [ -f "$f" ]
    run _paths "$f"
    [[ "$output" == *"**/supabase/**"* ]] || false
    [[ "$output" == *"**/*supabase*"* ]] || false
    grep -qi 'row level security' "$f"
    grep -q 'service_role' "$f"
    grep -qi 'client-side' "$f"
}

@test "pointers: point at their rule and no longer carry a copy of it" {
    local s
    for s in prisma supabase; do
        local f="$SKILLS_DIR/dev-$s/SKILL.md"
        grep -q "\.claude/rules/$s\.md" "$f" \
            || { echo "dev-$s does not point at .claude/rules/$s.md" >&2; false; }
        ! grep -q '^## Foundation rules preserved' "$f" \
            || { echo "dev-$s still carries its own copy of the rules" >&2; false; }
    done
    # `run` + status, not a bare `! grep`: a negated command never trips bats'
    # errexit, so anywhere but the last line it asserts nothing.
    run grep -q 'NEVER expose the' "$SKILLS_DIR/dev-supabase/SKILL.md"
    [ "$status" -ne 0 ]
    run grep -q 'prisma migrate deploy' "$SKILLS_DIR/dev-prisma/SKILL.md"
    [ "$status" -ne 0 ]
}

@test "selection: every JS/TS type ships both rules" {
    local t
    for t in react node-api fullstack generic vue svelte astro ""; do
        run bash -c ". '$LIB'; get_rules_for_type '$t'"
        [ "$status" -eq 0 ]
        [[ "$output" == *"prisma.md"* ]] || { echo "type '$t' lacks prisma.md" >&2; false; }
        [[ "$output" == *"supabase.md"* ]] || { echo "type '$t' lacks supabase.md" >&2; false; }
    done
}

@test "selection: python and flutter ship the Supabase rule, not the Prisma one" {
    # Supabase backs Python APIs (the fastapi preset) and Flutter apps
    # (supabase_flutter; dev-flutter points at dev-supabase). Prisma is JS/TS only.
    local t
    for t in python flutter; do
        run bash -c ". '$LIB'; get_rules_for_type $t"
        [ "$status" -eq 0 ]
        [[ "$output" == *"supabase.md"* ]] || { echo "type '$t' lacks supabase.md" >&2; false; }
        [[ "$output" != *"prisma.md"* ]] || { echo "type '$t' ships prisma.md" >&2; false; }
    done
}
