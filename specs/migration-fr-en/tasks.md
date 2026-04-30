# Taches : Migration FR -> EN du socle claude-socle

**Input** : `specs/migration-fr-en/spec.md` + `specs/migration-fr-en/plan.md`
**Cree** : 2026-04-30
**Fenetre cible** : jeudi 2026-04-30 22h -> dimanche 2026-05-03 22h

---

## Format des taches : `[ID] [P?] [US?] Description`

- **[P]** : Peut etre executee en parallele (fichiers differents, pas de dependances)
- **[US?]** : User story associee (US1 a US11, voir spec.md)
- **[HEADLESS]** : Tache executee par Claude headless la nuit (pas humain)
- **[BLOCKING HUMAIN]** : Bloque les taches suivantes, requiert action humaine

---

## Conventions

- Tous les chemins sont absolus depuis la racine du repo `claude-socle/`
- Branches : `migration-en/setup` pour Phases 1-3, puis `migration-en/tier-N` pour Phase 4-7
- Commits : Conventional Commits (`feat(migration): ...`, `test(migration): ...`)

---

## Phase 1 : Setup harness (jeudi 2026-04-30, ~3h humain)

**Objectif** : Infrastructure de base pour lancer la nuit 1 a 22h.

- [ ] T001 - Verifier que `specs/migration-fr-en/` et `scripts/migration/` existent (creer si absent)
- [ ] T002 - [P] Implementer `scripts/migration/inventory.sh` :
  - Genere `specs/migration-fr-en/inventory.json` avec liste fichiers par tier (1, 2, 3, 4)
  - Tier 1 : README.md, CLAUDE.md, docs/guides/*.md, docs/reference/*.md, .claude/rules/*.md
  - Tier 2 : .claude/agents/*.md, .claude/commands/**/*.md
  - Tier 3 : .claude/skills/**/*, scripts/hooks/*.sh
  - Tier 4 : website/docs/**/*.md (exclure website/build, website/.docusaurus, website/node_modules)
- [ ] T003 - [P] Rediger `scripts/migration/translate-prompt.md` :
  - Instructions absolues : ne jamais traduire frontmatter `name:`/`type:`, blocs de code, slash commands `/x:y-z`, chemins, identifiants en backticks
  - Charger glossaire YAML
  - Charger blacklist
  - Regle exemples Option C (commentaires `//` `#` traduits, identifiants intacts)
  - Style : conserver le ton, conserver l'humour, conserver les listes/tableaux, ne pas ajouter de contenu
- [ ] T004 - [P] Creer `specs/migration-fr-en/blacklist.txt` :
  - Toutes les slash commands `/work:work-*`, `/dev:dev-*`, `/qa:qa-*`, `/ops:ops-*`, etc.
  - Patterns : chemins `^[a-zA-Z0-9._/-]+\.(md|sh|ts|tsx|js|json|yaml|yml)$`
  - Frontmatter keys : `name:`, `type:`, `description:`, `paths:`
  - Identifiants techniques : noms de hooks, MCP servers, env vars (`SKIP_*`, `ENABLE_*`)
- [ ] T005 - [P] Creer `specs/migration-fr-en/journal.md` (template vide avec sections : Nuit 1, Nuit 2, Nuit 3, Nuit 4, Retro)
- [ ] T006 - Smoke test headless : `echo "Bonjour le monde" | claude --print "Translate to English"` doit retourner "Hello world" ou similaire

**Checkpoint Phase 1** : harness pret, peut prendre un fichier en input et sortir une traduction.

---

## Phase 2 : Glossaire + Validators (jeudi soir, ~3h humain)

**Objectif** : Filets de securite avant la nuit 1. **CRITIQUE - bloque toutes les nuits.**

### Tests TDD (rouge AVANT impl)

- [ ] T007 - [P] [US1] Test bats : `tests/migration/glossary.bats`
  - Verifie format YAML valide
  - Verifie unicite des termes FR
  - Verifie qu'un terme avec lock=true ne peut pas etre modifie
- [ ] T008 - [P] [US3] Test bats : `tests/migration/check-refs.bats`
  - Cas : slash command `/work:work-explore` dans EN -> doit etre detecte si transforme
  - Cas : chemin `docs/guides/PROMPTING-GUIDE.md` -> intact
  - Cas : ancre `#workflow-obligatoire` -> doit pointer vers section existante
- [ ] T009 - [P] [US3] Test bats : `tests/migration/check-structure.bats`
  - Frontmatter YAML inchange (cles intactes)
  - Nombre de blocs de code identique entre FR et EN
  - Nombre de headings H1/H2/H3 identique
- [ ] T010 - [P] [US1] Test bats : `tests/migration/check-glossary.bats`
  - Cas : 2 fichiers ou "boucle" est traduit "loop" et "cycle" -> drift detecte
  - Cas : terme bloque (audit -> seulement "audit" autorise) si traduit "review" -> erreur
- [ ] T011 - [P] [US10] Test bats : `tests/migration/recovery.bats`
  - Scenario : kill du batch milieu fichier, relance, fichiers traites avant kill non retraduits

### Implementation (rouge -> vert)

- [ ] T012 - [US1] Seed `specs/migration-fr-en/glossary.yaml` (50+ termes critiques) :
  - boucle -> loop
  - agent -> agent
  - regle -> rule
  - etape -> step
  - audit -> audit (NE PAS traduire "review")
  - dette -> debt
  - socle -> foundation (ou "scaffold" - a trancher en seed)
  - atelier -> workshop
  - etat -> state
  - hook -> hook (intact)
  - equipe -> team
  - lancement -> launch
  - chantier -> migration / project
  - fenetre -> window
  - vitrine -> showcase
  - workflow -> workflow (intact)
  - tier -> tier (intact)
  - tache -> task
  - exigence -> requirement
  - critere -> criterion
  - cas limite -> edge case
  - revue -> review
  - lecture -> reading
  - cycle -> cycle (intact, mais reserve pour cycle Red-Green-Refactor)
  - couverture -> coverage
  - dette technique -> technical debt
  - decision -> decision
  - choix -> choice
  - mainteneur -> maintainer
  - contributeur -> contributor
  - utilisateur -> user
  - developpeur -> developer
  - feature -> feature (intact)
  - bugfix -> bugfix (intact)
  - branche -> branch
  - commit -> commit (intact)
  - merger -> merge
  - revert -> revert
  - rollback -> rollback
  - point de clarification -> clarification point
  - hors scope -> out of scope
  - scope -> scope (intact)
  - definition de fait -> definition of done
  - fenetre cible -> target window
  - cap -> cap (en contexte rate limit)
  - quota -> quota
  - drift -> drift (intact)
  - ancre -> anchor
  - reference -> reference
  - frontmatter -> frontmatter (intact)
- [ ] T013 - [US3] [P] Implementer `scripts/migration/check-refs.sh` (lit blacklist + grep multi-fichiers, exit 1 si ref cassee)
- [ ] T014 - [US3] [P] Implementer `scripts/migration/check-structure.sh` (compare diff structurel FR vs EN : count headings, count code blocks, frontmatter equivalent)
- [ ] T015 - [US1] [P] Implementer `scripts/migration/check-glossary.sh` (grep cross-fichiers, detecte si terme glossaire traduit differemment)
- [ ] T016 - [US3,US1] Implementer `scripts/migration/validate-translation.sh` (orchestrateur : appelle check-refs, check-structure, check-glossary ; exit 1 si l'un echoue)
- [ ] T017 - [US10] Implementer `scripts/migration/recovery.sh` :
  - Format `state.json` : `{ "files": [{ "path": ..., "status": "todo|in-progress|draft|reviewed|merged", "checksum_source": ..., "tier": N }] }`
  - Au demarrage de batch : lit state.json, skip les `draft|reviewed|merged`
  - Apres traduction d'un fichier : update state.json + git add + git commit
- [ ] T018 - [US1] Implementer `scripts/migration/lock-glossary.sh` :
  - Ajoute `lock: true` a chaque entree
  - Cree git tag `glossary-locked-YYYY-MM-DD`
  - Commit le glossaire avec message explicite
  - Si lock-glossary appele 2 fois -> erreur (sauf flag --force)

**Checkpoint Phase 2** : 5 fichiers bats verts, validators operationnels, glossaire seed pret (NON locke).

---

## Phase 3 : Anti-drift bilingue + CONTRIBUTING (jeudi soir, ~1h humain)

**Objectif** : CI ne casse pas en phase bilingue + politique externe claire.

- [ ] T019 - [US4] Modifier `scripts/validate-counts.sh` :
  - Ajouter flag `--mixed` qui tolere co-existence FR/EN
  - Mode par defaut reste strict (full FR ou full EN)
  - Tester sur sample mixte (1 fichier traduit + reste FR)
- [ ] T020 - [US4] Mettre a jour `.github/workflows/*.yml` (CI) :
  - Identifier le job qui appelle `validate-counts.sh`
  - Pendant phase bilingue (entre debut PR Tier 1 et merge Tier 4) : utiliser `--mixed`
  - Documenter dans le workflow comment retirer le flag (cf T047)
- [ ] T021 - [US8] Creer ou modifier `CONTRIBUTING.md` :
  - Section "Language Policy" : English-only pour code, doc, commits, issues, PRs
  - Politique migration : tolerance zero contribs FR pendant la migration
  - Template de reponse pre-redige : "Hi! We're transitioning to English-first. Could you re-open this in English? Thank you for understanding."
- [ ] T022 - [US8] Mettre a jour `.github/ISSUE_TEMPLATE/*.md` et `.github/PULL_REQUEST_TEMPLATE.md` :
  - Ajouter ligne "All issues / PRs must be in English"
  - Si templates absents, les creer

**Checkpoint Phase 3** : CI passe en mode bilingue sur PR test, contributing aligne.

---

## Phase 4 : Tier 1 - nuit 1 + revue ven matin (jeu nuit + ven matin) 🎯 P1

**Objectif** : Vitrine EN coherent merge sur main vendredi soir.

- [ ] T023 - [US2] [HEADLESS] Lancer `scripts/migration/translate-batch.sh --tier 1` (jeudi 22h-7h)
  - Branche : `migration-en/tier-1` (creer depuis main avant lancement)
  - Cible : ~42 fichiers, ~50k mots
  - Commit par fichier (granularite recovery)
- [ ] T024 - [US6] [BLOCKING HUMAIN] Vendredi matin, revue tier 1 selon methode hybride D :
  - Lecture integrale : `README.md` (30 min) + `CLAUDE.md` (20 min) + `docs/guides/PROMPTING-GUIDE.md` ou equivalent (40 min)
  - Scan rapide : titres + intro + conclusions sur les autres docs/guides + docs/reference (15 min)
  - Spot-checks : 3-4 rules au hasard sur les 31 (15 min)
  - **Decision** : valider OU re-prompter sous-ensemble + corriger glossaire
  - Si revue depasse 2h, reduire scope revue (cf plan.md "Plan de repli")
- [ ] T025 - [US1] Apres validation T024, executer `scripts/migration/lock-glossary.sh`
  - Glossaire fige, tag git cree
  - **NE PAS LANCER LA NUIT 2 AVANT CETTE ETAPE**
- [ ] T026 - [US5] Ouvrir PR Tier 1 via `scripts/migration/create-tier-pr.sh --tier 1`
  - Titre : "feat(migration): translate tier 1 to English (README, CLAUDE.md, guides, rules)"
  - Body : checklist de revue + lien vers spec.md
- [ ] T027 - [US2] Self-review PR + merge sur main (squash ou merge selon policy)
- [ ] T028 - [US11] Mettre a jour `journal.md` : section "Nuit 1" :
  - Heures debut/fin
  - Nb fichiers traites
  - Nb retries
  - Anomalies validators
  - Decisions de revue (qu'est-ce qui a ete corrige ?)

**Checkpoint Phase 4** : Tier 1 sur main, glossaire lock, vitrine EN visible publiquement.

---

## Phase 5 : Tier 2 - nuit 2 (vendredi nuit + samedi matin)

**Objectif** : Agents et commandes en EN.

- [ ] T029 - [US7] [HEADLESS] Lancer `scripts/migration/translate-batch.sh --tier 2` (ven 22h - sam 7h)
  - Branche : `migration-en/tier-2` (creer depuis main APRES merge T027)
  - Cible : 194 fichiers (.claude/agents + .claude/commands), ~80k mots
  - Note : si depasse 200 fichiers, splitter en 2a (agents 63) et 2b (commands 131)
- [ ] T030 - [US7] Sam matin : sampling 10 fichiers tier 2 (~30 min)
  - Verifier glossaire stable (grep des 10 termes principaux)
  - Verifier 0 ref cassee
  - Si drift detecte : re-prompter le sous-ensemble concerne
- [ ] T031 - [US5] Ouvrir PR Tier 2 (branche `migration-en/tier-2`) en mode draft
- [ ] T032 - [US11] Update journal.md (rapport nuit 2)

**Checkpoint Phase 5** : Tier 2 en draft, sampling OK.

---

## Phase 6 : Tier 3 - samedi (jour + nuit)

**Objectif** : Skills, hooks user-facing en EN.

- [ ] T033 - [US7] [HEADLESS] Lancer `scripts/migration/translate-batch.sh --tier 3` (sam apres revue T030 - dim 7h)
  - Branche : `migration-en/tier-3`
  - Cible : 54+ fichiers .claude/skills/**/* + strings user-facing dans scripts/hooks/*.sh
  - Volume : ~60k mots
  - Pour les hooks shell : traduire SEULEMENT les chaines user-facing (echo, printf orientes contributeur), pas les commentaires internes
- [ ] T034 - [US7] Dim matin : sampling 5 skills (~20 min)
- [ ] T035 - [US5] Ouvrir PR Tier 3 (branche `migration-en/tier-3`) en mode draft
- [ ] T036 - [US11] Update journal.md (rapport nuit 3)

**Checkpoint Phase 6** : Tier 3 en draft.

---

## Phase 7 : Tier 4 - dimanche (jour + nuit)

**Objectif** : Site Docusaurus en EN.

- [ ] T037 - [US7] [HEADLESS] Lancer `scripts/migration/translate-batch.sh --tier 4` (dim apres revue T034)
  - Branche : `migration-en/tier-4`
  - Cible : website/docs/**/*.md hors build/.docusaurus/node_modules
  - Volume : ~150k mots (verifier exact via inventory.sh)
  - **Si Tier 4 estime > 1 nuit** : splitter 4a (intro + getting-started, ~50k mots, livre dim) et 4b (le reste, glisse a J+1 lundi nuit)
- [ ] T038 - [US7] Verifier `website/docusaurus.config.ts` :
  - Si config `i18n` presente -> retirer (clarif Q2 : coupe nette)
  - Verifier que `defaultLocale: 'en'` ou ajouter
- [ ] T039 - [US7] Verifier rendu local Docusaurus :
  - `cd website && npm run build` doit passer
  - Smoke test : ouvrir le build et verifier 3 pages au hasard
- [ ] T040 - [US5] Ouvrir PR Tier 4 (branche `migration-en/tier-4`)
- [ ] T041 - [US11] Update journal.md (rapport nuit 4)

**Checkpoint Phase 7** : 4 PRs ouvertes, tiers 2-4 a >=80% draft.

---

## Phase 8 : Polish + cap monitoring + finalisation (lundi matin)

**Objectif** : Garde-fous transverses + retro + reset CI strict.

- [ ] T042 - [P] [US9] Implementer `scripts/migration/check-max-cap.sh`
  - Lit l'usage Max (a determiner : `~/.claude/usage.json` ou call API)
  - Alerte si > 75% du cap hebdo
  - Stoppe le batch si > 90%
  - Ce script peut etre developpe en Phase 8 (pas bloquant pour les nuits, juste un garde-fou si on le fait avant)
- [ ] T043 - [US9] Integrer `check-max-cap.sh` dans `translate-batch.sh` (pause + alerte)
- [ ] T044 - [US10] Documenter recovery dans `journal.md` :
  - Procedure exacte si nuit X plante
  - Comment relancer
  - Comment verifier que rien n'a ete retraduit
- [ ] T045 - [US11] Lundi matin : retro complete dans `journal.md` :
  - Ce qui a marche
  - Ce qui a casse
  - Glossaire final (avec ajouts/corrections faits en cours de route)
  - Temps total mainteneur
  - Recommandations pour replication
- [ ] T046 - [US11] Mettre a jour memoire perso : retirer/marquer "localisation FR -> EN" comme done dans `project_socle_post_launch_roadmap.md`
- [ ] T047 - [US4] Apres merge des 4 PRs : retirer mode `--mixed` de la CI (revient mode strict full-EN)
  - Modifier `.github/workflows/*.yml`
  - Verifier CI verte sur main
- [ ] T048 - [P] [US11] Documenter le harness dans `docs/guides/MIGRATION-GUIDE.md` (replicable sur autre projet)

**Checkpoint Phase 8** : tout merge ou tier 4b documente comme glissant, repo coherent EN, retro disponible.

---

## Dependances et Ordre d'Execution

### Dependances entre phases

```
Phase 1 (Setup harness)
        │
        ▼
Phase 2 (Glossaire + Validators)  ◄──── BLOQUE toutes les nuits
        │
        ▼
Phase 3 (Anti-drift bilingue + CONTRIBUTING)
        │
        ▼
Phase 4 (Tier 1 nuit + revue ven matin) 🎯 P1 - CHECKPOINT HUMAIN T024
        │
        │ T025 (lock glossary) avant Phase 5
        ▼
Phase 5 (Tier 2 nuit)
        │
        ▼
Phase 6 (Tier 3 nuit)
        │
        ▼
Phase 7 (Tier 4 nuit)
        │
        ▼
Phase 8 (Polish + retro)
```

### Dependances entre user stories

| Story | Peut commencer apres | Dependances |
|-------|---------------------|-------------|
| US1 (P1 - glossaire) | Phase 1 | Aucune |
| US2 (P1 - tier 1) | Phase 3 + lock glossaire | US1 |
| US3 (P1 - refs) | Phase 1 | Aucune (couvert par validators) |
| US4 (P1 - anti-drift) | Phase 1 | Aucune |
| US5 (P1 - 4 PRs) | Phase 4 (premiere PR) | Aucune |
| US6 (P1 - checkpoint ven) | Phase 4 (T024) | US2 (tier 1 traduit) |
| US7 (P2 - tiers 2-4) | Phase 4 (lock glossaire) | US1, US2 |
| US8 (P2 - english-first) | Phase 3 | Aucune |
| US9 (P2 - cap Max) | Phase 1 (mais peut decaler en Phase 8) | Aucune |
| US10 (P3 - recovery) | Phase 2 (T011, T017) | US1 |
| US11 (P3 - documentation) | Phase 8 | Toutes les autres |

### Au sein de chaque phase

1. Tests bats DOIVENT etre rouges avant impl (Phase 2 strict)
2. Validators avant runner (Phase 2 avant Phase 4)
3. Lock glossaire AVANT lancer nuit 2 (T025 avant T029)
4. PR ouverte APRES batch termine (pas avant)

### Opportunites de parallelisation

- Phase 1 : T002, T003, T004, T005 sont [P] (developpables en parallele)
- Phase 2 (tests) : T007-T011 sont [P] (5 fichiers bats independants)
- Phase 2 (impl) : T013, T014, T015 sont [P] (3 validators independants)
- Phase 8 : T042, T048 sont [P]
- **Phases 5/6/7 NE SONT PAS paralleles** : meme harness, meme cap Max, meme glossaire (nuits sequentielles)

---

## Strategie d'Implementation

### Ordre obligatoire

1. **Jeudi 14h-21h** : Phases 1, 2, 3 (~7h humain dont 2h tests)
2. **Jeudi 22h - Vendredi 7h** : Phase 4 nuit 1 [HEADLESS]
3. **Vendredi 8h-12h** : Revue tier 1 (T024) + lock (T025) + PR (T026) + merge (T027)
4. **Vendredi 22h - Samedi 7h** : Phase 5 nuit 2 [HEADLESS]
5. **Samedi matin** : Sampling tier 2 (T030) + draft PR (T031)
6. **Samedi 14h - Dimanche 7h** : Phase 6 nuit 3 [HEADLESS]
7. **Dimanche matin** : Sampling tier 3 (T034) + draft PR (T035)
8. **Dimanche 14h - Lundi 7h** : Phase 7 nuit 4 [HEADLESS]
9. **Lundi matin** : Phase 8 (~3h humain)

### Plan de repli si glissement (cf plan.md section "Plan de repli")

| Scenario | Action |
|----------|--------|
| T024 (revue) depasse 2h | Reduire scope revue, tier 1 merge avant 19h |
| T023 (nuit 1) plante | Recovery T017, refaire jeudi nuit ou samedi matin |
| T037 (tier 4) trop gros | Splitter en T037a (intro + getting-started) et T037b (le reste, glisse J+1) |
| Cap Max approche 90% | T042 stoppe le batch, finir avec ce qui est traduit |

### Strategie equipe (parallelisation)

Avec un seul mainteneur (Chris) :
- Toutes les nuits sequentielles (pas de parallelisme entre tiers)
- Possibilite de paralleliser DANS une phase de dev (Phase 1, 2 surtout)
- Si support : T024 (revue) pourrait etre split entre 2 personnes (lecture integrale + spot-checks paralleles)

---

## Notes

- **[P]** taches = fichiers differents, pas de dependances
- **[US?]** label = tracabilite vers la user story
- **[HEADLESS]** = pas de presence humaine, le harness tourne seul
- **[BLOCKING HUMAIN]** = humain requis, bloque les taches suivantes
- Commit apres chaque tache ou groupe logique
- S'arreter a chaque checkpoint pour valider la phase

**A eviter** :
- Lancer la nuit 2 avant T025 (lock glossaire)
- Merger Tier 1 sans T024 (revue humaine)
- Modifier le glossaire apres T025 sans bumper le tag
- Faire confiance a un validator vert sans avoir fait tourner les tests bats au prealable

---

**Version** : 1.0 | **Cree** : 2026-04-30
