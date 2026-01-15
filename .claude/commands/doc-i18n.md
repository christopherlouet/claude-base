# Agent I18N (Internationalisation)

Internationalisation et localisation du code.

## Cible
$ARGUMENTS

## Concepts clés

| Terme | Définition |
|-------|------------|
| **i18n** | Internationalisation - préparer le code pour plusieurs langues |
| **l10n** | Localisation - adapter pour une langue/culture spécifique |
| **Locale** | Combinaison langue + région (fr-FR, en-US, zh-CN) |

## Checklist d'internationalisation

### 1. Textes

#### Extraction des chaînes
- [ ] Aucun texte hardcodé dans le code
- [ ] Toutes les chaînes dans des fichiers de traduction
- [ ] Clés descriptives et organisées

```typescript
// ❌ Avant
<button>Submit</button>

// ✅ Après
<button>{t('form.submitButton')}</button>
```

#### Fichiers de traduction
```json
// locales/en.json
{
  "form": {
    "submitButton": "Submit",
    "cancelButton": "Cancel",
    "errors": {
      "required": "This field is required",
      "email": "Please enter a valid email"
    }
  }
}

// locales/fr.json
{
  "form": {
    "submitButton": "Envoyer",
    "cancelButton": "Annuler",
    "errors": {
      "required": "Ce champ est obligatoire",
      "email": "Veuillez entrer un email valide"
    }
  }
}
```

### 2. Pluralisation

```typescript
// ❌ Avant
`${count} item(s)`

// ✅ Après (avec i18next)
t('items', { count })

// Dans le fichier de traduction
{
  "items_zero": "No items",
  "items_one": "{{count}} item",
  "items_other": "{{count}} items"
}
```

### 3. Dates et heures

```typescript
// ❌ Avant
date.toLocaleDateString()

// ✅ Après
new Intl.DateTimeFormat(locale, {
  dateStyle: 'long',
  timeStyle: 'short'
}).format(date)
```

### 4. Nombres et devises

```typescript
// Nombres
new Intl.NumberFormat(locale).format(1234567.89)
// en-US: "1,234,567.89"
// fr-FR: "1 234 567,89"
// de-DE: "1.234.567,89"

// Devises
new Intl.NumberFormat(locale, {
  style: 'currency',
  currency: 'EUR'
}).format(1234.56)
// en-US: "€1,234.56"
// fr-FR: "1 234,56 €"
```

### 5. Direction du texte (RTL)

```html
<!-- Support RTL automatique -->
<html dir="auto" lang="ar">

<!-- Ou dynamique -->
<html dir={isRTL ? 'rtl' : 'ltr'}>
```

```css
/* CSS logique (pas left/right) */
.element {
  margin-inline-start: 1rem; /* au lieu de margin-left */
  padding-inline-end: 1rem;  /* au lieu de padding-right */
}
```

### 6. Images et médias

- [ ] Texte dans les images externalisé
- [ ] Images culturellement appropriées
- [ ] Icônes universellement comprises

### 7. Formulaires

- [ ] Validation des formats locaux (téléphone, code postal)
- [ ] Noms : prénom/nom pas universel
- [ ] Adresses : format variable par pays

## Structure de fichiers recommandée

```
/src
├── /locales
│   ├── en/
│   │   ├── common.json
│   │   ├── auth.json
│   │   └── errors.json
│   ├── fr/
│   │   ├── common.json
│   │   ├── auth.json
│   │   └── errors.json
│   └── index.ts
├── /i18n
│   ├── config.ts      # Configuration i18next
│   ├── useTranslation.ts
│   └── LanguageSwitcher.tsx
```

## Configuration type (React + i18next)

```typescript
// i18n/config.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: require('../locales/en/common.json') },
      fr: { translation: require('../locales/fr/common.json') }
    },
    lng: 'en',
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false
    }
  });

export default i18n;
```

## Tests i18n

```typescript
describe('i18n', () => {
  it('should have all keys in all languages', () => {
    const enKeys = getAllKeys(en);
    const frKeys = getAllKeys(fr);
    expect(enKeys).toEqual(frKeys);
  });

  it('should not have empty translations', () => {
    const emptyKeys = findEmptyValues(fr);
    expect(emptyKeys).toHaveLength(0);
  });
});
```

## Output attendu

### Analyse
- Chaînes hardcodées trouvées: [nombre]
- Fichiers impactés: [liste]

### Fichiers de traduction générés
- `locales/[lang]/[namespace].json`

### Modifications de code
- Fichiers modifiés avec imports i18n
- Chaînes remplacées par clés de traduction

### Checklist post-i18n
- [ ] Toutes les chaînes extraites
- [ ] Traductions complètes
- [ ] Formats de date/nombre localisés
- [ ] RTL supporté (si applicable)
- [ ] Tests i18n ajoutés

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/seo` | SEO international |
| `/email` | Emails multilingues |
| `/test` | Tester les traductions |
| `/component` | Composants i18n-ready |

---

IMPORTANT: Penser i18n dès le début du projet.

IMPORTANT: Impliquer des locuteurs natifs pour les traductions.

YOU MUST tester toutes les langues supportées.

NEVER hardcoder de texte dans le code - toujours utiliser les clés de traduction.

Think hard sur les nuances culturelles au-delà de la simple traduction.
