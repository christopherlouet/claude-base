---
sidebar_position: 2
title: "accessibility"
description: "IMPORTANT: Chaque image doit avoir un attribut alt. IMPORTANT: Chaque formulaire doit avoir des labels associes. IMPORTANT: Le site doit etre 100% nav"
tags:
  - "rule"
  - "accessibility"
---

# Regles: accessibility

> IMPORTANT: Chaque image doit avoir un attribut alt. IMPORTANT: Chaque formulaire doit avoir des labels associes. IMPORTANT: Le site doit etre 100% navigable au clavier. IMPORTANT: Les attributs ARIA d

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/*.tsx`
- `**/*.jsx`
- `**/components/**`
- `**/pages/**`
- `**/app/**`

## Regles detaillees

# Accessibility Rules (WCAG 2.1/2.2 AA)

## Niveaux d'impact (inspire axe-core)

| Niveau | Definition | Action |
|--------|-----------|--------|
| **Critical** | Bloque completement l'acces | Corriger immediatement |
| **Serious** | Impact significatif sur l'utilisabilite | Corriger avant release |
| **Moderate** | Gene l'experience utilisateur | Planifier correction |
| **Minor** | Amelioration souhaitable | Backlog |

## 1. Images et medias

| Regle | Impact | WCAG |
|-------|--------|------|
| Chaque `&lt;img&gt;` doit avoir un attribut `alt` | Critical | 1.1.1 |
| Images decoratives : `alt=""` avec `role="presentation"` | Serious | 1.1.1 |
| SVG avec `role="img"` doit avoir `aria-label` ou `&lt;title&gt;` | Serious | 1.1.1 |
| `&lt;input type="image"&gt;` doit avoir `alt` | Critical | 1.1.1 |
| `&lt;object&gt;` et `&lt;embed&gt;` doivent avoir un texte alternatif | Serious | 1.1.1 |
| `&lt;area&gt;` dans image maps doit avoir `alt` | Critical | 1.1.1 |
| Videos doivent avoir des sous-titres (`&lt;track kind="captions"&gt;`) | Critical | 1.2.2 |
| Pas d'audio en lecture automatique (ou controle arret) | Serious | 1.4.2 |

## 2. Formulaires

| Regle | Impact | WCAG |
|-------|--------|------|
| Chaque input doit avoir un `&lt;label&gt;` associe (`htmlFor` ou imbrication) | Critical | 4.1.2 |
| `&lt;select&gt;` doit avoir un nom accessible | Critical | 4.1.2 |
| Erreurs doivent utiliser `aria-invalid` et `role="alert"` | Serious | 3.3.1 |
| Hints avec `aria-describedby` | Moderate | 3.3.2 |
| Attributs `autocomplete` valides et pertinents | Moderate | 1.3.5 |
| Pas de labels multiples sur un meme champ | Moderate | 4.1.2 |

## 3. Navigation clavier

| Regle | Impact | WCAG |
|-------|--------|------|
| Focus visible obligatoire (`:focus-visible` avec `outline`) | Serious | 2.4.7 |
| Ne jamais utiliser `tabIndex` positif | Serious | 2.4.3 |
| Site 100% navigable au clavier | Critical | 2.1.1 |
| Pas de piege clavier (focus ne doit pas rester bloque) | Critical | 2.1.2 |
| Lien "Skip to content" en debut de page | Serious | 2.4.1 |
| Zones scrollables doivent etre focusables | Serious | 2.1.1 |
| Pas d'elements interactifs imbriques (bouton dans bouton) | Serious | 4.1.2 |

## 4. Boutons et liens

| Regle | Impact | WCAG |
|-------|--------|------|
| Boutons doivent avoir un texte accessible | Critical | 4.1.2 |
| Boutons icones doivent avoir `aria-label` | Critical | 4.1.2 |
| Liens descriptifs (pas "cliquez ici") | Serious | 2.4.4 |
| Liens externes : indiquer ouverture nouvel onglet via `sr-only` | Moderate | 2.4.4 |
| Liens dans un bloc de texte distinguables sans la couleur seule | Serious | 1.4.1 |

## 5. Couleurs et contraste

| Regle | Impact | WCAG |
|-------|--------|------|
| Texte normal : ratio minimum 4.5:1 | Serious | 1.4.3 |
| Grand texte (18px+ ou 14px+ bold) : ratio minimum 3:1 | Serious | 1.4.3 |
| Elements UI et graphiques : ratio minimum 3:1 | Serious | 1.4.11 |
| Ne jamais utiliser la couleur comme seul indicateur | Serious | 1.4.1 |

## 6. ARIA

| Regle | Impact | WCAG |
|-------|--------|------|
| Seuls les attributs ARIA autorises pour le role utilise | Critical | 4.1.2 |
| Attributs ARIA requis presents selon le role | Critical | 4.1.2 |
| Pas d'attributs ARIA prohibes pour le role | Serious | 4.1.2 |
| Valeurs d'attributs ARIA valides | Critical | 4.1.2 |
| Roles ARIA valides (pas de role invente) | Critical | 4.1.2 |
| Pas de roles ARIA deprecies | Moderate | 4.1.2 |
| `aria-hidden="true"` ne doit pas etre sur des elements focusables | Critical | 4.1.2 |
| `aria-hidden="true"` interdit sur `&lt;body&gt;` | Critical | 4.1.2 |
| Relations parent/enfant ARIA respectees (ex: listbox &gt; option) | Serious | 1.3.1 |
| Composants ARIA nommes : dialog, meter, progressbar, tooltip | Serious | 4.1.2 |

## 7. Structure et semantique

| Regle | Impact | WCAG |
|-------|--------|------|
| `&lt;html&gt;` doit avoir un attribut `lang` valide | Serious | 3.1.1 |
| `&lt;title&gt;` non vide et descriptif | Serious | 2.4.2 |
| Hierarchie des headings respectee (pas de saut h1 &gt; h3) | Moderate | 1.3.1 |
| Headings non vides | Serious | 2.4.6 |
| Page contient un `&lt;h1&gt;` | Moderate | 1.3.1 |
| Landmarks (`&lt;main&gt;`, `&lt;nav&gt;`, `&lt;header&gt;`, `&lt;footer&gt;`) utilises | Moderate | 1.3.1 |
| Landmarks de meme type ont un label unique (`aria-label`) | Moderate | 2.4.1 |
| Tout le contenu de page dans un landmark (`&lt;main&gt;`) | Moderate | 1.3.1 |
| Listes structurees correctement (`&lt;ul&gt;/&lt;ol&gt;` &gt; `&lt;li&gt;`) | Moderate | 1.3.1 |
| Langue des passages etrangers marquee (`lang` sur l'element) | Minor | 3.1.2 |

## 8. Tables

| Regle | Impact | WCAG |
|-------|--------|------|
| Tables de donnees doivent avoir des `&lt;th&gt;` | Serious | 1.3.1 |
| `&lt;th&gt;` doit avoir un attribut `scope` (col/row) | Serious | 1.3.1 |
| `&lt;td headers=""&gt;` doit referencer des `&lt;th&gt;` existants | Serious | 1.3.1 |
| `&lt;th&gt;` ne doit pas etre vide | Serious | 1.3.1 |
| `&lt;caption&gt;` et `summary` ne doivent pas etre identiques | Minor | 1.3.1 |

## 9. Frames et iframes

| Regle | Impact | WCAG |
|-------|--------|------|
| Chaque `&lt;iframe&gt;` doit avoir un attribut `title` | Serious | 4.1.2 |
| Titres d'iframes uniques dans la page | Moderate | 4.1.2 |
| Iframe avec contenu focusable ne doit pas avoir `tabindex="-1"` | Serious | 2.1.1 |

## 10. Elements deprecies et dangereux

| Regle | Impact | WCAG |
|-------|--------|------|
| Ne pas utiliser `&lt;blink&gt;` | Serious | 2.2.2 |
| Ne pas utiliser `&lt;marquee&gt;` | Serious | 2.2.2 |
| Pas de `&lt;meta http-equiv="refresh"&gt;` avec delai | Serious | 2.2.1 |
| Pas d'autoplay audio/video sans controle | Serious | 1.4.2 |

## 11. WCAG 2.2

| Regle | Impact | WCAG |
|-------|--------|------|
| Cibles tactiles minimum 44x44px (boutons, liens, inputs) | Serious | 2.5.8 |
| Focus ne doit pas etre masque par d'autres elements | Serious | 2.4.11 |

## Regles IMPORTANTES

IMPORTANT: Chaque image doit avoir un attribut alt.
IMPORTANT: Chaque formulaire doit avoir des labels associes.
IMPORTANT: Le site doit etre 100% navigable au clavier.
IMPORTANT: Les attributs ARIA doivent etre valides et autorises pour le role.
YOU MUST respecter les ratios de contraste WCAG AA.
YOU MUST utiliser des landmarks semantiques (main, nav, header, footer).
NEVER utiliser la couleur comme seul indicateur d'information.
NEVER supprimer le focus visible sans alternative.
NEVER mettre aria-hidden="true" sur un element focusable.
NEVER utiliser des elements deprecies (blink, marquee).

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
