#!/usr/bin/env bats

# =============================================================================
# Tests for Docusaurus rendering correctness in Markdown sources.
#
# Docusaurus / MDX strips HTML comments outside fenced code blocks — but
# leaves them as literal text INSIDE code fences (```...``` and ```mermaid).
# When the `inject-counts-md` regen pipeline writes a count marker
# `<!-- count:KEY -->NNN<!-- /count -->` inside a code fence, the user sees
# the raw markers in the rendered page instead of just the number.
#
# This file gates against that regression. Currently 1 test ; add new tests
# here for any rendering-correctness invariant tied to Docusaurus / MDX
# parsing behaviour.
# =============================================================================

load 'test_helper'

@test "no count markers leak into fenced code blocks in website/docs/ or repo-root markdown" {
    # Scan every .md under the project except node_modules, .docusaurus build
    # artifacts, and CHANGELOG (which legitimately quotes historical markers).
    local count
    count=$(python3 <<'PY'
import os, sys

ROOT = os.environ.get('BATS_TEST_DIRNAME', '.') + '/..'
EXCLUDE_DIRS = {'node_modules', '.docusaurus', '.git', 'build'}
EXCLUDE_FILES = {'CHANGELOG.md'}  # historical records

issues = []
for dirpath, dirnames, files in os.walk(ROOT):
    dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
    for f in files:
        if not f.endswith('.md') or f in EXCLUDE_FILES:
            continue
        path = os.path.join(dirpath, f)
        try:
            with open(path, encoding='utf-8') as fh:
                in_fence = False
                for i, line in enumerate(fh, 1):
                    stripped = line.lstrip()
                    if stripped.startswith('```'):
                        in_fence = not in_fence
                        continue
                    if in_fence and '<!-- count:' in line:
                        rel = os.path.relpath(path, ROOT)
                        issues.append(f'{rel}:{i}: {line.rstrip()[:120]}')
        except (UnicodeDecodeError, OSError):
            pass

for x in issues:
    print(x, file=sys.stderr)
print(len(issues))
PY
)
    if [[ "$count" != "0" ]]; then
        echo "ERROR: $count count marker(s) found inside fenced code blocks" >&2
        echo "These render as literal text in Docusaurus (HTML comments are NOT" >&2
        echo "stripped inside code fences). Replace with the bare numeric value." >&2
        return 1
    fi
}

# =============================================================================
# 2026-07-12 drift guard — the hand-maintained website/docs/concepts/ pages have
# no generator and drifted into fiction (wrong agent models, fictional skill
# names, an "enabled" MCP flag that does not exist). These tests pin the facts
# against the real inventory so the pages cannot silently rot again.
# =============================================================================

@test "concepts/agents.md: every model-table row matches the agent's real frontmatter model" {
    run python3 - "$BATS_TEST_DIRNAME/.." <<'PY'
import os, re, sys, glob
root = sys.argv[1]
page = os.path.join(root, "website/docs/concepts/agents.md")
bad = []
row = re.compile(r'^\|\s*`([a-z][a-z0-9-]+)`\s*\|\s*(haiku|sonnet|opus)\s*\|')
for line in open(page, encoding="utf-8"):
    m = row.match(line)
    if not m:
        continue
    agent, claimed = m.group(1), m.group(2)
    matches = glob.glob(os.path.join(root, ".claude/agents", "**", agent + ".md"), recursive=True)
    if not matches:
        bad.append(f"{agent}: PHANTOM (no .claude/agents/{agent}.md)")
        continue
    real = None
    for ln in open(matches[0], encoding="utf-8"):
        mm = re.match(r'^model:\s*(\S+)', ln)
        if mm:
            real = mm.group(1)
            break
    if real != claimed:
        bad.append(f"{agent}: page says {claimed}, frontmatter says {real}")
if bad:
    print("\n".join(bad)); sys.exit(1)
print("OK")
PY
    [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "concepts/: no fictional (gerund) skill names survive" {
    # These names never existed as skills; each maps to a real skill instead.
    local fiction='reviewing-code|generating-commit-messages|creating-pull-requests|exploring-codebase|test-driven-development|debugging-issues|docker-containerization|ci-cd-pipeline|infrastructure-as-code|monitoring-instrumentation|dev-test'
    # Exclude external URLs — an O'Reilly book title legitimately contains
    # "test-driven-development"; only real skill-name uses should match.
    run bash -c "grep -rnE '$fiction' '$BATS_TEST_DIRNAME/../website/docs/concepts/' | grep -v 'https\\?://' || true"
    [ -z "$output" ] || { echo "fictional skill/agent token found:"; echo "$output"; false; }
}

@test "concepts/mcp-servers.md: no non-existent \"enabled\" flag in config examples" {
    # The real mechanism is copy-the-block; there is no per-server enabled flag.
    # Match only a JSON config line (indent + key at line start), NOT prose that
    # explains the flag's absence ("there is no \"enabled\": false toggle").
    run grep -nE '^[[:space:]]*"enabled"[[:space:]]*:' "$BATS_TEST_DIRNAME/../website/docs/concepts/mcp-servers.md"
    [ "$status" -eq 1 ] || { echo "stray enabled config flag:"; echo "$output"; false; }
}

@test "concepts/advanced-features.md: effort levels use xhigh, not max" {
    run grep -nE '/effort[[:space:]]+max|\bmax\b.*effort' "$BATS_TEST_DIRNAME/../website/docs/concepts/advanced-features.md"
    [ "$status" -eq 1 ] || { echo "effort 'max' should be 'xhigh':"; echo "$output"; false; }
}
