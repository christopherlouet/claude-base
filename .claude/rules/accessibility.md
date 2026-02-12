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

## Regles essentielles

### Images et medias
- Chaque image doit avoir un attribut `alt` (vide `alt=""` pour decoratives)
- Videos doivent avoir des sous-titres (`<track kind="captions">`)

### Formulaires
- Chaque input doit avoir un `<label>` associe (via `htmlFor` ou imbrication)
- Erreurs doivent utiliser `aria-invalid` et `role="alert"`
- Hints avec `aria-describedby`

### Navigation clavier
- Focus visible obligatoire (`:focus-visible` avec `outline`)
- Ne jamais utiliser `tabIndex` positif
- Site 100% navigable au clavier

### Boutons et liens
- Boutons icones doivent avoir `aria-label`
- Liens descriptifs (pas "cliquez ici")
- Liens externes : indiquer `(ouvre dans un nouvel onglet)` via `sr-only`

### Couleurs et contraste
- Texte normal : ratio minimum 4.5:1
- Grand texte (18px+) : ratio minimum 3:1
- Ne jamais utiliser la couleur comme seul indicateur

### Modales
- Utiliser `role="dialog"`, `aria-modal="true"`, `aria-labelledby`

### Texte masque
- Classe `.sr-only` pour texte lecteurs d'ecran uniquement

## Regles IMPORTANTES

IMPORTANT: Chaque image doit avoir un attribut alt.
IMPORTANT: Chaque formulaire doit avoir des labels associes.
IMPORTANT: Le site doit etre 100% navigable au clavier.
YOU MUST respecter les ratios de contraste WCAG AA.
NEVER utiliser la couleur comme seul indicateur d'information.
NEVER supprimer le focus visible sans alternative.
