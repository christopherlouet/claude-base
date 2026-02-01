# Guide Developpement Web

> Workflow complet pour applications web avec React/Next.js/Vue

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Frontend | React, Next.js, Vue.js, Svelte |
| Styling | Tailwind CSS, CSS Modules, styled-components |
| State | Redux, Zustand, React Query, Pinia |
| Backend | Node.js, Express, Fastify, tRPC |
| Database | PostgreSQL, MongoDB, Prisma, Drizzle |
| Auth | NextAuth, Clerk, Supabase Auth |
| Deploy | Vercel, Netlify, AWS, Railway |

## Architecture Recommandee

### React/Next.js

```
src/
├── app/                  # Next.js App Router (pages et layouts)
│   ├── (auth)/          # Groupe de routes auth
│   ├── (dashboard)/     # Groupe de routes dashboard
│   └── api/             # API Routes
├── components/          # Composants UI reutilisables
│   ├── ui/              # Composants primitifs (Button, Input, Card)
│   └── features/        # Composants metier (UserCard, ProductList)
├── hooks/               # Custom hooks React
├── lib/                 # Utilitaires et configurations
├── services/            # Logique metier et appels API
├── stores/              # State management (Zustand/Redux)
├── types/               # Types TypeScript
└── utils/               # Fonctions utilitaires pures
```

### Vue.js

```
src/
├── views/               # Pages/vues principales
├── components/          # Composants reutilisables
│   ├── base/            # Composants de base
│   └── features/        # Composants metier
├── composables/         # Logique reutilisable (hooks Vue)
├── stores/              # Pinia stores
├── services/            # Appels API
├── types/               # Types TypeScript
└── utils/               # Utilitaires
```

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /dev:dev-component → /dev:dev-tdd → /qa:qa-review → /work:work-pr
```

## Phase 1: Exploration

### Comprendre le projet existant

```bash
/work:work-explore
```

Ou avec l'agent dedie:
```
"Explore le code frontend et identifie les patterns utilises"
→ Agent work-explore (haiku, lecture seule)
```

### Questions a clarifier

- Framework utilise (React/Next/Vue)?
- Server-side rendering ou SPA?
- Strategie de state management?
- Conventions de nommage en place?

## Phase 2: Planification

### Planifier une feature

```bash
/work:work-plan "Ajouter un systeme de panier d'achat"
```

### Structure de plan type

```markdown
## Feature: Panier d'achat

### Fichiers a creer
- src/components/Cart/CartItem.tsx
- src/components/Cart/CartSummary.tsx
- src/hooks/useCart.ts
- src/store/cartSlice.ts
- src/api/cart.ts

### Fichiers a modifier
- src/components/Layout/Header.tsx (ajout badge cart)
- src/pages/_app.tsx (provider cart)

### Risques identifies
- Synchronisation cart localStorage/serveur
- Performance re-renders sur gros cart

### Questions
- Persistance cote client ou serveur?
- Guest checkout supporte?
```

## Phase 3: Developpement

### Creer un composant

```bash
/dev:dev-component "ProductCard avec image, titre, prix et bouton add to cart"
```

### Structure composant generee

```
src/components/ProductCard/
├── ProductCard.tsx        # Composant principal
├── ProductCard.test.tsx   # Tests unitaires
├── ProductCard.module.css # Styles (si CSS Modules)
├── ProductCard.stories.tsx # Storybook (optionnel)
└── index.ts               # Export
```

### Creer un hook

```bash
/dev:dev-hook "useCart pour gerer le panier avec localStorage"
```

### Bonnes pratiques React

| Pattern | Commande | Utilisation |
|---------|----------|-------------|
| Composant | `/dev:dev-component` | UI reutilisable |
| Hook | `/dev:dev-hook` | Logique partagee |
| Optimisation | `/dev:dev-react-perf` | Performance |
| State | `/work:work-plan` | Architecture |

## Phase 4: Tests

### TDD pour logique metier

```bash
/dev:dev-tdd "calcul du total panier avec reductions"
```

### Generer tests composant

```bash
/dev:dev-test "tester ProductCard avec differents etats"
```

### Couverture

```bash
/qa:qa-coverage
```

## Phase 5: Qualite

### Review de code

```bash
/qa:qa-review
```

### Audit performance

```bash
/qa:qa-perf
```

Metriques cibles:
| Metrique | Cible | Outil |
|----------|-------|-------|
| LCP | < 2.5s | Lighthouse |
| FID | < 100ms | Web Vitals |
| CLS | < 0.1 | Lighthouse |
| Bundle | < 200KB | webpack-bundle-analyzer |

### Audit accessibilite

```bash
/qa:qa-a11y
```

### Audit responsive

```bash
/qa:qa-responsive
```

## Phase 6: Deploy

### Configuration CI/CD

```bash
/ops:ops-ci "GitHub Actions pour Next.js avec Vercel"
```

### Docker (si necessaire)

```bash
/ops:ops-docker "Next.js standalone"
```

### Variables d'environnement

```bash
/ops:ops-env
```

## Commandes par Use Case

### Nouveau projet

```bash
1. /work:work-explore        # Comprendre le boilerplate
2. /work:work-plan          # Definir l'architecture
3. /ops:ops-env            # Configurer les environments
4. /ops:ops-ci             # Setup CI/CD
```

### Nouvelle feature

```bash
1. /work:work-explore       # Comprendre le contexte
2. /work:work-plan         # Planifier la feature
3. /dev:dev-component     # Creer les composants
4. /dev:dev-hook          # Creer les hooks
5. /dev:dev-tdd           # Tests
6. /qa:qa-review         # Review
7. /work:work-pr           # Pull Request
```

### Bug fix

```bash
1. /dev:dev-debug         # Identifier la cause
2. /work:work-flow-bugfix  # Workflow complet
```

### Optimisation

```bash
1. /qa:qa-perf           # Identifier les problemes
2. /dev:dev-react-perf    # Optimiser React
3. /qa:qa-a11y           # Verifier accessibilite
```

## Agents Automatiques

Ces agents sont declenches automatiquement selon le contexte:

| Contexte | Agent | Action |
|----------|-------|--------|
| "Explore le code" | work-explore | Lecture codebase |
| "Audit performance" | qa-perf | Analyse Core Web Vitals |
| "Review ce composant" | qa-review | Code review |
| "Debug cette erreur" | dev-debug | Investigation |

## Anti-patterns a Eviter

- Prop drilling excessif → Utiliser Context ou state manager
- useEffect pour tout → Utiliser React Query/SWR
- Re-renders inutiles → Utiliser memo/useMemo/useCallback
- CSS global partout → Utiliser CSS Modules/Tailwind
- any en TypeScript → Definir des types stricts

## Ressources

- [React Docs](https://react.dev)
- [Next.js Docs](https://nextjs.org/docs)
- [Tailwind CSS](https://tailwindcss.com)
- [Testing Library](https://testing-library.com)
