#!/usr/bin/env bash
# =============================================================================
# _policy-zsh-pipestatus.sh — harness-neutral core of zsh-pipestatus-guard.
#
# zsh has no PIPESTATUS: `${PIPESTATUS[0]}` expands to an EMPTY string without
# any error (zsh's array is the lower-case, 1-indexed `pipestatus`). A pipe
# check written for bash then reads "" — and "" is easily taken for success.
#
#   shell_is_zsh <path>              0 if the shell path names zsh.
#   has_pipestatus_expansion <cmd>   0 if the OUTER shell would expand
#                                    PIPESTATUS somewhere in <cmd>.
#
# Only expansions the outer shell performs count. These are handed on intact,
# so they pass: single quotes (`bash -c '…${PIPESTATUS[0]}'`), `$'…'`, an
# escaped `\$`, the bare word (`grep PIPESTATUS`), a comment, and the body of
# a heredoc whose delimiter is quoted (`<<'EOF'` — writing a script file).
# An unquoted-delimiter heredoc body IS expanded, so it counts.
#
# Known limits (a lexer, not a parser): a single quote inside `"…$(…'…')…"` is
# read as literal, and an `eval`/`zsh -c "…"` re-expansion is not followed.
#
# Pure: no stdin, no harness envelope, no exit codes beyond return values.
# Bash 3.2-safe; the scan is POSIX awk (BSD awk on macOS).
# =============================================================================

shell_is_zsh() {
  case "$(basename -- "${1:-}" 2>/dev/null)" in
    zsh*) return 0 ;;
    *) return 1 ;;
  esac
}

has_pipestatus_expansion() {
  case "${1:-}" in *PIPESTATUS*) ;; *) return 1 ;; esac
  printf '%s\n' "$1" | awk '
    function isword(c) { return c ~ /[A-Za-z0-9_]/ }
    # Does an expansion start at position i (s[i] == "$") of string s?
    function expands_at(s, i,   j) {
      j = i + 1
      if (substr(s, j, 1) == "{") { j++; if (substr(s, j, 1) == "#") j++ }
      if (substr(s, j, 10) != "PIPESTATUS") return 0
      return !isword(substr(s, j + 10, 1))
    }
    # Unquoted-heredoc body line: only `\` escapes matter.
    function line_expands(s,   i, c) {
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { i++; continue }
        if (c == "$" && expands_at(s, i)) return 1
      }
      return 0
    }
    { buf = buf $0 "\n" }
    END {
      s = buf; n = length(s); st = "n"; nh = 0; prev = "\n"
      for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (st == "sq") { if (c == "\047") st = "n"; prev = c; continue }
        if (st == "ansi") {
          if (c == "\\") { i++; continue }
          if (c == "\047") st = "n"
          prev = c; continue
        }
        if (st == "dq") {
          if (c == "\\") { i++; prev = "x"; continue }
          if (c == "\"") st = "n"
          else if (c == "$" && expands_at(s, i)) { found = 1; break }
          prev = c; continue
        }
        # st == "n": unquoted
        if (c == "\\") { i++; prev = "x"; continue }
        if (c == "\047") { st = "sq"; prev = c; continue }
        if (c == "\"") { st = "dq"; prev = c; continue }
        if (c == "$" && substr(s, i + 1, 1) == "\047") { st = "ansi"; i++; prev = "x"; continue }
        if (c == "$" && expands_at(s, i)) { found = 1; break }
        if (c == "#" && prev ~ /[ \t\n;|&(]/) {
          while (i < n && substr(s, i + 1, 1) != "\n") i++
          prev = "x"; continue
        }
        if (c == "<" && substr(s, i + 1, 1) == "<" && substr(s, i + 2, 1) != "<") {
          # heredoc operator: read optional -, blanks, then the delimiter
          j = i + 2; strip = 0
          if (substr(s, j, 1) == "-") { strip = 1; j++ }
          while (substr(s, j, 1) ~ /[ \t]/) j++
          d = ""; q = 0
          while (j <= n) {
            ch = substr(s, j, 1)
            if (ch == "\047" || ch == "\"") {
              q = 1; k = index(substr(s, j + 1), ch)
              if (k == 0) { j = n + 1; break }
              d = d substr(s, j + 1, k - 1); j += k + 1; continue
            }
            if (ch == "\\") { q = 1; d = d substr(s, j + 1, 1); j += 2; continue }
            if (ch ~ /[ \t\n;|&<>()]/) break
            d = d ch; j++
          }
          if (d != "") { nh++; hd[nh] = d; hq[nh] = q; hs[nh] = strip }
          i = j - 1; prev = "x"; continue
        }
        if (c == "\n" && nh > 0) {
          # consume pending heredoc bodies, in order
          p = i + 1
          for (h = 1; h <= nh; h++) {
            while (p <= n) {
              e = index(substr(s, p), "\n")
              line = (e == 0) ? substr(s, p) : substr(s, p, e - 1)
              p = (e == 0) ? n + 1 : p + e
              cmp = line
              if (hs[h]) sub(/^\t+/, "", cmp)
              if (cmp == hd[h]) break
              if (!hq[h] && line_expands(line)) { found = 1; break }
            }
            if (found) break
          }
          if (found) break
          nh = 0; i = p - 1; prev = "\n"; continue
        }
        prev = c
      }
      exit(found ? 0 : 1)
    }'
}
