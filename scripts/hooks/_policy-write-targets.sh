#!/usr/bin/env bash
# =============================================================================
# _policy-write-targets.sh — Harness-neutral write-target extraction core
# =============================================================================
# CORE side of the core/shell split (specs/agnostic-core/) for
# bash-write-guard.sh: given a raw shell command, print the candidate WRITE
# TARGET paths (redirections, tee, sed -i/--in-place, cp/mv/install DEST,
# dd of=plain-file), one per line, after:
#   - message/--file/--grep VALUE strip (a commit message NAMING a file
#     operation is data, not a write);
#   - quote-strip + newline-flatten for token extraction;
#   - package-manager `install` neutralization (pip/npm/apt/… install is not
#     a file write; coreutils `install SRC DST` is and still matches).
#
# No verdict here: target CLASSIFICATION lives in _sensitive-paths.sh
# (is_protected_config / is_secret_file), and ENVIRONMENT checks (existence,
# current branch, git-tracked) stay in the shell — they depend on the machine,
# not on the policy.
#
# NOT a hook by itself. Do not register in settings.json.
# macOS bash 3.2 compatible; functions only, no top-level side effects beyond
# sourcing the shared strip helper.
# =============================================================================

# Avoid double-sourcing
if [ -n "${POLICY_WRITE_TARGETS_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
POLICY_WRITE_TARGETS_LOADED=1

# --- policy bootstrap (keep byte-identical across _policy-*.sh; guarded by policy-structure.bats) ---
# Shared message/--grep/--file value strip (single canonical copy in
# _core-helpers.sh). Missing helper file → no-op strip fallback: message
# payloads may then over-block, but a missing file can never turn into a
# silent bypass. POLICY_HAVE_CORE_STRIP keys on CORE_HELPERS_LOADED, NOT on
# `declare -F` alone: a sibling policy lib's no-op fallback also satisfies
# declare -F, and mistaking it for the real strip would skip the per-segment
# defenses that assume values were really stripped (pass-3 false-block class).
_policy_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)
# shellcheck source=_core-helpers.sh
if [ -n "$_policy_dir" ] && [ -f "$_policy_dir/_core-helpers.sh" ]; then . "$_policy_dir/_core-helpers.sh"; fi
# shellcheck disable=SC2034  # consumed by dangerous-commands Category 9; set in every copy so the bootstrap stays byte-identical
if [ -n "${CORE_HELPERS_LOADED:-}" ] && declare -F strip_msg_values >/dev/null 2>&1; then
  POLICY_HAVE_CORE_STRIP=1
else
  POLICY_HAVE_CORE_STRIP=0
  declare -F strip_msg_values >/dev/null 2>&1 || strip_msg_values() { printf '%s' "$1"; }
fi
# --- end policy bootstrap ---

# _wt_mask_quotes — replace every quoted span with an inert placeholder.
#
# Prints the masked command on line 1, then one line per span, in index order.
# A span becomes \001<idx>\001, which the target regexes below still accept as
# a path token (it contains none of [[:space:]<>|&;()]), so a QUOTED TARGET is
# still found — but its CONTENT can no longer be read as syntax.
#
# This replaces a blanket `tr -d "\"'"`. Stripping the quotes made a quoted
# metacharacter indistinguishable from a real operator, and two plain read-only
# greps were blocked as writes during this repo's own merge work:
#   grep -n '^>>>>>>>' CHANGELOG.md        -> read as a redirect to CHANGELOG.md
#   grep -nE 'redirect|tee' <file>         -> read as a tee to <file>
# The shell never treats a quoted `>` or a quoted `tee` as syntax; neither
# should this. Note the fix cannot be "stop stripping quotes": `> ".env"` must
# still resolve to .env, which is what the placeholder preserves.
_wt_mask_quotes() {
  printf '%s' "$1" | awk '
    BEGIN { RS = "\0" }
    {
      s = $0; out = ""; n = 0; i = 1; L = length(s)
      while (i <= L) {
        c = substr(s, i, 1)
        if (c == "\"" || c == "\047") {
          q = c; i++; content = ""
          while (i <= L) { d = substr(s, i, 1); if (d == q) break; content = content d; i++ }
          i++
          out = out "\001" n "\001"
          span[n] = content; n++
          continue
        }
        out = out c; i++
      }
      print out
      for (k = 0; k < n; k++) print span[k]
    }'
}

extract_write_targets() {
  local CMD="$1"
  [ -z "$CMD" ] && return 0

  # Quote-masked, newline-flattened copy for token extraction.
  local CMD_UQ CMD_UQ_CPMV targets
  local _masked _line _i=0
  _masked=""
  # Parallel arrays (no associative arrays: macOS bash 3.2).
  local _spanv=() _spann=0
  while IFS= read -r _line; do
    if [ "$_i" -eq 0 ]; then _masked="$_line"
    else _spanv[_spann]="$_line"; _spann=$((_spann + 1)); fi
    _i=$((_i + 1))
  done <<EOF
$(_wt_mask_quotes "$(strip_msg_values "$CMD")")
EOF
  CMD_UQ=$(printf '%s' "$_masked" | tr '\n' ' ')

  # Package-manager `install` subcommands (pip/npm/apt/cargo/…) are not file
  # writes: without this, the (cp|mv|install) DEST extraction below reads
  # `pip install -r requirements.txt` as a write to requirements.txt and
  # hard-blocks routine installs on main. Neutralize `[sudo] <pm> [flags]
  # install` for that ONE extractor; the coreutils `install SRC DST` (a real
  # file write) has no such prefix and still matches. Redirect/tee/sed/dd
  # extraction keeps the untouched CMD_UQ (a `pip install x > file` redirect
  # must still be seen).
  CMD_UQ_CPMV=$(printf '%s' "$CMD_UQ" | sed -E 's/(^|[[:space:]|&;(])(sudo[[:space:]]+(-[^[:space:]]+[[:space:]]+)*)?(pip[0-9]*|pipx|pipenv|npm|pnpm|yarn|bun|apt|apt-get|dnf|yum|zypper|pacman|apk|brew|port|cargo|gem|bundle|composer|poetry|uv|conda|mamba|mvn|gradle|make|cmake|go|helm|snap|flatpak|choco|winget|scoop)([[:space:]]+-[^[:space:]]+)*[[:space:]]+install([[:space:]]|$)/\1/g')

  # Collect write targets from redirections, tee, and sed -i.
  targets=$(
    {
      # redirections: >, >>, &>, 2>  (fd-dup >&N produces no file token)
      printf '%s\n' "$CMD_UQ" | grep -oE '[0-9]*&?>>?[[:space:]]*[^[:space:]<>|&;()]+' \
        | sed -E 's/^[0-9]*&?>>?[[:space:]]*//'
      # tee [-opts] file...
      printf '%s\n' "$CMD_UQ" | grep -oE '(^|[[:space:]|&;(])tee([[:space:]]+-[a-zA-Z]+)*([[:space:]]+[^<>|&;()]+)' \
        | sed -E 's/^.*tee([[:space:]]+-[a-zA-Z]+)*[[:space:]]+//' | tr ' ' '\n'
      # sed -i / --in-place … <file>  (best-effort: last token of the invocation)
      printf '%s\n' "$CMD_UQ" | grep -oE '(^|[[:space:]|&;(])sed[[:space:]]+[^|&;()]*(-i[a-zA-Z0-9.]*|--in-place[=a-zA-Z0-9.]*)[[:space:]][^|&;()]+' \
        | awk '{ print $NF }'
      # cp / mv / install [opts] SRC… DEST  (DEST = last token) — the common
      # copy verbs are just as capable of clobbering an existing .env / config.
      # Runs on the PM-install-neutralized copy (see CMD_UQ_CPMV above).
      printf '%s\n' "$CMD_UQ_CPMV" | grep -oE '(^|[[:space:]|&;(])(cp|mv|install)([[:space:]]+-[a-zA-Z0-9=]+)*([[:space:]]+[^<>|&;()[:space:]]+)+' \
        | awk '{ print $NF }'
      # dd of=FILE  (device targets are handled by the dangerous-commands core;
      # this catches `dd if=/dev/zero of=.env` clobbering a plain secrets file).
      printf '%s\n' "$CMD_UQ" | grep -oE '(^|[[:space:]])of=[^[:space:]<>|&;()]+' \
        | sed -E 's/^[[:space:]]*of=//'
    } 2>/dev/null | sed '/^[[:space:]]*$/d'
  )
  # Put the quoted content back: a target may BE a placeholder (`> ".env"`) or
  # merely contain one (`> pre".env"`). Done after extraction so the content
  # never had a chance to be parsed as syntax.
  if [ -n "$targets" ] && [ "$_spann" -gt 0 ]; then
    local _k _ph
    for (( _k = 0; _k < _spann; _k++ )); do
      _ph=$'\001'"$_k"$'\001'
      targets="${targets//$_ph/${_spanv[_k]}}"
    done
  fi
  # A span that resolved to nothing (`> ""`) leaves an empty line; drop those
  # so an empty target is never handed to the classifier as a real path.
  targets=$(printf '%s\n' "$targets" | sed '/^[[:space:]]*$/d')

  if [ -n "$targets" ]; then
    printf '%s\n' "$targets"
  fi
  return 0
}
