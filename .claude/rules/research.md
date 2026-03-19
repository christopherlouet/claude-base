---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.dart"
  - "**/*.rs"
---

# Research Before Build

## Principe

Avant d'implementer une solution custom, verifier si le framework ou l'outil en place fournit deja la fonctionnalite nativement.

## Checklist obligatoire avant implementation

| Etape | Action | Exemple |
|-------|--------|---------|
| 1 | Lire la doc du framework utilise | Next.js, Payload CMS, Prisma, Flutter |
| 2 | Chercher dans le codebase existant | `grep -r "feature"`, explorer les modules |
| 3 | Verifier les plugins/extensions disponibles | npm packages, pub.dev, crates.io |
| 4 | Evaluer build vs buy | Effort custom vs solution existante |

## Red Flags — STOP et rechercher

| Signal | Reaction |
|--------|----------|
| Sur le point de creer 5+ fichiers pour une feature courante | STOP — le framework le gere probablement |
| Implementation d'un pattern standard (auth, i18n, upload, focal point) | STOP — verifier la doc du framework |
| Ecriture d'un wrapper autour d'une lib existante | STOP — la lib expose peut-etre deja cette API |
| Reimplementation d'une fonctionnalite supprimee | STOP — verifier pourquoi elle a ete supprimee |

## Workflow

```
1. IDENTIFIER le besoin precis
2. RECHERCHER dans le framework/CMS/lib utilise
   - Documentation officielle
   - grep/glob dans node_modules ou packages
   - Issues/discussions GitHub du framework
3. EVALUER: natif vs custom
   - Natif existe → l'utiliser
   - Natif partiel → etendre plutot que remplacer
   - Rien n'existe → implementer en custom (documenter pourquoi)
4. INFORMER l'utilisateur du choix et du raisonnement
```

## Regles

IMPORTANT: Ne JAMAIS implementer une solution custom sans avoir d'abord verifie les capacites natives du framework utilise.

IMPORTANT: Si une solution native existe, la preferer meme si elle est moins flexible qu'une solution custom.

NEVER creer plus de 5 fichiers pour une fonctionnalite standard sans avoir confirme qu'aucune solution native n'existe.
