---
name: web-scraping
description: Clean LLM-ready web scraping via Firecrawl (scrape/crawl/map/extract/search). Trigger when the user wants to extract content from a page, crawl a site, collect structured data, bypass anti-bot/JS-rendering, or perform a web search with integrated extraction. Fallback to Playwright/curl if Firecrawl is unavailable.
allowed-tools:
  - Read
  - Write
  - Bash
  - WebFetch
  - WebSearch
context: fork
---

# Web Scraping (Firecrawl-first)

## Goal

Extract LLM-ready web content without hacking around: clean markdown, structured JSON, anti-bot and JS-rendering handled. Firecrawl is the reference wrapper; fallback to Playwright or `curl + html2text` if unavailable.

## When to trigger this skill

- "scrape this page / this site"
- "extract data from ..."
- "crawl site X"
- "fetch all articles from ..."
- "search the web and extract the content"
- "parse this dynamic page" (site with JS-rendering)
- "bypass the paywall / anti-bot" (legitimate use only)

## When NOT to use this skill

- Quick web search without structured extraction -> `WebSearch` is enough
- A single static URL, simple page -> `WebFetch` is enough
- Visual test / browser interaction -> skill `qa-chrome` or agent-browser
- Form / login automation -> agent-browser or Playwright directly

## Prerequisites

### Option 1: Firecrawl cloud (recommended)

```bash
export FIRECRAWL_API_KEY="fc-xxx"      # https://firecrawl.dev
npm install -g firecrawl               # or pip install firecrawl-py
```

### Option 2: Firecrawl self-hosted

Docker compose available on github.com/mendableai/firecrawl. Useful if data is sensitive or budget is limited.

### Option 3: Fallback without Firecrawl

If Firecrawl is missing, degrade gracefully:

| Need | Fallback | Limitation |
|--------|----------|------------|
| Simple static page | `curl -sL URL \| pandoc -f html -t markdown` | No JS rendering |
| JS-heavy page | `npx playwright` + `page.content()` + markdownify | Heavy, 300MB+ of deps |
| Whole site | recursive filtered wget | No deduplication, no LLM-ready output |

IMPORTANT: always announce when degrading. The user must know if the content is partial (JS not rendered).

## The 5 Firecrawl operations

### 1. Scrape (one URL)

```bash
firecrawl scrape https://example.com/article \
  --formats markdown,links \
  --only-main-content
```

Output: clean markdown (navigation / footers stripped), list of links, OG metadata.

### 2. Crawl (whole site)

```bash
firecrawl crawl https://docs.example.com \
  --limit 100 \
  --include-paths "/docs/**" \
  --exclude-paths "/docs/legacy/**" \
  --formats markdown
```

Output: one markdown per page + JSON manifest. **Ask for confirmation before crawl > 50 pages** (API costs + time).

### 3. Map (URL discovery)

```bash
firecrawl map https://example.com --search "pricing"
```

Output: list of relevant URLs. Useful BEFORE a crawl to target the right sections.

### 4. Extract (structured data via LLM)

```bash
firecrawl extract https://example.com/pricing \
  --prompt "Extract plans with name, price, features" \
  --schema '{"plans":[{"name":"str","price":"num","features":["str"]}]}'
```

Output: JSON conforming to the schema. Saves hours of fragile CSS selectors.

### 5. Search (search + extract in one pass)

```bash
firecrawl search "best pve proxmox backup strategies" \
  --limit 10 \
  --scrape-options '{"formats":["markdown"]}'
```

Output: top N results with extracted content. Replaces `WebSearch` + N `WebFetch`.

## Recommended workflow

```
1. IDENTIFY the need
   - 1 page               -> scrape
   - N known pages        -> scrape in a loop with `xargs -P 4`
   - Whole site           -> map (recon) -> targeted crawl
   - Structured data      -> extract with schema
   - Search + extract     -> search

2. ESTIMATE costs
   - Firecrawl cloud: credits per page scraped
   - Ask for confirmation if > 50 pages or > 10 MB expected

3. RUN with limits on the first attempt
   - --limit 5 to test
   - Inspect the output
   - Re-run at full volume if OK

4. SAVE the result
   - `./scraped/<date>/<domain>.md` by convention
   - Commit if data is reusable (mind copyright)

5. CHECK legality / ethics
   - Respect robots.txt unless explicitly authorized
   - No personal data without consent (GDPR)
   - No commercial paywall bypass
```

## Concrete examples

### Extract a lib's docs for RAG

```bash
firecrawl crawl https://docs.terraform.io/language \
  --limit 200 --formats markdown \
  --output-dir ./rag-corpus/terraform
```

### Compare pricings of 5 competitors

```bash
for url in url1 url2 url3 url4 url5; do
    firecrawl extract "$url" \
      --prompt "Extract pricing plans" \
      --schema pricing.schema.json >> pricing-compared.jsonl
done
```

### Monitor a changelog

```bash
firecrawl scrape https://example.com/changelog \
  --formats markdown \
  | diff - last-changelog.md \
  && mv <(firecrawl scrape ...) last-changelog.md
```

## Red Flags — STOP immediately

| Signal | Reaction |
|--------|----------|
| Missing `FIRECRAWL_API_KEY` AND firecrawl self-hosted not detected | Propose explicit fallback, ask the user for their choice |
| `robots.txt` forbids scraping the target path | STOP — ask for explicit authorization before continuing |
| More than 100 pages without confirmation | STOP — announce estimated costs and wait for validation |
| Personal data detected (email, phone, ID) in the output | STOP — do not save without GDPR legal basis |
| Site with login / commercial paywall | STOP — scraping illegal except with explicit contract |
| Repeated 429 rate limit | STOP — exponential backoff, do not hammer |

## Integration with the rest of the foundation

| Combo | Usage |
|-------|-------|
| `web-scraping` -> `dev:dev-rag` | Build a corpus for RAG ingestion |
| `web-scraping` -> `biz:biz-competitor` | Factual competitive & market analysis on real data |
| `web-scraping` + `writing-skills` | Import third-party lib docs into a local skill |
| `qa-chrome` instead of `web-scraping` | Visual tests, DOM interaction, screenshots |

## Anti-patterns

- NEVER scrape without checking robots.txt AND Terms of Service
- NEVER commit scraped data without checking the rights
- NEVER launch a crawl > 50 pages without user confirmation
- NEVER use Firecrawl to replace `WebSearch` for a simple factual question (needlessly expensive)
- NEVER bruteforce a site in massive parallel (max 4 workers by default)

## Absolute rules

IMPORTANT: Always announce when degrading to a fallback (Playwright / curl) — the content may be partial.

IMPORTANT: Ask for confirmation before any crawl exceeding 50 pages or a site outside the user's control.

YOU MUST respect robots.txt and the target site's ToS.

YOU MUST save outputs in `./scraped/<date>/` with timestamp for traceability.

NEVER bypass an anti-bot system without documented legitimate justification.
