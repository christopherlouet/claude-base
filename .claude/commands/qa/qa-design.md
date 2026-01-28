# Agent QA-DESIGN

Audit de design UI/UX et verification des bonnes pratiques web.

## Contexte
$ARGUMENTS

## Objectif

Auditer une interface selon 100+ regles couvrant accessibilite, formulaires, animations, typographie, images, performance UI, navigation, dark mode, touch et internationalisation.

## Processus d'audit

```
┌─────────────────────────────────────────────────────────────┐
│                    UI/UX DESIGN AUDIT                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. ACCESSIBILITE   → Contraste, ARIA, focus, clavier      │
│  ═══════════════                                            │
│                                                             │
│  2. FORMULAIRES     → Validation, feedback, autocomplete   │
│  ═══════════════                                            │
│                                                             │
│  3. ANIMATIONS      → Reduced-motion, performance, timing  │
│  ══════════════                                             │
│                                                             │
│  4. TYPOGRAPHIE     → Hierarchie, lisibilite, responsive   │
│  ═════════════                                              │
│                                                             │
│  5. IMAGES          → Alt, lazy loading, formats modernes  │
│  ══════════                                                 │
│                                                             │
│  6. PERFORMANCE UI  → CLS, LCP, FID, skeleton states      │
│  ════════════════                                           │
│                                                             │
│  7. NAVIGATION      → Breadcrumbs, mobile menu, deep links │
│  ══════════════                                             │
│                                                             │
│  8. DARK MODE       → CSS vars, images, contraste          │
│  ═════════════                                              │
│                                                             │
│  9. TOUCH           → Taille cibles, espacement, gestures  │
│  ═══════                                                    │
│                                                             │
│  10. i18n           → RTL, dates, pluriels, traductions    │
│  ═════                                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Instructions

### 1. Scanner les fichiers UI

```bash
# Trouver les composants UI
find . -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" | head -50

# Trouver les fichiers CSS
find . -name "*.css" -o -name "*.scss" -o -name "*.module.css" | head -30
```

### 2. Verifier l'accessibilite

```bash
# Images sans alt
grep -rn '<img' --include="*.tsx" --include="*.jsx" | grep -v 'alt='

# Boutons sans texte
grep -rn '<button' --include="*.tsx" | grep -v 'aria-label'

# Inputs sans label
grep -rn '<input' --include="*.tsx" | grep -v 'aria-label\|id='
```

### 3. Verifier les formulaires

```bash
# Formulaires
grep -rn '<form\|<input\|<select\|<textarea' --include="*.tsx"

# Autocomplete
grep -rn 'autocomplete=' --include="*.tsx"

# Validation
grep -rn 'required\|pattern=\|minLength\|maxLength' --include="*.tsx"
```

### 4. Verifier les animations

```bash
# CSS animations
grep -rn 'animation\|transition\|@keyframes' --include="*.css" --include="*.scss"

# Reduced motion
grep -rn 'prefers-reduced-motion' --include="*.css" --include="*.scss"
```

### 5. Verifier les images

```bash
# Lazy loading
grep -rn 'loading=' --include="*.tsx" --include="*.jsx"

# Formats modernes
find . -name "*.webp" -o -name "*.avif" | wc -l
```

## Output attendu

```markdown
## Audit UI/UX Design

### Score global : X/100

| Categorie | Score | Issues critiques | Recommandations |
|-----------|-------|-----------------|-----------------|
| Accessibilite | /10 | X | Y |
| Formulaires | /10 | X | Y |
| Animations | /10 | X | Y |
| Typographie | /10 | X | Y |
| Images | /10 | X | Y |
| Performance UI | /10 | X | Y |
| Navigation | /10 | X | Y |
| Dark Mode | /10 | X | Y |
| Touch | /10 | X | Y |
| i18n | /10 | X | Y |

### Issues critiques
[Liste avec fichier:ligne]

### Quick wins
[Ameliorations rapides a fort impact]

### Recommandations
[Ameliorations structurelles]
```

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa-a11y` | Audit accessibilite WCAG detaille |
| `/qa-responsive` | Audit responsive/mobile |
| `/qa-perf` | Audit performance detaille |
| `/dev-component` | Creer des composants UI |
| `/dev-design-system` | Design tokens et systeme de design |

---

IMPORTANT: Couvrir les 10 categories, pas seulement les evidentes.

YOU MUST fournir des solutions concretes avec fichier:ligne.

YOU MUST prioriser par impact utilisateur.

NEVER ignorer l'accessibilite - c'est une obligation legale.

Think hard sur l'experience utilisateur globale, pas juste les details techniques.
