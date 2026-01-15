# Agent QA-RESPONSIVE

Audit responsive et mobile-first d'une application web.

## Contexte
$ARGUMENTS

## Processus d'audit

### 1. Breakpoints à tester

| Device | Largeur | Catégorie |
|--------|---------|-----------|
| Mobile S | 320px | Mobile |
| Mobile M | 375px | Mobile |
| Mobile L | 425px | Mobile |
| Tablet | 768px | Tablet |
| Laptop | 1024px | Desktop |
| Laptop L | 1440px | Desktop |
| 4K | 2560px | Large |

### 2. Checklist Mobile-First

#### Structure
- [ ] Viewport meta tag présent
```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```
- [ ] CSS mobile-first (min-width, pas max-width)
- [ ] Pas de largeur fixe en pixels
- [ ] Flexbox/Grid utilisé pour les layouts

#### Navigation
- [ ] Menu hamburger sur mobile
- [ ] Touch targets ≥ 44x44px
- [ ] Navigation accessible au pouce
- [ ] Pas de hover-only sur mobile

#### Typographie
- [ ] Taille de base ≥ 16px
- [ ] Line-height ≥ 1.5
- [ ] Pas de texte trop petit sur mobile
- [ ] Texte lisible sans zoom

#### Images
- [ ] Images responsives (srcset)
- [ ] Lazy loading activé
- [ ] Aspect ratio préservé
- [ ] Pas d'images trop grandes sur mobile

#### Formulaires
- [ ] Inputs assez grands (≥ 44px height)
- [ ] Labels visibles
- [ ] Type d'input correct (email, tel, number)
- [ ] Clavier approprié sur mobile

#### Performance mobile
- [ ] First Contentful Paint < 2s sur 3G
- [ ] Pas de layout shift
- [ ] Contenu above-the-fold rapide

### 3. Recherche dans le code

```bash
# Vérifier les media queries
grep -rn "@media" --include="*.css" --include="*.scss" --include="*.tsx" | head -20

# Vérifier les largeurs fixes
grep -rn "width:\s*[0-9]+px" --include="*.css" --include="*.scss" | head -20

# Vérifier le viewport
grep -rn "viewport" --include="*.html" --include="*.tsx"
```

### 4. Points de contrôle par page

Pour chaque page importante :

#### Header
- [ ] Logo visible et cliquable
- [ ] Navigation accessible
- [ ] Pas de débordement horizontal

#### Contenu principal
- [ ] Texte lisible
- [ ] Images redimensionnées
- [ ] Tableaux scrollables horizontalement
- [ ] Formulaires utilisables

#### Footer
- [ ] Liens accessibles
- [ ] Pas d'éléments cachés importants

### 5. Tests tactiles

#### Interactions
- [ ] Tap fonctionne correctement
- [ ] Swipe si nécessaire
- [ ] Pinch-to-zoom non bloqué (sauf si justifié)
- [ ] Double-tap comportement correct

#### Espacement
- [ ] Éléments cliquables espacés (≥ 8px)
- [ ] Pas de clics accidentels
- [ ] Zone de touch assez grande

### 6. Orientation

- [ ] Portrait fonctionne
- [ ] Paysage fonctionne
- [ ] Pas de contenu coupé
- [ ] Layout adapté si nécessaire

### 7. Problèmes courants

| Problème | Solution |
|----------|----------|
| Débordement horizontal | `overflow-x: hidden` sur body, vérifier les éléments larges |
| Texte trop petit | Minimum 16px, utiliser rem/em |
| Images non responsives | `max-width: 100%; height: auto;` |
| Touch targets trop petits | Minimum 44x44px |
| Hover-only | Ajouter alternatives tactiles |
| Input zoom iOS | Font-size ≥ 16px sur inputs |

## Output attendu

### Résumé de l'audit

```
Score Responsive: [X/100]
Mobile: [OK/KO]
Tablet: [OK/KO]
Desktop: [OK/KO]
```

### Problèmes par breakpoint

| Breakpoint | Page | Problème | Sévérité |
|------------|------|----------|----------|
| 320px | Home | [description] | Haute |
| 768px | Contact | [description] | Moyenne |

### Screenshots recommandés

- [ ] Mobile 375px - Home
- [ ] Mobile 375px - Navigation ouverte
- [ ] Tablet 768px - Home
- [ ] Desktop 1440px - Home

### Corrections prioritaires

#### Critique (bloquant)
1. [Problème] → [Solution]

#### Important
1. [Problème] → [Solution]

#### Mineur
1. [Problème] → [Solution]

### CSS recommandé

```css
/* Base mobile-first */
.container {
  padding: 1rem;
}

/* Tablet */
@media (min-width: 768px) {
  .container {
    padding: 2rem;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .container {
    padding: 3rem;
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

### Checklist de validation

- [ ] Testé sur 320px
- [ ] Testé sur 375px
- [ ] Testé sur 768px
- [ ] Testé sur 1024px
- [ ] Testé sur 1440px
- [ ] Testé en portrait
- [ ] Testé en paysage
- [ ] Touch targets validés
- [ ] Performance mobile OK

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/a11y` | Accessibilité mobile |
| `/perf` | Performance mobile |
| `/component` | Créer des composants responsives |
| `/landing` | Landing pages responsives |

---

IMPORTANT: Toujours tester sur de vrais devices, pas seulement les DevTools.

YOU MUST utiliser l'approche mobile-first (min-width, pas max-width).

NEVER utiliser de largeurs fixes en pixels pour les conteneurs.

Think hard sur l'expérience utilisateur sur petit écran.
