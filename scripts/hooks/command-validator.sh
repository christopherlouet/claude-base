#!/usr/bin/env bash
# Command Validator - PreToolUse hook for runtime security enforcement
# Blocks dangerous commands that bypass static deny lists
# Disable with SKIP_COMMAND_VALIDATOR=1

set -euo pipefail

[ "${SKIP_COMMAND_VALIDATOR:-0}" = "1" ] && exit 0

# Get the command from TOOL_INPUT
CMD="${TOOL_INPUT:-}"
[ -z "$CMD" ] && exit 0

# Normalize: lowercase, collapse whitespace
CMD_LOWER=$(echo "$CMD" | tr '[:upper:]' '[:lower:]' | tr -s ' ')

# === CATEGORY 1: Fork bombs and resource exhaustion ===
if echo "$CMD_LOWER" | grep -qE ':\(\)\{.*\|.*&'; then
  echo "BLOCKED: Fork bomb detected."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '(while true|for \(\(;;|yes \|)'; then
  # Allow if it's a test/watch command
  if ! echo "$CMD_LOWER" | grep -qE '(jest|vitest|mocha|pytest|watch|poll|retry|timeout)'; then
    echo "BLOCKED: Potential infinite loop detected."
    echo "Command: $(echo "$CMD" | head -c 200)"
    exit 1
  fi
fi

# === CATEGORY 2: Dangerous pipe-to-shell patterns ===
if echo "$CMD_LOWER" | grep -qE 'curl\s+[^|]*\|\s*(ba)?sh'; then
  echo "BLOCKED: Pipe-to-shell detected (curl | sh). Download first, verify, then execute."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE 'wget\s+[^|]*\|\s*(ba)?sh'; then
  echo "BLOCKED: Pipe-to-shell detected (wget | sh). Download first, verify, then execute."
  exit 1
fi

# === CATEGORY 3: Disk/filesystem destruction ===
if echo "$CMD_LOWER" | grep -qE '(mkfs|fdisk|parted|wipefs)\s'; then
  echo "BLOCKED: Disk formatting/partitioning operation detected."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE 'dd\s+if=.*(of=/dev|of=\s*/dev)'; then
  echo "BLOCKED: Direct write to device detected (dd)."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '>\s*/dev/(sd|nvme|vd|hd|xvd)'; then
  echo "BLOCKED: Redirection to block device detected."
  exit 1
fi

# === CATEGORY 4: Privilege escalation ===
if echo "$CMD_LOWER" | grep -qE '^sudo\s|;\s*sudo\s|\|\s*sudo\s'; then
  echo "BLOCKED: Privilege escalation (sudo). Operate without root privileges."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '(passwd|visudo|usermod|useradd|userdel|groupmod)\s'; then
  echo "BLOCKED: System user/group modification detected."
  exit 1
fi

# === CATEGORY 5: Network reconnaissance (outside pentest context) ===
if echo "$CMD_LOWER" | grep -qE '(nmap|masscan|zmap)\s'; then
  echo "BLOCKED: Network scanning tool detected. Authorize with SKIP_COMMAND_VALIDATOR=1 for a pentest context."
  exit 1
fi

# === CATEGORY 6: System service manipulation ===
if echo "$CMD_LOWER" | grep -qE 'systemctl\s+(stop|disable|mask|restart)\s'; then
  # Allow restart of dev services
  if ! echo "$CMD_LOWER" | grep -qE '(docker|nginx|postgresql|mysql|redis|node)'; then
    echo "BLOCKED: System service manipulation detected."
    exit 1
  fi
fi
if echo "$CMD_LOWER" | grep -qE 'kill\s+-9\s+(1|init|systemd)'; then
  echo "BLOCKED: Attempt to kill the init process."
  exit 1
fi

# === CATEGORY 7: Protected system paths ===
if echo "$CMD_LOWER" | grep -qE 'rm\s+(-[rfRI]+\s+)*/(etc|boot|sys|proc|usr/lib|lib|sbin)\b'; then
  echo "BLOCKED: Deletion in a protected system directory."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '(chmod|chown)\s.*/(etc|boot|sys|proc|usr)\b'; then
  echo "BLOCKED: Permission change on a system directory."
  exit 1
fi

# === CATEGORY 8: Environment/secret exfiltration ===
if echo "$CMD_LOWER" | grep -qE 'cat\s+.*\.(env|pem|key|cert)\s*\|.*(curl|wget|nc |netcat)'; then
  echo "BLOCKED: Potential secret exfiltration detected."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE 'env\s*\|.*(curl|wget|nc |netcat)'; then
  echo "BLOCKED: Environment variable exfiltration detected."
  exit 1
fi

# All checks passed
exit 0
