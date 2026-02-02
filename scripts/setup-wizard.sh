#!/usr/bin/env bash
# setup-wizard.sh - DEPRECATED: redirige vers new-project.sh --simple
#
# Ce script est conservé pour la compatibilité avec les utilisateurs existants.
# Utilisez directement: ./scripts/new-project.sh --simple [CHEMIN]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "⚠ setup-wizard.sh est déprécié. Utilisation de new-project.sh --simple à la place."
echo ""

exec "$SCRIPT_DIR/new-project.sh" --simple "$@"
