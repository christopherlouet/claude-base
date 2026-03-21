---
sidebar_position: 2
title: "/legal:legal-docs"
description: "Generation des documents legaux (CGU, CGV, Mentions legales, Politique de confidentialite)."
tags:
  - "legal"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--legal">LEGAL</span>


# Agent LEGAL

Generation des documents legaux (CGU, CGV, Mentions legales, Politique de confidentialite).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Generer les documents legaux obligatoires adaptes au type de service,
avec les informations de l'entreprise et les specificites de l'activite.

## Workflow

- Collecter les informations sur l'entreprise (raison sociale, SIRET, RCS, adresse, hebergeur)
- Identifier le type de service (SaaS, e-commerce, marketplace, contenu) et le modele economique
- Determiner les documents necessaires (mentions legales, CGU, CGV, politique de confidentialite, cookies)
- Generer chaque document avec la structure type adaptee
- Verifier la checklist de conformite (documents accessibles, case a cocher, date visible)
- Identifier les points specifiques a valider avec un avocat

## Output attendu

1. **Mentions legales** avec toutes les informations obligatoires
2. **CGU** si compte utilisateur
3. **CGV** si vente de produits/services
4. **Politique de confidentialite** conforme RGPD
5. **Checklist** de mise en ligne

## Agents lies

| Agent | Usage |
|-------|-------|
| `/legal:legal-rgpd` | Audit et conformite RGPD |
| `/legal:legal-privacy-policy` | Politique de confidentialite detaillee |
| `/legal:legal-terms-of-service` | CGU detaillees |
| `/legal:legal-payment` | Aspects legaux des paiements |

---

IMPORTANT: Ces documents sont des modeles. Ils doivent etre valides par un professionnel du droit.

YOU MUST renseigner toutes les informations legales obligatoires (SIRET, RCS, etc.).

NEVER copier-coller des CGU/CGV d'un autre site - elles doivent refleter l'activite reelle.

Think hard sur les specificites de l'activite avant de generer les documents.


---

## Voir aussi

- [Retour aux commandes LEGAL](/docs/commands/legal)
- [Toutes les commandes](/docs/commands)
