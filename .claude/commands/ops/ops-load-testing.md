# Agent OPS-LOAD-TESTING

Mettre en place et exécuter des tests de charge et de stress.

## Contexte
$ARGUMENTS

## Objectif

Valider les performances et la résilience de l'application sous charge,
identifier les limites et les goulots d'étranglement.

## Types de tests de performance

```
┌─────────────────────────────────────────────────────────────┐
│                    TYPES DE TESTS                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  LOAD TEST        → Charge normale/attendue                 │
│  ════════════                                               │
│  Objectif: Valider le comportement sous charge normale      │
│                                                             │
│  STRESS TEST      → Charge au-delà des limites             │
│  ═══════════                                                │
│  Objectif: Trouver le point de rupture                     │
│                                                             │
│  SPIKE TEST       → Pics soudains de charge                │
│  ══════════                                                 │
│  Objectif: Valider la réaction aux pics                    │
│                                                             │
│  SOAK TEST        → Charge prolongée                       │
│  ═════════                                                  │
│  Objectif: Détecter les fuites mémoire, dégradation        │
│                                                             │
│  BREAKPOINT TEST  → Augmentation jusqu'à rupture           │
│  ═══════════════                                            │
│  Objectif: Déterminer la capacité maximale                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Outils de load testing

### Comparatif

| Outil | Langage | Forces | Usage |
|-------|---------|--------|-------|
| **k6** | JavaScript | Moderne, scriptable | Recommandé |
| **Locust** | Python | Flexible, distribué | Python teams |
| **Artillery** | YAML/JS | Simple, CI-friendly | Quick tests |
| **JMeter** | Java/GUI | Complet, mature | Enterprise |
| **Gatling** | Scala | Rapports riches | Scala teams |
| **wrk/wrk2** | Lua | Ultra léger | Benchmarks simples |

### Recommandation : k6

```bash
# Installation
# macOS
brew install k6

# Linux
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Docker
docker run --rm -i grafana/k6 run - <script.js
```

## Scripts de test k6

### Test de charge basique

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },  // Ramp-up à 100 users
    { duration: '5m', target: 100 },  // Maintien
    { duration: '2m', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% des requêtes < 500ms
    http_req_failed: ['rate<0.01'],    // < 1% d'erreurs
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

### Test de stress

```javascript
// stress-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Charge normale
    { duration: '5m', target: 100 },
    { duration: '2m', target: 200 },   // Stress
    { duration: '5m', target: 200 },
    { duration: '2m', target: 300 },   // Plus de stress
    { duration: '5m', target: 300 },
    { duration: '2m', target: 400 },   // Limite
    { duration: '5m', target: 400 },
    { duration: '10m', target: 0 },    // Recovery
  ],
};

export default function () {
  const res = http.get('https://api.example.com/users');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

### Test de spike

```javascript
// spike-test.js
export const options = {
  stages: [
    { duration: '10s', target: 100 },   // Charge normale
    { duration: '1m', target: 100 },
    { duration: '10s', target: 1400 },  // Spike soudain
    { duration: '3m', target: 1400 },
    { duration: '10s', target: 100 },   // Retour normal
    { duration: '3m', target: 100 },
    { duration: '10s', target: 0 },
  ],
};
```

### Test de soak (endurance)

```javascript
// soak-test.js
export const options = {
  stages: [
    { duration: '5m', target: 100 },    // Ramp-up
    { duration: '8h', target: 100 },    // Charge prolongée
    { duration: '5m', target: 0 },      // Ramp-down
  ],
};
```

### Scénario complexe

```javascript
// scenario-test.js
import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const loginDuration = new Trend('login_duration');

export const options = {
  scenarios: {
    browse: {
      executor: 'constant-vus',
      vus: 50,
      duration: '10m',
      exec: 'browseProducts',
    },
    purchase: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 20 },
        { duration: '5m', target: 20 },
      ],
      exec: 'purchaseFlow',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    errors: ['rate<0.1'],
    login_duration: ['p(95)<2000'],
  },
};

export function browseProducts() {
  group('Browse Products', () => {
    const res = http.get('https://api.example.com/products');
    check(res, { 'products loaded': (r) => r.status === 200 });
    errorRate.add(res.status !== 200);
  });
  sleep(Math.random() * 3);
}

export function purchaseFlow() {
  group('Login', () => {
    const start = Date.now();
    const loginRes = http.post('https://api.example.com/login', {
      email: 'test@test.com',
      password: 'password',
    });
    loginDuration.add(Date.now() - start);
    check(loginRes, { 'logged in': (r) => r.status === 200 });
  });

  sleep(1);

  group('Add to Cart', () => {
    const res = http.post('https://api.example.com/cart', {
      productId: '123',
      quantity: 1,
    });
    check(res, { 'added to cart': (r) => r.status === 200 });
  });

  sleep(1);

  group('Checkout', () => {
    const res = http.post('https://api.example.com/checkout');
    check(res, { 'checkout success': (r) => r.status === 200 });
    errorRate.add(res.status !== 200);
  });

  sleep(3);
}
```

## Exécution et rapports

### Commandes k6

```bash
# Exécuter un test
k6 run load-test.js

# Avec output détaillé
k6 run --out json=results.json load-test.js

# Avec dashboard temps réel
k6 run --out influxdb=http://localhost:8086/k6 load-test.js

# Test distribué avec k6 Cloud
k6 cloud load-test.js
```

### Intégration Grafana

```yaml
# docker-compose.yml
version: '3'
services:
  influxdb:
    image: influxdb:1.8
    ports:
      - "8086:8086"
    environment:
      - INFLUXDB_DB=k6

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - ./grafana-provisioning:/etc/grafana/provisioning
```

## Analyse des résultats

### Métriques clés

| Métrique | Seuil recommandé | Description |
|----------|------------------|-------------|
| **http_req_duration p95** | < 500ms | 95% des requêtes |
| **http_req_duration p99** | < 1000ms | 99% des requêtes |
| **http_req_failed** | < 1% | Taux d'erreur |
| **http_reqs** | Variable | Throughput |
| **vus** | Variable | Users virtuels actifs |

### Template de rapport

```markdown
# Load Test Report

## Summary
- **Date**: 2024-01-15
- **Duration**: 30 minutes
- **Peak VUs**: 500
- **Total Requests**: 1,234,567

## Results

### Performance
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| p95 Response Time | 450ms | < 500ms | ✅ PASS |
| p99 Response Time | 890ms | < 1000ms | ✅ PASS |
| Error Rate | 0.5% | < 1% | ✅ PASS |
| Throughput | 2000 req/s | > 1500 | ✅ PASS |

### Bottlenecks Identified
1. Database queries slow down at 400+ concurrent users
2. Memory usage increases linearly (potential leak)

### Recommendations
1. Add database connection pooling
2. Implement query caching
3. Investigate memory leak in UserService
```

## Intégration CI/CD

### GitHub Actions

```yaml
name: Load Tests

on:
  schedule:
    - cron: '0 2 * * *'  # Nightly
  workflow_dispatch:

jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run k6 load test
        uses: grafana/k6-action@v0.3.0
        with:
          filename: tests/load/load-test.js
          flags: --out json=results.json

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: k6-results
          path: results.json

      - name: Check thresholds
        run: |
          if grep -q '"thresholds":{"http_req_duration":\["p(95)<500"\]' results.json; then
            echo "Thresholds passed"
          else
            echo "Thresholds failed"
            exit 1
          fi
```

## Checklist

### Avant les tests
- [ ] Environnement de test isolé
- [ ] Données de test réalistes
- [ ] Monitoring en place
- [ ] Baseline définie

### Pendant les tests
- [ ] Observer les métriques temps réel
- [ ] Noter les anomalies
- [ ] Surveiller les ressources serveur

### Après les tests
- [ ] Analyser les résultats
- [ ] Identifier les bottlenecks
- [ ] Documenter les findings
- [ ] Planifier les optimisations

## Agents liés

| Agent | Usage |
|-------|-------|
| `/qa-perf` | Optimisation performance |
| `/ops-monitoring` | Monitoring en production |
| `/ops-cost-optimization` | Optimiser les coûts |

---

IMPORTANT: Toujours tester sur un environnement isolé, jamais en production.

YOU MUST définir des seuils de performance acceptables avant les tests.

NEVER exécuter des tests de charge sans monitoring actif.

Think hard sur les scénarios réalistes avant de créer les tests.
