---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/components/**"
  - "**/pages/**"
  - "**/app/**"
---

# Accessibility Rules (WCAG 2.1 AA)

## Principes POUR (WCAG)

| Principe | Description |
|----------|-------------|
| **Perceivable** | Contenu perceptible par tous |
| **Operable** | Interface utilisable au clavier |
| **Understandable** | Contenu comprehensible |
| **Robust** | Compatible avec les technologies d'assistance |

## Images et medias

### Images

```tsx
// BON - Alt text descriptif
<img src="chart.png" alt="Graphique montrant une croissance de 25% des ventes en Q4" />

// BON - Image decorative
<img src="decoration.png" alt="" role="presentation" />

// MAUVAIS
<img src="chart.png" />
<img src="chart.png" alt="image" />
```

### Videos

```tsx
// Toujours fournir des sous-titres
<video controls>
  <source src="video.mp4" type="video/mp4" />
  <track kind="captions" src="captions.vtt" srclang="fr" label="Francais" />
</video>
```

## Formulaires

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

## Navigation clavier

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

## Boutons et liens

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

## Couleurs et contraste

### Ratio de contraste minimum

| Element | Ratio minimum |
|---------|---------------|
| Texte normal | 4.5:1 |
| Grand texte (18px+) | 3:1 |
| Elements UI | 3:1 |

### Ne pas utiliser la couleur seule

```tsx
// BON - Couleur + icone + texte
<span className="error">
  <ErrorIcon /> Ce champ est requis
</span>

// MAUVAIS - Couleur seule
<span style={{ color: 'red' }}>Erreur</span>
```

## Modales et dialogues

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

## Regles IMPORTANTES

IMPORTANT: Chaque image doit avoir un attribut alt (vide pour decoratives).

IMPORTANT: Chaque formulaire doit avoir des labels associes.

IMPORTANT: Le site doit etre 100% navigable au clavier.

YOU MUST tester avec un lecteur d'ecran (VoiceOver, NVDA).

YOU MUST respecter les ratios de contraste WCAG AA.

NEVER utiliser la couleur comme seul indicateur d'information.

NEVER supprimer le focus visible sans alternative.
