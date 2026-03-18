---
sidebar_position: 2
title: "accessibility"
description: "Regles d'accessibilite WCAG 2.1/2.2 AA inspirees du referentiel axe-core"
tags:
  - "rule"
  - "accessibility"
---

# Regles: accessibility

> Regles d'accessibilite WCAG 2.1/2.2 AA inspirees du referentiel axe-core (93+ regles)

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

## Principes POUR (WCAG)

| Principe | Description |
|----------|-------------|
| **Perceivable** | Contenu perceptible par tous |
| **Operable** | Interface utilisable au clavier |
| **Understandable** | Contenu comprehensible |
| **Robust** | Compatible avec les technologies d'assistance |

## 1. Images et medias

### Images avec alt text

```tsx
// BON - Alt text descriptif
<img src="chart.png" alt="Graphique montrant une croissance de 25% des ventes en Q4" />

// BON - Image decorative
<img src="decoration.png" alt="" role="presentation" />

// MAUVAIS
<img src="chart.png" />
<img src="chart.png" alt="image" />
```

### SVG accessibles

```tsx
// BON - SVG avec role et label
<svg role="img" aria-label="Logo de l'entreprise">
  <title>Logo de l'entreprise</title>
  <path d="..." />
</svg>

// BON - SVG decoratif
<svg aria-hidden="true" focusable="false">
  <path d="..." />
</svg>

// MAUVAIS - SVG sans accessibilite
<svg><path d="..." /></svg>
```

### Videos

```tsx
// Toujours fournir des sous-titres
<video controls>
  <source src="video.mp4" type="video/mp4" />
  <track kind="captions" src="captions.vtt" srclang="fr" label="Francais" />
</video>
```

## 2. Formulaires

### Labels

```tsx
// BON - Label explicite
<label htmlFor="email">Adresse email</label>
<input id="email" type="email" aria-describedby="email-hint" />
<span id="email-hint">Nous ne partagerons jamais votre email</span>

// BON - Label implicite
<label>
  Adresse email
  <input type="email" />
</label>

// MAUVAIS - Pas de label
<input type="email" placeholder="Email" />
```

### Select accessible

```tsx
// BON - Select avec label
<label htmlFor="country">Pays</label>
<select id="country" name="country">
  <option value="">Selectionnez un pays</option>
  <option value="fr">France</option>
</select>

// MAUVAIS - Select sans label
<select name="country">
  <option value="fr">France</option>
</select>
```

### Erreurs

```tsx
// BON - Erreur accessible
<input
  id="email"
  type="email"
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && (
  <span id="email-error" role="alert">
    Veuillez entrer une adresse email valide
  </span>
)}
```

## 3. Navigation clavier

### Focus visible

```css
/* Toujours avoir un focus visible */
:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Ne JAMAIS supprimer le focus sans alternative */
:focus {
  outline: none; /* MAUVAIS */
}

:focus-visible {
  outline: 2px solid var(--color-primary); /* BON */
}
```

### Ordre du focus

```tsx
// BON - Ordre logique avec tabindex
<button tabIndex={0}>Premier</button>
<button tabIndex={0}>Deuxieme</button>

// MAUVAIS - tabindex positif
<button tabIndex={2}>Deuxieme</button>
<button tabIndex={1}>Premier</button>
```

### Skip to content

```tsx
// BON - Lien d'evitement en debut de page
<a href="#main-content" className="sr-only focus:not-sr-only">
  Aller au contenu principal
</a>
{/* ... header, nav ... */}
<main id="main-content">
  {/* contenu principal */}
</main>
```

### Zones scrollables focusables

```tsx
// BON - Zone scrollable accessible au clavier
<div role="region" aria-label="Code source" tabIndex={0} style={{ overflow: 'auto' }}>
  <pre><code>{codeContent}</code></pre>
</div>

// MAUVAIS - Zone scrollable non focusable
<div style={{ overflow: 'auto' }}>
  <pre><code>{codeContent}</code></pre>
</div>
```

## 4. Boutons et liens

### Boutons

```tsx
// BON - Bouton avec texte
<button onClick={handleClick}>Sauvegarder</button>

// BON - Bouton icone avec label
<button onClick={handleClose} aria-label="Fermer la modale">
  <CloseIcon aria-hidden="true" />
</button>

// MAUVAIS - Bouton sans label accessible
<button onClick={handleClose}>
  <CloseIcon />
</button>
```

### Liens

```tsx
// BON - Lien descriptif
<a href="/pricing">Voir nos tarifs</a>

// BON - Lien externe
<a href="https://external.com" target="_blank" rel="noopener noreferrer">
  Documentation externe
  <span className="sr-only">(ouvre dans un nouvel onglet)</span>
</a>

// MAUVAIS
<a href="/pricing">Cliquez ici</a>
<a href="https://external.com" target="_blank">Lien</a>
```

### Pas d'elements interactifs imbriques

```tsx
// MAUVAIS - Bouton dans un lien
<a href="/product">
  <button>Acheter</button>
</a>

// BON - Un seul element interactif
<a href="/product" className="product-card">
  Voir le produit
</a>
```

## 5. Couleurs et contraste

### Ratio de contraste minimum

| Element | Ratio minimum | WCAG |
|---------|---------------|------|
| Texte normal | 4.5:1 | 1.4.3 |
| Grand texte (18px+ ou 14px+ bold) | 3:1 | 1.4.3 |
| Elements UI et graphiques | 3:1 | 1.4.11 |

### Ne pas utiliser la couleur seule

```tsx
// BON - Couleur + icone + texte
<span className="error">
  <ErrorIcon /> Ce champ est requis
</span>

// MAUVAIS - Couleur seule
<span style={{ color: 'red' }}>Erreur</span>
```

## 6. ARIA

### Attributs ARIA valides

```tsx
// BON - Attributs autorises pour le role
<div role="tablist" aria-label="Onglets parametres">
  <button role="tab" aria-selected={true} aria-controls="panel-1">General</button>
  <button role="tab" aria-selected={false} aria-controls="panel-2">Securite</button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">
  {/* contenu */}
</div>

// MAUVAIS - Role invente
<div role="card">...</div>

// MAUVAIS - Attribut ARIA invalide pour le role
<button aria-checked="true">Sauvegarder</button>
```

### aria-hidden et focus

```tsx
// BON - Element masque sans focus possible
<div aria-hidden="true">
  <span>Texte decoratif</span>
</div>

// MAUVAIS - aria-hidden sur element focusable
<div aria-hidden="true">
  <button>Ce bouton est invisible mais focusable !</button>
</div>

// MAUVAIS - aria-hidden sur body
<body aria-hidden="true">...</body>
```

### Relations parent/enfant ARIA

```tsx
// BON - Structure ARIA correcte
<ul role="listbox" aria-label="Choisir une couleur">
  <li role="option" aria-selected={true}>Rouge</li>
  <li role="option" aria-selected={false}>Bleu</li>
</ul>

// MAUVAIS - Enfant sans le bon role
<ul role="listbox">
  <li>Rouge</li>  {/* manque role="option" */}
</ul>
```

### Modales et dialogues

```tsx
// Modale accessible
<dialog
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  aria-describedby="modal-description"
>
  <h2 id="modal-title">Confirmer la suppression</h2>
  <p id="modal-description">Cette action est irreversible.</p>
  <button onClick={onConfirm}>Confirmer</button>
  <button onClick={onCancel} autoFocus>Annuler</button>
</dialog>
```

## 7. Structure et semantique

### Langue et titre

```tsx
// BON - HTML avec lang et title
<html lang="fr">
  <head>
    <title>Tableau de bord - MonApp</title>
  </head>
</html>

// MAUVAIS
<html>  {/* pas de lang */}
  <head>
    <title></title>  {/* title vide */}
  </head>
</html>
```

### Hierarchie des headings

```tsx
// BON - Hierarchie respectee
<h1>Titre principal</h1>
<h2>Section</h2>
<h3>Sous-section</h3>
<h2>Autre section</h2>

// MAUVAIS - Saut de niveau
<h1>Titre principal</h1>
<h3>Sous-section</h3>  {/* h2 manquant */}
```

### Landmarks

```tsx
// BON - Landmarks semantiques
<header>
  <nav aria-label="Navigation principale">{/* ... */}</nav>
</header>
<main>
  <h1>Contenu principal</h1>
  {/* ... */}
</main>
<aside aria-label="Barre laterale">
  {/* ... */}
</aside>
<footer>{/* ... */}</footer>

// BON - Landmarks multiples avec labels uniques
<nav aria-label="Navigation principale">{/* ... */}</nav>
<nav aria-label="Fil d'Ariane">{/* ... */}</nav>

// MAUVAIS - Landmarks multiples sans distinction
<nav>{/* ... */}</nav>
<nav>{/* ... */}</nav>
```

## 8. Tables accessibles

```tsx
// BON - Table de donnees avec headers
<table>
  <caption>Ventes par trimestre</caption>
  <thead>
    <tr>
      <th scope="col">Trimestre</th>
      <th scope="col">Ventes</th>
      <th scope="col">Croissance</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Q1 2025</th>
      <td>150 000 EUR</td>
      <td>+12%</td>
    </tr>
  </tbody>
</table>

// BON - Table de presentation (pas de donnees)
<table role="presentation">
  <tr><td>Layout content</td></tr>
</table>

// MAUVAIS - Table sans headers
<table>
  <tr>
    <td>Q1</td>
    <td>150 000</td>
  </tr>
</table>
```

## 9. Frames et iframes

```tsx
// BON - Iframe avec titre
<iframe
  src="https://maps.example.com"
  title="Carte de localisation de nos bureaux"
/>

// MAUVAIS - Iframe sans titre
<iframe src="https://maps.example.com" />

// MAUVAIS - Iframe focusable masque
<iframe src="widget.html" title="Widget" tabIndex={-1}>
  {/* contenu focusable a l'interieur */}
</iframe>
```

## 10. Elements deprecies

```tsx
// MAUVAIS - Elements interdits
<blink>Texte clignotant</blink>
<marquee>Texte defilant</marquee>

// MAUVAIS - Refresh automatique
<meta httpEquiv="refresh" content="5;url=https://example.com" />

// MAUVAIS - Autoplay sans controle
<video autoPlay src="video.mp4" />

// BON - Autoplay avec muted (accepte)
<video autoPlay muted src="background.mp4" />
```

## 11. WCAG 2.2 : Target size et focus

### Cibles tactiles (44x44px minimum)

```css
/* BON - Boutons et liens avec taille suffisante */
button, a, input, select {
  min-width: 44px;
  min-height: 44px;
}

/* BON - Espacement suffisant entre cibles */
.toolbar button {
  min-width: 44px;
  min-height: 44px;
  margin: 4px;
}
```

### Focus non masque

```css
/* BON - Le focus n'est jamais masque par un sticky/fixed */
.sticky-header {
  z-index: 100;
}

/* S'assurer que l'element focus est visible au-dessus */
:focus-visible {
  z-index: 101;
  position: relative;
}
```

## Texte masque pour lecteurs d'ecran

```css
/* Classe utilitaire sr-only */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

```tsx
<button>
  <HeartIcon />
  <span className="sr-only">Ajouter aux favoris</span>
</button>
```

## Verification : violation vs needs-review

| Type | Description | Exemples |
|------|-------------|----------|
| **Violation** | Detectable automatiquement | `<img>` sans alt, `<html>` sans lang, role invalide |
| **Needs Review** | Verification manuelle requise | Pertinence alt text, contraste dynamique, ordre de lecture |

## Outils complementaires recommandes

| Outil | Commande | Usage |
|-------|----------|-------|
| **axe-core** | `npx @axe-core/cli URL` | Audit runtime automatise |
| **Playwright + axe** | `@axe-core/playwright` | Tests E2E accessibilite |
| **Pa11y** | `npx pa11y URL` | Audit CLI rapide |
| **Lighthouse** | Chrome DevTools > Accessibility | Audit navigateur |

## Regles IMPORTANTES

IMPORTANT: Chaque image doit avoir un attribut alt (vide pour decoratives).

IMPORTANT: Chaque formulaire doit avoir des labels associes.

IMPORTANT: Le site doit etre 100% navigable au clavier.

IMPORTANT: Les attributs ARIA doivent etre valides et autorises pour le role.

YOU MUST tester avec un lecteur d'ecran (VoiceOver, NVDA).

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
