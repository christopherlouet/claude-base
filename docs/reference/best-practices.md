# Bonnes Pratiques Claude Code (Boris Cherny)

## Verification : Le Multiplicateur de Qualite

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." -- Boris Cherny

Donnez toujours a Claude un moyen de valider son travail:

| Complexite | Methode | Exemple |
|------------|---------|---------|
| Simple | Commande bash | `npm run lint`, `npm run typecheck` |
| Moderee | Suite de tests | `npm test`, `pytest`, `go test` |
| Complexe | Browser/Simulateur | Playwright, Chrome DevTools, emulateur mobile |

Integration: hooks PostToolUse (auto-format, type-check, lint), PreToolUse sur commit (tests obligatoires), agents QA (`/qa:qa-audit`).

## Modele Recommande

> "I use Opus 4.6 with adaptive thinking for everything." -- Boris Cherny

| Contexte | Modele | Justification |
|----------|--------|---------------|
| Taches complexes | **Opus 4.6** | Meilleur raisonnement, adaptive thinking, 1M contexte |
| Audits et analyses | **Sonnet** | Bon equilibre vitesse/qualite |
| Taches simples | **Haiku** | Rapide pour les operations triviales |

## Prompting Avance

| A eviter | Preferer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer in getUserById when user doesn't exist" |
| "Make it better" | "Reduce the time complexity from O(n^2) to O(n log n)" |
| "Add error handling" | "Add try/catch for network errors with retry logic (3 attempts, exponential backoff)" |

Techniques: "Grill me on these changes", "Prove to me this works", "Knowing everything you know now, implement the elegant solution".

Voir `docs/guides/PROMPTING-GUIDE.md` pour le guide complet.

## Sessions Paralleles

> "The single biggest productivity unlock." -- Boris Cherny

Utiliser git worktrees pour 5+ sessions Claude Code en parallele. Voir le skill `git-worktrees` pour les details.

## Commande Rapide

`/work:work-commit-push-pr "description"` -- commit + push + PR en une seule commande.
