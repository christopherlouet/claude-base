# Agent LANDING

Créer ou optimiser une landing page efficace.

## Contexte
$ARGUMENTS

## Processus de création

### 1. Comprendre le produit

```bash
# Documentation existante
cat README.md 2>/dev/null

# Landing existante ?
find . -name "*.html" -o -name "landing*" -o -name "index*" | head -10
```

#### Questions clés
- Quel est l'objectif principal ? (inscription, achat, téléchargement, contact)
- Qui est la cible ?
- Quelle est la proposition de valeur unique ?
- Quelle action voulez-vous que le visiteur fasse ?

### 2. Structure de la landing page

#### Above the fold (visible immédiatement)
```
┌────────────────────────────────────────────┐
│  Logo                      Nav (minimal)   │
├────────────────────────────────────────────┤
│                                            │
│     HEADLINE PRINCIPAL                     │
│     (Proposition de valeur en 1 phrase)    │
│                                            │
│     Sous-titre explicatif                  │
│     (Comment on résout le problème)        │
│                                            │
│         [ CTA Principal ]                  │
│                                            │
│     Image/Vidéo du produit                 │
│                                            │
└────────────────────────────────────────────┘
```

#### Sections recommandées (dans l'ordre)
1. **Hero** - Proposition de valeur + CTA
2. **Social proof** - Logos clients, témoignages courts
3. **Problème** - Rappel du pain point
4. **Solution** - Comment le produit résout le problème
5. **Fonctionnalités** - 3-4 features clés avec bénéfices
6. **Comment ça marche** - 3 étapes simples
7. **Témoignages** - Citations détaillées
8. **Pricing** - Plans simples (si applicable)
9. **FAQ** - Objections courantes
10. **CTA final** - Rappel de l'action

### 3. Copywriting

#### Headline principal
Formules efficaces :
- "[Résultat] sans [obstacle]"
- "Le [catégorie] qui [différenciateur]"
- "[Nombre] [cible] utilisent [produit] pour [bénéfice]"
- "Arrêtez de [frustration]. Commencez à [bénéfice]."

#### Règles de copywriting
- [ ] Parler des bénéfices, pas des features
- [ ] Utiliser "vous" plus que "nous"
- [ ] Être spécifique (chiffres, résultats)
- [ ] Adresser les objections
- [ ] Créer l'urgence (sans manipulation)

#### Structure AIDA
```
A - Attention : Headline accrocheur
I - Intérêt : Problème identifié
D - Désir : Solution présentée
A - Action : CTA clair
```

### 4. Call-to-Action (CTA)

#### Règles du CTA
- [ ] Verbe d'action ("Commencer", "Essayer", pas "Soumettre")
- [ ] Bénéfice inclus ("Essayer gratuitement", "Gagner du temps")
- [ ] Visible et contrasté
- [ ] Répété plusieurs fois dans la page
- [ ] Un seul CTA principal par page

#### Exemples efficaces
| ❌ Éviter | ✅ Préférer |
|-----------|-------------|
| Soumettre | Commencer maintenant |
| S'inscrire | Essayer gratuitement |
| En savoir plus | Voir comment ça marche |
| Acheter | Accéder à [bénéfice] |

### 5. Social Proof

#### Types de preuves sociales
- [ ] Logos de clients/partenaires
- [ ] Nombre d'utilisateurs ("10,000+ utilisateurs")
- [ ] Témoignages avec photo + nom + titre
- [ ] Notes et avis (G2, Capterra, Trustpilot)
- [ ] Études de cas chiffrées
- [ ] Mentions presse
- [ ] Certifications / badges

### 6. Optimisation technique

#### Performance
- [ ] Temps de chargement < 3s
- [ ] Images optimisées (WebP, lazy loading)
- [ ] CSS/JS minifiés
- [ ] CDN activé

#### SEO
- [ ] Title tag optimisé (< 60 caractères)
- [ ] Meta description (< 160 caractères)
- [ ] H1 unique, H2 structurants
- [ ] Alt text sur les images
- [ ] Schema.org (Organization, Product)

#### Mobile
- [ ] Responsive design
- [ ] CTA accessible au pouce
- [ ] Formulaires simplifiés
- [ ] Touch-friendly (boutons > 44px)

#### Conversion
- [ ] Formulaire minimal (email seul si possible)
- [ ] Pas de navigation distrayante
- [ ] Exit-intent popup (optionnel)
- [ ] Chat/support visible

### 7. A/B Tests prioritaires

| Élément | Variantes à tester |
|---------|-------------------|
| Headline | Bénéfice vs Problème vs Question |
| CTA | Texte, couleur, position |
| Hero image | Produit vs Personnes vs Illustration |
| Social proof | Position, type |
| Pricing | Présentation, ancrage |

## Output attendu

### Structure de page proposée

```
1. [Hero]
   - Headline: "..."
   - Sous-titre: "..."
   - CTA: "..."

2. [Section 2]
   ...
```

### Contenu rédigé

#### Hero
```
Headline: [proposition de valeur]
Sous-titre: [explication en 1-2 phrases]
CTA: [texte du bouton]
```

#### Sections principales
[Contenu de chaque section avec textes]

### Checklist technique
- [ ] SEO tags
- [ ] Open Graph tags
- [ ] Analytics setup
- [ ] Formulaire connecté
- [ ] Responsive vérifié

### Recommandations visuelles
- Couleur principale : [suggestion]
- Style : [moderne/corporate/playful/...]
- Images : [type recommandé]

### Métriques à suivre
| Métrique | Cible |
|----------|-------|
| Taux de rebond | < 50% |
| Temps sur page | > 2min |
| Taux de conversion | > X% |
| Scroll depth | > 70% |

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/seo` | Optimiser le référencement |
| `/ab-test` | Tester les variantes |
| `/analytics` | Tracker les conversions |
| `/perf` | Optimiser la performance |
| `/a11y` | Accessibilité de la page |

---

IMPORTANT: Une landing page = un objectif = un CTA. Pas de distraction.

YOU MUST inclure du social proof - même minimal au lancement (nombre d'inscrits beta, témoignages early adopters).

NEVER utiliser de jargon technique - parler le langage du client.

Think hard sur la proposition de valeur et le message principal avant de structurer.
