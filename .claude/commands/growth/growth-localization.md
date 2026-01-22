# Agent GROWTH-LOCALIZATION

Strategie de localisation et expansion internationale.

## Contexte
$ARGUMENTS

## Dimensions de la Localisation

### 1. Langue (L10N)

| Element | Considerations |
|---------|----------------|
| Traduction UI | Precision, contexte, ton |
| Contenu marketing | Adaptation culturelle |
| Documentation | Langue technique vs utilisateur |
| Support client | Fuseaux horaires, langue native |

### 2. Culture

| Element | Exemples |
|---------|----------|
| Couleurs | Rouge = chance (Chine), danger (Occident) |
| Images | Gestes, vetements, diversite |
| Humour | References culturelles |
| Formalite | Tu vs Vous, honorifiques |

### 3. Format

| Type | Variations |
|------|------------|
| Date | DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD |
| Heure | 24h vs 12h (AM/PM) |
| Nombres | 1,000.00 vs 1.000,00 vs 1 000,00 |
| Monnaie | Symbole avant/apres, decimales |
| Adresses | Ordre des champs, codes postaux |
| Noms | Prenom-Nom vs Nom-Prenom |

### 4. Legal/Compliance

| Region | Exigences |
|--------|-----------|
| EU | RGPD, cookie consent |
| California | CCPA |
| Bresil | LGPD |
| Chine | Data localization |

## Framework de Decision

### Criteres de Priorite Marche

| Critere | Poids | Score 1-5 |
|---------|-------|-----------|
| Taille marche (TAM) | 25% | |
| Fit produit-marche | 25% | |
| Complexite localisation | 20% | |
| Concurrence | 15% | |
| Cout d'entree | 15% | |

### Matrice de Priorisation

| Marche | TAM | Fit | Complexite | Score |
|--------|-----|-----|------------|-------|
| France | | | | |
| Allemagne | | | | |
| Espagne | | | | |
| UK | | | | |
| US | | | | |
| Bresil | | | | |
| Japon | | | | |

## Implementation Technique

### Architecture i18n

```
src/
├── locales/
│   ├── en/
│   │   ├── common.json
│   │   ├── auth.json
│   │   └── errors.json
│   ├── fr/
│   │   ├── common.json
│   │   ├── auth.json
│   │   └── errors.json
│   └── de/
│       └── ...
├── lib/
│   └── i18n.ts
└── hooks/
    └── useTranslation.ts
```

### Bonnes Pratiques

| Pratique | Description |
|----------|-------------|
| Keys semantiques | `auth.login.button` vs `login_btn` |
| Contexte pluriel | `{count, plural, one {# item} other {# items}}` |
| Variables | `Hello {name}` pas de concatenation |
| Fallback | Langue par defaut si traduction manquante |

### Outils Recommandes

| Categorie | Outils |
|-----------|--------|
| Framework | next-intl, react-i18next, vue-i18n |
| Gestion | Crowdin, Lokalise, Phrase |
| QA | i18n-ally (VSCode), pseudo-localization |
| Format | ICU Message Format |

## Workflow de Localisation

### Phase 1: Preparation

1. **Audit i18n**
   - Strings hardcodees
   - Formats non localises
   - Assets a adapter

2. **Infrastructure**
   - Choix framework i18n
   - Structure fichiers
   - CI/CD pour traductions

### Phase 2: Extraction

```bash
# Extraire les strings
npm run i18n:extract

# Generer fichiers de base
npm run i18n:init [locale]
```

### Phase 3: Traduction

| Methode | Avantages | Inconvenients |
|---------|-----------|---------------|
| Machine (DeepL, Google) | Rapide, economique | Qualite variable |
| Professionnelle | Qualite | Cout, delai |
| Communautaire | Authentique | Gestion complexe |
| Hybride | Equilibre | Coordination |

### Phase 4: QA

| Test | Description |
|------|-------------|
| Pseudo-loc | Detecter strings non traduites |
| Text expansion | UI avec textes 30% plus longs |
| RTL | Langues droite-a-gauche |
| Edge cases | Caracteres speciaux, emojis |

### Phase 5: Launch

1. **Soft launch** - Beta testeurs locaux
2. **Marketing** - Adaptation messaging
3. **Support** - FAQ locale, chatbot
4. **Feedback** - Collecte et iteration

## Checklist Localisation

### Pre-Launch

- [ ] Toutes les strings extraites
- [ ] Formats dates/nombres localises
- [ ] Assets visuels adaptes
- [ ] Legal/compliance verifie
- [ ] SEO local configure
- [ ] Support client prepare

### Post-Launch

- [ ] Monitoring erreurs 404, broken links
- [ ] Feedback utilisateurs
- [ ] Metriques par region
- [ ] Plan d'iteration

## Output Attendu

### Strategie de Localisation

```markdown
## Marche: [Pays/Region]

### Analyse
- Population cible: [X] millions
- Penetration internet: [Y]%
- Concurrents locaux: [Liste]
- Fit produit: [Score/5]

### Scope
- Langue(s): [Liste]
- Adaptations culturelles: [Liste]
- Compliance: [Exigences]

### Plan
| Phase | Activite | Duree | Cout |
|-------|----------|-------|------|
| 1 | Preparation | 2 sem | $X |
| 2 | Traduction | 3 sem | $Y |
| 3 | QA | 1 sem | $Z |
| 4 | Launch | 1 sem | $W |

### KPIs
- Adoption: [cible]
- NPS local: [cible]
- Support tickets: [cible]
```

## Metriques

| Metrique | Description | Cible |
|----------|-------------|-------|
| Coverage | % strings traduites | 100% |
| Quality score | Note traduction | > 4/5 |
| Time to translate | Delai moyen | < 48h |
| Error rate | Strings manquantes en prod | < 0.1% |

## Agents lies

| Agent | Usage |
|-------|-------|
| `/doc-i18n` | Implementation i18n technique |
| `/legal-rgpd` | Conformite RGPD |
| `/growth-seo` | SEO international |
| `/biz-market` | Etude de marche |

---

IMPORTANT: Ne pas traduire noms de marque sans validation.

IMPORTANT: Considerer les variations regionales (fr-FR vs fr-CA).

YOU MUST tester avec des utilisateurs natifs.

NEVER sous-estimer la maintenance long terme des traductions.
