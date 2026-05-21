---
name: dev-i18n
description: Internationalization (i18n) and localization (l10n) for web and mobile applications. Libraries next-intl, react-i18next, vue-i18n, formatjs, flutter_localizations, ARB. Trigger when the user wants to add multiple languages, extract strings, handle plurals, date/number formats, or when translation files are detected.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Internationalization (i18n)

## Choosing your lib

### Web

| Lib | Stack | Strength | Avoid |
|-----|-------|----------|-------|
| **next-intl** | Next.js 13+ App Router | Server Components first, type-safe, localized routes | Pages Router projects (use next-i18next) |
| **react-i18next** | React vanilla / SPA | Mature, large ecosystem, plugins | Heavy for SSR without effort |
| **formatjs (react-intl)** | React | ICU MessageFormat standard | More verbose boilerplate |
| **vue-i18n** | Vue 3 / Nuxt | Native, Composition API, lazy load | Vue-specific |
| **svelte-i18n** / **paraglide** | Svelte/SvelteKit | Lean, compile-time (paraglide) | Smaller ecosystem |

### Mobile

| Lib | Stack |
|-----|-------|
| **flutter_localizations + intl** | Flutter official, ARB files |
| **slang** | Flutter alternative, type-safe, code-generation |
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

### Server Component usage

```tsx
// app/[locale]/page.tsx
import { getTranslations } from "next-intl/server";

export default async function Page() {
  const t = await getTranslations("home");
  return <h1>{t("title")}</h1>;
}
```

### Client Component usage

```tsx
"use client";
import { useTranslations } from "next-intl";

export function Greeting() {
  const t = useTranslations("home");
  return <p>{t("welcome", { name: "Alice" })}</p>;
}
```

### Plurals (ICU)

```json
{
  "notifications": "{count, plural, =0 {No notifications} one {# notification} other {# notifications}}"
}
```

```tsx
t("notifications", { count: 3 });  // "3 notifications"
```

### Date/number formatting

```tsx
import { useFormatter } from "next-intl";

const format = useFormatter();
format.dateTime(new Date(), { dateStyle: "long" });  // "November 4, 2026"
format.number(1234.5, { style: "currency", currency: "EUR" });  // "€1,234.50"
format.relativeTime(date, now);  // "2 days ago"
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

## Best practices

### File structure

Organize by **namespace** (not by screen):

```
messages/
  fr/
    common.json       # Buttons, generic messages
    errors.json       # Error messages
    auth.json         # Auth screens (shared)
    dashboard.json    # Dashboard section
  en/
    ...
```

**Bad**: 1 file per screen (duplication of shared messages).

### Translation keys

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

Conventions:
- **kebab-case** or **camelCase** depending on the lib (camelCase for JS)
- **Hierarchical**: group by feature
- **Descriptive**: `dashboard.metrics.users` not `label1`
- **Typed placeholders**: `{count, plural, ...}`, `{name}`

### ICU MessageFormat

Universal standard for plurals, gender, select:

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

Supported by: next-intl, formatjs, flutter intl.

### Locale negotiation

```ts
// Priority order
1. User preference (stored in DB or cookie)
2. URL path (/fr/..., /en/...)
3. Accept-Language header
4. Fallback locale
```

### String extraction

Tools to extract strings from code into translation files:

| Stack | Tool |
|-------|------|
| next-intl | `@formatjs/cli` with extract |
| react-i18next | `i18next-parser` |
| Flutter | `flutter gen-l10n` |
| formatjs | `formatjs extract` |

```bash
# i18next-parser example
npx i18next-parser 'src/**/*.{ts,tsx}' --output 'public/locales/$LOCALE/$NAMESPACE.json'
```

## Common pitfalls

| Pitfall | Prevention |
|---------|------------|
| String concatenation | NEVER. Use placeholders: `t("hello", { name })` |
| Hardcoded strings in code | Automatic extractor + lint rule (`i18next/no-literal-string`) |
| Plurals with manual conditions | `{count === 1 ? "item": "items"}` doesn't work in all languages (Arabic, Russian: 6 forms) → ICU plural |
| Fixed word order | Sentences change order between languages → interpolate, don't split |
| Hardcoded formats | Use `Intl.DateTimeFormat`, `Intl.NumberFormat`, not `date.toLocaleString()` without options |
| RTL forgotten | Test with Arabic/Hebrew: `dir="rtl"`, `text-align: start` instead of `left` |
| Variable length | "OK" in English → "D'accord" in French (2x longer). Flexible layout. |

### RTL examples

```css
/* Instead of: */
.card { padding-left: 16px; text-align: left; }

/* Write: */
.card { padding-inline-start: 16px; text-align: start; }
```

## Typical workflow

### 1. Extract

```bash
npx i18next-parser 'src/**/*.tsx' -o 'messages/$LOCALE.json'
```

### 2. Translate

Hand off to translators via:
- Lokalise, Crowdin, Phrase (SaaS, collaboration)
- JSON/ARB files in git (small projects)
- DeepL / LLM for draft, native human review mandatory

### 3. Validate

```bash
# Check that all locales have the same keys
npx i18next-resources-for-ts --check

# Or custom script
node scripts/check-i18n.js
```

### 4. Integrate

CI: fail if a key is missing in a locale.

## Multi-language SEO

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

Add `hreflang` in `<head>` and sitemap.xml.

## Complement with the foundation

- Rule `.claude/rules/accessibility.md`: `lang="fr"`, `dir="rtl"` for a11y
- Skill `growth-localization`: localization strategy (markets, pricing per country)

## Expected output

1. **Structure**: namespaces (not by screen), descriptive hierarchical keys
2. **Plurals** in ICU MessageFormat (never manual conditions)
3. **Dates/numbers** via Intl or wrapper lib (never hardcoded)
4. **Extractor** configured (i18next-parser, formatjs, flutter gen-l10n)
5. **CI check**: validate that all locales have the same keys
6. **RTL** tested if RTL language targeted (CSS logical properties)

## Rules

IMPORTANT: NEVER concatenate strings to build sentences. Use placeholders.

IMPORTANT: NEVER `count === 1 ? "item": "items"`. Use ICU plurals.

IMPORTANT: NEVER hardcode formatted dates/numbers. Use `Intl.DateTimeFormat` or wrapper lib.

YOU MUST extract all user-visible strings (not `"Error"` in code).

YOU MUST add a CI check that validates translation completeness between locales.

NEVER commit LLM translations without native speaker human review (variable quality on nuances).

NEVER use `padding-left` / `margin-right` / `text-align: left` in an RTL-supported app. Use logical properties.
