# Agent SEO

Audit SEO et recommandations d'optimisation pour le référencement naturel.

## Contexte
$ARGUMENTS

## Processus d'audit

### 1. Analyse technique

#### Explorer la structure
```bash
# Pages HTML
find . -name "*.html" -o -name "*.tsx" -o -name "*.jsx" | head -20

# Configuration SEO existante
cat robots.txt 2>/dev/null
cat sitemap.xml 2>/dev/null

# Meta tags dans le code
grep -rn "<title>\|<meta\|og:\|twitter:" --include="*.html" --include="*.tsx" | head -30
```

#### Checklist technique

##### Indexation
- [ ] robots.txt correctement configuré
- [ ] sitemap.xml présent et à jour
- [ ] Pas de pages orphelines
- [ ] Pas de contenu dupliqué
- [ ] Canonical tags en place

##### Performance (Core Web Vitals)
| Métrique | Cible | Impact SEO |
|----------|-------|------------|
| **LCP** (Largest Contentful Paint) | < 2.5s | Élevé |
| **FID** (First Input Delay) | < 100ms | Moyen |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Moyen |

##### Crawlabilité
- [ ] Structure URL claire (/category/page)
- [ ] Pas de paramètres URL inutiles
- [ ] Redirections 301 pour les anciennes URLs
- [ ] Pas de chaînes de redirections
- [ ] Erreurs 404 gérées proprement

### 2. Analyse on-page

#### Title tags
```html
<!-- Format optimal -->
<title>Mot-clé principal | Marque</title>
<!-- Longueur: 50-60 caractères -->
```

Checklist :
- [ ] Unique par page
- [ ] Mot-clé principal en début
- [ ] < 60 caractères
- [ ] Incitatif au clic

#### Meta descriptions
```html
<meta name="description" content="Description incitative avec mot-clé. CTA implicite.">
<!-- Longueur: 150-160 caractères -->
```

Checklist :
- [ ] Unique par page
- [ ] Contient le mot-clé
- [ ] Incite au clic (bénéfice, CTA)
- [ ] < 160 caractères

#### Structure des headings
```
H1 - Titre principal (unique par page)
├── H2 - Section principale
│   ├── H3 - Sous-section
│   └── H3 - Sous-section
├── H2 - Section principale
└── H2 - Section principale
```

Checklist :
- [ ] Un seul H1 par page
- [ ] Hiérarchie logique (pas de H3 sans H2)
- [ ] Mots-clés dans les headings
- [ ] Headings descriptifs

#### Images
```html
<img src="nom-descriptif.webp" alt="Description avec mot-clé" loading="lazy">
```

Checklist :
- [ ] Noms de fichiers descriptifs
- [ ] Alt text sur toutes les images
- [ ] Format optimisé (WebP)
- [ ] Lazy loading activé
- [ ] Dimensions spécifiées

### 3. Contenu

#### Analyse de mots-clés

| Type | Exemple | Volume | Difficulté |
|------|---------|--------|------------|
| Principal | [mot-clé head] | Élevé | Difficile |
| Secondaire | [mot-clé mid-tail] | Moyen | Moyen |
| Long-tail | [phrase spécifique] | Faible | Facile |

#### Qualité du contenu
- [ ] Contenu unique et original
- [ ] Longueur suffisante (> 300 mots pages importantes)
- [ ] Réponse à l'intention de recherche
- [ ] Mise à jour régulière
- [ ] Pas de keyword stuffing

#### Structure du contenu
- [ ] Introduction avec mot-clé
- [ ] Paragraphes courts
- [ ] Listes à puces
- [ ] Liens internes pertinents
- [ ] Liens externes vers sources fiables

### 4. SEO technique avancé

#### Schema.org (Données structurées)
```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "...",
  "url": "...",
  "logo": "..."
}
```

Types recommandés :
- [ ] Organization / LocalBusiness
- [ ] Product (si e-commerce)
- [ ] FAQ (pour les FAQ)
- [ ] Article / BlogPosting
- [ ] BreadcrumbList

#### Open Graph (réseaux sociaux)
```html
<meta property="og:title" content="...">
<meta property="og:description" content="...">
<meta property="og:image" content="...">
<meta property="og:url" content="...">
<meta property="og:type" content="website">
```

#### Twitter Cards
```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="...">
<meta name="twitter:description" content="...">
<meta name="twitter:image" content="...">
```

### 5. SEO off-page

#### Backlinks
- [ ] Profil de liens analysé
- [ ] Liens toxiques identifiés
- [ ] Opportunités de liens identifiées

#### Présence locale (si applicable)
- [ ] Google Business Profile
- [ ] NAP cohérent (Nom, Adresse, Téléphone)
- [ ] Avis clients

### 6. Mobile & International

#### Mobile-first
- [ ] Design responsive
- [ ] Viewport configuré
- [ ] Touch targets > 48px
- [ ] Pas de contenu bloqué sur mobile

#### SEO international (si applicable)
```html
<link rel="alternate" hreflang="fr" href="https://example.com/fr/">
<link rel="alternate" hreflang="en" href="https://example.com/en/">
<link rel="alternate" hreflang="x-default" href="https://example.com/">
```

## Output attendu

### Score SEO global
```
Score technique: [X/100]
Score on-page: [X/100]
Score contenu: [X/100]
Score global: [X/100]
```

### Problèmes critiques
| Problème | Impact | Page(s) | Action |
|----------|--------|---------|--------|
| [Problème 1] | Élevé | [URL] | [Fix] |
| ... | ... | ... | ... |

### Recommandations par priorité

#### Priorité haute (impact immédiat)
1. [Action 1]
2. [Action 2]

#### Priorité moyenne
1. [Action 1]
2. [Action 2]

#### Priorité basse (optimisation)
1. [Action 1]
2. [Action 2]

### Meta tags recommandés
```html
<!-- Page: [nom] -->
<title>[titre optimisé]</title>
<meta name="description" content="[description optimisée]">
```

### Mots-clés cibles suggérés
| Page | Mot-clé principal | Mots-clés secondaires |
|------|-------------------|----------------------|
| Home | | |
| [Page 2] | | |

### Checklist d'implémentation
- [ ] [Action 1]
- [ ] [Action 2]
- [ ] [Action 3]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/landing` | Optimiser les landing pages |
| `/perf` | Améliorer les Core Web Vitals |
| `/a11y` | Accessibilité (impact indirect SEO) |
| `/i18n` | SEO international multilingue |
| `/analytics` | Tracker les performances SEO |

---

IMPORTANT: Le SEO est un travail continu - ces recommandations sont un point de départ.

YOU MUST vérifier les Core Web Vitals - Google les utilise comme facteur de ranking.

NEVER sacrifier l'expérience utilisateur pour le SEO - les deux doivent coexister.

Think hard sur l'intention de recherche des utilisateurs cibles.
