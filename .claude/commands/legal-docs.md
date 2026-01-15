# Agent LEGAL

Génération des documents légaux (CGU, CGV, Mentions légales, Politique de confidentialité).

## Contexte
$ARGUMENTS

## Processus de génération

### 1. Collecter les informations

#### Informations sur l'entreprise
| Champ | Valeur |
|-------|--------|
| Raison sociale | |
| Forme juridique | (SAS, SARL, EI, auto-entrepreneur) |
| Capital social | |
| SIRET | |
| RCS | |
| Adresse du siège | |
| Email de contact | |
| Téléphone | (optionnel) |
| Directeur de publication | |
| Hébergeur | (nom, adresse) |

#### Informations sur le service
| Champ | Valeur |
|-------|--------|
| Type de service | (SaaS, e-commerce, marketplace, contenu) |
| Modèle économique | (gratuit, freemium, abonnement, achat) |
| Cible | (B2B, B2C, les deux) |
| Données collectées | (voir `/rgpd`) |

### 2. Documents à générer

#### Obligatoires pour tous les sites
- [ ] Mentions légales
- [ ] Politique de confidentialité

#### Si vente de services/produits
- [ ] Conditions Générales de Vente (CGV)
- [ ] Conditions Générales d'Utilisation (CGU)

#### Optionnels mais recommandés
- [ ] Politique de cookies
- [ ] Politique de remboursement

### 3. Mentions Légales

#### Structure type
```markdown
# Mentions Légales

## Éditeur du site
- Raison sociale : [SOCIÉTÉ]
- Forme juridique : [FORME] au capital de [CAPITAL] €
- Siège social : [ADRESSE]
- SIRET : [NUMÉRO]
- RCS : [VILLE] [NUMÉRO]
- Email : [EMAIL]
- Téléphone : [TÉLÉPHONE]
- Directeur de la publication : [NOM]

## Hébergement
- Hébergeur : [NOM]
- Adresse : [ADRESSE]
- Téléphone : [TÉLÉPHONE]

## Propriété intellectuelle
Le contenu de ce site (textes, images, graphismes, logo, icônes, etc.)
est la propriété exclusive de [SOCIÉTÉ], sauf mentions contraires.
Toute reproduction, distribution, modification, adaptation, retransmission
ou publication de ces éléments est strictement interdite sans l'accord
écrit de [SOCIÉTÉ].

## Données personnelles
Conformément au RGPD, vous disposez de droits sur vos données personnelles.
Pour plus d'informations, consultez notre [Politique de confidentialité](/privacy).

## Cookies
Ce site utilise des cookies. Pour en savoir plus, consultez notre
[Politique de cookies](/cookies).

## Crédits
- Conception et développement : [CRÉDIT]
- Photographies : [CRÉDIT]
```

### 4. Conditions Générales d'Utilisation (CGU)

#### Structure type
```markdown
# Conditions Générales d'Utilisation

*Dernière mise à jour : [DATE]*

## 1. Objet
Les présentes CGU régissent l'utilisation du service [NOM DU SERVICE]
proposé par [SOCIÉTÉ].

## 2. Acceptation des conditions
L'utilisation du service implique l'acceptation pleine et entière
des présentes CGU.

## 3. Description du service
[DESCRIPTION DU SERVICE]

## 4. Accès au service
### 4.1 Inscription
[Conditions d'inscription, âge minimum, etc.]

### 4.2 Compte utilisateur
[Responsabilité du compte, confidentialité des identifiants]

## 5. Obligations de l'utilisateur
L'utilisateur s'engage à :
- Ne pas utiliser le service à des fins illégales
- Ne pas porter atteinte aux droits des tiers
- Ne pas tenter de contourner les mesures de sécurité
- [Autres obligations spécifiques]

## 6. Contenu utilisateur
### 6.1 Propriété
[Qui possède le contenu créé par l'utilisateur]

### 6.2 Licence accordée
[Droits que l'utilisateur accorde à la société]

### 6.3 Modération
[Politique de modération du contenu]

## 7. Propriété intellectuelle
[Droits sur le service, la marque, le contenu]

## 8. Responsabilité
### 8.1 Responsabilité de l'éditeur
[Limitations de responsabilité]

### 8.2 Force majeure
[Clause de force majeure]

## 9. Suspension et résiliation
[Conditions de suspension/résiliation du compte]

## 10. Modification des CGU
[Procédure de modification et notification]

## 11. Droit applicable et juridiction
Les présentes CGU sont soumises au droit français.
Tout litige sera soumis aux tribunaux compétents de [VILLE].

## 12. Contact
Pour toute question : [EMAIL]
```

### 5. Conditions Générales de Vente (CGV)

#### Structure type
```markdown
# Conditions Générales de Vente

*Dernière mise à jour : [DATE]*

## 1. Objet
Les présentes CGV régissent la vente de [PRODUIT/SERVICE] par [SOCIÉTÉ].

## 2. Produits/Services
### 2.1 Description
[Description des produits/services vendus]

### 2.2 Prix
- Les prix sont indiqués en euros, [HT/TTC]
- [SOCIÉTÉ] se réserve le droit de modifier ses prix à tout moment
- Le prix applicable est celui en vigueur au moment de la commande

## 3. Commande
### 3.1 Processus de commande
[Étapes de la commande]

### 3.2 Validation
[Moment où la commande est validée]

## 4. Paiement
### 4.1 Moyens de paiement
[Moyens acceptés : CB, PayPal, virement, etc.]

### 4.2 Sécurisation
Les paiements sont sécurisés par [PRESTATAIRE].

### 4.3 Facturation
Une facture est émise et envoyée par email après chaque paiement.

## 5. Livraison / Accès au service
### 5.1 Délais
[Pour un service en ligne : accès immédiat après paiement]

### 5.2 Modalités
[Comment le client accède au service]

## 6. Droit de rétractation
### 6.1 Délai
Conformément à l'article L221-18 du Code de la consommation,
vous disposez d'un délai de 14 jours pour exercer votre droit
de rétractation.

### 6.2 Exceptions
[Pour les contenus numériques : exception si accès immédiat avec
renoncement express au droit de rétractation]

### 6.3 Modalités
Pour exercer ce droit, contactez-nous à [EMAIL].

## 7. Garanties
[Garanties légales et commerciales]

## 8. Réclamations et litiges
### 8.1 Service client
[EMAIL] - Réponse sous [DÉLAI]

### 8.2 Médiation
Conformément à l'article L612-1 du Code de la consommation,
vous pouvez recourir au médiateur : [NOM DU MÉDIATEUR]
[URL DU MÉDIATEUR]

## 9. Responsabilité
[Limitations de responsabilité]

## 10. Données personnelles
Voir notre [Politique de confidentialité](/privacy).

## 11. Droit applicable
Les présentes CGV sont soumises au droit français.
```

### 6. Politique de Confidentialité

#### Structure type (conforme RGPD)
```markdown
# Politique de Confidentialité

*Dernière mise à jour : [DATE]*

## 1. Responsable du traitement
[SOCIÉTÉ]
[ADRESSE]
Email : [EMAIL]
DPO : [Si applicable]

## 2. Données collectées
### 2.1 Données fournies directement
- Nom, prénom
- Adresse email
- [Autres données]

### 2.2 Données collectées automatiquement
- Adresse IP
- Données de navigation
- [Autres données]

## 3. Finalités du traitement
| Finalité | Base légale | Durée de conservation |
|----------|-------------|----------------------|
| Gestion du compte | Contrat | Durée du compte + [X] ans |
| Facturation | Obligation légale | 10 ans |
| Newsletter | Consentement | Jusqu'au désabonnement |
| Amélioration du service | Intérêt légitime | [Durée] |

## 4. Destinataires des données
- Services internes de [SOCIÉTÉ]
- Sous-traitants : [Liste avec rôle]
- [Autres destinataires]

## 5. Transferts hors UE
[Liste des transferts avec garanties]

## 6. Vos droits
Conformément au RGPD, vous disposez des droits suivants :
- Droit d'accès
- Droit de rectification
- Droit à l'effacement
- Droit à la limitation
- Droit à la portabilité
- Droit d'opposition

Pour exercer vos droits : [EMAIL]

## 7. Sécurité
[Mesures de sécurité mises en place]

## 8. Cookies
Voir notre [Politique de cookies](/cookies).

## 9. Modifications
[Procédure de modification]

## 10. Contact
DPO / Contact vie privée : [EMAIL]
CNIL : www.cnil.fr
```

### 7. Checklist de conformité

#### Documents
- [ ] Mentions légales créées
- [ ] CGU créées (si compte utilisateur)
- [ ] CGV créées (si vente)
- [ ] Politique de confidentialité créée
- [ ] Politique de cookies créée

#### Mise en place
- [ ] Documents accessibles depuis le footer
- [ ] Case à cocher pour acceptation CGU/CGV
- [ ] Date de dernière mise à jour visible
- [ ] Version imprimable disponible

#### Spécifique e-commerce
- [ ] Prix TTC affichés
- [ ] Frais de livraison indiqués
- [ ] Délai de livraison indiqué
- [ ] Procédure de rétractation claire
- [ ] Médiateur mentionné

## Output attendu

### Documents générés
1. **Mentions légales** - [fichier]
2. **CGU** - [fichier]
3. **CGV** - [fichier si applicable]
4. **Politique de confidentialité** - [fichier]
5. **Politique de cookies** - [fichier si applicable]

### Checklist de mise en ligne
- [ ] [Actions à faire]

### Points d'attention
- [Éléments spécifiques à valider avec un avocat]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/rgpd` | Audit et conformité RGPD |
| `/privacy-policy` | Politique de confidentialité détaillée |
| `/terms-of-service` | CGU détaillées |
| `/payment` | Aspects légaux des paiements |

---

IMPORTANT: Ces documents sont des modèles. Ils doivent être adaptés à votre situation et validés par un professionnel du droit.

YOU MUST renseigner toutes les informations légales obligatoires (SIRET, RCS, etc.).

NEVER copier-coller des CGU/CGV d'un autre site - elles doivent refléter votre activité réelle.

Think hard sur les spécificités de l'activité avant de générer les documents.
