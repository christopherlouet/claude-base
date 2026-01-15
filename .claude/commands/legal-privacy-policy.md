# Agent PRIVACY-POLICY

Génère une Politique de Confidentialité conforme au RGPD et aux standards internationaux.

## Contexte du service
$ARGUMENTS

## Objectif

Créer une politique de confidentialité transparente, complète et conforme
aux réglementations sur la protection des données personnelles.

## Cadre réglementaire

```
┌─────────────────────────────────────────────────────────────┐
│                    RÉGLEMENTATIONS CLÉS                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  EUROPE           │ RGPD (Règlement 2016/679)              │
│  ══════════════════════════════════════════════════════════ │
│                                                             │
│  FRANCE           │ Loi Informatique et Libertés           │
│  ══════════════════════════════════════════════════════════ │
│                                                             │
│  USA (Californie) │ CCPA (California Consumer Privacy Act) │
│  ══════════════════════════════════════════════════════════ │
│                                                             │
│  INTERNATIONAL    │ ISO 27701, Privacy Shield successors   │
│  ══════════════════════════════════════════════════════════ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Structure de la politique

```
┌─────────────────────────────────────────────────────────────┐
│                    STRUCTURE POLITIQUE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. INTRODUCTION     → Responsable, DPO, contact           │
│  ════════════════                                           │
│                                                             │
│  2. DONNÉES          → Quelles données collectées          │
│  ══════════                                                 │
│                                                             │
│  3. FINALITÉS        → Pourquoi les collecter              │
│  ═══════════                                                │
│                                                             │
│  4. BASES LÉGALES    → Justification juridique             │
│  ═══════════════                                            │
│                                                             │
│  5. DESTINATAIRES    → Qui a accès aux données             │
│  ══════════════                                             │
│                                                             │
│  6. TRANSFERTS       → Transferts hors UE                  │
│  ════════════                                               │
│                                                             │
│  7. CONSERVATION     → Durée de conservation               │
│  ═════════════                                              │
│                                                             │
│  8. DROITS           → Droits des personnes                │
│  ════════                                                   │
│                                                             │
│  9. COOKIES          → Politique cookies                   │
│  ══════════                                                 │
│                                                             │
│  10. SÉCURITÉ        → Mesures de protection               │
│  ═══════════                                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Template Politique de Confidentialité

### 1. Introduction

```markdown
# Politique de Confidentialité

**Dernière mise à jour :** [Date]
**Version :** [X.X]

## 1. Qui sommes-nous ?

La présente politique de confidentialité décrit comment **[Nom de l'entreprise]**
(ci-après "nous", "notre" ou "[Nom]") collecte, utilise et protège vos données
personnelles lorsque vous utilisez notre service [Nom du service].

### Responsable du traitement
**[Nom de l'entreprise]**
[Adresse complète]
[Pays]

### Délégué à la Protection des Données (DPO)
[Nom du DPO ou "Non applicable"]
Email : dpo@[domaine].com

### Contact pour les questions relatives à la vie privée
Email : privacy@[domaine].com
Adresse : [Adresse du service privacy]
```

### 2. Données collectées

```markdown
## 2. Quelles données collectons-nous ?

Nous collectons différentes catégories de données personnelles :

### 2.1 Données que vous nous fournissez directement

| Catégorie | Exemples | Obligatoire |
|-----------|----------|-------------|
| **Identification** | Nom, prénom, email | Oui |
| **Contact** | Téléphone, adresse | Non |
| **Compte** | Mot de passe (hashé), photo de profil | Oui/Non |
| **Paiement** | Numéro de carte*, adresse de facturation | Oui* |
| **Professionnel** | Entreprise, poste, secteur | Non |

*Les données de paiement sont traitées par notre prestataire [Stripe/PayPal]
et ne sont pas stockées sur nos serveurs.

### 2.2 Données collectées automatiquement

| Catégorie | Exemples | Finalité |
|-----------|----------|----------|
| **Techniques** | Adresse IP, type de navigateur, OS | Sécurité, compatibilité |
| **Navigation** | Pages visitées, temps passé, clics | Amélioration du service |
| **Appareil** | Identifiant appareil, résolution écran | Expérience utilisateur |
| **Géolocalisation** | Pays, ville (approximatif) | Personnalisation |

### 2.3 Données provenant de tiers

| Source | Type de données | Usage |
|--------|-----------------|-------|
| **Connexion sociale** | Nom, email, photo (si autorisé) | Création de compte |
| **Partenaires** | [Décrire si applicable] | [Finalité] |

### 2.4 Données sensibles

Nous ne collectons **pas** de données sensibles (origine ethnique, opinions
politiques, convictions religieuses, données de santé, orientation sexuelle)
sauf si vous nous les fournissez volontairement et avec votre consentement
explicite.
```

### 3. Finalités du traitement

```markdown
## 3. Pourquoi utilisons-nous vos données ?

Nous utilisons vos données personnelles pour les finalités suivantes :

### 3.1 Fourniture du service

| Finalité | Données utilisées | Base légale |
|----------|-------------------|-------------|
| Création et gestion de compte | Email, mot de passe | Contrat |
| Accès aux fonctionnalités | Données de profil | Contrat |
| Support client | Email, historique | Contrat |
| Facturation | Données de paiement | Contrat |

### 3.2 Amélioration du service

| Finalité | Données utilisées | Base légale |
|----------|-------------------|-------------|
| Analyse d'usage | Données de navigation | Intérêt légitime |
| Tests A/B | Comportement anonymisé | Intérêt légitime |
| Développement produit | Feedback utilisateur | Intérêt légitime |

### 3.3 Communication

| Finalité | Données utilisées | Base légale |
|----------|-------------------|-------------|
| Emails transactionnels | Email | Contrat |
| Notifications produit | Email, préférences | Contrat |
| Newsletter marketing | Email | Consentement |
| Offres partenaires | Email | Consentement |

### 3.4 Sécurité et conformité

| Finalité | Données utilisées | Base légale |
|----------|-------------------|-------------|
| Prévention fraude | IP, comportement | Intérêt légitime |
| Sécurité du compte | Logs de connexion | Intérêt légitime |
| Obligations légales | Diverses | Obligation légale |
```

### 4. Bases légales

```markdown
## 4. Sur quelle base légale traitons-nous vos données ?

Conformément au RGPD, tout traitement de données doit reposer sur une base
légale. Voici les bases légales que nous utilisons :

### 4.1 Exécution du contrat (Article 6.1.b)
Le traitement est nécessaire à l'exécution du contrat que vous avez conclu
avec nous (fourniture du service, support, facturation).

### 4.2 Consentement (Article 6.1.a)
Vous avez donné votre consentement pour certains traitements spécifiques :
- Réception de communications marketing
- Cookies non essentiels
- [Autres traitements basés sur le consentement]

**Vous pouvez retirer votre consentement à tout moment** depuis les paramètres
de votre compte ou en nous contactant.

### 4.3 Intérêt légitime (Article 6.1.f)
Certains traitements sont fondés sur notre intérêt légitime :
- Amélioration de nos services
- Prévention de la fraude
- Sécurité informatique
- Analyses statistiques anonymisées

Nous veillons à ce que nos intérêts légitimes ne prévalent pas sur vos droits
et libertés fondamentaux.

### 4.4 Obligation légale (Article 6.1.c)
Nous sommes tenus de traiter certaines données pour respecter nos obligations
légales (conservation des factures, réponse aux autorités, etc.).
```

### 5. Destinataires des données

```markdown
## 5. Qui a accès à vos données ?

### 5.1 Au sein de notre organisation
Seuls les employés ayant besoin d'accéder à vos données dans le cadre de leurs
fonctions y ont accès :
- Équipe support client
- Équipe technique
- Équipe financière (facturation)
- Direction (statistiques agrégées uniquement)

### 5.2 Sous-traitants

Nous faisons appel à des sous-traitants qui traitent vos données pour notre
compte :

| Sous-traitant | Service | Pays | Garanties |
|---------------|---------|------|-----------|
| **[Hébergeur]** | Hébergement | France/UE | Contrat DPA |
| **[Stripe/PayPal]** | Paiements | USA | SCCs + Mesures supp. |
| **[SendGrid/Mailchimp]** | Emails | USA | SCCs + Mesures supp. |
| **[Google Analytics/Mixpanel]** | Analytique | USA | SCCs + Mesures supp. |
| **[Zendesk/Intercom]** | Support | USA | SCCs + Mesures supp. |

Tous nos sous-traitants sont contractuellement tenus de :
- Traiter les données uniquement selon nos instructions
- Garantir la confidentialité
- Mettre en œuvre des mesures de sécurité appropriées
- Nous notifier de tout incident de sécurité

### 5.3 Autres destinataires

Nous pouvons être amenés à partager vos données avec :
- **Autorités** : en cas d'obligation légale ou de demande judiciaire
- **Successeurs** : en cas de fusion, acquisition ou vente d'actifs
  (vous serez informé au préalable)

### 5.4 Ce que nous ne faisons PAS

Nous ne vendons **jamais** vos données personnelles à des tiers.
```

### 6. Transferts internationaux

```markdown
## 6. Transferts de données hors de l'Union Européenne

Certains de nos sous-traitants sont situés en dehors de l'UE, notamment
aux États-Unis.

### 6.1 Garanties pour les transferts

Pour ces transferts, nous mettons en place les garanties suivantes :

| Mécanisme | Description |
|-----------|-------------|
| **Clauses Contractuelles Types (SCCs)** | Clauses approuvées par la Commission Européenne |
| **Mesures supplémentaires** | Chiffrement, pseudonymisation, évaluation des législations locales |
| **Certifications** | ISO 27001, SOC 2 (selon les sous-traitants) |

### 6.2 Vos droits

Vous pouvez obtenir une copie des garanties mises en place en nous contactant
à privacy@[domaine].com.
```

### 7. Conservation des données

```markdown
## 7. Combien de temps conservons-nous vos données ?

Nous conservons vos données personnelles uniquement le temps nécessaire aux
finalités pour lesquelles elles ont été collectées.

### 7.1 Durées de conservation

| Type de données | Durée de conservation | Justification |
|-----------------|----------------------|---------------|
| **Données de compte** | Durée de la relation + 3 ans | Prescription civile |
| **Données de facturation** | 10 ans | Obligation comptable |
| **Logs de connexion** | 1 an | Sécurité |
| **Données de navigation** | 13 mois | Cookies |
| **Emails marketing** | Jusqu'au désabonnement | Consentement |
| **Données de support** | 5 ans après clôture ticket | Qualité de service |

### 7.2 Après la suppression de votre compte

À la suppression de votre compte :
- Vos données sont supprimées ou anonymisées sous **30 jours**
- Certaines données peuvent être conservées pour des obligations légales
- Les sauvegardes sont purgées sous **90 jours**

### 7.3 Anonymisation

Certaines données peuvent être anonymisées et conservées indéfiniment à des
fins statistiques. Les données anonymisées ne permettent plus de vous identifier.
```

### 8. Droits des personnes

```markdown
## 8. Quels sont vos droits ?

Conformément au RGPD, vous disposez des droits suivants :

### 8.1 Droit d'accès (Article 15)
Vous pouvez obtenir la confirmation que nous traitons vos données et en
recevoir une copie.

### 8.2 Droit de rectification (Article 16)
Vous pouvez demander la correction de données inexactes ou incomplètes.

### 8.3 Droit à l'effacement (Article 17)
Vous pouvez demander la suppression de vos données dans certains cas :
- Données plus nécessaires
- Retrait du consentement
- Opposition au traitement
- Traitement illicite

### 8.4 Droit à la limitation (Article 18)
Vous pouvez demander la limitation du traitement dans certains cas.

### 8.5 Droit à la portabilité (Article 20)
Vous pouvez recevoir vos données dans un format structuré et les transmettre
à un autre responsable.

### 8.6 Droit d'opposition (Article 21)
Vous pouvez vous opposer au traitement fondé sur l'intérêt légitime ou au
marketing direct.

### 8.7 Droit de retirer le consentement
Vous pouvez retirer votre consentement à tout moment, sans affecter la licéité
du traitement antérieur.

### 8.8 Droit d'introduire une réclamation
Vous pouvez déposer une plainte auprès de la CNIL :
- Site : www.cnil.fr
- Adresse : 3 Place de Fontenoy, 75007 Paris

### Comment exercer vos droits ?

**Par email :** privacy@[domaine].com
**Par courrier :** [Adresse]
**Dans votre compte :** Paramètres > Confidentialité

Nous répondons dans un délai de **30 jours** (extensible à 60 jours si complexe).
Une pièce d'identité peut être demandée pour vérifier votre identité.
```

### 9. Cookies

```markdown
## 9. Cookies et technologies similaires

### 9.1 Qu'est-ce qu'un cookie ?

Un cookie est un petit fichier texte déposé sur votre appareil lors de la
visite d'un site web.

### 9.2 Types de cookies utilisés

| Type | Finalité | Consentement | Durée |
|------|----------|--------------|-------|
| **Essentiels** | Fonctionnement du site | Non requis | Session |
| **Fonctionnels** | Préférences utilisateur | Non requis | 1 an |
| **Analytiques** | Statistiques d'usage | Requis | 13 mois |
| **Marketing** | Publicité personnalisée | Requis | 13 mois |

### 9.3 Cookies essentiels (toujours actifs)

| Cookie | Finalité | Durée |
|--------|----------|-------|
| `session_id` | Authentification | Session |
| `csrf_token` | Sécurité | Session |
| `cookie_consent` | Choix cookies | 6 mois |

### 9.4 Cookies analytiques (consentement requis)

| Cookie | Fournisseur | Finalité | Durée |
|--------|-------------|----------|-------|
| `_ga` | Google Analytics | Identification visiteur | 2 ans |
| `_gid` | Google Analytics | Identification session | 24h |

### 9.5 Gérer vos préférences

Vous pouvez gérer vos préférences cookies :
- **Bandeau cookies** : lors de votre première visite
- **Paramètres** : [lien vers centre de préférences]
- **Navigateur** : paramètres de votre navigateur

Note : Le refus de certains cookies peut affecter votre expérience.
```

### 10. Sécurité

```markdown
## 10. Comment protégeons-nous vos données ?

### 10.1 Mesures techniques

| Mesure | Description |
|--------|-------------|
| **Chiffrement** | HTTPS/TLS pour les transmissions, AES-256 au repos |
| **Authentification** | Mots de passe hashés (bcrypt), 2FA disponible |
| **Accès** | Principe du moindre privilège, logs d'accès |
| **Infrastructure** | Pare-feu, détection d'intrusion, sauvegardes |

### 10.2 Mesures organisationnelles

| Mesure | Description |
|--------|-------------|
| **Formation** | Sensibilisation régulière des équipes |
| **Procédures** | Gestion des incidents, privacy by design |
| **Audits** | Tests de sécurité réguliers |
| **Certifications** | [ISO 27001, SOC 2 si applicable] |

### 10.3 En cas d'incident

En cas de violation de données susceptible d'engendrer un risque pour vos
droits et libertés, nous vous en informerons dans les meilleurs délais,
conformément à nos obligations légales.
```

### 11. Modifications et contact

```markdown
## 11. Modifications de cette politique

Nous pouvons mettre à jour cette politique de confidentialité.

En cas de modification substantielle :
- Nous vous en informerons par email ou notification dans le service
- La date de mise à jour sera modifiée
- Vous pourrez consulter l'historique des versions

Votre utilisation continue du service après notification vaut acceptation.

## 12. Nous contacter

Pour toute question concernant cette politique ou vos données personnelles :

**Email :** privacy@[domaine].com
**Courrier :**
[Nom de l'entreprise]
Service Protection des Données
[Adresse]

**DPO :** dpo@[domaine].com

Nous nous engageons à répondre dans un délai de 30 jours.

---

**Historique des versions :**
- v1.0 - [Date] : Version initiale
- v1.1 - [Date] : [Description des changements]
```

## Checklist RGPD

```markdown
## Checklist conformité

### Contenu obligatoire (Articles 13-14 RGPD)
- [ ] Identité et coordonnées du responsable
- [ ] Coordonnées du DPO (si applicable)
- [ ] Finalités et bases légales
- [ ] Destinataires des données
- [ ] Transferts hors UE et garanties
- [ ] Durées de conservation
- [ ] Droits des personnes
- [ ] Droit de réclamation auprès de la CNIL
- [ ] Source des données (si collecte indirecte)

### Bonnes pratiques
- [ ] Langage clair et accessible
- [ ] Format structuré avec sommaire
- [ ] Date de dernière mise à jour
- [ ] Coordonnées de contact facilement accessibles
- [ ] Lien vers politique cookies
- [ ] Version PDF téléchargeable
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/rgpd` | Audit conformité RGPD complet |
| `/terms-of-service` | CGU du service |
| `/legal-docs` | Autres documents légaux |
| `/security` | Mesures de sécurité |

---

IMPORTANT: Cette politique est un modèle. Faire valider par un juriste/DPO.

YOU MUST adapter la politique aux traitements réels effectués.

YOU MUST maintenir la politique à jour en cas de changement.

NEVER collecter plus de données que nécessaire (minimisation).

Think hard sur chaque traitement et sa justification légale.
