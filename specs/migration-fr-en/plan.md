# Plan d'implementation : Migration FR -> EN du socle claude-socle

**Branche** : `migration-en/setup` (puis `migration-en/tier-N` pour chaque tier — local seulement)
**Date** : 2026-04-30
**Spec** : [specs/migration-fr-en/spec.md](./spec.md)
**Statut** : Draft (revisions : 2026-04-30 PM no-PR-until-end decision)

> **REVISION 2026-04-30 fin d'apres-midi** : la decision Q1 du clarify
> ("4 PRs successives sur main mergeables independamment") est OVERRIDE
> par decision utilisateur. Les 4 tier branches restent **locales** pendant
> tout le week-end. Aucun push, aucune PR avant la traduction totale.
> La strategie de publication finale (4 PRs / 1 PR / push direct) sera
> decidee lundi matin une fois tous les tiers traduits. Voir
> [journal.md](./journal.md) section "End-of-weekend checklist" et la
> memoire perso [feedback_no_pr_until_full_translation.md](
> ../../../../home/chris/.claude/projects/-home-chris-source-sideprojects-claude-socle/memory/feedback_no_pr_until_full_translation.md).
> Le checkpoint humain vendredi matin (T024) reste en place, mais sans
> merge ni PR — uniquement validation locale + lock du glossaire.

---

## Resume

Migrer le contenu FR du socle vers EN sur la fenetre jeudi soir 2026-04-30 -> dimanche soir 2026-05-03. Approche : un harness de traduction headless pilote par Claude Max + un glossaire fige + des validateurs anti-drift + une livraison en 4 PRs successives sur `main` (1 par tier). Checkpoint humain vendredi matin pour locker le glossaire avant les nuits 2-4.

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Harness runtime** | `claude` CLI en mode headless (`--print`, `--output-format stream-json`) avec `setup-token` | cf memoire `feedback_claude_max_headless.md` |
| **Modele Claude** | Opus 4.7 | Meilleur sur traduction nuancee + 1M contexte |
| **Glossaire** | YAML structure (`term_fr -> term_en + interdits + contexte + lock`) | Validateur grep multi-fichiers |
| **Etat / Checkpoint** | JSON par fichier (`state.json`), commit a chaque batch | Recovery par diff state vs disk |
| **Validators** | Scripts shell (`bash`) reutilisant patterns existants de `scripts/validate-counts.sh` | Pas de runtime supplementaire |
| **Anti-drift bilingue** | Mode `--mixed` ajoute a `validate-counts.sh` | Detecte la phase transitoire |
| **PR splitter** | `gh` CLI + branches `migration-en/tier-N` | Aligne sur `.claude/rules/git.md` |
| **Tests** | `bats-core` (deja utilise dans `tests/`) | Tests unitaires sur les validators |

### Contraintes

- Cap hebdomadaire Claude Max -> monitoring + priorisation T1 > T2 > T3 > T4
- 4 nuits headless seulement (jeu/ven/sam/dim) -> recovery obligatoire si plantage
- Repo public, branche main protegee, secret scanning ON -> pas de bypass des hooks
- Workflow obligatoire du socle : Explore -> Specify -> Plan -> TDD -> Audit -> Commit
- Anti-pattern declare : commits geants -> max 200 fichiers et 100k mots par PR

### Performance attendue

| Metrique | Cible |
|----------|-------|
| Tier 1 traduit + revu + merge | Vendredi 18h |
| Tiers 2-4 en draft | Dimanche 22h |
| References cassees apres merge | 0 |
| Incoherences glossaire (50 termes) | 0 |
| Cap Max | non epuise avant dim 23h59 |

---

## Verification Constitution / Conventions

- [x] Respecte les conventions du projet (CLAUDE.md, `.claude/rules/git.md`, `.claude/rules/workflow.md`)
- [x] Coherent avec l'architecture existante (reutilise `scripts/`, `tests/bats/`, hooks deja en place)
- [x] Pas d'over-engineering : un harness ad-hoc, pas un framework reutilisable (fait son job puis archive)
- [x] Tests planifies (Phase 2 : validators avec couverture bats)

---

## Structure du Projet

### Documentation (cette feature)

```
specs/migration-fr-en/
├── spec.md           # Specification fonctionnelle (existant)
├── plan.md           # Ce fichier
├── tasks.md          # Decoupage en taches (genere par /work:work-plan)
├── glossary.yaml     # Glossaire terminologique FR -> EN
├── blacklist.txt     # Termes intraduisibles (slash commands, identifiants)
├── inventory.json    # Liste des fichiers par tier (genere)
├── state.json        # Etat par fichier (todo/in-progress/draft/reviewed/merged)
└── journal.md        # Journal de migration (decisions, anomalies)
```

### Code (harness)

```
scripts/migration/
├── translate-batch.sh        # Runner principal (par tier)
├── translate-prompt.md       # Prompt template pour Claude headless
├── inventory.sh              # Liste fichiers par tier
├── lock-glossary.sh          # Lock du glossaire apres revue ven matin
├── validate-translation.sh   # Validator orchestrateur
├── check-refs.sh             # Verif slash commands, chemins, ancres
├── check-structure.sh        # Verif frontmatter, headings, codeblocks
├── check-glossary.sh         # Verif coherence terminologique
├── check-max-cap.sh          # Monitoring usage Max
├── recovery.sh               # Reprise apres plantage
└── create-tier-pr.sh         # Ouverture PR par tier
```

### Tests

```
tests/migration/
├── glossary.bats             # Validation format glossaire
├── check-refs.bats           # Tests du validateur refs
├── check-structure.bats      # Tests du validateur structure
├── check-glossary.bats       # Tests du validateur glossaire
└── recovery.bats             # Test scenario : nuit interrompue
```

---

## Fichiers Impactes

### A creer

| Fichier | Responsabilite |
|---------|----------------|
| `specs/migration-fr-en/glossary.yaml` | Glossaire 50+ termes (seed) |
| `specs/migration-fr-en/blacklist.txt` | Intraduisibles (`/work:work-*`, chemins, identifiants techniques) |
| `specs/migration-fr-en/inventory.json` | Liste fichiers par tier (genere par script) |
| `specs/migration-fr-en/state.json` | Etat par fichier (recovery) |
| `specs/migration-fr-en/journal.md` | Journal des decisions/anomalies pendant les 4 nuits |
| `scripts/migration/translate-batch.sh` | Runner principal par tier |
| `scripts/migration/translate-prompt.md` | Prompt template (instruct Claude pour traduction) |
| `scripts/migration/inventory.sh` | Inventaire fichiers par tier |
| `scripts/migration/lock-glossary.sh` | Lock glossaire post-revue ven matin |
| `scripts/migration/validate-translation.sh` | Validator orchestrateur |
| `scripts/migration/check-refs.sh` | Validator refs internes |
| `scripts/migration/check-structure.sh` | Validator structure |
| `scripts/migration/check-glossary.sh` | Validator glossaire |
| `scripts/migration/check-max-cap.sh` | Monitoring cap Max |
| `scripts/migration/recovery.sh` | Reprise post-plantage |
| `scripts/migration/create-tier-pr.sh` | PR opener par tier |
| `tests/migration/*.bats` | 5 fichiers de tests bats |
| `CONTRIBUTING.md` | Politique english-first + tolerance zero (creer si absent) |

### A modifier

| Fichier | Modification |
|---------|--------------|
| `scripts/validate-counts.sh` | Ajout mode `--mixed` (tolere bilingue temporaire) |
| `README.md` | Tier 1 : traduction integrale + revue humaine |
| `CLAUDE.md` | Tier 1 : traduction integrale + revue humaine |
| `docs/guides/*.md` (5 fichiers) | Tier 1 : traduction + revue 1 guide majeur |
| `docs/reference/*.md` (4 fichiers) | Tier 1 : traduction + scan |
| `.claude/rules/*.md` (31 fichiers) | Tier 1 : traduction + spot-checks 10% |
| `.claude/agents/*.md` (63 fichiers) | Tier 2 : traduction headless |
| `.claude/commands/**/*.md` (131 fichiers) | Tier 2 : traduction headless |
| `.claude/skills/**/*` (54+ fichiers) | Tier 3 : traduction headless |
| `scripts/hooks/*.sh` user-facing strings | Tier 3 : traduction des messages contributeur |
| `website/docs/**/*.md` | Tier 4 : traduction headless |
| `website/docusaurus.config.ts` | Tier 4 : strip i18n config (si presente) |

### Tests a ajouter

| Fichier | Couverture |
|---------|------------|
| `tests/migration/glossary.bats` | Format YAML, unicite des termes, lock |
| `tests/migration/check-refs.bats` | Refs slash commands, chemins, ancres |
| `tests/migration/check-structure.bats` | Frontmatter, headings, code blocks |
| `tests/migration/check-glossary.bats` | Coherence terminologique cross-fichiers |
| `tests/migration/recovery.bats` | Scenario : kill milieu de batch, relance, pas de retraduction |

---

## Approche Choisie

### Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   inventory.sh ──────▶ inventory.json (par tier)                   │
│                              │                                     │
│                              ▼                                     │
│   glossary.yaml ──┐    translate-batch.sh (lance la nuit)          │
│   blacklist.txt ──┤          │                                     │
│   prompt.md ──────┘          │                                     │
│                              ▼                                     │
│                       claude --print (Opus 4.7)                    │
│                              │                                     │
│                              ▼                                     │
│                       fichier traduit (draft)                      │
│                              │                                     │
│                              ▼                                     │
│   validate-translation.sh ◀─┤                                      │
│   ├── check-refs.sh         │                                      │
│   ├── check-structure.sh    │                                      │
│   └── check-glossary.sh     │                                      │
│                              │                                     │
│                       OK ────┴──── KO ── re-prompt (1 retry)       │
│                       │                                            │
│                       ▼                                            │
│                  state.json + commit                               │
│                       │                                            │
│                       ▼                                            │
│   create-tier-pr.sh (en fin de tier)                               │
│                       │                                            │
│                       ▼                                            │
│                  PR sur main                                       │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Justification

- **Headless `claude --print`** : alignement avec memoire `Claude Max works headless on user VMs` ; pas de Routines (pas adaptees au cap Max)
- **Glossaire YAML + validateur grep** : simple, lisible, modifiable a la main, controlable par CI
- **State JSON par fichier** : checkpoint atomique, recovery trivial
- **Validators shell** : aucune nouvelle dep, aligne sur `scripts/validate-counts.sh` existant
- **4 PRs successives sur main** : decision Q1 du clarify, rollback granulaire, valeur capturee progressivement
- **Tests bats** : framework deja utilise, pas de nouveau runner

### Alternatives considerees

| Alternative | Pourquoi rejetee |
|-------------|------------------|
| Routines Anthropic (planificateur cloud) | Memoire perso : Max est headless sur VM user, Routines ne servent pas ici |
| Service de traduction tiers (DeepL, Google Translate) | Pas de respect du glossaire, pas d'instruction sur les refs intraduisibles, qualite inferieure sur du markdown technique |
| Branche longue `migration-en` mergee a la fin | Rejete en clarify Q1 (anti-pattern PR geante) |
| i18n natif Docusaurus avec cohabitation FR+EN | Rejete en clarify Q2 (double maintenance, drift) |
| Renommage des identifiants de variables (`prenom` -> `firstName`) | Rejete en clarify Q3 (risque casse + faible valeur ajoutee) |
| Tolerance contribs FR pendant la migration | Rejete en clarify Q4 (signal contradictoire) |
| Revue mot a mot tier 1 (Option A clarify Q5) | Rejete : 4-6h vendredi matin -> rate la nuit 2 |

---

## Phases d'Implementation

### Phase 1 : Setup harness (jeudi 2026-04-30, apres-midi/soir, ~3h humain)

**Objectif** : Infrastructure de base pour lancer la nuit 1 a 22h.

**Couvre** : prereqs US1, US3, US4, US5, US10

- T001 - Creer `scripts/migration/` et `specs/migration-fr-en/` (deja partiel)
- T002 - [P] Implementer `scripts/migration/inventory.sh` (genere `inventory.json` listant fichiers par tier)
- T003 - [P] Rediger `scripts/migration/translate-prompt.md` (template avec glossaire, blacklist, regle exemples C, regle frontmatter, regle structure)
- T004 - [P] Creer `specs/migration-fr-en/blacklist.txt` (slash commands, chemins, frontmatter `name:`, identifiants)
- T005 - [P] Creer `specs/migration-fr-en/journal.md` (template vide, rempli au fil de l'eau)
- T006 - Verifier `claude setup-token` operationnel sur la VM (smoke test : `echo "test" | claude --print "Translate to English"`)

**Checkpoint Phase 1** : harness pret, peut prendre un fichier en input et sortir une traduction.

### Phase 2 : Glossaire + Validators (jeudi soir, ~3h humain)

**Objectif** : Filets de securite avant la nuit 1. **CRITIQUE - bloque toutes les nuits.**

**Couvre** : US1 (P1), US3 (P1), US4 (P1), US10 (P3)

#### Tests (TDD strict, cf `.claude/rules/tdd-enforcement.md`)
- T007 - [P] [US1] Test bats : `tests/migration/glossary.bats` (format YAML, unicite, lock)
- T008 - [P] [US3] Test bats : `tests/migration/check-refs.bats` (slash command preserve, chemin preserve, ancre preservee)
- T009 - [P] [US3] Test bats : `tests/migration/check-structure.bats` (frontmatter intact, codeblocks intacts, headings count)
- T010 - [P] [US1] Test bats : `tests/migration/check-glossary.bats` (drift detecte sur 2 traductions divergentes)
- T011 - [P] [US10] Test bats : `tests/migration/recovery.bats` (kill milieu, relance, pas de retraduction)

#### Implementation (rouge -> vert)
- T012 - [US1] Seed `specs/migration-fr-en/glossary.yaml` avec 50+ termes (boucle, agent, regle, etape, audit, dette, socle, atelier, etat, hook, equipe, lancement, atelier, fond, fond, atelier, etc.)
- T013 - [US3] [P] Implementer `scripts/migration/check-refs.sh`
- T014 - [US3] [P] Implementer `scripts/migration/check-structure.sh`
- T015 - [US1] [P] Implementer `scripts/migration/check-glossary.sh`
- T016 - [US3,US1] Implementer `scripts/migration/validate-translation.sh` (orchestrateur des 3)
- T017 - [US10] Implementer `scripts/migration/recovery.sh` + format `state.json`
- T018 - [US1] Implementer `scripts/migration/lock-glossary.sh`

**Checkpoint Phase 2** : tests bats verts, validators operationnels, glossaire seed pret.

### Phase 3 : Anti-drift bilingue + CONTRIBUTING (jeudi soir, ~1h humain)

**Objectif** : CI ne casse pas en phase bilingue + politique externe claire.

**Couvre** : US4 (P1), US8 (P2)

- T019 - [US4] Modifier `scripts/validate-counts.sh` : ajouter mode `--mixed` (tolere mix FR/EN), tester sur sample
- T020 - [US4] Mettre a jour CI workflow (`.github/workflows/*.yml`) : utiliser `--mixed` pendant phase bilingue
- T021 - [US8] Creer/modifier `CONTRIBUTING.md` : section "Language policy" + tolerance zero contribs FR
- T022 - [US8] Mettre a jour `.github/ISSUE_TEMPLATE/` et `.github/PULL_REQUEST_TEMPLATE.md` (mention EN-only)

**Checkpoint Phase 3** : CI passe en mode bilingue, contributing aligne.

### Phase 4 : Tier 1 - nuit 1 + revue vendredi matin (jeu nuit + ven matin) 🎯

**Objectif** : Vitrine EN coherent merge sur main vendredi soir.

**Couvre** : US2 (P1), US6 (P1), partie US5 (P1)

- T023 - [US2] [HEADLESS] Lancer `translate-batch.sh --tier 1` (jeudi 22h-7h)
  - Cible : README.md, CLAUDE.md, docs/guides/* (5 fichiers), docs/reference/* (4 fichiers), .claude/rules/*.md (31 fichiers)
  - Volume : ~50k mots, ~42 fichiers
- T024 - [US6] **[BLOCKING HUMAIN]** Vendredi matin, revue tier 1 selon methode hybride D :
  - Lecture integrale : README.md + CLAUDE.md + 1 guide majeur (1.5h)
  - Scan rapide : titres + intro + conclusions sur les autres docs/guides + docs/reference (15 min)
  - Spot-checks : 3-4 rules au hasard sur les 31 (15 min)
  - Decision : valider OU re-prompter sous-ensemble + corriger glossaire
- T025 - [US1] Apres validation, executer `lock-glossary.sh` (glossaire fige)
- T026 - [US5] Ouvrir PR Tier 1 via `create-tier-pr.sh` (branche `migration-en/tier-1`)
- T027 - [US2] Self-review PR + merge sur main
- T028 - [US11] Mettre a jour `journal.md` : rapport nuit 1 (anomalies, retries, decisions revue)

**Checkpoint Phase 4** : Tier 1 sur main, glossaire lock, vitrine EN.

### Phase 5 : Tier 2 - nuit 2 (vendredi nuit + samedi matin)

**Objectif** : Agents et commandes en EN.

**Couvre** : US7 (P2), partie US5

- T029 - [US7] [HEADLESS] Lancer `translate-batch.sh --tier 2` (ven 22h - sam 7h)
  - Cible : .claude/agents/*.md (63 fichiers), .claude/commands/**/*.md (131 fichiers)
  - Volume : ~80k mots, 194 fichiers
- T030 - [US7] Sam matin : sampling 10 fichiers tier 2 (~30 min) + verifier glossaire stable
- T031 - [US5] Ouvrir PR Tier 2 (branche `migration-en/tier-2`) - draft d'abord
- T032 - [US11] Update journal.md (rapport nuit 2)

**Checkpoint Phase 5** : Tier 2 en draft, sampling OK.

### Phase 6 : Tier 3 - samedi (jour + nuit)

**Objectif** : Skills, hooks user-facing en EN.

**Couvre** : US7 (P2), partie US5

- T033 - [US7] [HEADLESS] Lancer `translate-batch.sh --tier 3` (sam apres revue T030 - dim 7h)
  - Cible : .claude/skills/**/* (54+ fichiers), scripts/hooks/*.sh strings user-facing
  - Volume : ~60k mots
- T034 - [US7] Dim matin : sampling 5 skills (~20 min)
- T035 - [US5] Ouvrir PR Tier 3 (branche `migration-en/tier-3`) - draft
- T036 - [US11] Update journal.md (rapport nuit 3)

**Checkpoint Phase 6** : Tier 3 en draft.

### Phase 7 : Tier 4 - dimanche (jour + nuit)

**Objectif** : Site Docusaurus en EN.

**Couvre** : US7 (P2), partie US5, decision Q2 (coupe nette i18n)

- T037 - [US7] [HEADLESS] Lancer `translate-batch.sh --tier 4` (dim apres revue T034)
  - Cible : website/docs/**/*.md (estimer ~150-200k mots, le plus gros tier)
  - Volume : ~150k mots
- T038 - [US7] Verifier que `website/docusaurus.config.ts` ne contient pas de config i18n a stripper (clarif Q2)
- T039 - [US7] Verifier rendu local Docusaurus (`cd website && npm run build`)
- T040 - [US5] Ouvrir PR Tier 4 (branche `migration-en/tier-4`)
- T041 - [US11] Update journal.md (rapport nuit 4)

**Checkpoint Phase 7** : 4 PRs ouvertes, tiers 2-4 a >=80% draft.

### Phase 8 : Polish + cap monitoring + finalisation (transverse)

**Objectif** : Garde-fous transverses + retro.

**Couvre** : US9 (P2), US11 (P3), US10 (P3)

- T042 - [US9] [P] Implementer `scripts/migration/check-max-cap.sh` (lit `~/.claude/usage.json` ou equivalent, alerte si > 75% du cap)
- T043 - [US9] Integrer check-max-cap dans `translate-batch.sh` (pause si seuil atteint)
- T044 - [US10] Documenter recovery dans `journal.md` (procedure exacte)
- T045 - [US11] Lundi matin : retro complete dans `journal.md` (ce qui a marche, ce qui a casse, glossaire final)
- T046 - [US11] Mettre a jour roadmap perso (memoire) : retirer/marquer "localisation FR -> EN" comme done
- T047 - [US4] Apres merge des 4 PRs : retirer mode `--mixed` de la CI (revient mode strict full-EN)
- T048 - [P] [US11] Documenter le harness dans `docs/guides/MIGRATION-GUIDE.md` (replicable sur autre projet)

**Checkpoint Phase 8** : tout merge, repo coherent EN, retro disponible.

---

## Risques et Mitigations

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| **Glossaire derive entre nuits** | Eleve (incoherence sur 700+ fichiers) | Moyenne | Lock script (T018) + validateur cross-fichiers (T015) + checkpoint humain ven (T024) |
| **References cassees** | Eleve (workflows users casses) | Moyenne | Validator T013 + blacklist T004 + tests bats T008 |
| **Nuit headless plante** | Moyen (perte d'1 nuit) | Moyenne | Recovery T017 (checkpoint par fichier) + tests T011 |
| **Cap Max epuise avant fin** | Eleve (Tier 4 non termine) | Moyenne | Monitor T042 + priorisation T1>T2>T3>T4 + Tier 4 acceptable a J+1 |
| **Revue tier 1 ven matin depasse 2h** | Moyen (rate la nuit 2) | Moyenne | Methode hybride D (1.5-2h max), si depasse -> reduire scope revue, ne pas re-prompter intensivement |
| **Tier 4 (Docusaurus) trop gros (~150k mots)** | Eleve (depasse une nuit) | Elevee | Si Tier 4 ne tient pas, decouper en 4a (intro + getting-started) et 4b (le reste) ; 4b peut glisser a J+1 |
| **PR Tier 2 > 200 fichiers (194 fichiers)** | Faible (sous le seuil) | Faible | Si depasse, splitter en 2a (agents) et 2b (commands) |
| **Contribution externe FR pendant migration** | Faible | Faible | CONTRIBUTING T021 + template PR/issue T022 + reponse polie pre-redigee |
| **validate-counts.sh casse en mode bilingue** | Moyen (CI rouge bloque les merges) | Moyenne | Mode `--mixed` T019 + tests T011 + fallback : skip CI sur PR tier (manuellement) |
| **CI hooks bloquent un commit EN** | Faible | Faible | Tester chaque hook sur un fichier EN avant T023 |
| **Identifiants de fichiers traduits (Bouton.tsx)** | Faible | Faible | Clarif Q3 (Option C) + blacklist T004 explicite |
| **Lock glossaire trop tot** | Moyen (pas de correction possible) | Faible | Lock = soft : commit + tag, retire-able mais traceable |

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
Phase 4 (Tier 1 nuit + revue ven matin) 🎯 P1 - CHECKPOINT HUMAIN
        │
        ▼
Phase 5 (Tier 2 nuit) ─────────────┐
        │                          │
        ▼                          │
Phase 6 (Tier 3 nuit) ─────────────┤
        │                          │
        ▼                          │
Phase 7 (Tier 4 nuit) ─────────────┤
        │                          │
        ▼                          ▼
Phase 8 (Polish + retro)     [Phases 5-7 sequentielles, pas paralleles : meme harness, meme cap Max]
```

### Taches parallelisables a l'interieur d'une phase

- Phase 1 : T002, T003, T004, T005 sont [P]
- Phase 2 (tests) : T007-T011 sont [P] (fichiers differents)
- Phase 2 (impl) : T013, T014, T015 sont [P] (fichiers differents)
- Phase 8 : T042, T048 sont [P]

### Sequencement strict

- Phase 4 (revue T024) **bloque** Phases 5/6/7 (lock glossaire = prereq)
- T025 (lock) doit etre execute APRES T024 (revue) et AVANT T029 (nuit 2)

---

## Criteres de Validation

### Avant de commencer (Gate 1 - jeudi soir 22h)
- [x] Spec approuvee (clarify termine)
- [ ] Plan reviewe (cette etape)
- [ ] Phase 1 terminee (harness pret)
- [ ] Phase 2 terminee (validators verts)
- [ ] Phase 3 terminee (CI tolerante bilingue)
- [ ] `claude setup-token` operationnel
- [ ] Branche `migration-en/tier-1` creee depuis main

### Avant chaque merge de tier (Gate 2)
- [ ] `validate-translation.sh` vert sur tous les fichiers du tier
- [ ] `check-refs.sh` : 0 ref cassee
- [ ] `check-glossary.sh` : 0 incoherence
- [ ] CI mode `--mixed` verte
- [ ] Tier 1 uniquement : revue humaine validee

### Avant retro (Gate 3 - lundi matin)
- [ ] 4 PRs mergees ou tier 4 documente comme glissant a J+1
- [ ] CI repassee en mode strict (T047)
- [ ] `journal.md` complet (nuits 1-4 + retro)
- [ ] Memoire perso mise a jour
- [ ] CS-001 a CS-010 verifies (cf spec section 6)

---

## Strategie d'Implementation

### Ordre obligatoire

1. Phase 1 (Setup) : jeudi apres-midi
2. Phase 2 (Validators TDD) : jeudi soir avant 21h
3. Phase 3 (Anti-drift + CONTRIBUTING) : jeudi soir avant 22h
4. Phase 4 (Tier 1) : jeudi 22h -> vendredi 18h (incluant revue humaine + merge)
5. Phase 5 (Tier 2) : vendredi 22h -> samedi midi
6. Phase 6 (Tier 3) : samedi apres-midi/soir -> dimanche midi
7. Phase 7 (Tier 4) : dimanche apres-midi/soir
8. Phase 8 (Polish) : lundi matin

### Plan de repli si glissement

| Scenario | Action |
|----------|--------|
| Phase 4 revue depasse 2h | Reduire le scope revue (lecture integrale = README + CLAUDE.md uniquement) ; tier 1 merge avant 19h |
| Nuit 1 plante | Recovery T017 ; si non recuperable, refaire jeudi nuit ; tier 1 reportable a sam matin |
| Tier 4 ne tient pas dans la nuit dim | Splitter 4a/4b ; merger 4a dim soir, 4b lundi |
| Cap Max approche 90% | Skip Phase 8 polish, finir tier 4 puis stop ; T042 envoie alerte des 75% |
| Plus d'une nuit perdue | Tier 4 glisse a J+1 (mardi nuit), assume scope CS-002 a 80% est tenable |

---

## Notes

- **Important** : la regle 4 PRs separees impose que chaque branche `migration-en/tier-N` parte de `main` actuel. Apres merge tier 1, rebase tier 2 sur le nouveau main.
- **Glossaire seed** : commencer petit (50 termes critiques) plutot que grand (200+ termes diluant les choix). Etend a la volee si drift detectee en validation.
- **Prompt template** : le prompt doit ABSOLUMENT instruire Claude de NE JAMAIS toucher : (a) frontmatter `name:` / `type:` / `description:`, (b) blocs de code, (c) slash commands `/x:y-z`, (d) chemins, (e) noms de fichiers en backticks. Iterer le prompt sur 3-5 samples avant la nuit 1.
- **Recovery** : checkpoint = fichier traduit + valide + commit (pas seulement traduit). Si plantage milieu de batch, le commit garde l'avancement. Au reboot, `recovery.sh` lit `state.json` et reprend.

---

**Version** : 1.0 | **Cree** : 2026-04-30 | **Derniere modification** : 2026-04-30
