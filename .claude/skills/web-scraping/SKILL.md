---
name: web-scraping
description: Scraping web propre pour LLM via Firecrawl (scrape/crawl/map/extract/search). Declencher quand l'utilisateur veut extraire du contenu d'une page, crawler un site, collecter des donnees structurees, contourner anti-bot/JS-rendering, ou faire une recherche web avec extraction integree. Fallback Playwright/curl si Firecrawl absent.
allowed-tools:
  - Read
  - Write
  - Bash
  - WebFetch
  - WebSearch
context: fork
---

# Web Scraping (Firecrawl-first)

## Objectif

Extraire du contenu web exploitable par un LLM sans bricoler : markdown propre, JSON structure, contournement anti-bot et JS-rendering pris en charge. Firecrawl est le wrapper de reference ; fallback Playwright ou `curl + html2text` si indisponible.

## Quand declencher ce skill

- "scrape cette page / ce site"
- "extrait les donnees de ..."
- "crawle le site X"
- "recupere tous les articles de ..."
- "cherche sur le web et extrais le contenu"
- "parse cette page dynamique" (site avec JS-rendering)
- "contourne le paywall / anti-bot" (usage legitime uniquement)

## Quand NE PAS utiliser ce skill

- Recherche web rapide sans extraction structuree -> `WebSearch` suffit
- Une seule URL statique, page simple -> `WebFetch` suffit
- Test visuel / interaction navigateur -> skill `qa-chrome` ou agent-browser
- Automatisation de formulaires / login -> agent-browser ou Playwright direct

## Prerequis

### Option 1 : Firecrawl cloud (recommande)

```bash
export FIRECRAWL_API_KEY="fc-xxx"      # https://firecrawl.dev
npm install -g firecrawl               # ou pip install firecrawl-py
```

### Option 2 : Firecrawl self-hosted

Docker compose disponible sur github.com/mendableai/firecrawl. Utile si donnees sensibles ou budget limite.

### Option 3 : Fallback sans Firecrawl

Si Firecrawl absent, degrader gracieusement :

| Besoin | Fallback | Limitation |
|--------|----------|------------|
| Page statique simple | `curl -sL URL \| pandoc -f html -t markdown` | Pas de JS rendering |
| Page JS-heavy | `npx playwright` + `page.content()` + markdownify | Lourd, 300MB+ de deps |
| Site entier | wget recursif filtre | Pas de deduplication, pas d'output LLM-ready |

IMPORTANT: toujours annoncer quand on degrade. L'utilisateur doit savoir si le contenu est partiel (JS non rendu).

## Les 5 operations Firecrawl

### 1. Scrape (une URL)

```bash
firecrawl scrape https://example.com/article \
  --formats markdown,links \
  --only-main-content
```

Output : markdown propre (navigation / footers supprimes), liste des liens, metadata OG.

### 2. Crawl (site entier)

```bash
firecrawl crawl https://docs.example.com \
  --limit 100 \
  --include-paths "/docs/**" \
  --exclude-paths "/docs/legacy/**" \
  --formats markdown
```

Output : un markdown par page + manifest JSON. **Demander confirmation avant crawl > 50 pages** (couts API + temps).

### 3. Map (decouverte d'URLs)

```bash
firecrawl map https://example.com --search "pricing"
```

Output : liste des URLs pertinentes. Utile AVANT un crawl pour cibler les bonnes sections.

### 4. Extract (donnees structurees via LLM)

```bash
firecrawl extract https://example.com/pricing \
  --prompt "Extract plans with name, price, features" \
  --schema '{"plans":[{"name":"str","price":"num","features":["str"]}]}'
```

Output : JSON conforme au schema. Economise des heures de selectors CSS fragiles.

### 5. Search (search + extract en une passe)

```bash
firecrawl search "best pve proxmox backup strategies" \
  --limit 10 \
  --scrape-options '{"formats":["markdown"]}'
```

Output : top N resultats avec contenu extrait. Remplace `WebSearch` + N `WebFetch`.

## Workflow recommande

```
1. IDENTIFIER le besoin
   - 1 page               -> scrape
   - N pages connues      -> scrape en boucle avec `xargs -P 4`
   - Site entier          -> map (reconnaitre) -> crawl cible
   - Donnees structurees  -> extract avec schema
   - Recherche + extract  -> search

2. ESTIMER les couts
   - Firecrawl cloud : credits par page scrapee
   - Demander confirmation si > 50 pages ou > 10 MB attendus

3. EXECUTER avec limites sur le premier essai
   - --limit 5 pour tester
   - Inspecter l'output
   - Relancer en plein volume si OK

4. SAUVEGARDER le resultat
   - `./scraped/<date>/<domain>.md` par convention
   - Commit si donnees reutilisables (attention au droit d'auteur)

5. VERIFIER legalite / ethique
   - Respecter robots.txt si pas d'autorisation explicite
   - Pas de donnees perso sans consentement (RGPD)
   - Pas de contournement de paywall commercial
```

## Exemples concrets

### Extraire la doc d'une lib pour RAG

```bash
firecrawl crawl https://docs.terraform.io/language \
  --limit 200 --formats markdown \
  --output-dir ./rag-corpus/terraform
```

### Comparer les pricings de 5 concurrents

```bash
for url in url1 url2 url3 url4 url5; do
    firecrawl extract "$url" \
      --prompt "Extract pricing plans" \
      --schema pricing.schema.json >> pricing-compared.jsonl
done
```

### Monitorer un changelog

```bash
firecrawl scrape https://example.com/changelog \
  --formats markdown \
  | diff - last-changelog.md \
  && mv <(firecrawl scrape ...) last-changelog.md
```

## Red Flags — STOP immediat

| Signal | Reaction |
|--------|----------|
| Absence de `FIRECRAWL_API_KEY` ET firecrawl self-hosted non detecte | Proposer fallback explicite, demander a l'utilisateur son choix |
| `robots.txt` interdit le scraping du path cible | STOP — demander autorisation explicite avant de continuer |
| Plus de 100 pages sans confirmation | STOP — annoncer les couts estimes et attendre validation |
| Donnees personnelles detectees (email, tel, ID) dans l'output | STOP — ne pas sauvegarder sans base legale RGPD |
| Site avec login / paywall commercial | STOP — scraping illegal sauf contrat explicite |
| Rate limit 429 repete | STOP — backoff exponentiel, ne pas marteler |

## Integration avec le reste du socle

| Combo | Usage |
|-------|-------|
| `web-scraping` -> `dev:dev-rag` | Constituer un corpus pour ingestion RAG |
| `web-scraping` -> `biz:biz-competitor` | Analyse concurrentielle factuelle |
| `web-scraping` -> `biz:biz-market` | Market research base sur donnees reelles |
| `web-scraping` + `writing-skills` | Importer de la doc d'une lib tierce dans un skill local |
| `qa-chrome` au lieu de `web-scraping` | Tests visuels, interaction DOM, screenshots |

## Anti-patterns

- NEVER scraper sans verifier robots.txt ET Terms of Service
- NEVER commiter des donnees scrappees sans verifier les droits
- NEVER lancer un crawl > 50 pages sans confirmation utilisateur
- NEVER utiliser Firecrawl pour remplacer `WebSearch` sur une simple question factuelle (couteux inutilement)
- NEVER bruteforcer un site en parallele massif (max 4 workers par defaut)

## Regles absolues

IMPORTANT: Toujours annoncer quand on degrade vers un fallback (Playwright / curl) — le contenu peut etre partiel.

IMPORTANT: Demander confirmation avant tout crawl depassant 50 pages ou un site hors de la maitrise de l'utilisateur.

YOU MUST respecter robots.txt et les ToS du site cible.

YOU MUST sauvegarder les outputs dans `./scraped/<date>/` avec horodatage pour tracabilite.

NEVER contourner un systeme anti-bot sans justification legitime documentee.
