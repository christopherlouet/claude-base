---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/components/**"
  - "**/pages/**"
  - "**/app/**"
---

# Design Style Rules

## Direction artistique

La direction design du projet est definie dans CLAUDE.md :

```markdown
## Design Direction
Style: <direction>
```

Si aucune direction n'est specifiee, appliquer `modern` (equivalent de l'ancien glass).

## Directions disponibles

### terminal — L'interface qui code

| Aspect | Direction |
|--------|-----------|
| Palette | Fond noir/tres sombre, accent neon unique (vert, cyan ou ambre), texte clair haute lisibilite |
| Typographie | Monospace (JetBrains Mono, Fira Code, IBM Plex Mono), hierarchie par poids et taille |
| Radius | Sharp : 0-4px, bords nets |
| Spacing | Compact, dense, padding serre (8-12px), grilles alignees |
| Animations | Scan lines, glow pulse, caret blink, fade-in rapide (100-150ms). Pas de bounce ni de spring |
| Composants | Cards bordees (1px solid), inputs avec prompt-style, boutons outlined, badges monochromes |
| Anti-patterns | Coins arrondis > 8px, gradients colores, illustrations cartoon, ombres diffuses, pastels |

### cockpit — Le tableau de bord de pilote

| Aspect | Direction |
|--------|-----------|
| Palette | Dark-first, couleurs fonctionnelles (rouge alerte, vert OK, ambre warning, bleu info), fond sombre stratifie |
| Typographie | Sans-serif condensee (Inter, DM Sans), monospace pour les donnees chiffrees, hierarchie par densite |
| Radius | Faible : 4-6px, fonctionnel |
| Spacing | Dense, grilles multi-colonnes, peu de whitespace, panels juxtaposes |
| Animations | Transitions rapides (100-200ms), pulse sur indicateurs temps reel, fade pour mises a jour de donnees |
| Composants | Widgets modulaires, mini-charts inline, badges de statut, KPI cards, tables denses, sparklines |
| Anti-patterns | Grandes illustrations, whitespace excessif, coins tres arrondis, animations lentes, layouts single-column |

### vitality — L'energie positive

| Aspect | Direction |
|--------|-----------|
| Palette | Vive et harmonieuse, 3-4 couleurs de categorie bien distinctes, fond clair ou creme, accents energiques |
| Typographie | Sans-serif arrondie et amicale (Nunito, Plus Jakarta Sans, DM Sans), titres gras et engageants |
| Radius | Genereux : 12-16px, formes douces |
| Spacing | Aere, padding confortable (16-24px), espaces de respiration entre sections |
| Animations | Micro-animations de progression (barres, compteurs), spring/bounce subtils (200-300ms), celebratory feedback |
| Composants | Cards colorees avec icones, progress bars, streaks, badges de recompense, boutons pleins et ronds |
| Anti-patterns | Dark mode par defaut, monospace, esthetique technique/austere, absence de couleur, layouts denses |

### editorial — Le magazine numerique

| Aspect | Direction |
|--------|-----------|
| Palette | Neutre et sobre, noir/blanc dominant, 1 couleur d'accent editoriale, fond blanc ou creme papier |
| Typographie | Serif pour titres (Playfair Display, Lora, Merriweather), sans-serif pour corps, hierarchie tres marquee |
| Radius | Minimal : 0-4px, lignes droites |
| Spacing | Tres aere, grands espaces blancs, marges genereuses, max-width 65-75ch pour le texte |
| Animations | Subtiles, fade-in au scroll (200-400ms), transitions de page douces. Aucune animation decorative |
| Composants | Cartes image plein-format, citations stylisees, separateurs fins, navigation discrete, listes epurees |
| Anti-patterns | Surcharge visuelle, couleurs vives multiples, emojis, badges gamifies, grilles complexes, ombres prononcees |

### glass — La transparence moderne

| Aspect | Direction |
|--------|-----------|
| Palette | Fond avec profondeur (gradient subtil ou image), surfaces semi-transparentes, accent lumineux unique |
| Typographie | Sans-serif geometrique (Geist, Inter, SF Pro), poids light a medium, hierarchie par opacite |
| Radius | Moyen-genereux : 12-16px, formes fluides |
| Spacing | Equilibre, padding moyen (16-20px), layering avec espacement entre surfaces |
| Animations | Blur transitions, fade avec depth (200-300ms), hover avec elevation, parallax subtil |
| Composants | Cards glassmorphism (backdrop-blur + bg opacity), overlays, floating panels, boutons translucides |
| Anti-patterns | Bords durs, fonds opaques plats, ombres dures, high contrast brut, esthetique technique/terminal |

### signal — L'efficacite brute

| Aspect | Direction |
|--------|-----------|
| Palette | Neutre (gris/blanc), couleurs limitees au strict signal (action, erreur, succes), pas de decoration |
| Typographie | Sans-serif system-ui ou geometrique (Inter, system-ui), tailles serrees, pas de fioritures |
| Radius | Faible : 4-6px, utilitaire |
| Spacing | Serre mais lisible, padding minimal (8-12px), densite maximale sans sacrifier la lisibilite |
| Animations | Quasi-absentes, transitions instantanees (50-100ms), feedback immediat, pas d'animation decorative |
| Composants | Inputs inline, actions contextuelles, commande palette, raccourcis clavier, tables compactes, menus plats |
| Anti-patterns | Illustrations, gradients, ombres decoratives, animations longues, grandes marges, fioritures visuelles |

## Application des directions

IMPORTANT: La direction s'applique a TOUS les themes du projet. Un theme (light, dark, sepia) ne change que la palette de couleurs, pas la personnalite visuelle.

IMPORTANT: Ne pas mixer les directions. Si le projet est `terminal`, un theme light reste monospace, compact, avec bords nets.

YOU MUST lire la directive `Style:` dans CLAUDE.md avant de generer du code UI.

YOU MUST adapter les composants, espacements, animations et typographie a la direction choisie.

NEVER generer du code UI generique/par defaut quand une direction est specifiee.

NEVER changer la direction en cours de projet sans instruction explicite.
