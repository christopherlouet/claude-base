# Journal de migration FR -> EN

> Cree : 2026-04-30
> Rempli au fil des nuits headless et de la revue humaine.
> Sert a la retro lundi matin (T045) et a la documentation du processus (T048).

---

## Setup (jeudi 2026-04-30 apres-midi)

### Decouvertes

- **website/docs/{commands,agents,skills,rules}/ sont AUTO-GENERES** depuis `.claude/*` via `website/scripts/generate-*.ts`. Exclus de Tier 4. Regenerer apres merge T2+T3 via `cd website && npm run generate`.
- **Volumes reels** (via `inventory.sh`) :
  - Tier 1 : 44 fichiers, 37,711 mots
  - Tier 2 : 194 fichiers, 45,525 mots
  - Tier 3 : 96 fichiers, 60,233 mots
  - Tier 4 : 77 fichiers, 111,016 mots
  - **Total : 411 fichiers, 254,485 mots** (~38% moins que l'estimation initiale de 410k)

### Decisions affinees vs spec/plan initial

- Tier 4 confortable dans une nuit, plan B 4a/4b non necessaire (sauf imprevu)
- Total scope plus petit que prevu -> marge confortable sur cap Max
- Phase 1 demarree en pair-programming jeudi apres-midi (avance de quelques heures)

### Anomalies / questions

- T006 (smoke test claude headless) : confiee a l'utilisateur, a faire depuis un shell separe
- Bug attrape pendant l'e2e sanity check : translate-batch.sh --dry-run avec --root par defaut ecrit dans les vrais fichiers du repo (3 fichiers contamines avec marqueur, restaures via git restore). Safety guard ajoute (refuse --dry-run si --root pointe sur le repo du script).

### Procedure de lancement Nuit 1

```bash
# 1. Pre-flight
cd /home/chris/source/sideprojects/claude-socle
git checkout main && git pull
scripts/validate-counts.sh --mixed   # confirm baseline green
bats tests/migration/                # confirm 58/58 green

# 2. Smoke test Claude (a faire AVANT, depuis un autre shell, sinon nesting)
echo "Bonjour le monde" | claude --print "Translate to English. Output only the translation."

# 3. Creer la branche tier-1
git checkout -b migration-en/tier-1

# 4. Bring the harness from the setup branch
git checkout feature/migration-fr-en-setup -- \
    scripts/migration/ \
    tests/migration/ \
    specs/migration-fr-en/ \
    CONTRIBUTING.md \
    .github/ISSUE_TEMPLATE/ \
    .github/PULL_REQUEST_TEMPLATE.md \
    .github/workflows/ci.yml \
    scripts/validate-counts.sh
git commit -m "chore(migration): bring tier-1 harness onto branch"

# 5. SAFETY MICRO-TEST: 1 file with REAL claude (no commit, no validate, inspect manually)
scripts/migration/translate-batch.sh --tier 1 --limit 1 --no-commit
# Inspect README.md (or whichever was the first pending file)
git diff README.md   # check the translation looks reasonable
# If bad: git restore README.md and adjust prompt before launching the full batch

# 6. FULL BATCH (the night)
nohup scripts/migration/translate-batch.sh --tier 1 \
    > specs/migration-fr-en/nuit-1.log 2>&1 &
echo $! > specs/migration-fr-en/nuit-1.pid

# To monitor (from another shell):
tail -f specs/migration-fr-en/nuit-1.log
git log --oneline migration-en/tier-1   # commits accumulating

# To stop gracefully:
kill $(cat specs/migration-fr-en/nuit-1.pid)
# State.json preserves progress; relaunch resumes where it stopped.
```

### Recovery procedure (if a night crashes)

```bash
# Inspect state
jq '[.files[] | group_by(.status) | {status: .[0].status, count: length}] | from_entries' \
    specs/migration-fr-en/state-tier-1.json

# Find files marked done but not yet committed (inconsistency window)
git status   # any *.md in modified state should match state.json done entries

# Resume: the runner picks up automatically from state.json
scripts/migration/translate-batch.sh --tier 1
```

### Friday morning checklist (T024 hybrid review D)

> **DECISION 2026-04-30 (revised)**: NO push, NO PR until full translation
> done (end of weekend). All tier branches stay LOCAL until then. The tier 1
> branch is reviewed but stays unmerged through Sunday/Monday.

```bash
git checkout migration-en/tier-1
# Hybrid review D:
# - Full read: README.md, CLAUDE.md, 1 major guide
# - Quick scan: titles+intros+conclusions on remaining guides
# - Spot-checks: 3-4 random rules

# Mark files reviewed (informative only, no merge yet):
scripts/migration/recovery.sh mark-reviewed --state specs/migration-fr-en/state-tier-1.json --file README.md
# (or run validators in batch on the whole tier — see verify mode)

# After validation:
scripts/migration/lock-glossary.sh    # T025 — locks glossary, creates git tag

# DO NOT push, DO NOT create a PR — keep everything local until end of weekend.
# Then prepare nuit 2:
git checkout main && git checkout -b migration-en/tier-2
git checkout feature/migration-fr-en-setup -- scripts/migration/ tests/migration/ specs/migration-fr-en/ \
    CONTRIBUTING.md .github/ scripts/validate-counts.sh
git commit -m "chore(migration): bring tier-2 harness onto branch"
```

### End-of-weekend checklist (lundi matin, after all 4 tiers done)

```bash
# Verify all 4 tier branches exist and have commits
for t in 1 2 3 4; do
    git log --oneline migration-en/tier-$t | head -3
done

# Decide publication strategy (one of):
# A) 4 PRs successive: push each branch and create PR, merge in order
# B) 1 squashed PR: create a "translate-all" branch from main, cherry-pick from each tier, push, PR
# C) Direct push: rebase each tier onto main and fast-forward push

# Whichever strategy: this is when GitHub gets the changes, not before.
```

---

## Nuit 1 — Tier 1 (jeudi 2026-04-30 soir/nuit)

### Lancement

- Heure debut :
- Branche : `migration-en/tier-1`
- Cible : 44 fichiers, ~37k mots

### Deroulement

- Heure fin :
- Fichiers traites :
- Fichiers en erreur :
- Retries necessaires :

### Validators

- check-refs.sh :
- check-structure.sh :
- check-glossary.sh :

### Anomalies / observations

(a remplir)

---

## Revue humaine — Tier 1 (vendredi 2026-05-01 matin)

### Methode hybride D appliquee

- [ ] Lecture integrale README.md (cible 30 min)
- [ ] Lecture integrale CLAUDE.md (cible 20 min)
- [ ] Lecture integrale 1 guide majeur : ____ (cible 40 min)
- [ ] Scan rapide autres docs/guides + docs/reference (cible 15 min)
- [ ] Spot-checks 3-4 rules sur 31 (cible 15 min)

### Corrections appliquees

(lister chaque correction + raison)

### Decision finale

- [ ] Tier 1 valide pour merge
- [ ] Glossaire lock execute (T025)
- [ ] PR Tier 1 ouverte
- [ ] PR Tier 1 mergee

### Temps total revue

___ minutes (cible : 90-120 min)

---

## Nuit 2 — Tier 2 (vendredi 2026-05-01 soir/nuit)

### Lancement

- Heure debut :
- Branche : `migration-en/tier-2`
- Cible : 194 fichiers, ~45k mots

### Deroulement

- Heure fin :
- Fichiers traites :
- Fichiers en erreur :

### Sampling samedi matin

- 10 fichiers samples :
- Drift glossaire detecte ? :
- Refs cassees ? :

### Anomalies / observations

(a remplir)

---

## Nuit 3 — Tier 3 (samedi 2026-05-02 soir/nuit)

### Lancement

- Heure debut :
- Branche : `migration-en/tier-3`
- Cible : 96 fichiers, ~60k mots

### Deroulement

- Heure fin :
- Fichiers traites :
- Fichiers en erreur :

### Sampling dimanche matin

- 5 skills samples :
- Anomalies :

### Anomalies / observations

(a remplir)

---

## Nuit 4 — Tier 4 (dimanche 2026-05-03 soir/nuit)

### Lancement

- Heure debut :
- Branche : `migration-en/tier-4`
- Cible : 77 fichiers, ~111k mots

### Deroulement

- Heure fin :
- Fichiers traites :
- Fichiers en erreur :

### Verification Docusaurus

- [ ] `cd website && npm run generate` (regen auto-generated dirs)
- [ ] `cd website && npm run build` passe
- [ ] Smoke test 3 pages au hasard

### Anomalies / observations

(a remplir)

---

## Retro (lundi 2026-05-04 matin)

### Ce qui a marche

(a remplir)

### Ce qui a casse

(a remplir)

### Glossaire final

(noter ajouts/corrections faits en cours de route)

### Temps mainteneur total

___ heures cumulees sur la fenetre jeu->lun

### Recommandations pour replication sur autre projet

(a remplir)

### Etat final des criteres de succes (cf spec.md section 6)

| ID | Critere | Cible | Atteint ? |
|----|---------|-------|-----------|
| CS-001 | Tier 1 traduit, revu, et merge | 100% | |
| CS-002 | Tiers 2-4 traduits en draft | >=80% | |
| CS-003 | References internes cassees | 0 | |
| CS-004 | Incoherences terminologiques (50 termes) | 0 | |
| CS-005 | PRs livrees | 4 separees | |
| CS-006 | Cap Claude Max | non epuise dim 23h59 | |
| CS-007 | Anti-drift apres merge des 4 PRs | 100% vert | |
| CS-008 | Qualite tier 1 (revue humaine) | approuve | |
| CS-009 | Temps total relecture humaine | < 8h cumul | |
| CS-010 | Structure preservee (frontmatter, headings) | 100% | |
