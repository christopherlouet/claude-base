---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/components/**"
  - "**/pages/**"
  - "**/app/**"
---

# Accessibility Rules (WCAG 2.1/2.2 AA)

## Impact levels (inspired by axe-core)

| Level | Definition | Action |
|--------|-----------|--------|
| **Critical** | Completely blocks access | Fix immediately |
| **Serious** | Significant impact on usability | Fix before release |
| **Moderate** | Hinders user experience | Schedule fix |
| **Minor** | Desirable improvement | Backlog |

## 1. Images and media

| Rule | Impact | WCAG |
|-------|--------|------|
| Every `<img>` must have an `alt` attribute | Critical | 1.1.1 |
| Decorative images: `alt=""` with `role="presentation"` | Serious | 1.1.1 |
| SVG with `role="img"` must have `aria-label` or `<title>` | Serious | 1.1.1 |
| `<input type="image">` must have `alt` | Critical | 1.1.1 |
| `<object>` and `<embed>` must have alternative text | Serious | 1.1.1 |
| `<area>` in image maps must have `alt` | Critical | 1.1.1 |
| Videos must have captions (`<track kind="captions">`) | Critical | 1.2.2 |
| No autoplay audio (or stop control) | Serious | 1.4.2 |

## 2. Forms

| Rule | Impact | WCAG |
|-------|--------|------|
| Every input must have an associated `<label>` (`htmlFor` or nesting) | Critical | 4.1.2 |
| `<select>` must have an accessible name | Critical | 4.1.2 |
| Errors must use `aria-invalid` and `role="alert"` | Serious | 3.3.1 |
| Hints with `aria-describedby` | Moderate | 3.3.2 |
| Valid and relevant `autocomplete` attributes | Moderate | 1.3.5 |
| No multiple labels on the same field | Moderate | 4.1.2 |

## 3. Keyboard navigation

| Rule | Impact | WCAG |
|-------|--------|------|
| Visible focus required (`:focus-visible` with `outline`) | Serious | 2.4.7 |
| Never use positive `tabIndex` | Serious | 2.4.3 |
| Site 100% keyboard navigable | Critical | 2.1.1 |
| No keyboard trap (focus must not get stuck) | Critical | 2.1.2 |
| "Skip to content" link at the start of the page | Serious | 2.4.1 |
| Scrollable areas must be focusable | Serious | 2.1.1 |
| No nested interactive elements (button inside button) | Serious | 4.1.2 |

## 4. Buttons and links

| Rule | Impact | WCAG |
|-------|--------|------|
| Buttons must have accessible text | Critical | 4.1.2 |
| Icon buttons must have `aria-label` | Critical | 4.1.2 |
| Descriptive links (not "click here") | Serious | 2.4.4 |
| External links: indicate new tab opening via `sr-only` | Moderate | 2.4.4 |
| Links within a text block distinguishable without color alone | Serious | 1.4.1 |

## 5. Colors and contrast

| Rule | Impact | WCAG |
|-------|--------|------|
| Normal text: minimum ratio 4.5:1 | Serious | 1.4.3 |
| Large text (18px+ or 14px+ bold): minimum ratio 3:1 | Serious | 1.4.3 |
| UI elements and graphics: minimum ratio 3:1 | Serious | 1.4.11 |
| Never use color as the sole indicator | Serious | 1.4.1 |

## 6. ARIA

| Rule | Impact | WCAG |
|-------|--------|------|
| Only ARIA attributes allowed for the role used | Critical | 4.1.2 |
| Required ARIA attributes present according to the role | Critical | 4.1.2 |
| No prohibited ARIA attributes for the role | Serious | 4.1.2 |
| Valid ARIA attribute values | Critical | 4.1.2 |
| Valid ARIA roles (no invented role) | Critical | 4.1.2 |
| No deprecated ARIA roles | Moderate | 4.1.2 |
| `aria-hidden="true"` must not be on focusable elements | Critical | 4.1.2 |
| `aria-hidden="true"` forbidden on `<body>` | Critical | 4.1.2 |
| ARIA parent/child relationships respected (e.g., listbox > option) | Serious | 1.3.1 |
| Named ARIA components: dialog, meter, progressbar, tooltip | Serious | 4.1.2 |

## 7. Structure and semantics

| Rule | Impact | WCAG |
|-------|--------|------|
| `<html>` must have a valid `lang` attribute | Serious | 3.1.1 |
| `<title>` non-empty and descriptive | Serious | 2.4.2 |
| Heading hierarchy respected (no jump from h1 to h3) | Moderate | 1.3.1 |
| Non-empty headings | Serious | 2.4.6 |
| Page contains an `<h1>` | Moderate | 1.3.1 |
| Landmarks (`<main>`, `<nav>`, `<header>`, `<footer>`) used | Moderate | 1.3.1 |
| Landmarks of the same type have a unique label (`aria-label`) | Moderate | 2.4.1 |
| All page content within a landmark (`<main>`) | Moderate | 1.3.1 |
| Lists structured correctly (`<ul>/<ol>` > `<li>`) | Moderate | 1.3.1 |
| Language of foreign passages marked (`lang` on the element) | Minor | 3.1.2 |

## 8. Tables

| Rule | Impact | WCAG |
|-------|--------|------|
| Data tables must have `<th>` | Serious | 1.3.1 |
| `<th>` must have a `scope` attribute (col/row) | Serious | 1.3.1 |
| `<td headers="">` must reference existing `<th>` | Serious | 1.3.1 |
| `<th>` must not be empty | Serious | 1.3.1 |
| `<caption>` and `summary` must not be identical | Minor | 1.3.1 |

## 9. Frames and iframes

| Rule | Impact | WCAG |
|-------|--------|------|
| Every `<iframe>` must have a `title` attribute | Serious | 4.1.2 |
| Iframe titles unique within the page | Moderate | 4.1.2 |
| Iframe with focusable content must not have `tabindex="-1"` | Serious | 2.1.1 |

## 10. Deprecated and dangerous elements

| Rule | Impact | WCAG |
|-------|--------|------|
| Do not use `<blink>` | Serious | 2.2.2 |
| Do not use `<marquee>` | Serious | 2.2.2 |
| No `<meta http-equiv="refresh">` with delay | Serious | 2.2.1 |
| No autoplay audio/video without control | Serious | 1.4.2 |

## 11. WCAG 2.2

| Rule | Impact | WCAG |
|-------|--------|------|
| Touch targets minimum 44x44px (buttons, links, inputs) | Serious | 2.5.8 |
| Focus must not be obscured by other elements | Serious | 2.4.11 |

## IMPORTANT rules

IMPORTANT: Every image must have an alt attribute.
IMPORTANT: Every form must have associated labels.
IMPORTANT: The site must be 100% keyboard navigable.
IMPORTANT: ARIA attributes must be valid and allowed for the role.
YOU MUST respect WCAG AA contrast ratios.
YOU MUST use semantic landmarks (main, nav, header, footer).
NEVER use color as the sole indicator of information.
NEVER remove visible focus without an alternative.
NEVER set aria-hidden="true" on a focusable element.
NEVER use deprecated elements (blink, marquee).
