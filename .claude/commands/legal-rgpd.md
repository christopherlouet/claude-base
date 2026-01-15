# Agent RGPD

Audit de conformité RGPD (Règlement Général sur la Protection des Données) d'un projet.

## Contexte
$ARGUMENTS

## Processus d'audit

### 1. Identification des données personnelles

#### Scanner le codebase
```bash
# Rechercher les modèles de données
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) | head -50

# Patterns courants de données personnelles
grep -rn -E "(email|phone|address|name|password|birth|ssn|iban)" --include="*.ts" --include="*.js" --include="*.py" | head -30
```

#### Types de données à identifier
- [ ] **Identifiants** : email, téléphone, adresse IP, identifiants uniques
- [ ] **Identité** : nom, prénom, date de naissance, photo
- [ ] **Coordonnées** : adresse postale, géolocalisation
- [ ] **Financières** : IBAN, carte bancaire, historique achats
- [ ] **Sensibles** (Art. 9) : santé, religion, orientation sexuelle, opinions politiques
- [ ] **Comportementales** : historique navigation, préférences, logs

#### Cartographie des flux
- Où les données sont-elles collectées ? (formulaires, APIs, imports)
- Où sont-elles stockées ? (DB, fichiers, services tiers)
- Où sont-elles transmises ? (APIs externes, analytics, partenaires)

### 2. Base légale du traitement (Art. 6)

Pour chaque traitement identifié, vérifier la base légale :

| Base légale | Applicable si... |
|-------------|------------------|
| **Consentement** | L'utilisateur a donné son accord explicite |
| **Contrat** | Nécessaire à l'exécution d'un contrat |
| **Obligation légale** | Imposé par la loi (factures, etc.) |
| **Intérêt vital** | Protection de la vie de la personne |
| **Mission publique** | Exercice de l'autorité publique |
| **Intérêt légitime** | Intérêt de l'entreprise, balancé avec droits |

#### Checklist
- [ ] Chaque traitement a une base légale documentée
- [ ] Le consentement est libre, spécifique, éclairé et univoque
- [ ] Le consentement peut être retiré aussi facilement qu'il a été donné

### 3. Consentement et cookies

#### Vérifier l'implémentation
```bash
# Rechercher les cookies/trackers
grep -rn -E "(cookie|localStorage|sessionStorage|gtag|analytics|pixel|tracking)" --include="*.ts" --include="*.js" --include="*.html" | head -30

# Bannière de consentement
grep -rn -E "(consent|gdpr|cookie.?banner|cookie.?modal)" --include="*.ts" --include="*.js" --include="*.tsx" | head -20
```

#### Checklist cookies
- [ ] Bannière de consentement présente
- [ ] Cookies non-essentiels bloqués avant consentement
- [ ] Possibilité de refuser aussi facilement qu'accepter
- [ ] Pas de dark patterns (bouton refuser caché, pré-coché, etc.)
- [ ] Durée de vie des cookies documentée
- [ ] Liste des cookies accessible

#### Catégories de cookies
| Catégorie | Consentement requis |
|-----------|---------------------|
| Strictement nécessaires | Non |
| Fonctionnels | Oui |
| Analytiques | Oui |
| Publicitaires | Oui |

### 4. Droits des personnes (Art. 15-22)

#### Vérifier l'implémentation des droits

| Droit | Implémenté ? | Comment ? |
|-------|--------------|-----------|
| **Accès** (Art. 15) | [ ] | Export des données utilisateur |
| **Rectification** (Art. 16) | [ ] | Modification du profil |
| **Effacement** (Art. 17) | [ ] | Suppression de compte |
| **Limitation** (Art. 18) | [ ] | Gel du traitement |
| **Portabilité** (Art. 20) | [ ] | Export format standard (JSON, CSV) |
| **Opposition** (Art. 21) | [ ] | Opt-out marketing |

#### Rechercher les implémentations
```bash
# Fonctions de suppression/export
grep -rn -E "(deleteUser|removeUser|exportUser|downloadData|deleteAccount|gdpr)" --include="*.ts" --include="*.js" | head -20
```

### 5. Durée de conservation

#### Vérifier les politiques de rétention
- [ ] Durée définie pour chaque type de données
- [ ] Mécanisme de purge automatique implémenté
- [ ] Logs et backups inclus dans la politique

#### Durées recommandées
| Type de données | Durée suggérée |
|-----------------|----------------|
| Données de compte actif | Durée de la relation |
| Après suppression compte | 30 jours (récupération) |
| Logs de connexion | 1 an max |
| Factures | 10 ans (obligation légale) |
| Données prospects | 3 ans après dernier contact |

### 6. Transferts hors UE (Art. 44-49)

#### Identifier les transferts
```bash
# Services cloud et APIs externes
grep -rn -E "(aws|gcp|azure|cloudflare|stripe|twilio|sendgrid|mailchimp|segment|amplitude|mixpanel)" --include="*.ts" --include="*.js" --include="*.env*" | head -20
```

#### Checklist
- [ ] Liste des sous-traitants hors UE identifiée
- [ ] Clauses contractuelles types (CCT) en place
- [ ] Ou décision d'adéquation (UK, Suisse, Canada, etc.)
- [ ] Privacy Shield invalidé - vérifier les alternatives

### 7. Sécurité des données (Art. 32)

#### Mesures techniques
- [ ] Chiffrement en transit (HTTPS)
- [ ] Chiffrement au repos (DB, fichiers)
- [ ] Hachage des mots de passe (bcrypt, argon2)
- [ ] Contrôle d'accès (RBAC)
- [ ] Logs d'audit

#### Mesures organisationnelles
- [ ] Politique de sécurité documentée
- [ ] Formation des équipes
- [ ] Procédure de gestion des incidents

> Pour un audit technique approfondi, utiliser `/security`

### 8. Privacy by Design (Art. 25)

#### Principes à vérifier
- [ ] **Minimisation** : seules les données nécessaires sont collectées
- [ ] **Pseudonymisation** : données anonymisées quand possible
- [ ] **Paramètres par défaut** : vie privée maximale par défaut
- [ ] **Séparation** : données sensibles isolées

### 9. Documentation requise

#### Registre des traitements (Art. 30)
Pour chaque traitement :
```
Nom du traitement: [ex: Gestion des utilisateurs]
Finalité: [ex: Création et gestion des comptes]
Base légale: [ex: Contrat]
Catégories de données: [ex: email, nom, mot de passe hashé]
Catégories de personnes: [ex: Utilisateurs de l'application]
Destinataires: [ex: Service client, sous-traitant hébergement]
Transferts hors UE: [ex: AWS Ireland - CCT]
Durée de conservation: [ex: Durée du compte + 30 jours]
Mesures de sécurité: [ex: Chiffrement, RBAC, logs]
```

#### Autres documents
- [ ] Politique de confidentialité publique
- [ ] Mentions légales
- [ ] Politique cookies
- [ ] Contrats sous-traitants (DPA)
- [ ] Procédure de violation de données

## Output attendu

### Résumé de conformité

```
Projet: [nom]
Date d'audit: [date]
Niveau de conformité estimé: [Faible/Moyen/Bon/Excellent]
```

### Données personnelles identifiées

| Donnée | Localisation | Base légale | Durée conservation |
|--------|--------------|-------------|-------------------|
| [email] | [users table] | [Contrat] | [Durée compte] |
| ... | ... | ... | ... |

### Conformité par domaine

| Domaine | Statut | Priorité |
|---------|--------|----------|
| Consentement/Cookies | [OK/KO/Partiel] | [Haute/Moyenne/Basse] |
| Droits des personnes | [OK/KO/Partiel] | [Haute/Moyenne/Basse] |
| Durée de conservation | [OK/KO/Partiel] | [Haute/Moyenne/Basse] |
| Transferts hors UE | [OK/KO/Partiel] | [Haute/Moyenne/Basse] |
| Sécurité | [OK/KO/Partiel] | [Haute/Moyenne/Basse] |
| Documentation | [OK/KO/Partiel] | [Haute/Moyenne/Basse] |

### Non-conformités critiques

1. **[Problème]**
   - Impact : [description]
   - Recommandation : [action]
   - Priorité : Haute

### Plan d'action recommandé

| Action | Priorité | Complexité | Responsable suggéré |
|--------|----------|------------|---------------------|
| [Action 1] | Haute | Faible | Dev |
| [Action 2] | Haute | Moyenne | Legal + Dev |
| ... | ... | ... | ... |

### Registre des traitements (ébauche)

[Tableau des traitements identifiés selon format Art. 30]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/legal` | Documents légaux complets |
| `/privacy-policy` | Politique de confidentialité |
| `/security` | Sécurité des données |
| `/analytics` | Vérifier le tracking analytics |

---

IMPORTANT: Cet audit est une analyse technique du code. Il ne remplace pas un avis juridique professionnel.

YOU MUST identifier tous les flux de données personnelles, y compris vers les services tiers.

NEVER considérer qu'un service "populaire" est automatiquement conforme RGPD.

Think hard sur les flux de données et les risques avant de conclure.
