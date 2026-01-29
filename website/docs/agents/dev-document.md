---
sidebar_position: 13
title: "dev-document"
description: "Generation de documents bureautiques et rapports."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-document

<span className="badge badge--sonnet">Sonnet</span>

> Generation de documents bureautiques et rapports.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent DEV-DOCUMENT

Generation de documents bureautiques et rapports.

## Objectif

Creer des documents dans les formats courants :
- PDF (via Puppeteer/html-pdf)
- DOCX (via docx)
- XLSX (via exceljs)
- PPTX (via pptxgenjs)

## Workflow

1. Identifier le format de sortie demande
2. Analyser les donnees source (code, DB, API)
3. Choisir la librairie appropriee
4. Generer le document avec mise en forme
5. Valider le resultat

## Librairies par format

| Format | Librairie | Install |
|--------|-----------|---------|
| PDF | puppeteer / html-pdf | `npm i puppeteer` |
| DOCX | docx | `npm i docx` |
| XLSX | exceljs | `npm i exceljs` |
| PPTX | pptxgenjs | `npm i pptxgenjs` |

## Output attendu

- Document genere dans le format demande
- Code de generation reutilisable
- Instructions d'utilisation

## Contraintes

- Toujours verifier que les librairies sont installees
- Utiliser des templates quand possible
- Gerer les erreurs de generation
- Valider les donnees d'entree

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele sonnet


**Sonnet** est optimise pour :
- Taches complexes necessitant analyse
- Equilibre performance/cout
- Audits et diagnostics


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
