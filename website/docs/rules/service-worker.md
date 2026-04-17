---
sidebar_position: 23
title: "service-worker"
description: "The SW must NEVER cache `request.mode === \"navigate\"` responses. Caching HTML pages causes: - Stale JS references after deployments - Broken React/Vue"
tags:
  - "rule"
  - "service-worker"
---

# Regles: service-worker

> The SW must NEVER cache `request.mode === "navigate"` responses. Caching HTML pages causes: - Stale JS references after deployments - Broken React/Vue/Svelte hydration (buttons stop working) - Users s

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/sw.js`
- `**/service-worker*`
- `**/sw-*.js`

## Regles detaillees

# Service Worker Rules

## CRITICAL: Never cache HTML navigations

The SW must NEVER cache `request.mode === "navigate"` responses. Caching HTML pages causes:
- Stale JS references after deployments
- Broken React/Vue/Svelte hydration (buttons stop working)
- Users stuck on old versions until SW updates

**Only acceptable navigate handler:**
```js
if (request.mode === "navigate") {
  event.respondWith(
    fetch(request).catch(() => caches.match("/offline.html"))
  );
  return;
}
```

## Rules

1. **navigate** → network only, offline.html fallback
2. **/_next/static/** or framework static assets → pass through (browser HTTP cache handles immutable assets)
3. **RSC/SSR payloads** (`_rsc`, `__data`) → pass through
4. **/api/** → network-first with cache fallback for offline only
5. **Everything else** → pass through, no caching
6. **CACHE_NAME** must be bumped on every SW change to force old cache purge
7. **skipWaiting()** + **clients.claim()** required in install/activate

## Before modifying sw.js

- [ ] Verify navigate handler does NOT cache responses
- [ ] Bump CACHE_NAME version
- [ ] Test with real browser (not headless) — check SW tab in DevTools
- [ ] Test: deploy new version, verify old SW gets replaced
- [ ] Test in private browsing (no SW) to confirm baseline works

## Common mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Cache navigate responses | Stale HTML after deploy | Only offline fallback |
| Stale-while-revalidate on HTML | Shows old page briefly | Network-only for navigate |
| Not bumping CACHE_NAME | Old cache persists | Always bump version |
| No skipWaiting/clients.claim | SW update delayed | Add both in install/activate |
| Caching RSC payloads | Client router breaks | Pass through _rsc requests |

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
