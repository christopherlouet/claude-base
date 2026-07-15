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
# worktrees/memory: a parallel-agent checkout under .claude/worktrees/ (or a
# session memory dir) re-exposes the false-fail class validate-counts.sh
# already excludes — this scan must skip them for the same reason.
EXCLUDE_DIRS = {'node_modules', '.docusaurus', '.git', 'build', 'worktrees', 'memory'}
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

# =============================================================================
# 2026-07-13 drift guard — website/docs/guides/learning-path.md is also
# hand-maintained (no docs/ source) and exhibits the same rot class as the
# concepts pages: model attributions that drifted from the real frontmatter,
# fictional skill names, a non-existent per-server "enabled" flag for
# .mcp.json, and CLI flags that never existed. Pin those facts here.
# =============================================================================

@test "learning-path.md: every model attribution matches the real agent frontmatter" {
    run python3 - "$BATS_TEST_DIRNAME/.." <<'PY'
import os, re, sys, glob
root = sys.argv[1]
page = os.path.join(root, "website/docs/guides/learning-path.md")
lines = open(page, encoding="utf-8").read().splitlines()

def real_model(agent):
    matches = glob.glob(os.path.join(root, ".claude/agents", "**", agent + ".md"), recursive=True)
    if not matches:
        return None
    for ln in open(matches[0], encoding="utf-8"):
        mm = re.match(r'^model:\s*(\S+)', ln)
        if mm:
            return mm.group(1)
    return None

bad = []

# 1. YAML frontmatter examples (```yaml blocks with `name:` + `model:` pairs).
name = None
for i, line in enumerate(lines, 1):
    mn = re.match(r'^name:\s*([a-z][a-z0-9-]+)\s*$', line)
    if mn:
        name = mn.group(1)
        continue
    mm = re.match(r'^model:\s*(haiku|sonnet|opus)\s*$', line)
    if mm and name:
        real = real_model(name)
        if real is not None and real != mm.group(1):
            bad.append(f"line {i}: yaml example `{name}`: page says {mm.group(1)}, frontmatter says {real}")
        name = None

# 2. ASCII diagrams: "[<agent> agent - ..." header followed by "- Model: X".
agent = None
for i, line in enumerate(lines, 1):
    mh = re.search(r'\[([a-z][a-z0-9-]+) agent\b', line)
    if mh:
        agent = mh.group(1)
        continue
    mm = re.match(r'^\s*-?\s*Model:\s*(haiku|sonnet|opus)\b', line)
    if mm and agent:
        real = real_model(agent)
        if real is not None and real != mm.group(1):
            bad.append(f"line {i}: diagram for `{agent}`: page says {mm.group(1)}, frontmatter says {real}")
        agent = None

# 3. Command tables with a trailing model column: `| \`/dom:cmd\` | ... | model |`.
#    A model may only be claimed when a real agent file exists AND agrees;
#    commands without an agent file must not claim haiku/sonnet/opus.
row = re.compile(r'^\|\s*`/([a-z]+):([a-z0-9-]+)`\s*\|.*\|\s*(haiku|sonnet|opus)\s*\|\s*$')
for i, line in enumerate(lines, 1):
    m = row.match(line)
    if not m:
        continue
    cmd, claimed = m.group(2), m.group(3)
    real = real_model(cmd)
    if real is None:
        bad.append(f"line {i}: `{cmd}`: model column claims {claimed} but no agent file exists")
    elif real != claimed:
        bad.append(f"line {i}: `{cmd}`: page says {claimed}, frontmatter says {real}")

if bad:
    print("\n".join(bad)); sys.exit(1)
print("OK")
PY
    [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "learning-path.md: no fictional skill names survive" {
    # Same fiction list as the concepts/ guard, plus every name a skill table
    # could invent. Each maps to a real skill/command (dev-tdd, work-commit,
    # work-pr, dev-debug, qa-security, work-explore, ops-docker...).
    local fiction='reviewing-code|generating-commit-messages|creating-pull-requests|exploring-codebase|test-driven-development|debugging-issues|docker-containerization|security-audit|ci-cd-pipeline|infrastructure-as-code|monitoring-instrumentation|dev-test\b'
    # Exclude external URLs — book titles legitimately contain such tokens.
    run bash -c "grep -nE '$fiction' '$BATS_TEST_DIRNAME/../website/docs/guides/learning-path.md' | grep -v 'https\\?://' || true"
    [ -z "$output" ] || { echo "fictional skill/agent token found:"; echo "$output"; false; }
}

@test "learning-path.md: every skill named in the skills-to-know table exists" {
    run python3 - "$BATS_TEST_DIRNAME/.." <<'PY'
import os, re, sys
root = sys.argv[1]
page = os.path.join(root, "website/docs/guides/learning-path.md")
lines = open(page, encoding="utf-8").read().splitlines()
bad, in_table = [], False
for i, line in enumerate(lines, 1):
    if "skills to know" in line:
        in_table = True
        continue
    if in_table:
        m = re.match(r'^\|\s*`([a-z][a-z0-9-]+)`\s*\|', line)
        if m:
            name = m.group(1)
            exists = any(
                os.path.exists(p) for p in (
                    os.path.join(root, ".claude/skills", name, "SKILL.md"),
                    os.path.join(root, ".claude/agents", name + ".md"),
                )
            ) or bool(__import__("glob").glob(
                os.path.join(root, ".claude/commands", "**", name + ".md"),
                recursive=True))
            if not exists:
                bad.append(f"line {i}: `{name}` is not a real skill/agent/command")
        elif line.strip() and not line.strip().startswith("|"):
            in_table = False
if bad:
    print("\n".join(bad)); sys.exit(1)
print("OK")
PY
    [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "learning-path.md: no non-existent \"enabled\" flag taught for .mcp.json" {
    # The real contract: .mcp.json ships empty; a server is active iff its
    # block is present (copied from .mcp.json.example). There is no per-server
    # enabled flag. Prose explaining the flag's ABSENCE is fine; teaching
    # `"enabled": true/false` is not.
    run grep -nE '"enabled"[[:space:]]*:[[:space:]]*(true|false)' "$BATS_TEST_DIRNAME/../website/docs/guides/learning-path.md"
    [ "$status" -eq 1 ] || { echo "non-existent .mcp.json enabled flag taught:"; echo "$output"; false; }
}

@test "learning-path.md: claude-base validate flags are --json/--score, not --format" {
    run grep -nE 'validate[^|]*--format' "$BATS_TEST_DIRNAME/../website/docs/guides/learning-path.md"
    [ "$status" -eq 1 ] || { echo "claude-base validate has no --format flag (use --json / --score):"; echo "$output"; false; }
}
