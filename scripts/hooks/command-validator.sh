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

# Normalize: lowercase, collapse whitespace
CMD_LOWER=$(echo "$CMD" | tr '[:upper:]' '[:lower:]' | tr -s ' ')

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
if echo "$CMD_LOWER" | grep -qE 'curl\s+[^|]*\|\s*(ba)?sh'; then
  echo >&2 "BLOCKED: Pipe-to-shell detected (curl | sh). Download first, verify, then execute."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE 'wget\s+[^|]*\|\s*(ba)?sh'; then
  echo >&2 "BLOCKED: Pipe-to-shell detected (wget | sh). Download first, verify, then execute."
  exit 2
fi

# === CATEGORY 3: Disk/filesystem destruction ===
if echo "$CMD_LOWER" | grep -qE '(mkfs|fdisk|parted|wipefs)\s'; then
  echo >&2 "BLOCKED: Disk formatting/partitioning operation detected."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE 'dd\s+if=.*(of=/dev|of=\s*/dev)'; then
  echo >&2 "BLOCKED: Direct write to device detected (dd)."
  exit 2
fi
if echo "$CMD_LOWER" | grep -qE '>\s*/dev/(sd|nvme|vd|hd|xvd)'; then
  echo >&2 "BLOCKED: Redirection to block device detected."
  exit 2
fi

# === CATEGORY 4: Privilege escalation ===
if echo "$CMD_LOWER" | grep -qE '^sudo\s|;\s*sudo\s|\|\s*sudo\s'; then
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
if echo "$CMD_LOWER" | grep -qE 'rm\s+(-[rfRI]+\s+)*/(etc|boot|sys|proc|usr/lib|lib|sbin)\b'; then
  echo >&2 "BLOCKED: Deletion in a protected system directory."
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
# boundary: an agent can still bypass via the Bash tool (e.g. `sed -i` a hook),
# env vars (HUSKY=0), or `git -c core.hooksPath=…` — those are outside a
# command-string matcher's reach by design. Operates on the ORIGINAL command so
# commit's `-F/--file` is not confused with push's `-f/--force`. Message VALUES
# (the quoted/next token after -m/-am/--message/-F/--file, and heredoc bodies) are
# stripped so flag text INSIDE a message is ignored, while a real flag placed
# AFTER the message is still caught. Known v1 limits (recoverable via
# SKIP_COMMAND_VALIDATOR=1): a rare commit MESSAGE containing a bare ' -…n… '
# token may over-block; `--no-verify` on a non-git command chained after a git
# push may over-block. Granular opt-out: SKIP_NO_VERIFY_CHECK=1 disables ONLY this
# category (the other 8 stay active), for the rare legitimate bypass — unlike the
# blunt SKIP_COMMAND_VALIDATOR=1 which drops every check.
if [ "${SKIP_NO_VERIFY_CHECK:-0}" != "1" ] \
   && echo "$CMD" | grep -qiE 'git[[:space:]]+([^|&;]*[[:space:]])?(commit|push)'; then
  # Strip message VALUES only (keep trailing flags). -[a-z]*m covers -m/-am/-sm…;
  # then long --message/--file/-F; then any heredoc body.
  GIT_FLAGS=$(echo "$CMD" | tr '\n' ' ' \
    | sed -E "s/[[:space:]]-[a-z]*m([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g" \
    | sed -E "s/[[:space:]](--message|--file|-F)([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g" \
    | sed -E 's/[[:space:]]<<.*$//')
  # --no-verify, tolerating git's unambiguous-abbreviation (--no-veri, --no-ver…).
  if echo "$GIT_FLAGS" | grep -qE '(^|[[:space:]])--no-ver[a-z]*([[:space:]=]|$)'; then
    echo >&2 "BLOCKED: 'git --no-verify' bypasses the pre-commit/pre-push gates. Fix the failing check instead of skipping it."
    exit 2
  fi
  # Short -n (no-verify) on commit only (git log -n N is a count). Standalone -n is
  # checked on the stripped flags; a bundled cluster (-nm, -anm) is checked on the
  # raw command because the message-strip consumes a trailing -m bundle.
  if echo "$CMD" | grep -qiE 'git[[:space:]]+([^|&;]*[[:space:]])?commit'; then
    if echo "$GIT_FLAGS" | grep -qE '(^|[[:space:]])-n([[:space:]]|$)' \
       || echo "$CMD" | grep -qE '(^|[[:space:]])-[a-z]*n[a-z]+([[:space:]]|$)'; then
      echo >&2 "BLOCKED: 'git commit -n' (no-verify) bypasses the pre-commit gate. Fix the failing check instead of skipping it."
      exit 2
    fi
  fi
fi

# All checks passed
exit 0
