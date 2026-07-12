#!/usr/bin/env bash
# Command Validator - PreToolUse hook for runtime security enforcement
# Blocks dangerous commands that bypass static deny lists
# Disable with SKIP_COMMAND_VALIDATOR=1

set -euo pipefail

[ "${SKIP_COMMAND_VALIDATOR:-0}" = "1" ] && exit 0

# Read the PreToolUse payload from STDIN as JSON. The Claude Code CLI passes
# hook input on stdin (.tool_input.command), NOT via a TOOL_INPUT env var
# (see https://code.claude.com/docs/en/hooks). Reading the old env var made
# this guard a silent no-op. Fall back to the raw payload when jq is missing
# so an absent jq cannot silently bypass the security screen — note the
# fallback greps the whole JSON envelope, so anchored rules (e.g. ^sudo)
# degrade and a benign command merely *mentioning* a trigger phrase may block;
# that fails safe (extra blocks, never a silent bypass). jq is the documented
# default path and is exact.
INPUT=$(cat 2>/dev/null || true)
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
else
  CMD="$INPUT"
fi
[ -z "$CMD" ] && exit 0

# Strip git message / --grep / --file VALUES (the quoted string or next token
# after -m/-am/--message/--file/-F/--grep) BEFORE the pattern scans. A trigger
# token that appears only as a commit-message or --grep PAYLOAD is data, never
# executed, so it must not falsely block a benign command (`git commit -m
# "document mkfs usage"`, `git log --grep "passwd rotation"`). This mirrors the
# per-segment strip in Category 9 and destructive-ops.sh. Done on the raw CMD
# (case preserved) so -F/--grep match precisely, then lowercased for the scans.
CMD_STRIPPED=$(printf '%s' "$CMD" \
  | sed -E "s/[[:space:]]-[A-Za-z]*m([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g" \
  | sed -E "s/[[:space:]](--message|--file|--grep|-F)([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g")
# Normalize: lowercase, collapse whitespace
CMD_LOWER=$(printf '%s' "$CMD_STRIPPED" | tr '[:upper:]' '[:lower:]' | tr -s ' ')
# A quote-stripped copy for the protected-path checks, so a quoted target
# (`rm -rf '/etc'`, `dd of="/dev/sda"`) can't slip past a regex anchored on the
# path after the flags.
CMD_NQ=$(printf '%s' "$CMD_LOWER" | tr -d "\"'")

# === CATEGORY 1: Fork bombs and resource exhaustion ===
if echo "$CMD_LOWER" | grep -qE ':\(\)\{.*\|.*&'; then
  echo >&2 "BLOCKED: Fork bomb detected."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE '(while true|for \(\(;;|yes \|)'; then
  # Allow if it's a test/watch command
  if ! echo "$CMD_LOWER" | grep -qE '(jest|vitest|mocha|pytest|watch|poll|retry|timeout)'; then
    echo >&2 "BLOCKED: Potential infinite loop detected."
    echo >&2 "Command: $(echo "$CMD" | head -c 200)"
    exit 2
  fi
fi

# === CATEGORY 2: Dangerous pipe-to-shell patterns ===
# Match any interpreter after the pipe, with an optional path prefix
# (`| /bin/sh`, `| zsh`, `| python3`). The trailing ($|[^a-z0-9]) both terminates
# the interpreter name and stops `sh` from matching inside `shellcheck`. Scope:
# the plain `curl … | sh` an agent actually writes; deliberate obfuscation
# (`\sh`, process substitution `sh <(curl …)`) is out of scope by design.
PIPE_INTERP='([^[:space:]|]*/)?(sh|bash|zsh|dash|ksh|python[0-9.]*|perl|ruby|node)($|[^a-z0-9])'
if echo "$CMD_LOWER" | grep -qE "curl\s+[^|]*\|\s*$PIPE_INTERP"; then
  echo >&2 "BLOCKED: Pipe-to-shell detected (curl | sh). Download first, verify, then execute."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE "wget\s+[^|]*\|\s*$PIPE_INTERP"; then
  echo >&2 "BLOCKED: Pipe-to-shell detected (wget | sh). Download first, verify, then execute."
  exit 2
fi

# === CATEGORY 3: Disk/filesystem destruction ===
# mkfs matches its filesystem-specific forms too (`mkfs.ext4`, `mkfs.vfat`), the
# most common real invocation — the bare `mkfs\s` form missed all of them.
if echo "$CMD_LOWER" | grep -qE '(mkfs(\.[a-z0-9]+)?|fdisk|parted|wipefs)\s'; then
  echo >&2 "BLOCKED: Disk formatting/partitioning operation detected."
  exit 2
fi
# Device write via of=… regardless of argument order (`dd of=/dev/sda if=…` was
# a bypass — the previous regex required if= to appear before of=).
if echo "$CMD_NQ" | grep -qE 'dd\s+([^&|;]*\s)?of=\s*/dev/(sd|nvme|vd|hd|xvd|mmcblk|loop)'; then
  echo >&2 "BLOCKED: Direct write to device detected (dd)."
  exit 2
fi
if echo "$CMD_NQ" | grep -qE '>\s*/dev/(sd|nvme|vd|hd|xvd)'; then
  echo >&2 "BLOCKED: Redirection to block device detected."
  exit 2
fi

# === CATEGORY 4: Privilege escalation ===
# Match `sudo` in COMMAND position: at the start, after a separator (; & |, so
# && and || are covered too), optionally preceded by env-var assignments
# (FOO=bar sudo …), a wrapper command (env/command/exec/xargs/nice/… sudo …),
# and/or an absolute path (/usr/bin/sudo). A leading-only or assignment-only
# lead-in was bypassable via `env sudo`, `command sudo`, `xargs sudo` or
# `/usr/bin/sudo`. The command-position anchor still keeps the word `sudo`
# inside a string or message from matching. Scope: the forms a well-meaning
# agent types; deliberate obfuscation (`$(sudo …)`, `\sudo`) is out of scope —
# a best-effort anti-accident guard, not an anti-evasion boundary.
if echo "$CMD_LOWER" | grep -qE '(^|[;&|])\s*(([a-z_][a-z0-9_]*=[^[:space:]]*|command|exec|env|xargs|nice|nohup|setsid|time|stdbuf|timeout)\s+)*(/[^[:space:]]*/)?sudo(\s|$)'; then
  echo >&2 "BLOCKED: Privilege escalation (sudo). Operate without root privileges."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE '(passwd|visudo|usermod|useradd|userdel|groupmod)\s'; then
  echo >&2 "BLOCKED: System user/group modification detected."
  exit 2
fi

# === CATEGORY 5: Network reconnaissance (outside pentest context) ===
if echo "$CMD_LOWER" | grep -qE '(nmap|masscan|zmap)\s'; then
  echo >&2 "BLOCKED: Network scanning tool detected. Authorize with SKIP_COMMAND_VALIDATOR=1 for a pentest context."
  exit 2
fi

# === CATEGORY 6: System service manipulation ===
if echo "$CMD_LOWER" | grep -qE 'systemctl\s+(stop|disable|mask|restart)\s'; then
  # Allow restart of dev services
  if ! echo "$CMD_LOWER" | grep -qE '(docker|nginx|postgresql|mysql|redis|node)'; then
    echo >&2 "BLOCKED: System service manipulation detected."
    exit 2
  fi
fi
if echo "$CMD_LOWER" | grep -qE 'kill\s+-9\s+(1|init|systemd)'; then
  echo >&2 "BLOCKED: Attempt to kill the init process."
  exit 2
fi

# === CATEGORY 7: Protected system paths ===
# Any-depth deletion inside a purely-system tree (no legit subdir to delete).
# The flag group accepts long flags too (`rm --recursive --force /etc`), matching
# the (usr|var|opt) check below — the short-flag-only version was bypassable.
# Runs on the dequoted command so `rm -rf '/etc'` is caught.
if echo "$CMD_NQ" | grep -qE 'rm\s+(-{1,2}[a-z]+\s+)*/(etc|boot|sys|proc|usr/lib|lib|sbin)\b'; then
  echo >&2 "BLOCKED: Deletion in a protected system directory."
  exit 2
fi
# Whole-tree wipe of a system root that DOES hold legit subdirs (/usr /var /opt):
# block only the bare root (`rm -rf /var`, optional trailing slash) — a real
# subpath like /var/www/html stays allowed. Closes the gap where `rm -rf /usr`
# slipped through while `/usr/lib` was blocked.
if echo "$CMD_NQ" | grep -qE 'rm\s+(-{1,2}[a-z]+\s+)*/(usr|var|opt)/?(\s|$)'; then
  echo >&2 "BLOCKED: Deletion of a system tree root (/usr, /var or /opt)."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE '(chmod|chown)\s.*/(etc|boot|sys|proc|usr)\b'; then
  echo >&2 "BLOCKED: Permission change on a system directory."
  exit 2
fi

# === CATEGORY 8: Environment/secret exfiltration ===
if echo "$CMD_LOWER" | grep -qE 'cat\s+.*\.(env|pem|key|cert)\s*\|.*(curl|wget|nc |netcat)'; then
  echo >&2 "BLOCKED: Potential secret exfiltration detected."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE 'env\s*\|.*(curl|wget|nc |netcat)'; then
  echo >&2 "BLOCKED: Environment variable exfiltration detected."
  exit 2
fi

# === CATEGORY 9: Verification bypass (git --no-verify) ===
# Blocks skipping the pre-commit / pre-push gates. ADVISORY guardrail, not a hard
# boundary (an agent can still bypass via the Bash tool — `sed -i` a hook,
# HUSKY=0, …). The command is split into SEGMENTS — first joining backslash-
# newline continuations, then splitting on newlines and shell separators
# (; && || | &) — and ONLY the segments that are a git commit/push are
# inspected. That way a -n/--no-verify belonging to a chained `git log -n 5`, a
# heredoc BODY line, or hidden across a `\`-continuation is neither misattributed
# to nor hidden from the commit. Within a segment, message VALUES (after
# -m/-am/--message/-F/--file) are stripped so a flag NAMED in a commit message is
# ignored while a real flag AFTER the message is still caught; and commit/push
# must be the git SUBCOMMAND (only options may precede it) so `git log --grep
# commit` is not mistaken for a commit. Known limit: a commit MESSAGE containing
# a bare `-…n…` token may over-block (recoverable via SKIP_NO_VERIFY_CHECK=1).
# Granular opt-out: SKIP_NO_VERIFY_CHECK=1 disables ONLY this category.
case "$CMD" in *git*commit*|*git*push*) _maybe_git=1 ;; *) _maybe_git=0 ;; esac
if [ "${SKIP_NO_VERIFY_CHECK:-0}" != "1" ] && [ "$_maybe_git" = 1 ]; then
  # `git <options...> <subcommand>`: only tokens starting with '-' (and their
  # non-option values) may sit between `git` and the subcommand.
  _git_cp='git[[:space:]]+(-[^[:space:]]+[[:space:]]+([^-][^[:space:]]*[[:space:]]+)?)*(commit|push)([[:space:]]|$)'
  _git_commit='git[[:space:]]+(-[^[:space:]]+[[:space:]]+([^-][^[:space:]]*[[:space:]]+)?)*commit([[:space:]]|$)'
  _nv_hit=""
  while IFS= read -r _seg; do
    echo "$_seg" | grep -qiE "$_git_cp" || continue
    # Strip message VALUES in this segment (keep trailing flags).
    _segf=$(echo "$_seg" \
      | sed -E "s/[[:space:]]-[a-z]*m([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g" \
      | sed -E "s/[[:space:]](--message|--file|-F)([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g")
    # --no-verify, tolerating git's unambiguous-abbreviation (--no-veri, --no-ver…).
    if echo "$_segf" | grep -qiE '(^|[[:space:]])--no-ver[a-z]*([[:space:]=]|$)'; then
      _nv_hit="verify"; break
    fi
    # Short -n (no-verify) on commit only. Standalone -n on the stripped flags; a
    # bundled cluster (-nm/-anm/-an) on a QUOTE-STRIPPED copy. The cluster arm
    # allows a TRAILING n (`-an` = -a + --no-verify) — requiring a letter AFTER n
    # missed that reordering — but scanning the quote-stripped copy (not the raw
    # segment) keeps a ` -n ` inside a commit MESSAGE from false-matching, since a
    # real short-flag cluster is never quoted while message text is.
    _segq=$(printf '%s' "$_seg" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")
    if echo "$_seg" | grep -qiE "$_git_commit"; then
      if echo "$_segf" | grep -qE '(^|[[:space:]])-n([[:space:]]|$)' \
         || echo "$_segq" | grep -qE '(^|[[:space:]])-[a-z]*n[a-z]*([[:space:]]|$)'; then
        _nv_hit="n"; break
      fi
    fi
  done < <(printf '%s' "$CMD" \
    | awk '{ if (sub(/\\$/,"")) printf "%s ", $0; else print }' \
    | awk '{ gsub(/\|\||&&|;|\||&/,"\n"); print }')
  if [ "$_nv_hit" = "verify" ]; then
    echo >&2 "BLOCKED: 'git --no-verify' bypasses the pre-commit/pre-push gates. Fix the failing check instead of skipping it."
    exit 2
  elif [ "$_nv_hit" = "n" ]; then
    echo >&2 "BLOCKED: 'git commit -n' (no-verify) bypasses the pre-commit gate. Fix the failing check instead of skipping it."
    exit 2
  fi
fi

# All checks passed
exit 0
