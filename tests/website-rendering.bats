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
