#!/usr/bin/env bash
# =============================================================================
# substance-check.sh — static "substance gate" (anti-hollow-test / anti-stub).
#
# Flags work that satisfies "tests exist and pass" + coverage % while proving
# nothing: hollow tests (no assertion / always-true / skipped / empty) and stub
# implementations. ADVISORY + deterministic + offline (no execution, no network,
# no model). The next step in the anti-gaming-of-quality-gates thread.
#
# A finding prints to stdout as:   path:line: <kind>: <hint>
#   kinds: no-assertion | always-true | skipped | empty | stub
# Exit: 0 ALWAYS in advisory mode (findings are data, not failures); 2 on usage.
#
# FAIL-SAFE (EF-007): an unknown language, an unrecognized file, or any parse
# ambiguity yields NO finding — favour a false-negative over a false-positive.
# The hardest constraint (EF-008): ZERO findings on the foundation's own suite.
#
# Usage: substance-check.sh [--tests-only|--code-only] [--quiet] [paths…]
#   paths default to "." ; dirs are scanned recursively for supported files.
# =============================================================================

set -euo pipefail

MODE=both          # both | tests | code
QUIET=0
PATHS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --tests-only) MODE=tests; shift ;;
        --code-only)  MODE=code; shift ;;
        --quiet)      QUIET=1; shift ;;
        -h|--help)
            sed -nE 's/^# ?//p' "$0" | sed -nE '/^substance-check/,/^Usage/p'; exit 0 ;;
        --) shift; while [ $# -gt 0 ]; do PATHS+=("$1"); shift; done ;;
        -*) echo "substance-check: unknown option: $1" >&2; exit 2 ;;
        *)  PATHS+=("$1"); shift ;;
    esac
done
[ "${#PATHS[@]}" -gt 0 ] || PATHS=(".")

# ---------------------------------------------------------------------------
# Scanners (one awk per language). Each prints `file:line: kind: hint` lines.
# ---------------------------------------------------------------------------

# Bats hollow-test scanner (state machine). A bats @test is HOLLOW when every
# meaningful body line is INERT — i.e. cannot fail the test: `run …` (captures
# status, never fails), echo/printf, assignments, load/source, comments. In bats
# ANY other bare command (`[ … ]`, `jq …`, `grep …`, a helper call) fails the
# test on non-zero exit, so it counts as a real check — we favour NOT flagging.
# Heredoc bodies are skipped (a test file may embed `@test` snippets in a heredoc).
# Bats `skip` is NOT flagged in v1: it is overwhelmingly a legitimate conditional
# env-guard in real suites (`skip_if_no_jq`, `if root; then skip`); flagging it
# would break the zero-false-positive constraint. JS/Py/Go skip detection (Phase 2)
# handles genuine disables.
_scan_bats() {
    local f="$1"
    awk -v file="$f" '
        function flush(   i, line, meaningful, allInert) {
            if (!inblock) return
            meaningful=0; allInert=1
            for (i=0;i<n;i++) {
                line=body[i]
                if (line ~ /^[[:space:]]*#/) continue
                if (line ~ /^[[:space:]]*$/) continue
                if (line ~ /^[[:space:]]*[}][[:space:]]*$/) continue
                meaningful++
                # INERT = a line that cannot make the test fail / assert nothing.
                if (line !~ /^[[:space:]]*(run([[:space:]]|$)|echo([[:space:]]|$)|printf([[:space:]]|$)|load([[:space:]]|$)|source([[:space:]]|$)|sleep([[:space:]]|$)|cd([[:space:]]|$)|true([[:space:]]|$)|:([[:space:]]|$)|export[[:space:]]|local[[:space:]]|declare[[:space:]]|readonly[[:space:]]|[A-Za-z_][A-Za-z0-9_]*=)/)
                    allInert=0
            }
            if (meaningful==0)
                printf "%s:%d: empty: empty test body\n", file, startline
            else if (allInert)
                printf "%s:%d: no-assertion: runs code but asserts nothing\n", file, startline
            inblock=0; n=0
        }
        {
            # Skip heredoc bodies entirely (brace/@test inside data must not count).
            if (inheredoc) { if ($0 ~ hend) inheredoc=0; next }
            tmp=$0; o=gsub(/[{]/,"",tmp); tmp=$0; c=gsub(/[}]/,"",tmp)
            startsheredoc=0
            if (match($0, /<<-?["'"'"']?[A-Za-z_][A-Za-z0-9_]*/)) {
                hm=substr($0, RSTART, RLENGTH); gsub(/[<\-"'"'"']/,"",hm)
                hend="^[[:space:]]*" hm "[[:space:]]*$"; startsheredoc=1
            }
        }
        /^[[:space:]]*@test/ && !inblock {
            flush(); inblock=1; startline=NR; n=0; depth=o-c
            if (startsheredoc) inheredoc=1
            next
        }
        inblock {
            depth += o-c
            body[n++]=$0
            if (depth<=0) { flush() }
            else if (startsheredoc) inheredoc=1
            next
        }
        END { flush() }
    ' "$f" || true
}

# JS/TS hollow-test scanner. Per individual test (`it(`/`test(`/`specify(`/`fit(`,
# incl. `it.each(`/`it.only(`), the body is captured by brace-matching from the
# first `{` until depth returns to 0, so sibling tests don't bleed together. A
# test is:
#   - skipped     : declared with `.skip`/`.todo` or an `x`-prefix (xit/xdescribe).
#   - empty       : a brace body with no meaningful line (only braces/comments).
#   - no-assertion: a non-empty body with no recognized assertion idiom.
#   - always-true : every assertion is a narrow tautology (expect(true).toBe(true),
#                   assert(true), …) — kept deliberately narrow so substantive
#                   assertions without a value literal (not.toThrow, snapshots) pass.
# Assertion idiom is matched GENEROUSLY (expect(, any `assert`, chai .should/.to.,
# jest `.toX`, ava `t.is/…`) so an unrecognized library yields a false-negative,
# never a false-positive. A test whose callback has no `{ }` body (one-line arrow
# expression) is NOT analyzed — favour not-flagging (EF-007). Comments/strings are
# not stripped: a brace inside a multi-line template/string can mis-bound a block;
# that errs toward a false-negative, which is the safe direction here.
_scan_js() {
    local f="$1"
    # Regexes are awk regex CONSTANTS (not -v string vars) so backslash escapes
    # are not mangled by awk's string→regex conversion.
    awk -v file="$f" '
        # A line that opens an individual test. describe/context are suites, not
        # tests (their inner it()s are matched on their own lines) — excluded.
        function is_testdecl(s) {
            return s ~ /(^|[^A-Za-z0-9_.])(it|test|specify|fit|xit|xtest|xspecify)([.][A-Za-z]+)*[[:space:]]*\(/
        }
        function is_skipdecl(s) {
            return s ~ /(^|[^A-Za-z0-9_.])(x(it|test|specify|describe|context)[[:space:]]*\(|(it|test|specify|describe|context)[.](skip|todo)[^A-Za-z])/
        }
        function has_assert(s) {
            return s ~ /(expect[[:space:]]*\(|assert|\.should[^A-Za-z]|\.to\.|\.to[A-Z]|toMatchSnapshot|toThrow|[^A-Za-z]t\.(is|deepEqual|true|false|truthy|falsy|throws|notThrows|regex|snapshot|like|pass|fail))/
        }
        function is_tautology(s) {
            return s ~ /(expect[[:space:]]*\([[:space:]]*true[[:space:]]*\)[[:space:]]*\.(toBe|toEqual|toStrictEqual)\([[:space:]]*true[[:space:]]*\)|expect[[:space:]]*\([[:space:]]*false[[:space:]]*\)[[:space:]]*\.(toBe|toEqual|toStrictEqual)\([[:space:]]*false[[:space:]]*\)|expect[[:space:]]*\([[:space:]]*1[[:space:]]*\)[[:space:]]*\.(toBe|toEqual|toStrictEqual)\([[:space:]]*1[[:space:]]*\)|expect[[:space:]]*\([[:space:]]*0[[:space:]]*\)[[:space:]]*\.(toBe|toEqual|toStrictEqual)\([[:space:]]*0[[:space:]]*\)|expect[[:space:]]*\([[:space:]]*true[[:space:]]*\)[[:space:]]*\.toBeTruthy\([[:space:]]*\)|assert(\.ok)?[[:space:]]*\([[:space:]]*true[[:space:]]*\)|assert\.(equal|strictEqual|deepEqual)[[:space:]]*\([[:space:]]*true[[:space:]]*,[[:space:]]*true[[:space:]]*\))/
        }
        # meaningful = real body content (not blank / comment / lone punctuation).
        function meaningful(s) {
            if (s ~ /^[[:space:]]*$/) return 0
            if (s ~ /^[[:space:]]*\/\//) return 0
            if (s ~ /^[[:space:]]*[*]/) return 0
            if (s ~ /^[[:space:]]*\/[*]/) return 0
            if (s ~ /^[[:space:]]*[{}();,]*[[:space:]]*$/) return 0
            return 1
        }
        function analyze(   i, line, mcount, acount, tautall) {
            mcount=0; acount=0; tautall=1
            for (i=0;i<n;i++) {
                line=body[i]
                if (i>0 && meaningful(line)) mcount++   # i==0 is the decl line
                if (has_assert(line)) {
                    acount++
                    if (!is_tautology(line)) tautall=0
                }
            }
            if (skipflag)
                printf "%s:%d: skipped: test is disabled (skip/todo/x-prefix) - not evidence yet\n", file, startline
            else if (acount>0 && tautall)
                printf "%s:%d: always-true: only assertion is a tautology - assert real behavior\n", file, startline
            else if (acount==0 && mcount==0)
                printf "%s:%d: empty: empty test body - implement or remove\n", file, startline
            else if (acount==0)
                printf "%s:%d: no-assertion: runs code but asserts nothing\n", file, startline
        }
        {
            o=gsub(/[{]/,"&",$0); c=gsub(/[}]/,"&",$0)   # raw brace counts (gsub returns count)
            if (inblock) {
                body[n++]=$0
                if (!braceseen && o>0) braceseen=1
                if (braceseen) depth+=o-c
                if (braceseen && depth<=0) { analyze(); inblock=0; n=0 }
                next
            }
            if (is_testdecl($0)) {
                inblock=1; startline=NR; n=0; depth=0; braceseen=0
                skipflag=is_skipdecl($0)
                body[n++]=$0
                if (o>0) { braceseen=1; depth+=o-c; if (depth<=0) { analyze(); inblock=0; n=0 } }
            }
        }
        END { if (inblock && braceseen) analyze() }   # EOF inside a block (no brace seen ⇒ drop, safe)
    ' "$f" || true
}

# Python hollow-test scanner (indentation-based blocks). A `def test_*` body runs
# from the def line until a line de-indents to the def's level. Skip is flagged
# only for an UNCONDITIONAL decorator (`@pytest.mark.skip`, `@unittest.skip`,
# `@skip`) — a conditional `@pytest.mark.skipif(...)` env-guard is NOT flagged
# (same rationale as bats `skip`). `pass` / `...` / docstrings are non-meaningful.
_scan_py() {
    local f="$1"
    awk -v file="$f" '
        function py_assert(s) {
            return s ~ /((^|[^A-Za-z0-9_.])assert([[:space:]]|\()|\.assert[A-Za-z]|pytest\.(raises|warns|approx|fail|deprecated_call)|np\.testing\.|(^|[^A-Za-z0-9_])assert_|\.fail\()/
        }
        function py_taut(s) {
            return s ~ /((^|[^A-Za-z0-9_.])assert[[:space:]]+(True|1)[[:space:]]*($|,|#)|(^|[^A-Za-z0-9_.])assert[[:space:]]+(True[[:space:]]*==[[:space:]]*True|1[[:space:]]*==[[:space:]]*1)([[:space:]]|$|,|#)|\.assertTrue\([[:space:]]*True[[:space:]]*\)|\.assertEqual\([[:space:]]*1[[:space:]]*,[[:space:]]*1[[:space:]]*\))/
        }
        function py_meaningful(s) {
            if (s ~ /^[[:space:]]*$/) return 0
            if (s ~ /^[[:space:]]*#/) return 0
            if (s ~ /^[[:space:]]*pass[[:space:]]*$/) return 0
            if (s ~ /^[[:space:]]*\.\.\.[[:space:]]*$/) return 0
            if (s ~ /^[[:space:]]*(r|f|rb|br)?("""|'"'"''"'"''"'"'|"|'"'"')/) return 0   # bare string / docstring
            return 1
        }
        function flush(   i, line, mcount, acount, tautall) {
            if (!inpy) return
            mcount=0; acount=0; tautall=1
            for (i=0;i<n;i++) {
                line=body[i]
                if (py_meaningful(line)) mcount++
                if (py_assert(line)) { acount++; if (!py_taut(line)) tautall=0 }
            }
            if (skipflag)
                printf "%s:%d: skipped: test is disabled (skip decorator) - not evidence yet\n", file, startline
            else if (acount>0 && tautall)
                printf "%s:%d: always-true: only assertion is a tautology - assert real behavior\n", file, startline
            else if (acount==0 && mcount==0)
                printf "%s:%d: empty: empty test body - implement or remove\n", file, startline
            else if (acount==0)
                printf "%s:%d: no-assertion: runs code but asserts nothing\n", file, startline
            inpy=0; n=0
        }
        {
            blank = ($0 ~ /^[[:space:]]*$/)
            match($0, /^[ \t]*/); ind=RLENGTH
            if (inpy) {
                if (blank || ind > defind) { body[n++]=$0; next }
                flush()   # de-indent ends the block; fall through to re-handle this line
            }
            if ($0 ~ /^[[:space:]]*@([A-Za-z_][A-Za-z0-9_.]*\.)?skip([^A-Za-z]|$)/) { pending_skip=1; next }
            if ($0 ~ /^[[:space:]]*@/) { next }   # other decorator: keep pending_skip across the stack
            if ($0 ~ /^[[:space:]]*def[[:space:]]+test[A-Za-z0-9_]*[[:space:]]*\(/) {
                inpy=1; startline=NR; n=0; defind=ind; skipflag=pending_skip; pending_skip=0; next
            }
            if (!blank) pending_skip=0
        }
        END { flush() }
    ' "$f" || true
}

# Go hollow-test scanner (brace-based, like JS). A `func Test*`/`func Fuzz*` body
# is captured by brace-matching. Skip is flagged only when `t.Skip(` is an
# UNCONDITIONAL statement at line start — a guarded `if short { t.Skip() }` is not.
# Assertion idiom: t.Error/Fatal/Fail*, testify assert./require. (generous).
_scan_go() {
    local f="$1"
    awk -v file="$f" '
        function go_assert(s) {
            return s ~ /(\.(Error|Errorf|Fatal|Fatalf|Fail|FailNow)\(|assert\.|require\.|\.(Equal|NoError|True|False|NotNil|Nil|Contains)\()/
        }
        function go_skip(s) { return s ~ /^[[:space:]]*t\.Skip(Now|f)?[[:space:]]*\(/ }
        function analyze(   i, line, mcount, acount, skipfound) {
            mcount=0; acount=0; skipfound=0
            for (i=0;i<n;i++) {
                line=body[i]
                if (i>0 && line !~ /^[[:space:]]*[{}()]*[[:space:]]*$/ && line !~ /^[[:space:]]*\/\// && line !~ /^[[:space:]]*$/) mcount++
                if (go_skip(line)) skipfound=1
                if (go_assert(line)) acount++
            }
            if (skipfound)
                printf "%s:%d: skipped: test is disabled (t.Skip) - not evidence yet\n", file, startline
            else if (acount==0 && mcount==0)
                printf "%s:%d: empty: empty test body - implement or remove\n", file, startline
            else if (acount==0)
                printf "%s:%d: no-assertion: runs code but asserts nothing\n", file, startline
        }
        {
            o=gsub(/[{]/,"&",$0); c=gsub(/[}]/,"&",$0)
            if (inblock) {
                body[n++]=$0
                if (!braceseen && o>0) braceseen=1
                if (braceseen) depth+=o-c
                if (braceseen && depth<=0) { analyze(); inblock=0; n=0 }
                next
            }
            if ($0 ~ /^func[[:space:]]+(Test|Fuzz)[A-Za-z0-9_]*[[:space:]]*\(/) {
                inblock=1; startline=NR; n=0; depth=0; braceseen=0
                body[n++]=$0
                if (o>0) { braceseen=1; depth+=o-c; if (depth<=0) { analyze(); inblock=0; n=0 } }
            }
        }
        END { if (inblock && braceseen) analyze() }
    ' "$f" || true
}

# Stub scanner — Phase 3 fills the per-language patterns. For now a no-op so the
# "no stubs in our own scripts/" regression (EF-008) holds while we build the
# hollow-test path first. NEVER emit on ambiguity.
_scan_code_stub() { : ; }

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

# _is_test_file <path> — bats/shell test file (has @test), or a *.test.* /
# *.spec.* / *_test.go / test_*.py name. Cheap heuristic.
_file_is_bats_tests() {
    case "$1" in
        *.bats) return 0 ;;
        *.sh|*.bash) grep -qE '^[[:space:]]*@test' "$1" 2>/dev/null && return 0 || return 1 ;;
        *) return 1 ;;
    esac
}

# A minified/bundled file (e.g. one very long line, or a *.min.js name) is never
# real test source — skip it (edge-8: generated code excludable) so minified
# identifiers like `it(` / `test(` cannot masquerade as hollow tests.
_looks_minified() {
    case "$1" in *.min.js|*.min.ts|*.bundle.js|*.bundle.ts) return 0 ;; esac
    awk 'length($0)>1000{f=1} END{exit f?0:1}' "$1" 2>/dev/null
}

# A JS/TS test file: a *.test.* / *.spec.* name, or a source file that calls a
# test function (it(/test(/describe(). Plain source modules are not scanned as tests.
_file_is_js_tests() {
    case "$1" in
        *.test.ts|*.test.tsx|*.test.js|*.test.jsx|*.test.mts|*.test.cts) return 0 ;;
        *.spec.ts|*.spec.tsx|*.spec.js|*.spec.jsx|*.spec.mts|*.spec.cts) return 0 ;;
        *.ts|*.tsx|*.js|*.jsx|*.mts|*.cts)
            grep -qE '(^|[^A-Za-z0-9_.])(it|test|describe)[[:space:]]*\(' "$1" 2>/dev/null && return 0 || return 1 ;;
        *) return 1 ;;
    esac
}

# A Python test file: a test_*.py / *_test.py name, or a .py defining a test_*.
_file_is_py_tests() {
    case "$1" in
        test_*.py|*_test.py) return 0 ;;
        *.py) grep -qE '^[[:space:]]*def[[:space:]]+test' "$1" 2>/dev/null && return 0 || return 1 ;;
        *) return 1 ;;
    esac
}

# A Go test file: the *_test.go name (Go's own convention), defining func Test/Fuzz.
_file_is_go_tests() {
    case "$1" in
        *_test.go) grep -qE '^func[[:space:]]+(Test|Fuzz)' "$1" 2>/dev/null && return 0 || return 1 ;;
        *) return 1 ;;
    esac
}

_scan_one() {
    local f="$1"
    [ -f "$f" ] || return 0
    if [ "$MODE" != code ]; then
        if _file_is_bats_tests "$f"; then
            _scan_bats "$f"
        elif _file_is_js_tests "$f" && ! _looks_minified "$f"; then
            _scan_js "$f"
        elif _file_is_py_tests "$f"; then
            _scan_py "$f"
        elif _file_is_go_tests "$f"; then
            _scan_go "$f"
        fi
    fi
    if [ "$MODE" != tests ]; then
        _scan_code_stub "$f"
    fi
}

# Collect target files: expand dirs to supported extensions.
_collect() {
    local p
    for p in "${PATHS[@]}"; do
        if [ -d "$p" ]; then
            # Prune generated/vendored trees (edge-8) — portable BSD+GNU find idiom.
            find "$p" \
                \( -type d \( -name node_modules -o -name .git -o -name build \
                    -o -name dist -o -name .next -o -name out -o -name coverage \
                    -o -name vendor -o -name .svelte-kit -o -name .nuxt \) -prune \) -o \
                \( -type f \( -name '*.bats' -o -name '*.sh' -o -name '*.bash' \
                    -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
                    -o -name '*.py' -o -name '*.go' \) -print \) 2>/dev/null
        elif [ -e "$p" ]; then
            printf '%s\n' "$p"
        fi
    done
}

findings=0
while IFS= read -r f; do
    [ -n "$f" ] || continue
    out=$(_scan_one "$f")
    if [ -n "$out" ]; then
        printf '%s\n' "$out"
        findings=$((findings + $(printf '%s\n' "$out" | grep -c ': ')))
    fi
done < <(_collect)

[ "$QUIET" = 1 ] || echo "substance-check: $findings finding(s)" >&2
exit 0
