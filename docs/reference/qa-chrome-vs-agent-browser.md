# qa-chrome vs agent-browser

> Evaluation : faut-il remplacer ou completer `qa-chrome` par `agent-browser` (Vercel Labs) ?

## TL;DR

**Complementaires, pas concurrents.** Garder `qa-chrome` pour les tests visuels interactifs que l'utilisateur supervise, et **ajouter `agent-browser` comme skill** pour l'automatisation navigateur headless, les workflows CI et les cas ou le flag `--chrome` n'est pas disponible (WSL, serveurs, Linux sans display).

Recommandation : ne **pas** retirer `qa-chrome`. **Ajouter** un skill `browser-automation` qui wrappe `agent-browser`.

## Comparaison detaillee

| Critere | `qa-chrome` (socle actuel) | `agent-browser` (Vercel Labs) |
|---------|---------------------------|-------------------------------|
| **Techno** | Extension Chrome + flag `claude --chrome` | Binaire Rust + Chrome for Testing |
| **Prerequis** | Chrome visible + extension installee | `npm i -g agent-browser` ou `cargo install` |
| **Mode** | Headed obligatoire (fenetre visible) | Headless ou headed au choix |
| **WSL / Linux sans display** | Non supporte | Supporte |
| **CI / serveurs** | Impossible | Natif |
| **Interaction DOM** | Oui (clic, saisie, nav) | Oui (plus riche : wait, networkidle, ARIA) |
| **Snapshots semantiques** | Screenshot + DOM brut | Snapshots avec references `@e1`, `@e2` et accessibilite |
| **Screenshots / GIFs** | Oui | Oui |
| **Profiles / sessions** | Utilise le Chrome de l'utilisateur | Profiles persistants dedies |
| **Multi-navigateur** | Chrome seulement | Chrome + Chromium + Brave |
| **Supervision humaine** | Naturelle (user voit la fenetre) | Optionnelle (mode headed) |
| **Maintenu par** | Anthropic (extension officielle) | Vercel Labs (open source) |

## Use cases — quel skill choisir ?

### Cas pour `qa-chrome`

- Test visuel supervise par l'utilisateur, feedback en temps reel
- Debug d'une page dans le Chrome de l'utilisateur (cookies de session, extensions perso)
- Demo client / capture d'ecran pour documentation
- Pair programming UI avec supervision directe

### Cas pour `agent-browser`

- Automatisation CI/CD (tests E2E en headless dans une GitHub Action)
- Workflow serveur / WSL ou le flag `--chrome` ne marche pas
- Scraping interactif avec login / session persistante
- Tests de regression visuelle automatises (snapshots)
- Formulaires multi-etapes sans supervision humaine
- Scenarios sur plusieurs navigateurs (Chromium, Brave)

### Cas partages : le skill `web-scraping` (Firecrawl) est plus adapte

- Extraction de contenu markdown sur > 5 pages : Firecrawl plus rapide et mieux formate pour LLM
- Crawl d'un site entier : Firecrawl (pas de rendering interactif necessaire)
- Recherche + extract en une passe : `firecrawl search`

## Proposition d'integration dans le socle

### Option A : minimaliste (recommande)

Ajouter UN skill `browser-automation` qui wrappe `agent-browser`, avec trigger conditions complementaires a `qa-chrome` :

```yaml
---
name: browser-automation
description: Automatisation navigateur headless via agent-browser (Vercel Labs). Declencher pour tests E2E CI, workflows serveur, scraping avec session, regression visuelle. Complementaire a qa-chrome (supervise) et web-scraping (contenu markdown).
---
```

**Trigger conditions distincts de qa-chrome** :
- Mots-cles : "CI", "serveur", "headless", "automatise sans supervision", "regression visuelle", "WSL"
- Contexte : absence du flag `--chrome`, environnement sans display

### Option B : consolidation (plus risque)

Remplacer `qa-chrome` par un unique `browser-ops` qui route vers `agent-browser` en headless / `claude --chrome` en supervise. **Non recommande** : casse la compat existante et perd la simplicite du flag `--chrome`.

### Option C : ne rien faire

Documenter `agent-browser` dans `docs/reference/external-skills.md` sans creer de skill local. **A envisager** si l'usage reste marginal. L'utilisateur peut toujours `npm i -g agent-browser` et l'appeler directement.

## Recommandation finale

**Option A dans 2 semaines** apres :

1. Tester `agent-browser` manuellement sur 2 cas concrets (un E2E CI + un scraping avec session) pour valider la qualite du binaire Vercel.
2. Verifier la maintenance du repo (commits recents, issues ouvertes).
3. Benchmark : `agent-browser` headless vs Playwright direct (est-ce que le wrapper ajoute une vraie valeur ?).

Si les 3 points passent -> creer le skill `browser-automation`. Sinon -> option C (simple reference documentaire).

## Decision log

| Date | Statut | Note |
|------|--------|------|
| 2026-04-20 | Evaluation initiale | Option A recommandee, en attente de validation terrain |
