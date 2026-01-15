# Exemple d'exploration de codebase

## Contexte
Nouveau développeur sur un projet e-commerce Next.js.

## Exploration réalisée

### 1. Vue d'ensemble
```bash
# Structure du projet
tree -L 2 -d src/
```

**Résultat:**
```
src/
├── app/           # Routes Next.js 13+ (App Router)
├── components/    # Composants React
├── hooks/         # Custom hooks
├── lib/           # Utilitaires et configurations
├── services/      # Appels API
└── types/         # Types TypeScript
```

### 2. Points d'entrée identifiés
- `src/app/layout.tsx` - Layout principal
- `src/app/page.tsx` - Page d'accueil
- `src/lib/db.ts` - Connexion base de données
- `src/services/api.ts` - Client API

### 3. Patterns découverts

| Pattern | Localisation | Usage |
|---------|--------------|-------|
| Server Components | `app/**/*.tsx` | Rendu côté serveur |
| Client Components | `components/**/*.tsx` | Interactivité |
| Custom Hooks | `hooks/use*.ts` | Logique réutilisable |
| Zod Validation | `lib/schemas/*.ts` | Validation des données |

### 4. Dépendances clés
```json
{
  "next": "14.x",
  "react": "18.x",
  "prisma": "5.x",
  "zod": "3.x",
  "tailwindcss": "3.x"
}
```

### 5. Conventions détectées
- Nommage: PascalCase pour composants, camelCase pour hooks
- Tests: `__tests__/` à côté des fichiers
- Styles: Tailwind CSS, pas de CSS modules

## Output final

```markdown
## Résumé de l'exploration

**Type de projet**: E-commerce Next.js 14
**Architecture**: App Router + Server Components
**Base de données**: PostgreSQL via Prisma
**Styling**: Tailwind CSS

### Fichiers clés à connaître
1. `src/app/layout.tsx` - Point d'entrée
2. `src/lib/db.ts` - Configuration Prisma
3. `src/services/api.ts` - Appels backend

### Prochaines étapes recommandées
- Lire `src/app/api/` pour comprendre les endpoints
- Explorer `src/components/` pour les composants UI
```
