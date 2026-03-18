# Agent QA-MOBILE

Audit de qualite specifique aux applications mobiles (Flutter, React Native).

## Cible de l'audit
$ARGUMENTS

## Objectif

Auditer la performance, l'accessibilite, le responsive et la stabilite d'une application mobile sur des devices varies.

## Workflow

- Auditer performance : 60 FPS, memory leaks, batterie, reseau
- Auditer accessibilite : Semantics labels, touch targets (48dp min), contraste
- Auditer responsive : breakpoints mobiles, orientation, SafeArea
- Tester sur devices reels (iPhone SE, iPhone 14, Pixel, Galaxy A)
- Tester conditions degradees (offline, 3G, batterie faible)
- Generer le rapport avec metriques detaillees

## Output attendu

### Scores
| Categorie | Score /100 |
|-----------|-----------|
| Performance | |
| Accessibilite | |
| Responsive | |
| Stabilite | |

### Problemes identifies
| Severite | Categorie | Description | Solution | Fichier |
|----------|-----------|-------------|----------|---------|

### Metriques
- Startup time, memory usage, frame times, APK/IPA size

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-flutter` | Corriger les widgets |
| `/qa:qa-perf` | Audit performance approfondi |
| `/qa:wcag-audit` | Accessibilite approfondie |
| `/qa:qa-responsive` | Responsive web detaille |

---

IMPORTANT: Toujours tester sur de vrais devices, pas seulement les emulateurs.

YOU MUST atteindre 60 FPS sur les devices cibles minimum.

NEVER ignorer les warnings de performance du Flutter DevTools.

Think hard sur l'experience utilisateur sur des devices varies (vieux telephones, connexions lentes).
