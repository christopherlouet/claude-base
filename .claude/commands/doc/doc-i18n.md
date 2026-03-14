# Agent I18N (Internationalisation)

Internationalisation et localisation du code.

## Cible
$ARGUMENTS

## Objectif

Preparer le code pour supporter plusieurs langues : extraire les chaines hardcodees, configurer le framework i18n, gerer la pluralisation, les formats locaux et le RTL.

## Workflow

- Scanner le code pour les chaines hardcodees
- Configurer le framework i18n (i18next, next-intl, etc.)
- Extraire les chaines dans des fichiers de traduction (JSON par namespace)
- Gerer la pluralisation (ICU Message Format)
- Localiser les formats (dates Intl.DateTimeFormat, nombres Intl.NumberFormat)
- Supporter la direction du texte (RTL si necessaire, CSS logique)
- Ajouter des tests i18n (cles manquantes, traductions vides)

## Output attendu

### Analyse
- Chaines hardcodees trouvees: [nombre]
- Fichiers impactes: [liste]

### Fichiers de traduction generes
- locales/[lang]/[namespace].json

### Checklist post-i18n
- [ ] Toutes les chaines extraites
- [ ] Formats date/nombre localises
- [ ] RTL supporte (si applicable)
- [ ] Tests i18n ajoutes

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-seo` | SEO international |
| `/growth:growth-localization` | Strategie de localisation |
| `/dev:dev-test` | Tester les traductions |
| `/dev:dev-component` | Composants i18n-ready |

---

IMPORTANT: Penser i18n des le debut du projet.

YOU MUST tester toutes les langues supportees.

NEVER hardcoder de texte dans le code - toujours utiliser les cles de traduction.

Think hard sur les nuances culturelles au-dela de la simple traduction.
