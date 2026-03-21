---
sidebar_position: 13
title: "/qa:qa-responsive"
description: "Audit responsive et mobile-first d'une application web."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent QA-RESPONSIVE

Audit responsive et mobile-first d'une application web.

## Contexte
`&lt;arguments&gt;`

## Objectif

Verifier que l'application fonctionne correctement sur tous les breakpoints (320px a 2560px), en approche mobile-first, avec des touch targets adequats.

## Workflow

- Tester les 7 breakpoints (320, 375, 425, 768, 1024, 1440, 2560)
- Verifier structure (viewport, mobile-first CSS, flexbox/grid)
- Verifier navigation (hamburger, touch targets &gt;= 44px)
- Verifier typographie (&gt;= 16px, line-height &gt;= 1.5)
- Verifier images (srcset, lazy loading, aspect ratio)
- Verifier formulaires (inputs &gt;= 44px, type correct, clavier mobile)
- Tester orientation (portrait + paysage)
- Verifier interactions tactiles (tap, swipe, espacement &gt;= 8px)

## Output attendu

### Score Responsive: [X/100]
| Breakpoint | Status |
|------------|--------|
| Mobile 320-425px | OK/KO |
| Tablet 768px | OK/KO |
| Desktop 1024-1440px | OK/KO |

### Problemes par breakpoint
| Breakpoint | Page | Probleme | Severite |
|------------|------|----------|----------|

### Corrections prioritaires
1. Critique: [Probleme] -&gt; [Solution]
2. Important: [Probleme] -&gt; [Solution]

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:wcag-audit` | Accessibilite mobile |
| `/qa:qa-perf` | Performance mobile |
| `/dev:dev-component` | Creer des composants responsives |
| `/growth:growth-landing` | Landing pages responsives |

---

IMPORTANT: Toujours tester sur de vrais devices, pas seulement les DevTools.

YOU MUST utiliser l'approche mobile-first (min-width, pas max-width).

NEVER utiliser de largeurs fixes en pixels pour les conteneurs.

Think hard sur l'experience utilisateur sur petit ecran.


---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
