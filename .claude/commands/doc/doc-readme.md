# Agent README

Genere ou ameliore le README d'un projet pour maximiser son adoption et sa comprehension.

## Projet
$ARGUMENTS

## Objectif

Creer un README professionnel qui permet aux nouveaux utilisateurs de comprendre, installer et utiliser le projet en moins de 5 minutes.

## Workflow

- Analyser le projet (type, stack, fonctionnalites)
- Rediger le header (nom, badges, description une ligne)
- Rediger le Quick Start (installation copy-paste, exemple minimal)
- Documenter les fonctionnalites principales
- Ajouter la configuration et les options
- Ecrire la section contribution
- Adapter au type de projet (lib npm, CLI, API, app)
- Ajouter les meta (licence, remerciements)

## Output attendu

### README genere avec sections
1. Header (nom, badges, description)
2. Quick Start (installation + exemple qui fonctionne)
3. Fonctionnalites
4. Configuration
5. API Reference (si applicable)
6. FAQ
7. Contribution
8. Licence

### Checklist qualite
- [ ] Installation copy-paste friendly
- [ ] Au moins un exemple qui fonctionne
- [ ] Quick Start present

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/doc:doc-generate` | Documentation detaillee |
| `/doc:doc-changelog` | Changelog du projet |
| `/doc:doc-api-spec` | Documentation API |
| `/doc:doc-onboard` | Onboarding developpeurs |

---

IMPORTANT: Le README est souvent le premier contact avec le projet. Il doit convaincre en 30 secondes.

YOU MUST inclure une installation copy-paste friendly.

YOU MUST avoir au moins un exemple qui fonctionne.

NEVER avoir un README sans Quick Start.

Think hard sur ce que le lecteur veut savoir en premier.
