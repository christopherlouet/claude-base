---
name: dev-i18n
description: Internationalisation (i18n) et localisation (l10n) d'applications web et mobile. Librairies next-intl, react-i18next, vue-i18n, formatjs, flutter_localizations, ARB. Declencher quand l'utilisateur veut ajouter plusieurs langues, extraire des strings, gerer les pluriels, les formats date/nombre, ou quand on detecte des fichiers de traduction.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Internationalisation (i18n)

## Choisir sa lib

### Web

| Lib | Stack | Force | A eviter |
|-----|-------|-------|----------|
| **next-intl** | Next.js 13+ App Router | Server Components first, type-safe, routes localisees | Projets Pages Router (utiliser next-i18next) |
| **react-i18next** | React vanilla / SPA | Mature, large ecosysteme, plugins | Lourd pour SSR sans effort |
| **formatjs (react-intl)** | React | ICU MessageFormat standard | Boilerplate plus verbose |
| **vue-i18n** | Vue 3 / Nuxt | Native, Composition API, lazy load | Specifique Vue |
| **svelte-i18n** / **paraglide** | Svelte/SvelteKit | Lean, compile-time (paraglide) | Ecosysteme plus restreint |

### Mobile

| Lib | Stack |
|-----|-------|
| **flutter_localizations + intl** | Flutter officiel, fichiers ARB |
| **slang** | Flutter alternatif, type-safe, code-generation |
| **react-native-localize + i18next** | React Native |

## next-intl (Next.js App Router)

### Setup

```bash
npm install next-intl
```

```
messages/
  fr.json
  en.json
app/
  [locale]/
    layout.tsx
    page.tsx
middleware.ts
i18n/
  request.ts
  routing.ts
```

### Config

```ts
// i18n/routing.ts
import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  locales: ["fr", "en"],
  defaultLocale: "fr",
  localePrefix: "as-needed",  // /en/about, /about (default locale)
});
```

```ts
// middleware.ts
import createMiddleware from "next-intl/middleware";
import { routing } from "./i18n/routing";

export default createMiddleware(routing);

export const config = {
  matcher: ["/", "/(fr|en)/:path*"],
};
```

### Usage Server Component

```tsx
// app/[locale]/page.tsx
import { getTranslations } from "next-intl/server";

export default async function Page() {
  const t = await getTranslations("home");
  return <h1>{t("title")}</h1>;
}
```

### Usage Client Component

```tsx
"use client";
import { useTranslations } from "next-intl";

export function Greeting() {
  const t = useTranslations("home");
  return <p>{t("welcome", { name: "Alice" })}</p>;
}
```

### Pluriels (ICU)

```json
{
  "notifications": "{count, plural, =0 {No notifications} one {# notification} other {# notifications}}"
}
```

```tsx
t("notifications", { count: 3 });  // "3 notifications"
```

### Format date/nombre

```tsx
import { useFormatter } from "next-intl";

const format = useFormatter();
format.dateTime(new Date(), { dateStyle: "long" });  // "4 novembre 2026"
format.number(1234.5, { style: "currency", currency: "EUR" });  // "1 234,50 €"
format.relativeTime(date, now);  // "il y a 2 jours"
```

## react-i18next (SPA)

```bash
npm install react-i18next i18next i18next-browser-languagedetector
```

```ts
// i18n/config.ts
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

import fr from "./locales/fr.json";
import en from "./locales/en.json";

i18n.use(LanguageDetector).use(initReactI18next).init({
  resources: { fr: { translation: fr }, en: { translation: en } },
  fallbackLng: "fr",
  interpolation: { escapeValue: false },
});
```

```tsx
import { useTranslation } from "react-i18next";

function Welcome() {
  const { t, i18n } = useTranslation();
  return (
    <>
      <h1>{t("welcome")}</h1>
      <button onClick={() => i18n.changeLanguage("en")}>EN</button>
    </>
  );
}
```

## Flutter (flutter_localizations + intl)

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_fr.arb
output-localization-file: app_localizations.dart
```

```json
// lib/l10n/app_fr.arb
{
  "@@locale": "fr",
  "welcome": "Bienvenue",
  "notifications": "{count, plural, =0{Aucune notification} one{{count} notification} other{{count} notifications}}",
  "@notifications": {
    "placeholders": { "count": { "type": "int" } }
  }
}
```

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
);

Text(AppLocalizations.of(context)!.welcome);
Text(AppLocalizations.of(context)!.notifications(count));
```

## Vue 3 (vue-i18n)

```bash
npm install vue-i18n@9
```

```ts
// i18n.ts
import { createI18n } from "vue-i18n";
import fr from "./locales/fr.json";
import en from "./locales/en.json";

export const i18n = createI18n({
  legacy: false,
  locale: "fr",
  fallbackLocale: "en",
  messages: { fr, en },
});
```

```vue
<template>
  <h1>{{ t('welcome') }}</h1>
</template>

<script setup>
import { useI18n } from "vue-i18n";
const { t } = useI18n();
</script>
```

## Bonnes pratiques

### Structure des fichiers

Organiser par **namespace** (pas par ecran) :

```
messages/
  fr/
    common.json       # Boutons, messages generiques
    errors.json       # Messages d'erreur
    auth.json         # Ecrans auth (shared)
    dashboard.json    # Section dashboard
  en/
    ...
```

**Mauvais** : 1 fichier par ecran (duplication des messages partages).

### Keys de traduction

```json
{
  "dashboard": {
    "header": {
      "title": "Tableau de bord",
      "subtitle": "Vue d'ensemble"
    },
    "metrics": {
      "users": "Utilisateurs actifs",
      "revenue": "Revenu"
    }
  }
}
```

Conventions :
- **kebab-case** ou **camelCase** selon la lib (camelCase pour JS)
- **Hierarchique** : grouper par feature
- **Descriptif** : `dashboard.metrics.users` pas `label1`
- **Placeholders typés** : `{count, plural, ...}`, `{name}`

### ICU MessageFormat

Standard universel pour pluriels, genre, select :

```
{count, plural,
  =0 {No items}
  one {One item}
  other {# items}
}

{gender, select,
  male {He}
  female {She}
  other {They}
}
```

Supporte par : next-intl, formatjs, flutter intl.

### Locale negociation

```ts
// Ordre de priorite
1. User preference (stored in DB or cookie)
2. URL path (/fr/..., /en/...)
3. Accept-Language header
4. Fallback locale
```

### Extraction de strings

Tools pour extraire les strings du code vers les fichiers de traduction :

| Stack | Outil |
|-------|-------|
| next-intl | `@formatjs/cli` avec extract |
| react-i18next | `i18next-parser` |
| Flutter | `flutter gen-l10n` |
| formatjs | `formatjs extract` |

```bash
# Exemple i18next-parser
npx i18next-parser 'src/**/*.{ts,tsx}' --output 'public/locales/$LOCALE/$NAMESPACE.json'
```

## Pieges courants

| Piege | Prevention |
|-------|-----------|
| Concatenation de strings | JAMAIS. Utiliser des placeholders : `t("hello", { name })` |
| Strings dures dans le code | Extracteur automatique + lint rule (`i18next/no-literal-string`) |
| Pluriels avec conditions manuelles | `{count === 1 ? "item" : "items"}` ne marche pas en toutes langues (arabe, russe : 6 formes) → ICU plural |
| Ordre des mots fixe | Les phrases changent d'ordre entre langues → interpoler, ne pas decouper |
| Formats hardcodes | Utiliser `Intl.DateTimeFormat`, `Intl.NumberFormat`, pas `date.toLocaleString()` sans options |
| RTL oublie | Tester avec arabe/hebreu : `dir="rtl"`, `text-align: start` au lieu de `left` |
| Longueur variable | "OK" en anglais → "D'accord" en francais (2x plus long). Layout flexible. |

### Exemples RTL

```css
/* Au lieu de : */
.card { padding-left: 16px; text-align: left; }

/* Ecrire : */
.card { padding-inline-start: 16px; text-align: start; }
```

## Workflow typique

### 1. Extraire

```bash
npx i18next-parser 'src/**/*.tsx' -o 'messages/$LOCALE.json'
```

### 2. Traduire

Confier aux traducteurs via :
- Lokalise, Crowdin, Phrase (SaaS, collaboration)
- Fichiers JSON/ARB dans git (petits projets)
- DeepL / LLM pour draft, revue humaine obligatoire

### 3. Valider

```bash
# Verifier que toutes les locales ont les memes cles
npx i18next-resources-for-ts --check

# Ou script custom
node scripts/check-i18n.js
```

### 4. Integrer

CI : fail si une cle est manquante dans une locale.

## SEO multi-langue

```tsx
// next-intl
export async function generateMetadata({ params: { locale } }) {
  return {
    alternates: {
      canonical: `/${locale}`,
      languages: { fr: "/fr", en: "/en" },
    },
  };
}
```

Ajouter `hreflang` dans `<head>` et sitemap.xml.

## Complement avec le socle

- Agent `doc-i18n` : aide a la traduction de documentation
- Rule `.claude/rules/accessibility.md` : `lang="fr"`, `dir="rtl"` pour a11y
- Skill `growth-localization` : strategie de localisation (marches, pricing par pays)

## Output attendu

1. **Structure** : namespaces (pas par ecran), cles hierarchiques descriptives
2. **Pluriels** en ICU MessageFormat (jamais de condition manuelle)
3. **Dates/nombres** via Intl ou lib wrapper (jamais hardcode)
4. **Extracteur** configure (i18next-parser, formatjs, flutter gen-l10n)
5. **CI check** : valider que toutes les locales ont les memes cles
6. **RTL** teste si langue RTL cible (logical properties CSS)

## Regles

IMPORTANT: NEVER concatener des strings pour construire des phrases. Utiliser des placeholders.

IMPORTANT: NEVER `count === 1 ? "item" : "items"`. Utiliser les pluriels ICU.

IMPORTANT: NEVER hardcoder des dates/nombres formattes. Utiliser `Intl.DateTimeFormat` ou wrapper lib.

YOU MUST extraire toutes les strings visibles par l'utilisateur (pas `"Error"` dans le code).

YOU MUST ajouter un CI check qui valide la completion des traductions entre locales.

NEVER commiter de traduction par LLM sans revue humaine native speaker (qualite variable sur les nuances).

NEVER utiliser `padding-left` / `margin-right` / `text-align: left` dans une app RTL-supportee. Utiliser les logical properties.
