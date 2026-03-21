# Plan d'implémentation : Veille Automatique Claude Code et Skills

**Spec**: `specs/check-updates/spec.md`
**Date**: 2026-03-21
**Complexité globale**: Moyenne (1 script Bash + cache + 2 sources réseau)

---

## Résumé

Créer `scripts/check-updates.sh` qui vérifie les mises à jour disponibles (Claude Code CLI via GitHub API, skills communautaires via skills.sh) et affiche un rapport structuré. Réutilise les patterns existants de `doctor.sh` (check/fail/warn + résumé) et `update.sh` (arg parsing + modes).

---

## Contexte technique

### Patterns à réutiliser

| Pattern | Source | Usage |
|---------|--------|-------|
| Script header + `common.sh` | Tous les scripts | Boilerplate, logging, `version_gte()` |
| `check_pass/check_fail/check_warn` | `doctor.sh` | Compteurs de résultat |
| `print_summary` + JSON output | `doctor.sh` | Rapport final texte et JSON |
| `parse_args` + `show_help` | `update.sh` | Parsing arguments, `--quiet`, `--json` |
| Temp files + cleanup trap | `update.sh` | Gestion des fichiers temporaires |
| `claude --version` | `doctor.sh` | Détection version CLI locale |

### Sources de données

| Source | Méthode | Timeout |
|--------|---------|---------|
| Claude Code CLI (local) | `claude --version` | Instantané |
| Claude Code (distant) | `curl` GitHub API `/repos/anthropics/claude-code/releases/latest` | 10s |
| skills.sh | `curl` page web | 10s |

### Cache

- **Emplacement**: `~/.cache/claude-socle/`
- **Fichiers**: `cli-version.json`, `skills.json`
- **TTL**: 24h par défaut, configurable
- **Format**: JSON simple `{"data": ..., "timestamp": ..., "ttl": ...}`

---

## Fichiers impactés

| Fichier | Action | Description |
|---------|--------|-------------|
| `scripts/check-updates.sh` | CRÉER | Script principal (~250 lignes) |
| `scripts/lib/common.sh` | MODIFIER | Ajouter `cache_read()`, `cache_write()`, `cache_valid()` (~30 lignes) |

Pas de modification de hooks ni de settings — l'intégration SessionStart (US4 P2) sera un ajout futur optionnel.

---

## Architecture du script

```
check-updates.sh
├── parse_args()           # --quiet, --json, --force, --no-cli, --no-skills, --timeout
├── init_cache()           # Créer ~/.cache/claude-socle/ si absent
├── check_cli_version()    # [US1] Version locale vs GitHub API
├── check_skills()         # [US3] Nouveaux skills sur skills.sh
├── print_report()         # [US2] Rapport texte structuré
├── print_json()           # [US5] Sortie JSON
├── print_summary()        # Résumé avec compteurs
└── main()                 # Orchestration
```

### Flux d'exécution

1. `parse_args` → valider options
2. `init_cache` → créer répertoire cache
3. Si `--no-cli` non passé → `check_cli_version` (cache ou réseau)
4. Si `--no-skills` non passé → `check_skills` (cache ou réseau)
5. Si `--json` → `print_json` sinon `print_report` + `print_summary`
6. Code retour : 0 si tout à jour, 1 si mises à jour disponibles, 2 si erreur

---

## Phases

### Phase 1 — P1 : Infrastructure [US1, US2]

Créer le script avec le boilerplate, le parsing d'arguments, le cache, et la vérification de version CLI. C'est le MVP.

### Phase 2 — P2 : Skills communautaires [US3]

Ajouter la vérification skills.sh avec gestion d'erreur réseau.

### Phase 3 — P3 : JSON + Cache TTL [US5, US6]

Ajouter la sortie JSON et le cache avec TTL configurable.

### Phase 4 — P2 : Intégration maintenance [US4]

Ajouter un hook SessionStart optionnel (hors scope initial, à voir).

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| GitHub API rate limit (60 req/h sans auth) | Impossible de vérifier la version CLI | Cache 24h, message d'erreur explicite, utiliser `$GITHUB_TOKEN` si disponible |
| skills.sh change de structure | Parsing cassé | Isoler le parsing dans une fonction, fallback gracieux |
| `claude --version` format change | Extraction version cassée | Regex flexible, test de format avant comparaison |
| Pas de `curl` installé | Script ne fonctionne pas | `check_dependencies curl` au démarrage |
| Pas de `jq` installé | Parsing JSON impossible | Fallback `grep`/`sed` pour extraction basique, `jq` optionnel |

---

## Vérification

```bash
# Tests manuels
scripts/check-updates.sh                    # Mode normal
scripts/check-updates.sh --json             # Sortie JSON
scripts/check-updates.sh --quiet            # Mode silencieux
scripts/check-updates.sh --force            # Ignorer le cache
scripts/check-updates.sh --no-skills        # CLI uniquement
scripts/check-updates.sh --no-cli           # Skills uniquement
scripts/check-updates.sh --json | jq .      # Validation JSON

# Vérification cohérence
scripts/validate.sh                         # Tests du socle
shellcheck scripts/check-updates.sh         # Qualité Bash
```
