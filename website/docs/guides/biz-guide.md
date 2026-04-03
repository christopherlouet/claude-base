---
sidebar_position: 11
title: "Guide Business & Strategie"
description: " Workflow complet de l'idee au lancement produit"
tags:
  - "guide"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Guide Business & Strategie

&gt; Workflow complet de l'idee au lancement produit

## Contexte

Les commandes `/biz:biz-*` accompagnent chaque phase de la strategie produit : etude de marche, modelisation business, definition du MVP et lancement. Ce guide couvre les livrables concrets, les matrices de decision et les templates pour chaque etape.

## Workflow Recommande

```
/biz:biz-research → /biz:biz-personas → /biz:biz-competitor → /biz:biz-model → /biz:biz-pricing → /biz:biz-mvp → /biz:biz-roadmap → /biz:biz-launch
```

---

## Phase 1: Recherche et Analyse

| Commande | Description |
|----------|-------------|
| `/biz:biz-research` | Etude de marche, tendances, opportunites |
| `/biz:biz-market` | Analyse de la taille du marche (TAM/SAM/SOM) |
| `/biz:biz-personas` | Definition des personas utilisateurs |
| `/biz:biz-competitor` | Analyse concurrentielle (forces, faiblesses, positionnement) |

### Checklist Phase 1

| Element | Critere de validation |
|---------|----------------------|
| Marche cible | Segment defini, taille estimee (TAM/SAM/SOM) |
| Probleme valide | Au moins 5 entretiens utilisateurs realises |
| Personas | 3 personas minimum avec jobs-to-be-done |
| Concurrents | 5 concurrents directs/indirects identifies |
| Positionnement | Differentiation claire sur 2 axes minimum |

### Template Persona

```markdown
## Persona: [Prenom, Titre]

**Profil**
- Age / Secteur / Taille entreprise (B2B) ou situation (B2C)
- Outils utilises au quotidien
- Budget disponible (si B2B: cycle d'achat, decideur vs utilisateur)

**Jobs-to-be-done**
- Fonctionnel: [Ce qu'il cherche a accomplir]
- Emotionnel: [Ce qu'il veut ressentir]
- Social: [Comment il veut etre percu]

**Frustrations actuelles (Pain points)**
1. [Douleur principale avec la solution actuelle]
2. [...]

**Objectifs**
1. [Resultat mesurable qu'il veut atteindre]
2. [...]

**Citation representative**
"[Verbatim issu d'un entretien ou de recherche qualitative]"
```

### Matrice Concurrentielle (exemple SaaS de gestion RH)

| Critere | Notre produit | Concurrent A | Concurrent B | Concurrent C |
|---------|--------------|-------------|-------------|-------------|
| Prix/mois | 29 EUR | 79 EUR | Gratuit (limits) | 49 EUR |
| Onboarding | &lt; 5 min | 2 semaines | Immediat | 1 semaine |
| Integrations | 20+ | 50+ | 5 | 30+ |
| Support | Chat 24h | Email seul | Forum | Chat 8h-18h |
| Mobile | Oui | Non | Oui | Non |
| **Positionnement** | **Simplicite + prix** | Enterprise | Self-service | Mid-market |

### Approche Market Sizing

| Methode | Quand l'utiliser | Exemple |
|---------|-----------------|---------|
| Top-down | Marche etabli avec donnees Gartner/IDC | TAM mondial des RH SaaS = 30 Mds EUR |
| Bottom-up | Marche emergent, peu de donnees | 50k PME en France x 29 EUR/mois x 12 = 17 M EUR/an |
| Value-based | Disruption d'un marche existant | Remplace logiciel a 500 EUR/an → marche addressable = nb licences x delta prix |

---

## Phase 2: Modelisation Business

| Commande | Description |
|----------|-------------|
| `/biz:biz-model` | Business Model Canvas (proposition de valeur, canaux, revenus) |
| `/biz:biz-pricing` | Strategie de pricing (freemium, tiers, usage-based) |
| `/biz:biz-okr` | Objectifs et resultats cles (OKR) par trimestre |

### Checklist Phase 2

| Element | Critere de validation |
|---------|----------------------|
| Business Model Canvas | 9 blocs remplis, coherence verifiee |
| Unite economique | CAC, LTV, LTV/CAC &gt; 3, payback &lt; 18 mois |
| Pricing | Teste sur 10+ prospects, pas au feeling |
| OKRs Q1/Q2 | 3 Objectives max, 2-3 KR par Objective |
| Projections | P&L 18 mois avec hypotheses documentees |

### Template Business Model Canvas

```markdown
## Business Model Canvas: [Nom Produit]

**1. Segments clients**
- Segment primaire: [description, taille estimee]
- Segment secondaire: [description]

**2. Proposition de valeur**
- Pour [segment], qui [probleme], notre produit [solution]
  contrairement a [alternative], nous [differentiation cle]

**3. Canaux**
- Acquisition: [SEO, Product Hunt, cold outreach, partenaires...]
- Distribution: [SaaS web, mobile, API, marketplace...]
- Retention: [email, in-app, customer success...]

**4. Relations clients**
- Type: [self-service / assisted / community / automated]
- Support: [email, chat, docs, onboarding...]

**5. Sources de revenus**
- Modele: [subscription / usage-based / freemium / marketplace]
- ARPU cible: [X EUR/mois]
- Upsell: [tiers superieur, add-ons, services]

**6. Ressources cles**
- Technologie: [stack, IP, donnees]
- Humain: [competences critiques en interne]
- Financier: [runway, financement]

**7. Activites cles**
- [Developpement produit, ventes, support, content...]

**8. Partenaires cles**
- [Integrateurs, revendeurs, fournisseurs de donnees...]

**9. Structure de couts**
- Fixes: [infra, salaires, outils]
- Variables: [support, commissions, CAC]
- Break-even prevu: [mois X avec Y clients]
```

### Template OKR

```markdown
## OKRs Q[N] [Annee]

### Objective 1: [Valider l'adéquation produit-marche]
- KR1: Atteindre un NPS >= 40 sur 50 repondants
- KR2: 80% des utilisateurs actifs apres 30 jours (retention D30)
- KR3: 5 case studies clients publiees

### Objective 2: [Generer les premiers revenus]
- KR1: 50 clients payants a la fin du trimestre
- KR2: MRR de 5 000 EUR
- KR3: CAC < 150 EUR (canal digital)

### Objective 3: [Construire l'equipe fondatrice]
- KR1: CTO recrute avant fin du mois 2
- KR2: 2 AE (Account Executives) en poste
- KR3: Processus de recrutement documente et reproductible
```

### Matrice de Decision Pricing

| Critere | Freemium | Flat rate | Tiers | Usage-based |
|---------|----------|-----------|-------|-------------|
| Marche | Grand, self-service | SMB simple | SMB a Enterprise | Dev tools, API |
| Valeur | Difficile a montrer sans usage | Valeur claire et fixe | Valeur scalable | Valeur = usage |
| CAC | Faible (PLG) | Moyen | Eleve (sales) | Faible a moyen |
| Predictabilite MRR | Faible | Haute | Haute | Faible |
| Exemple | Notion, Slack | Basecamp | HubSpot | Stripe, Twilio |

### Matrice de Decision B2B vs B2C

| Dimension | B2C | B2B SMB | B2B Mid-market | B2B Enterprise |
|-----------|-----|---------|---------------|---------------|
| Cycle de vente | Immediat | &lt; 2 semaines | 1-3 mois | 6-18 mois |
| ACV cible | &lt; 100 EUR/an | 200-2k EUR/an | 5k-50k EUR/an | &gt; 50k EUR/an |
| Decideur | Utilisateur final | Fondateur/manager | VP / Directeur | C-level + procurement |
| Canal principal | SEO, social, app stores | PLG, inbound | Inbound + SDR | Outbound + partenaires |
| Support attendu | Self-service | Chat | CS dedie | Account manager |

### Grille Tarifaire (exemple SaaS B2B)

```markdown
## Pricing: [Nom Produit]

| Plan     | Prix/mois | Cible          | Limites              | Inclus                        |
|----------|-----------|----------------|----------------------|-------------------------------|
| Starter  | Gratuit   | Indie / test   | 1 user, 100 records  | Features core, doc, community |
| Growth   | 29 EUR    | PME < 20 pers  | 10 users, 10k records| + integrations, email support |
| Scale    | 99 EUR    | PME 20-100     | 50 users, illimite   | + SSO, custom reports, SLA    |
| Enterprise| Sur devis | > 100 pers     | Illimite             | + on-premise, CS dedie, audit |

**Hypotheses de conversion**
- Freemium → Growth: 5-8% (benchmark SaaS PLG)
- Growth → Scale: 15-20% apres 6 mois
- Upsell annuel: -20% → reduire churn, ameliorer CAC payback
```

---

## Phase 3: MVP et Roadmap

| Commande | Description |
|----------|-------------|
| `/biz:biz-mvp` | Definition du MVP (features P1, scope minimal) |
| `/biz:biz-roadmap` | Roadmap produit (phases, jalons, priorites) |

### Checklist Phase 3

| Element | Critere de validation |
|---------|----------------------|
| MVP scope | Features P1 listees, P2/P3 separees explicitement |
| Hypothese MVP | 1 hypothese principale a valider (falsifiable) |
| Jalon de validation | Metrique de succes definie avant de coder |
| Roadmap | 3 horizons (now/next/later) ou 4 trimestres |
| Risques | Top 3 risques identifies avec mitigation |

### Priorisation Features (matrice Impact/Effort)

| Feature | Impact | Effort | Priorite | Raison |
|---------|--------|--------|----------|--------|
| Inscription email | Haut | Faible | P1 | Prerequis tout le reste |
| Dashboard principal | Haut | Moyen | P1 | Valeur core visible |
| Export CSV | Moyen | Faible | P1 | Demande forte early adopters |
| SSO / SAML | Moyen | Eleve | P3 | Uniquement Enterprise |
| Mobile natif | Haut | Tres eleve | P2 | Apres product-market fit |
| Marketplace partenaires | Moyen | Tres eleve | P3 | Phase croissance |

### Template Roadmap (format Now/Next/Later)

```markdown
## Roadmap [Nom Produit] - [Trimestre] [Annee]

### NOW (ce trimestre - MVP)
**Objectif: valider que les utilisateurs reviennent sans relance**
- [ ] Authentification et onboarding (< 5 min)
- [ ] Feature core #1 (la raison principale d'inscription)
- [ ] Feature core #2 (la raison principale de retention)
- [ ] Dashboard et metriques basiques
- Jalon: 100 utilisateurs actifs hebdomadaires, retention D7 > 40%

### NEXT (trimestre suivant - traction)
**Objectif: passer a 1 000 utilisateurs actifs, premiers revenus**
- [ ] Modele payant (1 plan minimum)
- [ ] Integrations top 3 (selon feedback)
- [ ] Notifications et onboarding email
- Jalon: 50 clients payants, MRR > 1 000 EUR

### LATER (horizon 6-12 mois - scale)
**Objectif: position de marche, croissance reproductible**
- [ ] API publique et documentation developpeur
- [ ] Plan Enterprise (SSO, audit logs, SLA)
- [ ] Expansion (langue, region ou segment adjacent)
- Jalon: 500 clients payants, MRR > 15 000 EUR
```

---

## Phase 4: Pitch et Lancement

| Commande | Description |
|----------|-------------|
| `/biz:biz-pitch` | Pitch deck (probleme, solution, marche, traction) |
| `/biz:biz-launch` | Plan de lancement (pre-launch, launch day, post-launch) |

### Checklist Phase 4

| Element | Critere de validation |
|---------|----------------------|
| Pitch deck | 10-12 slides, narrative coherente problem → solution → market → traction |
| Traction | Au moins 1 metrique concrete (users, MRR, LOIs) |
| Plan de lancement | Actions definies pour J-30, J-7, J0, J+7, J+30 |
| Canaux identifies | 2-3 canaux d'acquisition testes avant le lancement |
| Support prepare | FAQ, onboarding emails, doc minimale prete |

### Structure Pitch Deck (10 slides)

```markdown
## Pitch Deck: [Nom Produit]

**Slide 1 - Cover**
Nom, tagline en une phrase, logo, contact

**Slide 2 - Probleme**
Douleur specifique, chiffree si possible.
"X% des [segment] perdent Y heures par semaine sur [probleme]."

**Slide 3 - Solution**
Screenshot ou demo, 3 benefices cles maximum.
Pas de feature dump — montrer le resultat pour l'utilisateur.

**Slide 4 - Marche**
TAM / SAM / SOM avec source. Bottom-up preferable a top-down.
Montrer pourquoi le moment est bon (tailwind macro).

**Slide 5 - Business Model**
Comment vous gagnez de l'argent. Prix, ACV, LTV/CAC cible.

**Slide 6 - Traction**
Metriques clés : MRR, croissance MoM, retention, NPS, clients logos.
Si pre-revenue : waitlist, LOIs, entretiens, pilotes.

**Slide 7 - Concurrence**
Matrice 2x2 ou tableau. Votre position differentielle en une phrase.

**Slide 8 - Go-to-Market**
Canal principal d'acquisition. Pourquoi vous etes credibles dessus.

**Slide 9 - Equipe**
Fondateurs : experience pertinente uniquement. Pourquoi vous ?

**Slide 10 - Ask**
Montant leve, use of funds (3-4 postes max), jalon atteint avec cet argent.
```

### Checklist Lancement

| Phase | Action | Responsable | Statut |
|-------|--------|------------|--------|
| J-30 | Waitlist ouverte, landing page live | Fondateur | [ ] |
| J-30 | 50 beta testeurs recrutes | Fondateur | [ ] |
| J-14 | Documentation et FAQ minimales | Tech | [ ] |
| J-14 | Onboarding emails sequences configures | Marketing | [ ] |
| J-7 | Tests de charge effectues | Tech | [ ] |
| J-7 | Support (chat ou email) configure et teste | Ops | [ ] |
| J-1 | Embargo presse si applicable | Fondateur | [ ] |
| J0 | Publication Product Hunt (00h01 PT) | Marketing | [ ] |
| J0 | Post LinkedIn / Twitter du fondateur | Fondateur | [ ] |
| J0 | Email a la waitlist | Marketing | [ ] |
| J+1 | Repondre a chaque commentaire PH | Fondateur | [ ] |
| J+7 | Analyse metriques semaine 1 | Fondateur | [ ] |
| J+30 | Retro lancement, decisions Q2 | Equipe | [ ] |

---

## Metriques par Etape

### Pre-launch (validation)

| Metrique | Cible | Signal |
|----------|-------|--------|
| Entretiens utilisateurs | &gt;= 20 | Comprendre le probleme en profondeur |
| Taux de re-engagement waitlist | &gt; 30% | Interet reel vs curiosite |
| NPS beta | &gt;= 30 | Valeur percue avant lancement |
| Taux de completion onboarding | &gt; 60% | UX suffisamment claire |

### Launch (acquisition)

| Metrique | Cible | Signal |
|----------|-------|--------|
| Inscriptions J0-J7 | Contexte-dependant | Volume d'acquisition initial |
| Activation (action cle dans 24h) | &gt; 40% | Onboarding efficace |
| Retention D7 | &gt; 25% | Valeur suffisante pour revenir |
| CAC canal principal | &lt; LTV/3 | Economie d'acquisition viable |

### Growth (scaling)

| Metrique | Cible | Signal |
|----------|-------|--------|
| MRR growth MoM | &gt; 15% | Croissance saine |
| Churn mensuel | &lt; 5% | Retention produit |
| LTV/CAC | &gt; 3 | Unite economique positive |
| NPS | &gt;= 40 | Viralite et retention long terme |
| Payback period | &lt; 18 mois | Retour sur investissement acquisition |
| Expansion revenue | &gt; 20% du MRR | Upsell fonctionnel |

---

## Strategies Go-to-Market

### Product-Led Growth (PLG)

Adapte quand : produit SaaS self-service, valeur demonstrable rapidement, marche B2C ou B2B SMB.

| Etape | Action | Outil |
|-------|--------|-------|
| Discovery | SEO, viral loops, intégrations | Contenu, API publique |
| Activation | Onboarding &lt; 5 min, free tier | Produit |
| Retention | Habitude d'usage, notifications | Email, in-app |
| Expansion | Limits atteintes → upgrade | Pricing progressif |
| Referral | Invitations, partage natif | Feature produit |

**Signaux que PLG fonctionne** : retention D30 &gt; 30%, taux de conversion freemium &gt; 5%, viral coefficient &gt; 0.3.

### Sales-Led Growth (SLG)

Adapte quand : marche Enterprise, ACV &gt; 10k EUR/an, cycle de vente long, decision d'achat complexe.

| Etape | Action | Responsable |
|-------|--------|------------|
| Awareness | Contenu expert, evenements, partenaires | Marketing |
| Prospection | Outbound SDR, cold email personalise | SDR |
| Qualification | BANT ou MEDDIC, demo | AE |
| Pilot | POC 30-60 jours, KPIs definis | AE + Customer Success |
| Closing | Negociation, legal, securite | AE + Fondateur |
| Expansion | QBR, upsell, referencement | Customer Success |

**Signaux que SLG est necessaire** : deals &gt; 10k EUR/an, acheteur != utilisateur, compliance obligatoire (SOC2, RGPD...).

### Comparaison PLG vs SLG

| Critere | PLG | SLG |
|---------|-----|-----|
| ACV typique | &lt; 5k EUR/an | &gt; 10k EUR/an |
| Temps au premier revenu | Jours | Mois |
| Taille equipe initiale | 2-3 (tech + growth) | 4-6 (tech + sales + CS) |
| Scalabilite | Haute (automatise) | Moyenne (lineaire avec headcount) |
| Retention driver | Produit | Relation + contrat |
| Exemple | Notion, Figma, Linear | Salesforce, Workday, SAP |

---

## Funding Readiness Checklist

Ce qu'un investisseur Seed/Serie A verifie systematiquement.

### Marche et Probleme

| Element | Niveau Seed | Niveau Serie A |
|---------|------------|---------------|
| Taille de marche | TAM &gt; 1 Md EUR, argumente | TAM &gt; 5 Mds EUR, bottom-up |
| Probleme valide | 20+ entretiens qualitatifs | Prouves par les metriques produit |
| Timing | Pourquoi maintenant ? (tailwind) | Tailwind confirme par les chiffres |

### Produit et Traction

| Element | Niveau Seed | Niveau Serie A |
|---------|------------|---------------|
| Produit | MVP live, premiers utilisateurs | Produit mature, roadmap credible |
| Retention | D30 &gt; 25% | D90 &gt; 40%, churn &lt; 3%/mois |
| Revenue | Pre-revenue OK ou &lt; 10k MRR | MRR &gt; 50k EUR, croissance &gt; 15%/mois |
| NPS | &gt;= 30 | &gt;= 50 |

### Unite Economique

| Element | Niveau Seed | Niveau Serie A |
|---------|------------|---------------|
| LTV/CAC | Hypothese documentee | &gt; 3, mesure sur 6+ mois |
| Payback | Modele credible | &lt; 18 mois observe |
| Gross margin | &gt; 60% (SaaS) | &gt; 70%, path to 80% |

### Equipe

| Element | Niveau Seed | Niveau Serie A |
|---------|------------|---------------|
| Fondateurs | 2+ co-fondateurs complementaires | Equipe de direction en place |
| Domaine | Experience pertinente | Track record ou expertise demontree |
| Reference | 3 references investisseurs/clients | References solides multiples |

### Governance et Legale

| Element | Minimum requis |
|---------|---------------|
| Structure juridique | SAS ou equivalent, cap table propre |
| IP | Tout le code appartient a la societe |
| Contrats | Conditions generales, CGV, DPA si RGPD |
| Data room | Accessible et a jour (Notion, Google Drive) |

---

## Commandes par Use Case

### Nouveau produit SaaS

```bash
1. /biz:biz-research           # Etude de marche
2. /biz:biz-personas           # Personas cibles
3. /biz:biz-competitor         # Analyse concurrence
4. /biz:biz-model              # Business model
5. /biz:biz-pricing            # Strategie tarifaire
6. /biz:biz-mvp                # Definition MVP
7. /biz:biz-roadmap            # Roadmap
```

### Lever des fonds

```bash
1. /biz:biz-market             # Taille du marche (TAM/SAM/SOM)
2. /biz:biz-model              # Business model et unite economique
3. /biz:biz-okr                # OKRs et metriques
4. /biz:biz-pitch              # Pitch deck 10 slides
```

### Lancement produit

```bash
1. /biz:biz-pricing            # Pricing final valide
2. /biz:biz-launch             # Plan de lancement J-30 a J+30
```

### Pivoter apres feedback

```bash
1. /biz:biz-research           # Re-analyser le marche avec nouvelles donnees
2. /biz:biz-personas           # Requalifier les segments
3. /biz:biz-mvp                # Redefinir le scope MVP
4. /biz:biz-roadmap            # Adapter la roadmap
```

---

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Analyse le marche" | biz-research | Etude de marche et TAM/SAM/SOM |
| "Cree un business model" | biz-model | Business Model Canvas complet |
| "Definis le MVP" | biz-mvp | Scope MVP et priorisation P1/P2/P3 |
| "Prepare le pitch" | biz-pitch | Pitch deck 10 slides structure |
| "Analyse la concurrence" | biz-competitor | Matrice concurrentielle et positionnement |
| "Definis le pricing" | biz-pricing | Grille tarifaire et decision freemium/paid |

---

## Anti-patterns a Eviter

| Anti-pattern | Consequence | Correction |
|-------------|-------------|------------|
| Construire sans valider le marche | Produit sans demande | `/biz:biz-research` + 20 entretiens avant de coder |
| MVP trop ambitieux | Delai infini, pivots couteux | Limiter aux features P1 strictement, jalon de validation clair |
| Pricing au feeling | Sous-monetisation ou friction inutile | Analyser la concurrence, tester avec 10 prospects |
| Pas de personas | Decisions produit sans direction | 3 personas minimum avec jobs-to-be-done |
| Roadmap sans OKRs | Pas de criteres de succes mesurables | 1 jalon metrique par phase NOW/NEXT/LATER |
| Lancement sans plan | Pic d'inscriptions non converti | Preparer pre-launch, launch day et post-launch en detail |
| Ignorer l'unite economique | Croissance qui detruit de la valeur | CAC/LTV calcules avant de scaler l'acquisition |
| PLG sur marche Enterprise | Cycles longs, deals perdus | Adapter le GTM au segment : PLG SMB, SLG Enterprise |
