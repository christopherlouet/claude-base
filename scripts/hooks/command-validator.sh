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
  echo "BLOQUE: Fork bomb detectee."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '(while true|for \(\(;;|yes \|)'; then
  # Allow if it's a test/watch command
  if ! echo "$CMD_LOWER" | grep -qE '(jest|vitest|mocha|pytest|watch|poll|retry|timeout)'; then
    echo "BLOQUE: Boucle infinie potentielle detectee."
    echo "Commande: $(echo "$CMD" | head -c 200)"
    exit 1
  fi
fi

# === CATEGORY 2: Dangerous pipe-to-shell patterns ===
if echo "$CMD_LOWER" | grep -qE 'curl\s+[^|]*\|\s*(ba)?sh'; then
  echo "BLOQUE: Pipe-to-shell detecte (curl | sh). Telechargez d'abord, verifiez, puis executez."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE 'wget\s+[^|]*\|\s*(ba)?sh'; then
  echo "BLOQUE: Pipe-to-shell detecte (wget | sh). Telechargez d'abord, verifiez, puis executez."
  exit 1
fi

# === CATEGORY 3: Disk/filesystem destruction ===
if echo "$CMD_LOWER" | grep -qE '(mkfs|fdisk|parted|wipefs)\s'; then
  echo "BLOQUE: Operation de formatage/partitionnement disque detectee."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE 'dd\s+if=.*(of=/dev|of=\s*/dev)'; then
  echo "BLOQUE: Ecriture directe sur device detectee (dd)."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '>\s*/dev/(sd|nvme|vd|hd|xvd)'; then
  echo "BLOQUE: Redirection vers device block detectee."
  exit 1
fi

# === CATEGORY 4: Privilege escalation ===
if echo "$CMD_LOWER" | grep -qE '^sudo\s|;\s*sudo\s|\|\s*sudo\s'; then
  echo "BLOQUE: Escalade de privileges (sudo). Operez sans privileges root."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '(passwd|visudo|usermod|useradd|userdel|groupmod)\s'; then
  echo "BLOQUE: Modification utilisateur/groupe systeme detectee."
  exit 1
fi

# === CATEGORY 5: Network reconnaissance (hors contexte pentest) ===
if echo "$CMD_LOWER" | grep -qE '(nmap|masscan|zmap)\s'; then
  echo "BLOQUE: Outil de scan reseau detecte. Autorisez avec SKIP_COMMAND_VALIDATOR=1 pour un contexte pentest."
  exit 1
fi

# === CATEGORY 6: System service manipulation ===
if echo "$CMD_LOWER" | grep -qE 'systemctl\s+(stop|disable|mask|restart)\s'; then
  # Allow restart of dev services
  if ! echo "$CMD_LOWER" | grep -qE '(docker|nginx|postgresql|mysql|redis|node)'; then
    echo "BLOQUE: Manipulation de service systeme detectee."
    exit 1
  fi
fi
if echo "$CMD_LOWER" | grep -qE 'kill\s+-9\s+(1|init|systemd)'; then
  echo "BLOQUE: Tentative de kill du processus init."
  exit 1
fi

# === CATEGORY 7: Protected system paths ===
if echo "$CMD_LOWER" | grep -qE 'rm\s+(-[rfRI]+\s+)*/(etc|boot|sys|proc|usr/lib|lib|sbin)\b'; then
  echo "BLOQUE: Suppression dans un repertoire systeme protege."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE '(chmod|chown)\s.*/(etc|boot|sys|proc|usr)\b'; then
  echo "BLOQUE: Changement de permissions sur un repertoire systeme."
  exit 1
fi

# === CATEGORY 8: Environment/secret exfiltration ===
if echo "$CMD_LOWER" | grep -qE 'cat\s+.*\.(env|pem|key|cert)\s*\|.*(curl|wget|nc |netcat)'; then
  echo "BLOQUE: Exfiltration potentielle de secrets detectee."
  exit 1
fi
if echo "$CMD_LOWER" | grep -qE 'env\s*\|.*(curl|wget|nc |netcat)'; then
  echo "BLOQUE: Exfiltration de variables d'environnement detectee."
  exit 1
fi

# All checks passed
exit 0
