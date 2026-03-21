# Tâches : Veille Automatique Claude Code et Skills

**Plan**: `specs/check-updates/plan.md`

---

## Phase 1 — MVP : Infrastructure + CLI version [US1, US2]

- [ ] **T001** [US1] — Ajouter fonctions cache dans `scripts/lib/common.sh` : `cache_read()`, `cache_write()`, `cache_valid()` avec support TTL et répertoire `~/.cache/claude-socle/`
  - Fichier: `scripts/lib/common.sh` (ajouter en fin de fichier, ~30 lignes)
  - Pattern: JSON simple `{"data": "...", "timestamp": 1234567890, "ttl": 86400}`

- [ ] **T002** [US1] — Créer `scripts/check-updates.sh` avec boilerplate : header, `source common.sh`, `enable_error_handler`, `check_base_requirements`, `check_dependencies curl`
  - Fichier: `scripts/check-updates.sh` (CRÉER)
  - Pattern: copier structure de `doctor.sh` L1-30

- [ ] **T003** [US1] — Implémenter `show_help()` et `parse_args()` : options `--quiet`, `--json`, `--force`, `--no-cli`, `--no-skills`, `--timeout N`
  - Fichier: `scripts/check-updates.sh`
  - Pattern: copier structure de `update.sh` parse_args

- [ ] **T004** [US1] — Implémenter `check_cli_version()` : extraire version locale via `claude --version`, requêter GitHub API `repos/anthropics/claude-code/releases/latest`, comparer avec `version_gte()`, gérer cache et erreurs réseau
  - Fichier: `scripts/check-updates.sh`
  - Edge cases: CLI non installé, hors ligne, rate limit, format version inconnu

- [ ] **T005** [US2] — Implémenter `print_report()` : afficher résumé texte avec `section()`, compteurs (à jour / mises à jour / erreurs), lien vers releases si mise à jour disponible
  - Fichier: `scripts/check-updates.sh`
  - Pattern: `doctor.sh` print_summary

- [ ] **T006** [US1, US2] — Implémenter `main()` : orchestration parse_args → init_cache → check_cli → print_report, code retour (0=à jour, 1=mises à jour, 2=erreur)
  - Fichier: `scripts/check-updates.sh`

- [ ] **T007** [US1] — Rendre le script exécutable et tester manuellement : mode normal, `--quiet`, `--force`, `--no-skills`, hors ligne (déconnecter réseau)
  - Commande: `chmod +x scripts/check-updates.sh`
  - Tests: 5 scénarios manuels

## Phase 2 — Skills communautaires [US3]

- [ ] **T008** [US3] — Implémenter `check_skills()` : requêter skills.sh, parser la liste (nom + description + lien), comparer avec cache précédent, afficher nouveaux skills
  - Fichier: `scripts/check-updates.sh`
  - Edge cases: skills.sh inaccessible, structure changée, aucun nouveau skill

- [ ] **T009** [US3] — Intégrer `check_skills()` dans `main()` et `print_report()` : ajouter section skills dans le rapport, respecter `--no-skills`
  - Fichier: `scripts/check-updates.sh`

- [ ] **T010** [US3] — Tester : skills.sh accessible, inaccessible, `--no-skills`, première exécution sans cache
  - Tests: 4 scénarios manuels

## Phase 3 — JSON + Cache TTL [US5, US6]

- [ ] **T011** [P] [US5] — Implémenter `print_json()` : sortie JSON valide avec cli_version, skills, statut global, timestamp
  - Fichier: `scripts/check-updates.sh`
  - Validation: `scripts/check-updates.sh --json | jq .`

- [ ] **T012** [P] [US6] — Ajouter support `--timeout N` dans les appels `curl` et TTL cache configurable via variable `CHECK_UPDATES_TTL` (défaut 86400s = 24h)
  - Fichier: `scripts/check-updates.sh`

- [ ] **T013** [US5, US6] — Tester : `--json` valide, cache expiré vs frais, `--force` ignore le cache, double exécution rapide utilise le cache
  - Tests: 4 scénarios manuels

## Vérification finale

- [ ] **T014** — Lancer `shellcheck scripts/check-updates.sh` et corriger les warnings
- [ ] **T015** — Lancer `scripts/validate.sh` et vérifier OK
- [ ] **T016** — Vérifier que le script fonctionne sur une connexion lente (timeout 3s) et hors ligne

---

## Résumé

| Phase | Tâches | US | Parallélisable |
|-------|--------|----|----------------|
| 1 (MVP) | T001-T007 | US1, US2 | T002+T003 [P] après T001 |
| 2 | T008-T010 | US3 | Séquentiel |
| 3 | T011-T013 | US5, US6 | T011+T012 [P] |
| Vérif | T014-T016 | — | Séquentiel |

**Total**: 16 tâches, complexité Moyenne, 1 fichier créé + 1 modifié.
