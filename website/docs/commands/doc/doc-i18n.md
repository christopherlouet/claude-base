---
sidebar_position: 8
title: "/doc:doc-i18n"
description: "Code internationalization and localization."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# I18N Agent (Internationalization)

Code internationalization and localization.

## Target
`&lt;arguments&gt;`

## Objective

Prepare the code to support multiple languages: extract hardcoded strings, configure the i18n framework, handle pluralization, local formats and RTL.

## Workflow

- Scan the code for hardcoded strings
- Configure the i18n framework (i18next, next-intl, etc.)
- Extract strings into translation files (JSON per namespace)
- Handle pluralization (ICU Message Format)
- Localize formats (dates Intl.DateTimeFormat, numbers Intl.NumberFormat)
- Support text direction (RTL if necessary, logical CSS)
- Add i18n tests (missing keys, empty translations)

## Expected output

### Analysis
- Hardcoded strings found: [number]
- Affected files: [list]

### Generated translation files
- locales/[lang]/[namespace].json

### Post-i18n checklist
- [ ] All strings extracted
- [ ] Date/number formats localized
- [ ] RTL supported (if applicable)
- [ ] i18n tests added

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/growth:growth-seo` | International SEO |
| `/growth:growth-localization` | Localization strategy |
| `/dev:dev-test` | Test translations |
| `/dev:dev-component` | i18n-ready components |

---

IMPORTANT: Think i18n from the start of the project.

YOU MUST test all supported languages.

NEVER hardcode text in the code - always use translation keys.

Think hard about cultural nuances beyond simple translation.


---

## See also

- [Back to DOC commands](/docs/commands/doc)
- [All commands](/docs/commands)
