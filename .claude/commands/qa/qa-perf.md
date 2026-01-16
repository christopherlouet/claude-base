# Agent PERF (Performance)

Analyse et optimisation des performances.

## Cible
$ARGUMENTS

## Méthodologie

### 1. Mesurer AVANT d'optimiser
- IMPORTANT: Pas d'optimisation sans mesure préalable
- Établir une baseline de performance
- Identifier les métriques clés (temps, mémoire, CPU)

### 2. Identifier les bottlenecks

#### Code
- [ ] Boucles inefficaces (O(n²) évitables)
- [ ] Calculs redondants (memoization possible)
- [ ] Allocations mémoire excessives
- [ ] Opérations synchrones bloquantes
- [ ] Requêtes N+1 (base de données)

#### Frontend
- [ ] Bundle size trop important
- [ ] Renders inutiles (React)
- [ ] Images non optimisées
- [ ] Pas de lazy loading
- [ ] CSS bloquant

#### Backend
- [ ] Requêtes DB non optimisées (index manquants)
- [ ] Pas de cache
- [ ] Sérialisation/désérialisation coûteuse
- [ ] Connexions non poolées

### 3. Profiling

#### Node.js
```bash
# Profiling CPU
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# Profiling mémoire avec heapdump
node --expose-gc app.js
# Dans le code: global.gc(); require('heapdump').writeSnapshot();

# Diagnostic en temps réel
node --inspect app.js
# Puis ouvrir chrome://inspect
```

#### Chrome DevTools
- Performance tab pour le frontend
- Memory tab pour les fuites mémoire
- Network tab pour les requêtes
- Lighthouse pour audit complet

#### Outils de profiling
```bash
# Lighthouse CLI
npx lighthouse https://example.com --output=json --output-path=./report.json

# Autocannon pour les API
npx autocannon -c 100 -d 30 http://localhost:3000/api

# 0x pour flamegraphs Node.js
npx 0x app.js
```

### 4. Core Web Vitals (SEO & UX)

| Métrique | Description | Objectif | Impact |
|----------|-------------|----------|--------|
| **LCP** | Largest Contentful Paint | < 2.5s | SEO + UX |
| **FID** | First Input Delay | < 100ms | UX |
| **CLS** | Cumulative Layout Shift | < 0.1 | UX |
| **TTFB** | Time to First Byte | < 800ms | Perf serveur |
| **INP** | Interaction to Next Paint | < 200ms | UX |

```typescript
// Mesurer les Web Vitals
import { getCLS, getFID, getLCP } from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getLCP(console.log);
```

### 5. Optimisations par priorité

| Priorité | Type | Impact | Effort |
|----------|------|--------|--------|
| 1 | Algorithme | Très élevé | Variable |
| 2 | Caching | Élevé | Faible |
| 3 | Lazy loading | Moyen | Faible |
| 4 | Parallélisation | Moyen | Moyen |
| 5 | Micro-optimisations | Faible | Élevé |

### 6. Techniques d'optimisation
- Memoization (useMemo, useCallback, cache manuel)
- Pagination / Infinite scroll
- Debounce / Throttle
- Web Workers pour calculs lourds
- Connection pooling
- Index de base de données
- Compression (gzip, brotli)
- CDN pour assets statiques

## Output attendu

### Baseline
- Métrique 1: [valeur initiale]
- Métrique 2: [valeur initiale]

### Bottlenecks identifiés
| Localisation | Problème | Impact estimé |
|--------------|----------|---------------|
| fichier:ligne | Description | Élevé/Moyen/Faible |

### Optimisations proposées
1. [Optimisation 1] - Gain estimé: [X%]
2. [Optimisation 2] - Gain estimé: [X%]

### Résultats après optimisation
- Métrique 1: [avant] → [après] ([X% amélioration])

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/monitoring` | Monitoring des perfs en prod |
| `/database` | Optimiser les requêtes DB |
| `/audit` | Audit complet (inclut perf) |
| `/seo` | Core Web Vitals pour SEO |

---

IMPORTANT: "Premature optimization is the root of all evil" - Knuth. Optimise uniquement ce qui est mesuré comme lent.

YOU MUST mesurer avant et après chaque optimisation pour valider l'impact.

NEVER optimiser sans profiling préalable - identifier le vrai bottleneck.

Think hard sur le rapport coût/bénéfice de chaque optimisation.
