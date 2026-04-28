# Agent QA-LOOP

Boucle autonome AUDIT (parallele) → VALIDATE → FIX → VERIFY → CHECK avec criteres d'arret.

Aligne sur le pattern Anthropic 2026 (plugin officiel `code-review`) :
- Phase AUDIT en parallele (4 sub-agents : qa-security, qa-perf, wcag-audit, qa-claudemd)
- Phase VALIDATE filtre les faux positifs (1 sub-agent par finding)
- Filtre high-signal : exclut nitpicks/style
- Auto-scope `git diff main...HEAD` par defaut

## Contexte
$ARGUMENTS

## Objectif

Executer une boucle continue d'amelioration qualite : auditer le projet en parallele,
valider les findings (filtre faux positifs), corriger les problemes P0/P1 high-signal,
verifier les tests, et recommencer jusqu'a atteindre le score cible.

## Parametres (extraire de $ARGUMENTS)

- **Score cible** : score minimum pour arreter (defaut: 90/100)
- **Max iterations** : nombre maximum de cycles (defaut: 5)
- **Domaines** : securite, perf, a11y, claudemd (defaut: tous)
- **Severite** : P0+P1 (defaut), ou P0 uniquement
- **Scope** : `git diff main...HEAD` par defaut, ou chemin/glob/`--full` explicite

## Flags

| Flag | Effet |
|------|-------|
| `--audit-only` | Audit + rapport, **pas de FIX** (mode lecture seule, equivalent plugin Anthropic) |
| `--comment` | Post inline sur la PR courante via `gh pr comment` (necessite gh + PR ouverte) |

## Workflow

```
AUDIT (4 sub-agents paralleles) → VALIDATE (filtre faux positifs)
  → FILTER (high-signal P0/P1 uniquement) → FIX (sauf --audit-only)
  → VERIFY (tests) → CHECK (criteres) → BOUCLE ou STOP
```

1. **AUDIT** : 4 sub-agents Task en parallele (qa-security/qa-perf/wcag-audit/qa-claudemd)
2. **VALIDATE** : 1 sub-agent par finding pour confirmer ou rejeter
3. **FILTER** : exclut nitpicks/style, ne garde que P0/P1 high-signal
4. **FIX** : corriger P0 puis P1 avec TDD, commits atomiques (skippe si `--audit-only`)
5. **VERIFY** : tests complets, lint, type-check — revert si regression
6. **CHECK** : score >= cible ET 0 P0/P1 → STOP, sinon → AUDIT

## Output attendu

1. **Par iteration** : tableau scores par domaine, findings bruts vs confirmes, fixes appliques
2. **Rapport final** : score initial → final, fixes total, faux positifs filtres, problemes restants
3. **Commits** : un par fix, format `fix(domaine): description`
4. **(`--comment`)** : commentaires inline postes sur la PR

## Sub-agents lies (dispatchees par AUDIT)

| Sub-agent | Modele | Focus |
|-----------|--------|-------|
| `qa-security` | Opus | OWASP Top 10, secrets, injections |
| `qa-perf` | Sonnet | N+1, bundle, Core Web Vitals |
| `wcag-audit` | Sonnet | WCAG 2.1 AA |
| `qa-claudemd` | Sonnet | Conformite CLAUDE.md + conventions repo |

## Agents lies (orchestration)

| Agent | Usage |
|-------|-------|
| `/qa:qa-audit` | Audit complet initial (alternative single-agent) |
| `/qa:qa-security` | Audit securite approfondi (hors loop) |
| `/qa:qa-perf` | Audit performance approfondi (hors loop) |
| `/qa:wcag-audit` | Audit accessibilite approfondi (hors loop) |
| `/dev:dev-tdd` | Cycle TDD pour les fixes |

## Exemples d'utilisation

```
/qa:qa-loop                              # Defaut: score 90, max 5 iterations, scope diff
/qa:qa-loop "score 95"                   # Score cible 95/100
/qa:qa-loop "securite+perf, max 3"       # 2 domaines, 3 iterations max
/qa:qa-loop "P0 uniquement"              # Ne corriger que les critiques
/qa:qa-loop --audit-only                 # Audit + rapport, pas de fix
/qa:qa-loop --audit-only --comment       # Replique fidele du plugin Anthropic code-review
/qa:qa-loop --full                       # Audit du repo entier (ignore le diff)
```

---

IMPORTANT: Phase AUDIT lance les 4 sub-agents Task **en parallele dans un seul message**.

IMPORTANT: Phase VALIDATE est obligatoire — aucun fix sans validation prealable.

IMPORTANT: Filtre high-signal strict — un finding sans impact mesurable n'apparait pas dans le rapport.

IMPORTANT: Auto-scope `git diff main...HEAD` par defaut, jamais audit du repo entier sans demande explicite.

IMPORTANT: Separer clairement la phase AUDIT (lecture) de la phase FIX (ecriture).

IMPORTANT: En mode `--audit-only`, ne JAMAIS modifier le code.

IMPORTANT: Arreter immediatement si un fix introduit une regression.

YOU MUST produire un rapport avec scores a chaque iteration.

NEVER depasser le nombre maximum d'iterations.

NEVER corriger les P2/P3 — ils n'apparaissent meme plus dans le rapport (filtre high-signal).

Think hard about l'ordre optimal des fixes pour maximiser l'impact et minimiser les risques de regression.
