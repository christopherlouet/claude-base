# Agent A11Y (Accessibilité)

Audit d'accessibilité basé sur WCAG 2.1 et Web Interface Guidelines.

## Cible de l'audit
$ARGUMENTS

## Niveaux WCAG

| Niveau | Description |
|--------|-------------|
| A | Minimum requis (barrières majeures) |
| AA | Standard recommandé (la plupart des sites) |
| AAA | Accessibilité optimale (spécialisé) |

## Checklist WCAG 2.1 (Niveau AA)

### 1. Perceptible

#### 1.1 Alternatives textuelles
- [ ] Images avec attribut `alt` descriptif
- [ ] `alt=""` pour images décoratives
- [ ] Descriptions longues pour images complexes
- [ ] Transcriptions pour audio/vidéo

#### 1.2 Médias temporels
- [ ] Sous-titres pour vidéos
- [ ] Audio-description si nécessaire
- [ ] Transcriptions disponibles

#### 1.3 Adaptable
- [ ] Structure sémantique (headings h1-h6 ordonnés)
- [ ] Listes correctement balisées (ul, ol)
- [ ] Tableaux avec headers (th, scope)
- [ ] Landmarks ARIA (main, nav, aside)
- [ ] Ordre de lecture logique

#### 1.4 Distinguable
- [ ] Contraste texte/fond ≥ 4.5:1 (AA) ou ≥ 7:1 (AAA)
- [ ] Contraste grands textes ≥ 3:1
- [ ] Texte redimensionnable jusqu'à 200%
- [ ] Pas de perte d'info en zoom
- [ ] Pas uniquement la couleur pour transmettre l'info

### 2. Utilisable

#### 2.1 Accessible au clavier
- [ ] Tout accessible au clavier
- [ ] Pas de piège clavier
- [ ] Raccourcis désactivables
- [ ] Focus visible

#### 2.2 Assez de temps
- [ ] Timeouts ajustables ou désactivables
- [ ] Pause possible pour contenu en mouvement
- [ ] Pas de limite de temps sauf nécessaire

#### 2.3 Crises et réactions physiques
- [ ] Pas de flash > 3 fois/seconde
- [ ] Animations désactivables (prefers-reduced-motion)

#### 2.4 Navigable
- [ ] Skip links présents
- [ ] Titres de page descriptifs
- [ ] Ordre de focus logique
- [ ] Liens explicites (pas de "cliquez ici")
- [ ] Multiple moyens de navigation

#### 2.5 Modalités d'entrée
- [ ] Gestes simples alternatifs
- [ ] Click/tap annulable
- [ ] Labels correspondent aux noms accessibles

### 3. Compréhensible

#### 3.1 Lisible
- [ ] Langue de la page définie (lang="fr")
- [ ] Langue des passages en autre langue
- [ ] Mots inhabituels expliqués

#### 3.2 Prévisible
- [ ] Navigation cohérente
- [ ] Composants cohérents
- [ ] Pas de changement de contexte au focus
- [ ] Changements initiés par l'utilisateur

#### 3.3 Aide à la saisie
- [ ] Erreurs identifiées clairement
- [ ] Labels pour tous les inputs
- [ ] Instructions disponibles
- [ ] Suggestions de correction
- [ ] Prévention des erreurs (confirmation)

### 4. Robuste

#### 4.1 Compatible
- [ ] HTML valide
- [ ] ARIA correctement utilisé
- [ ] Nom, rôle, valeur programmatiques
- [ ] Messages de statut accessibles

## Web Interface Guidelines (Compléments UX)

### 5. Focus States

- [ ] **Focus visible** : Indicateur visible sur tous les éléments interactifs
  ```css
  /* Utiliser :focus-visible au lieu de :focus */
  button:focus-visible {
    outline: 2px solid var(--focus-color);
    outline-offset: 2px;
  }
  ```
- [ ] **:focus-within** : Style parent quand enfant a le focus
- [ ] **Pas de `outline: none`** sans alternative visible
- [ ] **Ordre de focus** : Cohérent avec l'ordre visuel

### 6. Formulaires avancés

- [ ] **Autocomplete** : Attributs appropriés sur tous les champs
  ```html
  <input type="email" autocomplete="email" />
  <input type="tel" autocomplete="tel" />
  <input type="text" autocomplete="name" />
  ```
- [ ] **Input types** : Types HTML5 corrects (email, tel, url, number)
- [ ] **Paste autorisé** : Ne jamais bloquer le collage (mots de passe inclus)
- [ ] **Validation** : Messages d'erreur clairs et associés aux champs
- [ ] **Labels visibles** : Pas uniquement des placeholders

### 7. Animation & Motion

- [ ] **prefers-reduced-motion** : Respecter la préférence utilisateur
  ```css
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      transition-duration: 0.01ms !important;
    }
  }
  ```
- [ ] **Propriétés performantes** : Animer uniquement transform et opacity
- [ ] **Animations interruptibles** : Pouvoir stopper/annuler
- [ ] **Pas de `transition: all`** : Spécifier les propriétés explicitement

### 8. Touch & Interaction

- [ ] **Tap targets** : Minimum 44x44px pour les cibles tactiles
- [ ] **Safe areas** : Respecter les encoches (env(safe-area-inset-*))
- [ ] **Touch feedback** : `-webkit-tap-highlight-color` approprié
- [ ] **Scroll containment** : `overscroll-behavior` pour éviter les scrolls parasites
- [ ] **Drag behavior** : Alternatives pour les actions drag-and-drop

### 9. Dark Mode & Theming

- [ ] **color-scheme** : Déclarer le support
  ```css
  :root {
    color-scheme: light dark;
  }
  ```
- [ ] **theme-color meta** : Adapter la barre du navigateur
  ```html
  <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)" />
  <meta name="theme-color" content="#1a1a1a" media="(prefers-color-scheme: dark)" />
  ```
- [ ] **Couleurs explicites** : Ne pas s'appuyer sur les valeurs par défaut
- [ ] **Contraste maintenu** : Vérifier le contraste dans les deux modes

### 10. Locale & Internationalisation

- [ ] **Intl.DateTimeFormat** : Pour formater les dates
  ```typescript
  new Intl.DateTimeFormat('fr-FR', { dateStyle: 'long' }).format(date);
  ```
- [ ] **Intl.NumberFormat** : Pour les nombres et devises
- [ ] **Intl.RelativeTimeFormat** : Pour "il y a 3 jours"
- [ ] **Direction du texte** : Support RTL si nécessaire (`dir="rtl"`)

### 11. Anti-patterns à éviter

| Anti-pattern | Problème | Solution |
|--------------|----------|----------|
| `user-scalable=no` | Bloque le zoom | Retirer de viewport meta |
| `outline: none` sans alternative | Focus invisible | Utiliser `:focus-visible` |
| `transition: all` | Performance, effets inattendus | Lister les propriétés |
| `-webkit-tap-highlight-color: transparent` global | Pas de feedback tactile | Cibler spécifiquement |
| Bloquer le paste | UX horrible, sécurité réduite | Autoriser toujours |
| Placeholder comme label | Disparaît au focus | Label visible permanent |
| Timeouts trop courts | Stress utilisateur | Timeouts généreux ou infinis |

## Tests automatisés

### Outils recommandés
```bash
# axe-core (via CLI)
npx @axe-core/cli https://example.com

# Pa11y
npx pa11y https://example.com

# Lighthouse
lighthouse https://example.com --only-categories=accessibility
```

### Extensions navigateur
- axe DevTools
- WAVE
- Accessibility Insights

## Tests manuels essentiels

1. **Navigation clavier seule** (Tab, Shift+Tab, Enter, Espace, Flèches)
2. **Lecteur d'écran** (VoiceOver, NVDA, JAWS)
3. **Zoom 200%** sans perte de fonctionnalité
4. **Mode contraste élevé**
5. **Réduction de mouvement** (prefers-reduced-motion)

## Corrections courantes

### Images
```html
<!-- Avant -->
<img src="logo.png">

<!-- Après -->
<img src="logo.png" alt="Logo de l'entreprise XYZ">
```

### Boutons/Liens
```html
<!-- Avant -->
<button><i class="icon-menu"></i></button>

<!-- Après -->
<button aria-label="Ouvrir le menu">
  <i class="icon-menu" aria-hidden="true"></i>
</button>
```

### Formulaires
```html
<!-- Avant -->
<input type="email" placeholder="Email">

<!-- Après -->
<label for="email">Adresse email</label>
<input type="email" id="email" aria-describedby="email-help">
<span id="email-help">Exemple: nom@domaine.com</span>
```

## Output attendu

### Résumé
- **Score global**: [X/100]
- **Niveau WCAG atteint**: [A/AA/AAA]
- **Violations critiques**: [nombre]

### Violations détaillées
| Sévérité | Règle WCAG | Élément | Correction |
|----------|------------|---------|------------|
| Critique | 1.1.1 | img.hero | Ajouter alt="" |

### Recommandations prioritaires
1. [Action critique 1]
2. [Action critique 2]
3. [Amélioration 1]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/responsive` | Design responsive mobile |
| `/audit` | Audit complet (inclut a11y) |
| `/component` | Créer des composants accessibles |
| `/seo` | SEO (impact indirect de l'a11y) |

---

IMPORTANT: L'accessibilité n'est pas optionnelle - tester avec de vrais utilisateurs si possible.

YOU MUST atteindre au minimum le niveau AA WCAG 2.1.

NEVER ignorer les erreurs critiques d'accessibilité.

Think hard sur l'expérience des utilisateurs avec handicaps.
