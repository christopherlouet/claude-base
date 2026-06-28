#!/usr/bin/env bash
# =============================================================================
# coldstart.sh — score the METHOD gates by the process ARTIFACTS a session left
# behind. The biggest claude-base/bare-Claude difference isn't a line of code —
# it's that the workflow (Explore -> Specify -> Plan -> TDD -> Audit -> Commit)
# produces a paper trail a bare session never makes. This counts that trail.
#
# Give it the directory a session produced for one task. It checks for each method
# artifact and prints a checklist. Run it on a bare-Claude output AND a claude-base
# output for the SAME task: the gap is the method-gate value, made concrete.
#
# Deterministic, offline (find + grep). Usage: coldstart.sh <dir>  (exit 0; 2 usage)
# =============================================================================
set -u

DIR="${1:-}"
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "usage: coldstart.sh <session-output-dir>" >&2
    exit 2
fi

# present <name-glob> <content-regex> -> 1 if a file matches the name OR content
present() {
    local nameglob="$1" contentre="$2"
    if [ -n "$nameglob" ] && find "$DIR" -type f -iname "$nameglob" 2>/dev/null | grep -q .; then
        return 0
    fi
    if [ -n "$contentre" ] && grep -rilE "$contentre" "$DIR" 2>/dev/null | grep -q .; then
        return 0
    fi
    return 1
}

have=0
total=0
row() {  # <artifact> <yes|no> <gap>
    total=$((total+1))
    local mark="absent"
    if [ "$2" = "yes" ]; then mark="present"; have=$((have+1)); fi
    printf ' %-14s | %-8s | %s\n' "$1" "$mark" "$3"
}
chk() { if present "$1" "$2"; then echo yes; else echo no; fi; }

# tests are detected by test-FILE convention, not content (the words "it"/"test"
# appear in ordinary code and would false-positive a content grep).
has_tests() {
    if find "$DIR" -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*.py' \
        -o -name '*_test.go' -o -path '*/tests/*' -o -path '*/__tests__/*' \) 2>/dev/null | grep -q .; then
        echo yes
    else echo no; fi
}

echo "=================================================================================="
echo " Cold-start method-gate scorecard — $DIR"
echo "=================================================================================="
printf ' %-14s | %-8s | %s\n' "artifact" "state" "the method gate it evidences"
echo "----------------------------------------------------------------------------------"
row "spec"   "$(chk '*spec*'   'user stor|given[^.]*when[^.]*then|acceptance criteri')" "Specify — defined before building"
row "plan"   "$(chk '*plan*'   '## *plan|implementation plan|architecture')"            "Plan — architecture before code"
row "tests"  "$(has_tests)"                                                              "TDD — tests written"
row "audit"  "$(chk '*audit*'  'owasp|security review|wcag|audit report|qa[- ]loop')"    "Audit — reviewed before commit"
row "commit" "$(chk '*commit*' '^(feat|fix|docs|refactor|test|chore|perf)(\(|:)')"      "Commit — conventional message"
row "pr"     "$(chk '*pr*'     '## *summary|pull request|## *changes')"                 "PR — structured description"
echo "----------------------------------------------------------------------------------"
printf ' Method artifacts present: %s / %s\n' "$have" "$total"
echo " A bare session ships code; the foundation's workflow ships the trail too."
echo " Run on bare-vs-base outputs for the same task — the gap is the value."
echo "=================================================================================="
