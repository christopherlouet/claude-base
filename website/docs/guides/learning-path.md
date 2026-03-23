---
sidebar_position: 10
title: "Parcours d'apprentissage - De Novice a Pro"
description: "Guide progressif pour maitriser Claude Code et claude-socle, du premier lancement a l'utilisation avancee"
---

# Parcours d'apprentissage : De Novice a Pro

Ce guide vous accompagne pas a pas dans la maitrise de Claude Code et de claude-socle, du premier lancement a la creation d'applications complexes. Il est structure en 5 niveaux progressifs, chacun avec des exercices pratiques, les erreurs courantes a eviter, et un checkpoint pour savoir quand passer au suivant.

| Niveau | Titre | Duree | Ce que vous apprenez |
|--------|-------|-------|----------------------|
| 1 | Decouverte | 30 min | Installation, premiers pas, orchestrateur |
| 2 | Fondamentaux | 2h | Workflow complet, commands, agents, skills, rules |
| 3 | Productivite | 2h | TDD, audits, hooks, prompting avance, parallelisme |
| 4 | Maitrise | 3h | Creation de skills/agents/rules, hooks, MCP |
| 5 | Expert | 2h | Architecture, optimisation tokens, teams, contribution |

**Duree totale estimee : 9h30** (a repartir sur plusieurs jours)

---

## Niveau 1 - Decouverte (30 minutes)

**Objectif :** Comprendre ce qu'est Claude Code, installer claude-socle et realiser vos premieres interactions.

**Public :** Vous n'avez jamais ouvert Claude Code, ou vous l'avez utilise comme un simple chatbot de terminal sans configuration particuliere.

---

### 1.1 Qu'est-ce que Claude Code ?

Claude Code est un agent de developpement qui s'execute dans votre terminal. Contrairement a un assistant qui repond simplement a vos questions, Claude Code peut lire votre code source, ecrire des fichiers, executer des commandes shell, et enchainer des operations complexes de facon autonome.

La difference fondamentale avec un chatbot classique :

| Chatbot classique | Claude Code |
|-------------------|-------------|
| Repond a des questions | Agit dans votre projet |
| Connait seulement ce que vous lui dites | Lit directement vos fichiers |
| Une reponse par message | Peut enchainer des dizaines d'operations |
| Pas de persistance | Memoire automatique entre sessions |

### 1.2 Qu'est-ce que claude-socle ?

Claude Code seul est puissant, mais il necessite que vous sachiez exactement quoi lui demander. claude-socle est un template de configuration qui transforme Claude Code en un systeme structure et reproductible.

Concretement, claude-socle ajoute dans le dossier `.claude/` de votre projet :

- **126 commandes** : des instructions pre-ecrites pour les taches courantes (`/work:work-explore`, `/dev:dev-tdd`, `/qa:qa-security`, etc.)
- **62 agents** : des sous-processus specialises qui s'activent automatiquement pour des taches d'analyse ou d'audit
- **44 skills** : des comportements qui se declenchent automatiquement selon vos mots-cles
- **24 rules** : des conventions de code appliquees automatiquement selon les fichiers que vous modifiez

Sans claude-socle, vous devez tout specifier a chaque session. Avec claude-socle, les bonnes pratiques sont intergrees et activees automatiquement.

### 1.3 Installation

Suivez le [guide d'installation complet](/docs/intro/installation) pour les details. En resume :

```bash
# Dans le repertoire de votre projet
git clone https://github.com/christopherlouet/claude-socle.git temp-socle
cp -r temp-socle/.claude .
cp temp-socle/CLAUDE.md .
rm -rf temp-socle
```

Verifiez l'installation en lancant Claude Code :

```bash
claude
```

Au demarrage, vous devriez voir un message similaire a :

```
=== Claude Code Session ===
Version socle: 1.27.0
Commandes: 123
Agents: 59
===========================
```

Si ce message n'apparait pas, consultez la section troubleshooting du [guide d'installation](/docs/intro/installation).

### 1.4 Comprendre l'interface terminal

Claude Code s'utilise dans votre terminal. L'interface est minimaliste : vous tapez vos messages ou commandes, Claude repond et peut executer des actions.

Quelques points importants a comprendre des le debut :

**Claude voit votre repertoire courant.** Quand vous lancez `claude` depuis `/home/chris/mon-projet`, Claude peut lire et modifier tous les fichiers de ce repertoire. Lancez toujours Claude depuis la racine de votre projet.

**Les commandes commencent par `/`.** Taper `/work:work-explore` execute la commande `work-explore` du domaine `work`. Le reste du temps, vous ecrivez en langage naturel.

**Claude peut se tromper.** Relisez les modifications proposees avant de les accepter. Le workflow du socle est concu pour minimiser les erreurs, mais votre vigilance reste necessaire.

### 1.5 Les commandes de base

Ces quatre commandes sont les premieres a maitriser. Elles fonctionnent dans n'importe quelle session, independamment du projet.

**`/help`** - Affiche la liste des commandes disponibles dans votre session actuelle. Utile quand vous cherchez quelle commande utiliser.

**`/clear`** - Efface completement le contexte de la conversation. A utiliser quand vous changez de sujet ou demarrez une nouvelle tache sans rapport avec la precedente. Attention : Claude "oublie" tout ce qui a ete dit.

**`/compact`** - Resume intelligemment le contexte tout en conservant les decisions importantes. Preferer `/compact` a `/clear` entre les phases d'un workflow (par exemple, apres une longue exploration avant de passer a la planification).

**`/effort`** - Controle le niveau de raisonnement utilise. Quatre niveaux :

| Niveau | Commande | Quand l'utiliser |
|--------|----------|-----------------|
| Faible | `/effort low` | Exploration, lecture de fichiers, taches simples |
| Moyen | `/effort medium` | Developpement standard, corrections |
| Eleve | `/effort high` | Architecture, refactoring complexe |
| Maximum | `/effort max` | Audit critique, debug complexe |

Par defaut, Claude Code ajuste son niveau automatiquement. Utilisez `/effort` pour forcer un niveau specifique.

### 1.6 L'orchestrateur `/assistant`

`/assistant` est le point d'entree recommande quand vous ne savez pas quelle commande utiliser. Decrivez votre besoin, et l'orchestrateur vous guide vers la bonne commande ou enchainement de commandes.

```bash
# Mode guide : attend votre confirmation avant d'agir
/assistant

# Exemple avec contexte
/assistant "Je veux ajouter un systeme de notification par email a mon API Node.js"
```

L'orchestrateur analysera votre demande et proposera un plan d'action. C'est le point de depart ideal pour les debutants.

Pour les utilisateurs qui veulent une execution directe sans confirmation :

```bash
# Mode automatique : execute directement le workflow adapte
/assistant-auto "Ajouter des tests de regression pour le module auth"
```

La difference entre les deux : `/assistant` vous laisse valider chaque etape, `/assistant-auto` enchaine les actions automatiquement. Commencez par `/assistant` jusqu'a ce que vous soyez a l'aise avec le systeme.

### 1.7 Premiere interaction : explorer un projet

La meilleure facon de decouvrir Claude Code est d'explorer un projet existant. La commande `/work:work-explore` est specifiquement congue pour cela : elle analyse votre code en lecture seule et produit une vue d'ensemble structuree.

```bash
/work:work-explore
```

Claude va examiner :
- La structure des dossiers et fichiers principaux
- Les dependances et technologies utilisees
- Les patterns et conventions en place
- Les points d'attention eventuels

Vous pouvez aussi explorer un aspect specifique :

```bash
/work:work-explore "Comprendre le systeme d'authentification"
```

---

### Exercice Niveau 1

Choisissez un projet existant sur votre machine (peu importe la taille ou le langage).

1. Positionnez-vous dans le repertoire du projet : `cd /chemin/vers/mon-projet`
2. Installez claude-socle si ce n'est pas fait
3. Lancez Claude Code : `claude`
4. Executez `/work:work-explore` et lisez le rapport produit
5. Posez deux questions en langage naturel sur le code (par exemple : "Quelles sont les principales dependances de ce projet ?" ou "Ou se trouve la logique metier principale ?")
6. Essayez `/assistant "Que faudrait-il faire pour ameliorer ce projet ?"` et observez les recommandations

**Duree estimee :** 15 a 30 minutes.

---

### Erreurs courantes au Niveau 1

**Lancer Claude depuis le mauvais repertoire.** Si vous lancez `claude` depuis votre home (`~`), Claude voit votre repertoire personnel, pas votre projet. Verifiez toujours avec `pwd` que vous etes au bon endroit.

**Utiliser Claude comme un chatbot.** La tentation est forte de poser des questions generales ("Comment faire du TDD en Python ?"). Claude Code est optimise pour travailler sur votre code specifique. Ancrez vos demandes dans le contexte de votre projet.

**Accepter toutes les modifications sans relire.** Claude peut faire des erreurs. Lisez les diffs avant de valider, surtout au debut.

**Ne pas utiliser `/compact` dans les sessions longues.** Apres 30 a 60 minutes de travail, le contexte s'accumule. Utilisez `/compact` pour garder les sessions fluides.

**Confondre `/clear` et `/compact`.** `/clear` efface tout, `/compact` resumer intelligemment. Dans la majorite des cas, `/compact` est le bon choix.

---

### Checkpoint Niveau 1

Vous etes pret pour le Niveau 2 quand vous pouvez repondre "oui" a ces questions :

- [ ] Claude Code demarre correctement et affiche le message d'accueil du socle
- [ ] Vous savez lancer `/work:work-explore` et interpreter le rapport produit
- [ ] Vous comprenez la difference entre `/clear` et `/compact`
- [ ] Vous avez utilise `/assistant` pour obtenir une recommandation
- [ ] Vous savez que Claude voit le repertoire depuis lequel vous l'avez lance

---

## Niveau 2 - Fondamentaux (2 heures)

**Objectif :** Maitriser le workflow obligatoire Explore -> Specify -> Plan -> TDD -> Audit -> Commit, comprendre les quatre concepts cles (Commands, Agents, Skills, Rules) et savoir choisir la bonne commande pour chaque situation.

**Public :** Vous avez complete le Niveau 1. Vous savez demarrer Claude Code et executer des commandes simples.

---

### 2.1 Le workflow obligatoire

Claude-socle impose un workflow en six etapes pour tout developpement significatif. Ce n'est pas une suggestion : sauter des etapes produit systematiquement des resultats de moins bonne qualite et introduit des regressions.

```
EXPLORE -> SPECIFY -> PLAN -> TDD -> AUDIT -> COMMIT
```

Voici pourquoi chaque etape est necessaire :

**EXPLORE** (`/work:work-explore`)

Lire et comprendre le code existant avant toute modification. Claude Code ne connait pas votre projet par defaut (sauf ce qui est dans le contexte courant). L'exploration etablit la base de connaissance necessaire pour que les etapes suivantes soient pertinentes.

```bash
/work:work-explore
# ou avec un focus specifique
/work:work-explore "Comprendre le module de gestion des utilisateurs"
```

**SPECIFY** (`/work:work-specify`)

Traduire votre besoin en User Stories structurees avec des criteres d'acceptation. Cette etape force la clarification des ambiguites avant d'investir du temps en planification et en code.

```bash
/work:work-specify "Ajouter la fonctionnalite de reinitialisation de mot de passe"
```

La commande produit un document dans `specs/[feature]/spec.md` avec :
- Des User Stories priorisees (P1=MVP, P2=Important, P3=Nice-to-have)
- Des criteres d'acceptation au format Given/When/Then
- Les contraintes techniques identifiees

**PLAN** (`/work:work-plan`)

Proposer une architecture technique avant d'implementer. Cette etape liste les fichiers a creer ou modifier, les dependances entre taches, et les risques potentiels. Vous validez le plan avant que le code soit ecrit.

```bash
/work:work-plan
```

Le plan est stocke dans `specs/[feature]/plan.md`. Ne passez pas a l'etape TDD sans avoir valide ce plan.

**TDD** (`/dev:dev-tdd`)

Implementer en suivant le cycle Red-Green-Refactor : ecrire le test qui echoue en premier, puis ecrire le code minimal pour le faire passer, puis ameliorer le code sans casser les tests. La couverture minimale attendue est 80%.

```bash
/dev:dev-tdd "Implementer le service de reinitialisation de mot de passe"
```

L'ordre est strict : tests d'abord, code ensuite. Cette contrainte peut sembler contre-intuitive au debut, mais elle force a clarifier les specifications avant de coder et produit un code plus maintenable.

**AUDIT** (`/qa:qa-loop "score 90"`)

Verifier la qualite globale apres l'implementation : securite, performance, accessibilite, dette technique. La commande `qa-loop` execute un audit et corrige automatiquement les problemes jusqu'a atteindre un score de 90.

```bash
/qa:qa-loop "score 90"
```

Ne commitez pas sans avoir atteint le score cible. L'audit valide ce que les tests ne couvrent pas : vulnerabilites de securite, problemes de performance, dette technique.

**COMMIT** (`/work:work-commit` ou `/work:work-pr`)

Creer un commit propre avec un message au format Conventional Commits, ou une Pull Request complete avec description.

```bash
# Commit simple
/work:work-commit

# Pull Request complete
/work:work-pr
```

#### Vue d'ensemble du workflow

```
/work:work-explore
        |
        v
/work:work-specify
        |
        v
/work:work-plan -----> Validation du plan
        |                      |
        |               Reviser si besoin
        |                      |
        v<---------------------+
/dev:dev-tdd
        |
        v
/qa:qa-loop "score 90" -----> Score < 90 : corriger et re-auditer
        |                               |
        |                               |
        v<-----------------------------+
/work:work-pr
```

#### Raccourcis pour les cas courants

Pour les taches standard, des commandes de workflow complet enchainent toutes les etapes automatiquement :

```bash
# Nouvelle feature : enchaine tout le workflow
/work:work-flow-feature "Ajouter la fonctionnalite de recherche"

# Correction de bug : workflow adapte
/work:work-flow-bugfix "Corriger le crash au chargement du profil"

# Changement trivial (refactoring mineur, correction typo) :
/work:work-quick "Renommer la variable userId en user_id dans auth.ts"
```

---

### 2.2 Les Commands : le declenchement manuel

Une **command** est un fichier Markdown dans `.claude/commands/` qui contient des instructions pour Claude. Vous la declenchez explicitement avec le prefixe `/`.

La convention de nommage est `domaine:domaine-action` :

```bash
/work:work-explore      # domaine "work", action "explore"
/dev:dev-tdd            # domaine "dev", action "tdd"
/qa:qa-security         # domaine "qa", action "security"
/ops:ops-deploy         # domaine "ops", action "deploy"
```

Les 9 domaines disponibles :

| Domaine | Commandes | Usage |
|---------|-----------|-------|
| `work` | Workflow principal (explore, specify, plan, commit, pr...) | Orchestration du developpement |
| `dev` | Developpement (tdd, api, component, debug, refactor...) | Ecriture de code |
| `qa` | Qualite (audit, security, perf, wcag...) | Verification et tests |
| `ops` | Operations (deploy, docker, ci, database...) | Infrastructure |
| `doc` | Documentation (generate, changelog, explain...) | Documentation |
| `biz` | Business (model, mvp, competitor, personas...) | Strategie produit |
| `growth` | Croissance (seo, analytics, landing, funnel...) | Marketing technique |
| `data` | Donnees (pipeline, analytics, modeling...) | Data engineering |
| `legal` | Legal (rgpd, privacy, terms...) | Conformite |

La caracteristique cle d'une command : elle partage le contexte de votre conversation. Claude voit tout l'historique de la session quand il execute une command. Cela permet des enchainements logiques : explorer, puis planifier en connaissant l'exploration, puis coder en connaissant le plan.

Les commands acceptent des arguments :

```bash
/dev:dev-tdd "Implementer la validation d'email dans UserService"
/work:work-plan "Feature: systeme de notifications push"
/qa:qa-loop "score 95"
```

---

### 2.3 Les Agents : le traitement autonome isole

Un **agent** est un sous-processus lance par Claude pour executer une tache de facon autonome, dans un contexte isole qui ne pollue pas votre conversation principale.

La difference avec une command :

| Aspect | Command | Agent |
|--------|---------|-------|
| Declenchement | Manuel (`/cmd`) | Automatique (delegation) |
| Contexte | Partage avec la session | Isole (ne voit pas la session) |
| Outils | Tous disponibles | Restreints selon l'agent |
| Modele | Celui de la session | Haiku ou Sonnet selon l'agent |

Exemple concret : quand vous tapez "Fais un audit de securite", Claude delegue automatiquement a l'agent `qa-security`. Cet agent :
- S'execute avec le modele Sonnet (optimise pour ce type d'analyse)
- N'a acces qu'aux outils Read, Grep et Glob (lecture seule, impossible de modifier accidentellement)
- Produit un rapport qui est reintegre dans votre conversation principale

```
Votre conversation
      |
      | "Fais un audit de securite"
      v
 Claude delegue
      |
      v
 [Agent qa-security - contexte isole]
 - Model: sonnet
 - Outils: Read, Grep, Glob seulement
 - Analyse le code...
      |
      v
 Rapport d'audit
      |
      v
Votre conversation
(resume des resultats)
```

Vous pouvez aussi invoquer les agents via des commands :

```bash
/qa:qa-security     # Lance l'agent qa-security
/qa:qa-perf         # Lance l'agent qa-perf
/work:work-explore  # Lance l'agent work-explore
```

Les 62 agents sont regroupes dans les memes domaines que les commands. Les agents haiku (26) sont utilises pour les taches rapides et economiques (exploration, documentation, audits simples). Les agents sonnet (30) pour les analyses complexes (securite, performance, debug, architecture).

---

### 2.4 Les Skills : le comportement automatique

Un **skill** est un ensemble d'instructions qui s'activent automatiquement quand certains mots-cles sont detectes dans vos messages.

Vous n'avez pas besoin de faire quoi que ce soit : les skills se declenchent en arriere-plan. Par exemple :

- Mentionner "TDD" ou "test first" active le skill `test-driven-development` : Claude suivra automatiquement le cycle Red-Green-Refactor
- Mentionner "commit" ou "git commit" active le skill `generating-commit-messages` : Claude utilisera le format Conventional Commits
- Mentionner "docker" ou "containeriser" active le skill `docker-containerization` : Claude appliquera les bonnes pratiques Docker

```
Vous : "Je veux faire du TDD pour ce nouveau service"
                    |
                    v
         Detection : "TDD" detecte
                    |
                    v
         Skill test-driven-development active
                    |
                    v
         Claude applique automatiquement :
         - RED : ecrire le test qui echoue d'abord
         - GREEN : code minimal pour passer
         - REFACTOR : ameliorer sans casser
```

Les skills principaux a connaitre :

| Skill | Mots-cles declencheurs | Comportement induit |
|-------|----------------------|---------------------|
| `test-driven-development` | TDD, test first, red green | Cycle Red-Green-Refactor obligatoire |
| `generating-commit-messages` | commit, git commit | Format Conventional Commits |
| `creating-pull-requests` | PR, pull request, merge | Structure de PR complete |
| `debugging-issues` | bug, erreur, crash, debug | Investigation systematique |
| `security-audit` | securite, OWASP, vulnerability | Audit OWASP Top 10 |
| `exploring-codebase` | explorer, comprendre, decouvrir | Analyse en lecture seule |

---

### 2.5 Les Rules : les conventions automatiques

Une **rule** est un ensemble de conventions appliquees automatiquement quand vous travaillez sur certains types de fichiers.

Le systeme est base sur les chemins de fichiers. Quand Claude modifie `src/components/Button.tsx`, les rules correspondant aux patterns `**/*.tsx` et `**/components/**` s'activent automatiquement. Claude applique alors les conventions TypeScript et React sans que vous ayez besoin de les rappeler.

```
Claude modifie src/api/auth.ts
          |
          v
  Detection : le fichier correspond a
  - "**/*.ts" -> rule typescript activee
  - "**/api/**" -> rule api activee
  - "**/auth/**" -> rule security activee
          |
          v
  Claude applique automatiquement :
  - TypeScript strict mode, pas de `any`
  - Conventions REST, codes HTTP corrects
  - Validation des entrees, protection XSS
```

Les 24 rules du socle couvrent :
- Les langages : TypeScript, Python, Go, Java, C#, Ruby, PHP, Rust, Flutter/Dart
- Les frameworks : React, Next.js
- Les domaines transversaux : Testing, Security, API, Git, Workflow, Performance, Accessibility

**Ordre de priorite quand plusieurs rules s'appliquent simultanement :**

| Priorite | Rule | Raison |
|----------|------|--------|
| 1 (max) | `security` | La securite prime sur tout |
| 2 | `verification` | Verification obligatoire avant completion |
| 3 | `tdd-enforcement` | TDD obligatoire pour tout code |
| 4 | Rules de langage | Conventions specifiques |
| 5 | Rules de framework | Conventions du framework |
| 6 | `testing` | Normes de tests |
| 7+ | `performance`, `accessibility`, `api`... | Optimisations et bonnes pratiques |

---

### 2.6 Les 9 domaines : vue d'ensemble

Claude-socle organise ses 126 commandes en 9 domaines. Chaque domaine couvre un aspect du developpement logiciel.

```
.claude/commands/
├── work/      # Workflow : explore, specify, plan, commit, pr, flows...
├── dev/       # Code : tdd, api, component, debug, refactor, test...
├── qa/        # Qualite : audit, security, perf, wcag, review, loop...
├── ops/       # Infra : deploy, docker, ci, database, monitoring...
├── doc/       # Docs : generate, changelog, explain, onboard...
├── biz/       # Business : model, mvp, competitor, personas, pricing...
├── growth/    # Croissance : seo, analytics, landing, funnel, cro...
├── data/      # Donnees : pipeline, analytics, modeling...
└── legal/     # Legal : rgpd, privacy-policy, terms-of-service...
```

Pour les developpeurs, les domaines les plus utilises au quotidien sont `work`, `dev`, `qa` et `ops`. Les domaines `biz`, `growth`, `data` et `legal` sont pertinents selon le contexte de votre projet.

---

### 2.7 Exercice pratique : implementer une feature complete

Cet exercice vous fait parcourir l'integralite du workflow sur un exemple concret. Choisissez un projet sur lequel vous travaillez, ou creez un projet vide.

**Scenario :** Ajouter une fonction de validation d'adresse email dans un module utilitaire.

**Etape 1 - Explorer**
```bash
/work:work-explore "Comprendre les utilitaires existants et les conventions de validation"
```
Lisez le rapport. Identifiez : existe-t-il deja une logique de validation ? Quel est le style de code utilise ?

**Etape 2 - Specifier**
```bash
/work:work-specify "Ajouter une fonction validateEmail dans le module utils"
```
Lisez les User Stories generees. Verifiez que les criteres d'acceptation correspondent a votre intention. Ajustez si necessaire.

**Etape 3 - Planifier**
```bash
/work:work-plan
```
Examinez le plan : quels fichiers seront crees ou modifies ? Y a-t-il des risques identifies ? Validez le plan explicitement (repondez "ok" ou "valide le plan").

**Etape 4 - Implmenter en TDD**
```bash
/dev:dev-tdd "Implementer validateEmail selon le plan valide"
```
Observez le cycle : Claude ecrit d'abord le test (qui echoue), puis le code minimal, puis refactorise si necessaire.

**Etape 5 - Auditer**
```bash
/qa:qa-loop "score 90"
```
Attendez la completion de l'audit. Si des problemes sont identifies, Claude les corrige automatiquement. Verifiez le score final.

**Etape 6 - Commiter**
```bash
/work:work-commit
```
Lisez le message de commit propose. Verifiez qu'il respecte le format Conventional Commits (`feat:`, `fix:`, etc.).

---

### 2.8 Table de decision : quelle commande pour quelle situation ?

| Je veux... | Commande | Domaine |
|------------|----------|---------|
| Comprendre un projet ou module | `/work:work-explore` | work |
| Creer des User Stories | `/work:work-specify` | work |
| Clarifier des ambiguites de spec | `/work:work-clarify` | work |
| Planifier une implementation | `/work:work-plan` | work |
| Developper en TDD | `/dev:dev-tdd` | dev |
| Generer des tests pour du code existant | `/dev:dev-test` | dev |
| Debugger un bug | `/dev:dev-debug` | dev |
| Refactorer du code | `/dev:dev-refactor` | dev |
| Creer un composant UI | `/dev:dev-component` | dev |
| Creer un endpoint API | `/dev:dev-api` | dev |
| Audit complet (securite + perf + a11y) | `/qa:qa-audit` | qa |
| Audit + correction automatique | `/qa:qa-loop "score 90"` | qa |
| Audit securite uniquement | `/qa:qa-security` | qa |
| Audit performance | `/qa:qa-perf` | qa |
| Audit accessibilite WCAG | `/qa:wcag-audit` | qa |
| Code review | `/qa:qa-review` | qa |
| Creer un commit propre | `/work:work-commit` | work |
| Creer une Pull Request | `/work:work-pr` | work |
| Deployer en production | `/ops:ops-deploy` | ops |
| Dockeriser une application | `/ops:ops-docker` | ops |
| Configurer une CI/CD | `/ops:ops-ci` | ops |
| Health check du projet | `/ops:ops-health` | ops |
| Generer de la documentation | `/doc:doc-generate` | doc |
| Expliquer du code complexe | `/doc:doc-explain` | doc |
| Workflow feature complet | `/work:work-flow-feature "..."` | work |
| Workflow bugfix complet | `/work:work-flow-bugfix "..."` | work |
| Je ne sais pas quelle commande utiliser | `/assistant` | - |

---

### Erreurs courantes au Niveau 2

**Sauter l'etape SPECIFY.** Beaucoup de developpeurs passent directement d'EXPLORE a PLAN. Les User Stories forcent a clarifier le "quoi" avant de definir le "comment". Sans cette etape, le plan repose sur des hypotheses non validees.

**Valider le plan trop vite.** Le plan produit par `/work:work-plan` est une proposition. Lisez-le attentivement. Posez des questions si quelque chose n'est pas clair. C'est votre derniere opportunite de recadrer avant l'implementation.

**Ecrire le code avant les tests en TDD.** Quand vous utilisez `/dev:dev-tdd`, la tentation est de demander "ecris le code et les tests". Le TDD impose un ordre : test echouant en premier, code ensuite. Si vous constatez que Claude ecrit le code avant les tests, rappelez-lui explicitement : "Ecris d'abord le test qui echoue, puis le code minimal."

**Commiter sans auditer.** L'audit n'est pas optionnel. Il detecte des problemes que les tests unitaires ne couvrent pas : vulnerabilites de securite, problemes d'accessibilite, dette technique. Un code qui passe tous les tests peut quand meme avoir un score d'audit de 40/100.

**Confondre agent et command.** Les commands s'invoquent avec `/`. Les agents s'activent automatiquement par delegation. Vous n'invoquez pas un agent directement (meme si certaines commands lancent des agents). La distinction devient importante quand vous creez vos propres outils.

**Ignorer les rules activees.** Quand Claude applique des conventions TypeScript ou de securite, ce n'est pas arbitraire : les rules du socle ont ete conigues pour un projet specifique. Ne demandez pas a Claude d'ignorer ces conventions sans bonne raison.

**Sessions trop ambitieuses.** Si votre feature necessite 15 taches ou plus, decoupez-la en sous-features independantes. Les sessions trop longues accumulent du contexte et generent des regressions. La regle pratique : plus de 10 fichiers modifies sans commit intermediaire est un signal d'alarme.

---

### Checkpoint Niveau 2

Vous etes pret pour le Niveau 3 (Intermediaire) quand :

- [ ] Vous avez execute le workflow complet Explore -> Specify -> Plan -> TDD -> Audit -> Commit sur une feature, meme petite
- [ ] Vous savez expliquer la difference entre une command, un agent, un skill et une rule
- [ ] Vous utilisez la convention de nommage `domaine:domaine-action` sans avoir a chercher
- [ ] Vous connaissez les 9 domaines et savez dans quel domaine chercher pour une tache donnee
- [ ] Vous utilisez `/assistant` quand vous ne savez pas quelle commande utiliser
- [ ] Vous avez execute `/qa:qa-loop` au moins une fois et verifie le score d'audit
- [ ] Vous comprenez pourquoi on ecrit les tests avant le code en TDD

---

## Niveau 3 - Productivite (2h)

Ce niveau transforme votre usage de Claude Code en un workflow professionnel. Vous apprendrez a travailler avec la discipline du TDD, a automatiser la qualite par les hooks, a formuler des prompts precis qui multiplient la qualite des resultats, et a paralleliser vos sessions pour traiter plusieurs features simultanement.

---

### 3.1 TDD avec Claude Code

Le Test-Driven Development n'est pas optionnel dans claude-socle : c'est une contrainte du workflow. La rule `tdd-enforcement` se declenche automatiquement quand vous demandez a Claude d'implementer, ajouter, creer ou corriger du code. Comprendre pourquoi le TDD fonctionne mieux avec un LLM qu'en solo est la cle de ce niveau.

#### Le cycle Red-Green-Refactor en pratique

```
┌─────────┐     ┌─────────┐     ┌──────────┐
│   RED   │ --> │  GREEN  │ --> │ REFACTOR │
│  Test   │     │  Code   │     │  Clean   │
│  fail   │     │  pass   │     │   up     │
└─────────┘     └─────────┘     └──────────┘
      ^                              |
      └──────────────────────────────┘
```

**Phase RED** : Claude ecrit les tests AVANT d'avoir le code. C'est le signal de depart. Un test qui passe immediatement est un mauvais test -- il ne prouve rien.

```typescript
// Phase RED : le test echoue car UserService n'existe pas encore
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid email', async () => {
      const user = await userService.createUser({
        email: 'test@example.com',
        name: 'Test User',
      });
      expect(user.id).toBeDefined();
      expect(user.email).toBe('test@example.com');
    });

    it('should throw InvalidEmailError when email has no @', async () => {
      await expect(
        userService.createUser({ email: 'invalide', name: 'Test' })
      ).rejects.toThrow(InvalidEmailError);
    });

    it('should throw when email is empty', async () => {
      await expect(
        userService.createUser({ email: '', name: 'Test' })
      ).rejects.toThrow();
    });
  });
});
```

**Phase GREEN** : Code minimal pour faire passer les tests. Pas d'optimisation, pas de generalisation. YAGNI (You Aren't Gonna Need It).

```typescript
// Phase GREEN : minimum viable pour les tests
export class UserService {
  async createUser(data: CreateUserDto): Promise<User> {
    if (!data.email || !data.email.includes('@')) {
      throw new InvalidEmailError(data.email);
    }
    return { id: generateId(), email: data.email, name: data.name };
  }
}
```

**Phase REFACTOR** : Ameliorer sans casser. Si le refactoring casse les tests, `/rewind` ramene a l'etat stable precedent. Claude Code sauvegarde automatiquement un checkpoint avant chaque modification.

```typescript
// Phase REFACTOR : injection de dependances, validation extraite
export class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async createUser(data: CreateUserDto): Promise<User> {
    this.validateEmail(data.email);
    return this.userRepository.create(data);
  }

  private validateEmail(email: string): void {
    if (!email || !email.includes('@')) {
      throw new InvalidEmailError(email);
    }
  }
}
```

#### Utiliser `/dev:dev-tdd` efficacement

La commande `/dev:dev-tdd` orchestre le cycle complet. Elle fonctionne mieux quand vous lui donnez une description precise de la feature, pas juste un nom de fichier.

```bash
# Vague - Claude devra deviner l'intention
/dev:dev-tdd "user service"

# Precis - Claude comprend les contraintes et les cas limites
/dev:dev-tdd "Service de creation d'utilisateur avec validation email,
  gestion des doublons, et hash du mot de passe via bcrypt"
```

Claude va systematiquement :
1. Identifier les cas de test (nominal, edge cases, erreurs)
2. Ecrire les tests avec la structure Arrange-Act-Assert
3. Commiter les tests : `git commit -m "test(scope): add tests for [feature]"`
4. Implementer le code minimal
5. Refactorer
6. Commiter l'implementation : `git commit -m "feat(scope): implement [feature]"`

#### Ecrire de bonnes descriptions de test pour Claude

La structure `it('should [comportement] when [condition]')` est obligatoire. Elle force a penser en termes de comportement observable plutot que d'implementation.

```typescript
// Mauvais - test l'implementation, pas le comportement
it('calls hashPassword method', ...)

// Bon - teste le comportement observable
it('should store hashed password when user is created', ...)
it('should reject login when password does not match hash', ...)
```

Les edge cases a toujours inclure dans vos descriptions :

| Type | Exemples a mentionner |
|------|-----------------------|
| Valeurs limites | 0, -1, valeur maximale |
| Null / Undefined | "y compris quand X est null" |
| Chaines vides | "y compris email vide" |
| Collections vides | "y compris panier vide" |
| Erreurs reseau | "y compris timeout de la base de donnees" |

#### Couverture et verification

Claude Code configure un hook PostToolUse qui verifie automatiquement la couverture apres modification des fichiers de test. La cible est 80% sur le nouveau code.

```bash
# Lancer les tests avec couverture
npm run test:coverage

# Tests en watch mode pendant le developpement
npm run test:watch

# Un seul test pour debug rapide
npm test -- --grep "should create a user"
```

#### Exercice 3.1

Implementez une fonction `calculateDiscount(cart: CartItem[], code: string): number` en TDD strict :
1. Commencez par lister tous les cas de test (panier vide, code invalide, code expire, remise en pourcentage, remise fixe)
2. Lancez `/dev:dev-tdd "calculateDiscount avec codes promo, gestion expiration, panier vide"`
3. Verifiez que les tests echouent avant l'implementation
4. Verifiez la couverture apres le cycle complet

---

### 3.2 Audits et qualite

Le TDD valide que le code fait ce qu'il est suppose faire. L'audit valide que le code est pret pour la production : securite, performance, accessibilite, maintenabilite. Ce sont deux dimensions orthogonales -- un code avec 100% de couverture peut avoir des vulnerabilites SQL injection.

#### Comprendre `/qa:qa-loop` et le systeme de score

`/qa:qa-loop` est la commande d'audit centrale. Elle fonctionne en boucle : audit, correction des problemes P0/P1, re-audit, jusqu'a atteindre le score cible.

```bash
/qa:qa-loop              # Score cible 90 (defaut)
/qa:qa-loop "score 85"   # Score cible personnalise
/qa:qa-loop "score 95"   # Audit strict avant une release majeure
```

Le score est calcule sur plusieurs dimensions :
- Securite (vulnerabilites OWASP, secrets exposes, injections)
- Performance (temps de reponse, N+1 queries, bundle size)
- Accessibilite (WCAG 2.1, aria, contraste)
- Maintenabilite (complexite cyclomatique, duplication, couplage)

#### Types d'audits disponibles

| Commande | Usage | Modele |
|----------|-------|--------|
| `/qa:qa-audit` | Audit complet lecture seule (securite + perf + a11y) | sonnet |
| `/qa:qa-loop` | Audit + corrections autonomes en boucle | sonnet |
| `/qa:qa-review` | Code review rapide, feedback sans corrections | sonnet |
| `/qa:qa-security` | Audit securite OWASP Top 10 uniquement | sonnet |
| `/qa:qa-perf` | Audit performance et Core Web Vitals | sonnet |
| `/qa:wcag-audit` | Audit accessibilite WCAG 2.1 | haiku |
| `/qa:qa-design` | Audit UI/UX (100+ regles design web) | haiku |
| `/qa:qa-tech-debt` | Identification et priorisation dette technique | haiku |

La distinction importante entre ces trois commandes :

```
qa-review     --> Feedback seulement, aucune modification
qa-audit      --> Rapport complet avec priorites, aucune modification
qa-loop       --> Audit + corrections automatiques en boucle jusqu'au score cible
```

#### La boucle audit-fix : comment ca fonctionne

`/qa:qa-loop` orchestre plusieurs agents en parallele, consolide les rapports, puis corrige automatiquement les problemes par priorite :

```
Lancement qa-loop
      |
      v
[qa-security] [qa-perf] [wcag-audit]   <- Agents paralleles
      |              |          |
      v              v          v
   Rapport       Rapport    Rapport
      |
      v
Consolidation + calcul score
      |
      v
Score >= 90 ?
   Non --> Corriger P0, P1 --> Re-auditer
   Oui --> Rapport final
```

Les problemes sont classes par priorite :
- **P0 - Critique** : vulnerabilites de securite, donnees exposees -- corriges en priorite absolue
- **P1 - Important** : regressions de performance significatives, erreurs d'accessibilite majeures
- **P2 - Mineur** : dette technique, optimisations mineures

#### Quand utiliser quelle commande

```bash
# Avant de merger une PR standard
/qa:qa-review

# Avant une mise en production
/qa:qa-audit   # Voir les problemes d'abord
/qa:qa-loop    # Puis corriger automatiquement jusqu'a 90

# Feature avec auth ou paiement (critique)
/qa:qa-loop "score 95"

# Suspicion de vulnerabilite specifique
/qa:qa-security

# Apres refactoring d'interface utilisateur
/qa:qa-design
/qa:wcag-audit
```

#### Exercice 3.2

Sur un projet existant ou le starter claude-socle :
1. Lancez `/qa:qa-audit` et lisez le rapport sans rien corriger
2. Identifiez les 3 problemes P0/P1 les plus importants
3. Lancez `/qa:qa-loop "score 85"` et observez la boucle de correction
4. Comparez le rapport avant et apres

---

### 3.3 Hooks - L'automatisation invisible

Chaque fois que Claude modifie un fichier, une chaine de hooks s'execute automatiquement. Ces hooks sont la raison pour laquelle claude-socle garantit une qualite constante sans effort conscient de votre part.

#### Qu'est-ce qu'un hook et pourquoi ca compte

Un hook est un script shell execute automatiquement avant (PreToolUse) ou apres (PostToolUse) qu'un outil soit utilise par Claude. Ils sont configures dans `.claude/settings.json`.

```
Claude veut modifier un fichier
          |
          v
  [PreToolUse Hook]
  Verifie qu'on n'est pas sur main
  Detecte les secrets dans le contenu
          |
          v (si le hook passe)
  Fichier modifie
          |
          v
  [PostToolUse Hook]
  Formate automatiquement le code
  Verifie les types TypeScript
  Lance ESLint
```

Sans hooks, vous devriez penser a formatter, type-checker et linter apres chaque modification. Avec les hooks, c'est invisible et automatique.

#### Hooks PreToolUse : protection et validation

Ces hooks s'executent AVANT la modification. S'ils echouent (exit code != 0), la modification est bloquee.

**Protection de la branche main** : bloque toute modification sur `main` ou `master`. Si vous essayez de modifier un fichier directement sur main, Claude recoit un message d'erreur explicite.

```bash
# Pour contourner exceptionnellement (hotfix urgent)
ALLOW_MAIN_EDIT=1 claude
```

**Detection de secrets (Gitleaks)** : scanne le contenu ecrit avant de le sauvegarder. Si Claude genere un fichier contenant ce qui ressemble a une API key ou un mot de passe, le hook bloque l'ecriture et signale le probleme.

**Tests pre-commit** : quand Claude execute `git commit`, ce hook lance la suite de tests avant d'autoriser le commit. Si les tests echouent, le commit est bloque. Le hook detecte et repare aussi Husky si necessaire.

```bash
# Pour passer les tests pre-commit en urgence (deconseille)
SKIP_PRE_COMMIT_TESTS=1
```

**CI locale pre-push** : avant `git push`, execute lint + type-check + tests. Evite de pousser du code qui cassera la CI.

```bash
SKIP_PRE_PUSH_CI=1  # Pour contourner si CI deja en echec
```

**Command validator** : valide les commandes Bash contre 8 categories de risque : fork bombs, pipe-to-shell (`curl URL | sh`), destruction de disque, escalade de privileges, etc.

```bash
SKIP_COMMAND_VALIDATOR=1  # Pour contourner (utiliser avec precaution)
```

**Destructive ops guard** : bloque les commandes `DELETE`, `DROP`, `TRUNCATE`, `rm -rf` sans confirmation explicite.

```bash
SKIP_DESTRUCTIVE_CHECK=1  # Pour les scripts de migration approuves
```

#### Hooks PostToolUse : qualite automatique

Ces hooks s'executent APRES chaque modification reussie. Ils ne bloquent pas -- ils ameliorent.

**Auto-format par langage** :

| Fichier modifie | Action automatique |
|-----------------|--------------------|
| `*.ts`, `*.tsx`, `*.js`, `*.jsx` | Prettier |
| `*.py` | Ruff / Black |
| `*.go` | gofmt |
| `*.rs` | rustfmt |
| `*.dart` | dart format |
| `*.lua` | stylua |

**Type-check TypeScript** : apres modification d'un fichier `.ts` ou `.tsx`, `tsc --noEmit` s'execute et affiche les erreurs de types.

**ESLint** : lint JS/TS apres modification.

**Auto-install des dependances** : si `package.json` est modifie, `npm install` (ou yarn/pnpm/bun selon la config) s'execute automatiquement. Idem pour `pyproject.toml` (uv sync), `pubspec.yaml` (flutter pub get), `go.mod` (go mod tidy), `Cargo.toml` (cargo check).

**Coverage check** : apres modification de fichiers de test, verifie que la couverture reste au-dessus du seuil.

#### Hooks SessionStart : contexte et securite

Au demarrage de chaque session, plusieurs hooks s'executent :

- **Session info** : affiche les informations du projet (branch courante, derniers commits, status git)
- **Check node_modules** : avertit si `package.json` existe mais `node_modules` est absent
- **Check .env** : verifie que `.env` est bien dans `.gitignore`
- **Warning hooks tiers** : avertit si des hooks personnalises non-standards sont detectes

#### Variables d'environnement de controle

| Variable | Effet |
|----------|-------|
| `ALLOW_MAIN_EDIT=1` | Autoriser les modifications sur main |
| `SKIP_PRE_COMMIT_TESTS=1` | Passer les tests pre-commit |
| `SKIP_PRE_PUSH_CI=1` | Passer la CI locale pre-push |
| `SKIP_COMMAND_VALIDATOR=1` | Desactiver la validation des commandes |
| `SKIP_DESTRUCTIVE_CHECK=1` | Desactiver la protection destructive |
| `ENABLE_RTK=1` | Activer l'optimisation de tokens RTK (-60-90%) |

Ces variables peuvent etre definies dans `.claude/settings.local.json` pour une session persistante, ou exportees dans le shell pour un usage ponctuel.

#### Le command validator en detail

Le command validator (PreToolUse sur Bash) est une nouveaute qui analyse chaque commande Bash avant execution. Il detecte :

- Fork bombs : `:(){ :|:& };:`
- Pipe-to-shell : `curl URL | sh` ou `wget URL | bash`
- Destruction de disque : `dd if=/dev/zero`, `mkfs` sur un disque monte
- Escalade de privileges : `chmod 777 /etc/`, `sudo` dans des contextes risques
- Exfiltration de donnees potentielle

Quand une commande est bloquee, Claude recoit une explication et peut proposer une alternative plus sure.

#### Exercice 3.3

Ouvrez une session Claude Code et modifiez un fichier TypeScript. Observez ce qui se passe :
1. Le hook PreToolUse verifie la branche (vous devriez etre sur une feature branch)
2. La modification s'applique
3. Le hook PostToolUse formate automatiquement le fichier avec Prettier
4. Le hook PostToolUse lance `tsc --noEmit`

Essayez ensuite de commiter avec un test qui echoue intentionnellement. Observez le blocage du hook pre-commit.

---

### 3.4 Prompting avance

La qualite d'un prompt est directement proportionnelle a la qualite du resultat. Boris Cherny (createur de Claude Code) formule ca ainsi : "The more specific and detailed the specification, the better the output."

La difference entre un prompt mediocre et un prompt efficace peut representer un facteur 2 a 3 sur la qualite du code produit.

#### Specifique vs vague : exemples concrets

| Vague (a eviter) | Specifique (preferer) |
|------------------|-----------------------|
| "Fix this bug" | "Fix the null pointer exception in `getUserById` when the user ID doesn't exist in the database" |
| "Make it better" | "Reduce the time complexity from O(n^2) to O(n log n) by replacing the nested loop with a hash map lookup" |
| "Add error handling" | "Add try/catch for network errors in `fetchUser` with retry logic: 3 attempts, exponential backoff (1s, 2s, 4s), log each retry at warn level" |
| "Add tests" | "Add unit tests for `calculateDiscount` covering: empty cart, single item, multiple items, expired discount code, and negative quantities" |
| "Refactor this" | "Extract the email validation logic into a separate `EmailValidator` class with `isValid(email)` and `normalize(email)` methods" |
| "It doesn't work" | "The function returns `undefined` instead of the expected `User` object when I call `getUserById(123)`. Error log: [log]" |

#### Le contexte compte : donner suffisamment d'informations

Claude Code n'a pas de memoire entre les sessions (sauf ce qui est dans `~/.claude/memory/`). Chaque session repart du contexte du fichier CLAUDE.md et des fichiers ouverts. Donnez le contexte explicitement :

```
"Avant de faire des changements :
1. Lis src/services/auth.ts pour comprendre le flux d'authentification actuel
2. Lis src/middleware/authenticate.ts pour voir comment les tokens sont valides
3. Lis src/types/user.ts pour l'interface User

Ensuite, implemente la fonctionnalite de reset de mot de passe
en suivant les patterns existants."
```

Ce pattern Context Loading force Claude a comprendre avant d'agir, ce qui correspond a la phase EXPLORE du workflow.

#### La technique "Grill Me"

Demandez a Claude de vous challenger AVANT de proceder. C'est particulierement utile avant de merger une PR importante ou de deployer en production.

```
"Grill me on these changes and don't make a PR until I pass your test."
```

Claude va alors poser des questions critiques sur votre comprehension, identifier les edge cases que vous n'avez pas anticipes, et s'assurer que vous avez pense aux consequences de vos changements. C'est une revue de code Socratique.

#### La technique "Prove It"

Forcez Claude a justifier ses choix avec des preuves concretes :

```
"Prove to me this works. Show me the diff and explain why it solves
the problem. List the edge cases you've handled and the ones you haven't."
```

Utile pour les changements critiques (securite, performance) et pour comprendre en profondeur le raisonnement derriere une implementation.

#### La technique "Scrap and Redo"

Apres une premiere implementation fonctionnelle, demandez une version plus elegante :

```
"Knowing everything you know now, scrap this and implement the elegant solution."
```

La premiere implementation explore le probleme. La deuxieme beneficie des apprentissages. Le resultat est generalement plus propre, mieux structure, et plus maintenable.

#### Niveaux d'effort : adapter la profondeur de raisonnement

Claude Code supporte 4 niveaux d'effort qui controlent la profondeur du raisonnement :

```bash
/effort low      # Exploration, lecture de fichiers, formatage
/effort medium   # Implementation standard, corrections
/effort high     # Architecture, refactoring complexe
/effort max      # Audit critique, debug complexe (Opus 4.6 uniquement)
```

Guide par phase du workflow :

| Phase | Effort recommande | Raison |
|-------|-------------------|--------|
| `/work:work-explore` | `low` | Lecture seule, pas de raisonnement profond necessaire |
| `/work:work-specify`, `/work:work-plan` | `high` | Decisions d'architecture importantes |
| `/dev:dev-tdd` | `medium` | Implementation standard |
| `/qa:qa-audit`, `/qa:qa-security` | `max` | Audit critique (Opus 4.6) |
| `/work:work-commit` | `low` | Operation simple |

L'effort `max` est exclusif au modele Opus 4.6 avec adaptive thinking. Il est inutile de l'utiliser pour reformatter du code ou ecrire un message de commit.

#### Verification explicite : le multiplicateur de qualite

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." -- Boris Cherny

Ajoutez toujours une etape de verification explicite dans vos prompts :

```
"Apres l'implementation :
1. Lance npm test et montre-moi les resultats
2. Lance npm run lint et corrige les warnings
3. Explique ce qui pourrait mal se passer en production
4. Liste les edge cases traites et ceux non traites"
```

#### Exercice 3.4

Prenez ces 3 prompts mediocres et reformulez-les en prompts efficaces :

1. "Ajoute la pagination"
2. "Le login ne marche pas"
3. "Optimise les performances"

Pour chaque prompt, precisez : le fichier concerne, le comportement actuel, le comportement attendu, les contraintes techniques, et les cas limites a couvrir.

---

### 3.5 Parallelisme et sessions

> "The single biggest productivity unlock." -- Boris Cherny

Travailler sur une seule feature a la fois avec une seule session Claude Code est la facon la plus lente de developper. Les git worktrees permettent de faire tourner 5+ sessions en parallele sur des branches isolees.

#### Git worktrees pour le travail parallele

Un worktree est une copie de travail du depot dans un repertoire different, sur une branche differente. Chaque worktree a son propre index git, mais partage l'historique.

```bash
# Creer un worktree pour une feature
git worktree add ../monapp-auth -b feature/auth

# Ouvrir une session Claude Code dans ce worktree
cd ../monapp-auth && claude --name "auth-feature"

# Pendant ce temps, dans le repertoire principal
cd monapp && claude --name "main-session"
```

L'option `--name` (ou `-n`) nomme la session pour la retrouver facilement. Combine avec les worktrees, chaque session est isolee et identifiable.

Structure typique avec 3 features en parallele :

```
monapp/           <- Session principale (revue, merge)
monapp-auth/      <- Session "auth-feature" (feature/auth)
monapp-payment/   <- Session "payment-feature" (feature/payment)
monapp-perf/      <- Session "perf-fixes" (fix/performance)
```

```bash
# Lister les worktrees actifs
git worktree list

# Supprimer un worktree apres merge
git worktree remove ../monapp-auth
```

#### Gestion du contexte : /compact vs /clear

Le contexte d'une session Claude Code grossit au fil des echanges. Deux commandes permettent de le gerer :

| Commande | Effet | Quand utiliser |
|----------|-------|----------------|
| `/compact` | Resume le contexte, conserve l'essentiel | Entre phases longues du workflow |
| `/clear` | Efface tout le contexte | Changement de sujet complet, nouvelle tache sans rapport |

La regle : preferer `/compact` a `/clear`. La compaction conserve les decisions d'architecture, les conventions apprises, et les contextes importants. `/clear` efface tout et vous repartez de zero.

Moments recommandes pour `/compact` :
- Apres une exploration longue (`/work:work-explore`), avant de passer au plan
- Apres un plan detaille, avant de commencer le TDD
- Apres un cycle TDD long, avant l'audit

#### Recuperation rapide avec /rewind

Claude Code sauvegarde automatiquement l'etat du code (checkpoint) avant chaque modification. Si un refactoring casse tout :

```bash
/rewind          # Choisir un checkpoint dans l'historique
Esc x2           # Annuler la derniere modification uniquement
```

C'est plus rapide que `git stash` ou `git checkout` pour les erreurs recentes. Recommande en phase REFACTOR du TDD : si les tests se cassent apres un refactoring, `/rewind` ramene a l'etat GREEN precedent en une commande.

#### Handoff entre sessions

Quand vous fermez une session et en ouvrez une nouvelle sur la meme feature, le contexte est perdu. Pour faciliter le handoff :

1. Terminez toujours par un commit avec un message descriptif
2. Laissez un commentaire `TODO` ou une note dans le fichier de spec si le travail est incomplet
3. La memoire automatique (`~/.claude/memory/`) conserve les preferences et decisions d'architecture entre sessions -- elle est consultee automatiquement

```bash
# Bonne pratique : commiter avant de fermer
git commit -m "feat(auth): implement login flow - WIP: session refresh pending"
```

#### Exercice 3.5

1. Creez deux worktrees a partir de votre projet : `feature/widget-a` et `feature/widget-b`
2. Ouvrez une session Claude nommee dans chaque worktree
3. Dans chaque session, lancez une implementation differente
4. Observez que les deux branches avancent independamment
5. Fusionnez les deux features dans main

---

### 3.6 Workflows raccourcis

Le workflow complet Explore → Specify → Plan → TDD → Audit → Commit est la reference. Mais tous les changements ne justifient pas 6 etapes. claude-socle fournit des raccourcis adaptes a la complexite de chaque situation.

#### `/work:work-quick` pour les changements triviaux

`/work:work-quick` saute le cycle complet pour les changements mineurs. Il est strict sur les criteres d'eligibilite.

Criteres d'eligibilite (TOUS doivent etre satisfaits) :

| Critere | Seuil |
|---------|-------|
| Fichiers modifies | 1 a 3 maximum |
| Lignes changees | Moins de 50 lignes |
| Impact | Aucun changement d'API publique |
| Risque | Aucun risque de regression |
| Tests existants | Passent deja |

```bash
/work:work-quick "Corriger la typo dans le message d'erreur de login"
/work:work-quick "Renommer la variable userList en users dans ProfilePage"
/work:work-quick "Mettre a jour la version de react-query dans package.json"
```

Si pendant l'execution les criteres ne sont plus respectes (le changement est plus impactant que prevu), `/work:work-quick` s'arrete et recommande de basculer sur `/dev:dev-tdd`.

NON eligibles a work-quick : nouvelle feature, refactoring, correction de bug logique, changement d'interface, nouveau fichier (sauf fichier de test).

#### `/work:work-batch` pour les backlogs de stories

`/work:work-batch` execute sequentiellement un backlog de user stories depuis un fichier PRD, avec TDD et commit atomique par story.

Format du fichier PRD :

```json
{
  "project": "mon-app",
  "stories": [
    {
      "id": "US-001",
      "title": "Validation email a la creation",
      "description": "L'email doit etre valide et unique",
      "priority": "P1",
      "acceptance_criteria": [
        "Given un email invalide, When je cree un utilisateur, Then une erreur est retournee",
        "Given un email deja utilise, When je cree un utilisateur, Then une erreur de doublon est retournee"
      ],
      "files": ["src/services/user.service.ts", "src/services/user.service.spec.ts"]
    },
    {
      "id": "US-002",
      "title": "Hash du mot de passe",
      "priority": "P1",
      "description": "Les mots de passe doivent etre stockes en bcrypt",
      "acceptance_criteria": [
        "Given un mot de passe en clair, When je cree un utilisateur, Then le mot de passe est stocke hache"
      ],
      "files": ["src/services/user.service.ts"]
    }
  ]
}
```

```bash
/work:work-batch "specs/user-features.json"
```

Claude va traiter les stories dans l'ordre P1 → P2 → P3, appliquer TDD sur chacune, et commiter avec `feat(scope): US-XXX description`. La progression est sauvegardee dans `.claude/output/batch/progress.json` -- si la session est interrompue, la reprise repart de la derniere story incomplete.

Garde-fous :
- Maximum 10 stories par batch (au-dela, decouper)
- Arret si 2 stories consecutives echouent
- Jamais de commit sans tests qui passent

#### `/work:work-flow-feature` vs workflow manuel

`/work:work-flow-feature` est le workflow complet en une seule commande. Il enchaine automatiquement : `work-explore` → `work-specify` → `work-plan` → `dev-tdd` → `qa-loop` → `work-pr`.

```bash
# Workflow automatise
/work:work-flow-feature "Systeme de notifications push avec preferences utilisateur"

# Workflow manuel equivalent
/work:work-explore
/work:work-specify
/work:work-plan
/dev:dev-tdd
/qa:qa-loop "score 90"
/work:work-pr
```

Quand choisir le workflow manuel :
- Quand vous voulez valider le plan avant de coder (le workflow automatise peut enchainer sans pause)
- Quand une etape specifique necessite votre attention
- Pour l'apprentissage (comprendre ce que chaque etape fait)

Quand utiliser le workflow automatise :
- Features bien definies dans les specs
- Apres maitrise du workflow manuel
- Pour le travail en lots avec `/work:work-batch`

#### Quand sauter des etapes (et quand ne pas le faire)

| Situation | Etapes a sauter | Etapes obligatoires |
|-----------|----------------|---------------------|
| Typo / rename | Tout sauf fix + verify | Verification que les tests passent |
| Bugfix simple | Explore, Specify | TDD (test de non-regression), Audit rapide |
| Feature simple (< 100 lignes) | Specify | Explore, Plan, TDD, Audit |
| Feature complexe | Rien | Tout le workflow |
| Hotfix production | Plan | Explore, TDD, Audit minimal, Commit |

Regles absolues independantes du contexte :
- Ne jamais commiter sans que les tests passent
- Ne jamais modifier `main` directement (sauf hotfix approuve)
- Ne jamais sauter l'audit pour du code critique (auth, paiement, donnees sensibles)

#### Matrice de choix rapide

```
Le changement touche combien de fichiers ?
      |
      v
   1-3 fichiers, < 50 lignes, pas d'API publique
      |                    |
     Oui                  Non
      |                    |
      v                    v
/work:work-quick    C'est une feature complete ?
                          |               |
                         Oui             Non (bug)
                          |               |
                          v               v
                   Backlog ?       /work:work-flow-bugfix
                    |       |
                   Oui     Non
                    |       |
                    v       v
             /work:work-batch  /work:work-flow-feature
                               (ou workflow manuel)
```

---

### Bilan du Niveau 3

Vous avez maintenant les outils pour travailler avec Claude Code de maniere professionnelle :

- **TDD** : ecrire les tests avant le code, cycle Red-Green-Refactor avec `/dev:dev-tdd`
- **Audits** : `/qa:qa-loop` pour atteindre automatiquement le score cible avant chaque merge
- **Hooks** : comprendre l'automatisation invisible qui garantit la qualite a chaque modification
- **Prompting** : formuler des prompts precis qui multiplient la qualite des resultats
- **Parallelisme** : git worktrees + sessions nommees pour travailler sur plusieurs features simultanement
- **Raccourcis** : choisir le workflow adapte a la complexite du changement

Le Niveau 4 (Maitrise) couvre les patterns avances : agents en equipe, configuration fine des hooks, workflows custom, et integration dans un environnement d'equipe.

## Niveau 4 : Maitrise (3h)

A ce stade, vous utilisez Claude Code avec aisance. Il est temps de sortir du mode consommateur pour passer au mode producteur : creer vos propres briques, adapter le socle a votre contexte, et automatiser votre environnement de travail.

---

### 4.1 Creer ses propres skills

Un **skill** est un bloc d'instructions specialise que Claude Code peut declencher automatiquement selon le contexte, ou que vous appelez manuellement. Contrairement aux commandes, un skill s'execute dans un contexte isole (`fork`) et peut etre lie a un agent ou appele depuis plusieurs commandes.

#### Structure d'un fichier SKILL.md

Chaque skill est un fichier `SKILL.md` dans `.claude/skills/[nom-du-skill]/` avec un frontmatter YAML obligatoire :

```yaml
---
name: mon-skill
description: Analyse et optimise les requetes SQL lentes. Declencher quand
  l'utilisateur mentionne des requetes lentes, N+1, ou veut optimiser une DB.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
context: fork
model: sonnet
argument-hint: "[fichier-ou-description]"
---
```

Les champs cles du frontmatter :

| Champ | Description | Exemple |
|-------|-------------|---------|
| `name` | Identifiant unique du skill | `sql-optimizer` |
| `description` | Description + mots-cles de declenchement automatique | Voir ci-dessus |
| `allowed-tools` | Outils autorises (principe du moindre privilege) | `Read, Grep, Bash` |
| `context` | `fork` (isole, recommande) ou `shared` (contexte principal) | `fork` |
| `model` | Modele prefere pour ce skill | `haiku`, `sonnet`, `opus` |
| `argument-hint` | Indication affichee a l'utilisateur sur les arguments attendus | `"[description]"` |
| `disable-model-invocation` | Empeche le declenchement automatique | `true` |
| `user-invocable` | Rend le skill invisible a l'utilisateur direct | `false` |

#### Le declenchement automatique

Le champ `description` joue un double role : documenter le skill ET servir de base pour le declenchement automatique. Claude Code analyse les mots-cles de la description pour savoir quand proposer le skill. Par exemple, le skill `dev-tdd` du socle se declenche automatiquement quand vous mentionnez "TDD", "test first", "ecrire les tests", ou demandez d'implementer une nouvelle fonctionnalite.

Exemples de mots-cles efficaces dans une description :

```yaml
description: Optimisation des performances React. Declencher automatiquement
  quand l'utilisateur mentionne "re-render", "memo", "React perf", "useMemo",
  "useCallback", ou veut optimiser un composant React.
```

#### Sous-repertoires examples/ et references/

Pour les skills complexes, deporter le contenu detaille dans des sous-fichiers :

```
.claude/skills/mon-skill/
  SKILL.md          # Instructions principales (< 500 lignes)
  examples/
    exemple-simple.md
    exemple-avance.md
  references/
    checklists.md
    patterns.md
```

Le fichier `SKILL.md` reste concis et fait reference aux sous-fichiers. Cela evite de depasser le budget de 15 000 caracteres (`SLASH_COMMAND_TOOL_CHAR_BUDGET`).

#### Variables disponibles dans un skill

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | Tous les arguments passes au skill |
| `$ARGUMENTS[0]` | Premier argument |
| `$1`, `$2` | Raccourcis pour les arguments |
| `${CLAUDE_SESSION_ID}` | ID de la session en cours |

#### Dynamic context injection

Injecter du contenu dynamique au moment de l'execution avec la syntaxe `` !`commande` `` :

```markdown
## Contexte du projet

Scripts disponibles :
!`cat package.json | jq .scripts`

Version actuelle :
!`cat VERSION 2>/dev/null || echo "inconnue"`
```

#### Exercice : creer un skill pour votre projet

Creez `.claude/skills/mon-deploy-check/SKILL.md` qui verifie les preconditions avant un deploiement (tests passent, pas de `console.log`, variables d'environnement presentes). Declenchez-le avec les mots "deployer", "mise en production", "release".

---

### 4.2 Creer ses propres agents

Un **agent** est une instance Claude Code separee avec ses propres outils, son propre modele, et ses propres permissions. Il s'execute de facon isolee et ne peut acceder qu'aux outils que vous lui autorisez explicitement.

#### Structure d'un fichier agent

Les agents sont des fichiers `.md` dans `.claude/agents/` avec un frontmatter YAML :

```yaml
---
name: mon-agent-audit
description: Audit specialise de conformite RGPD. Analyse le code pour
  detecter les violations de confidentialite et proposer des corrections.
tools: Read, Grep, Glob
model: sonnet
permissionMode: default
skills:
  - qa-security
  - legal-rgpd
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo '[AUDIT-RGPD] Analyse en cours...'"
          timeout: 5000
---
```

Champs du frontmatter agent :

| Champ | Description | Valeurs |
|-------|-------------|---------|
| `name` | Identifiant de l'agent | kebab-case |
| `description` | Description + declenchement auto | Texte libre |
| `tools` | Outils autorises (virgule separee) | `Read, Grep, Glob, Bash` |
| `model` | Modele a utiliser | `haiku`, `sonnet`, `opus` |
| `permissionMode` | Niveau de permissions | `default`, `acceptEdits` |
| `disallowedTools` | Outils explicitement interdits | `Bash, Write` |
| `skills` | Skills a charger pour cet agent | Liste de noms |

Voici la structure de l'agent `dev-debug` du socle a titre d'exemple reel :

```yaml
---
name: dev-debug
description: Diagnostic et investigation de bugs.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
skills:
  - dev-debug
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo '[DEV-DEBUG] Investigation en cours...'"
          timeout: 5000
---
```

Le corps du fichier agent doit etre minimal (30-55 lignes) : il orchestre, le skill fournit le detail. C'est le pattern agent/skill du socle.

#### Choisir le bon modele pour un agent

| Modele | Cas d'usage agent | Nombre dans le socle |
|--------|-------------------|---------------------|
| `haiku` | Exploration, documentation, generation standard, audits simples | 26 agents |
| `sonnet` | Debug complexe, securite, architecture, integration | 30 agents |
| `opus` | Reserve aux taches critiques avec `/effort max` | Sur demande |

Regle pratique : si l'agent lit sans modifier, utilisez `haiku`. S'il analyse pour proposer des corrections ou des decisions architecturales, utilisez `sonnet`.

#### Lier un agent a des skills

La propriete `skills` dans le frontmatter d'un agent charge automatiquement les instructions du skill dans le contexte de l'agent. Un agent peut charger plusieurs skills :

```yaml
skills:
  - qa-security
  - qa-perf
  - legal-rgpd
```

#### Hooks dans le frontmatter agent

Les hooks declares dans le frontmatter d'un agent s'appliquent uniquement pendant l'execution de cet agent. C'est distinct des hooks globaux dans `settings.json`.

#### Exercice : creer un agent d'audit specialise

Creez `.claude/agents/qa-rgpd.md` avec les outils `Read, Grep, Glob` (pas de `Bash`, pas de `Write`), le modele `haiku`, lie au skill `legal-rgpd` existant. Le description doit mentionner "RGPD", "GDPR", "confidentialite", "donnees personnelles" pour le declenchement automatique.

---

### 4.3 Creer ses propres rules

Les **rules** sont des instructions de code qui s'activent automatiquement quand un fichier correspondant aux chemins declares est modifie. Elles definissent les conventions specifiques a un langage, un framework, ou votre domaine metier.

#### Structure d'une rule

Les rules sont des fichiers `.md` dans `.claude/rules/` avec un frontmatter `paths` :

```yaml
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
---

# TypeScript Rules

## Strict Mode

- IMPORTANT: Mode strict active (`"strict": true`)
- IMPORTANT: Pas de `any` sauf cas exceptionnels documentes
- YOU MUST definir des interfaces pour les objets complexes
```

Le frontmatter `paths` accepte des patterns glob. Une rule sans `paths` s'applique a tous les fichiers (rule globale). Voir `.claude/rules/git.md` et `.claude/rules/workflow.md` dans le socle : ce sont des rules globales sans paths.

#### Patterns de paths efficaces

| Pattern | Cible |
|---------|-------|
| `**/*.ts` | Tous les fichiers TypeScript |
| `**/api/**` | Tout sous-dossier `api/` |
| `**/components/**` | Composants React |
| `**/auth/**` | Code d'authentification |
| `**/migrations/**` | Fichiers de migration DB |
| `**/docker-compose*` | Fichiers Docker Compose |

#### Systeme de priorite

Quand plusieurs rules correspondent au meme fichier, elles s'appliquent toutes simultanement selon cet ordre de priorite :

| Priorite | Rule | Raison |
|----------|------|--------|
| 1 (max) | `security` | La securite prime sur tout |
| 2 | `verification` | Validation obligatoire avant completion |
| 3 | `tdd-enforcement` | TDD obligatoire |
| 4 | Langage (`typescript`, `python`...) | Conventions de langage |
| 5 | Framework (`react`, `nextjs`...) | Conventions de framework |
| 6 | `testing` | Normes de tests |
| 7 | `performance`, `accessibility` | Optimisations |

Exemple : modifier `src/components/Button.tsx` active simultanement `typescript`, `react`, `accessibility`, `performance`, `verification`, et `tdd-enforcement`.

#### Ecrire des directives efficaces

Claude Code accorde plus d'attention a certains mots-cles dans les rules :

| Mot-cle | Poids | Usage |
|---------|-------|-------|
| `IMPORTANT:` | Eleve | Regles critiques a respecter |
| `YOU MUST` | Tres eleve | Obligation absolue |
| `NEVER` | Tres eleve | Interdiction |
| `ALWAYS` | Eleve | A faire systematiquement |
| `WARNING:` | Moyen | Point d'attention |

Utilisez des tables pour les conventions : elles sont plus lisibles que des listes a puces et prennent moins de tokens.

#### Exercice : creer une rule projet

Creez `.claude/rules/api-conventions.md` avec les paths `**/api/**` et `**/routes/**`. Definissez vos conventions d'API : format des reponses d'erreur, validation des inputs, codes HTTP utilises, nommage des endpoints.

---

### 4.4 Personnaliser les hooks

Les hooks permettent d'automatiser des actions avant ou apres chaque operation de Claude Code. Le socle inclut 25+ hooks preconfigures ; vous pouvez en ajouter ou modifier leur comportement.

#### Anatomie d'un hook dans settings.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "description": "Notification Slack apres chaque commit",
        "matcher": "Bash(git commit:*)",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'curl -s -X POST $SLACK_WEBHOOK -d \"{\\\"text\\\":\\\"Commit effectue dans $(basename $PWD)\\\"}\"'",
            "async": true,
            "onFailure": "ignore",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

#### Types de hooks

| Type | Description | Cas d'usage |
|------|-------------|-------------|
| `command` | Execute un script bash | Formatage, validation, notification |
| `prompt` | Evalue via un LLM Haiku | Decisions contextuelles intelligentes |
| `http` | Envoie un POST JSON vers une URL | Webhooks, integrations externes |

#### Events disponibles et quand les utiliser

| Event | Declencheur | Usage typique |
|-------|-------------|---------------|
| `PreToolUse` | Avant un outil | Validation, protection, securite |
| `PostToolUse` | Apres un outil | Formatage, type-check, notification |
| `SessionStart` | Demarrage session | Affichage info, verification env |
| `SessionEnd` | Fin de session | Logging, nettoyage |
| `PreCompact` | Avant compaction | Sauvegarde contexte |
| `PostCompact` | Apres compaction | Resume disponible |
| `TeammateIdle` | Agent inactif (teams) | Re-assignation de taches |

#### Le systeme de matchers

Le `matcher` filtre les hooks par outil ou par pattern regex :

```json
"matcher": "Edit|Write"           // Edition ou creation de fichier
"matcher": "Bash"                  // Toute commande bash
"matcher": "Bash(git commit:*)"    // Uniquement git commit
"matcher": "Bash(npm run:*)"       // Toute commande npm run
```

#### onFailure : bloquer ou ignorer

| onFailure | Effet | Quand l'utiliser |
|-----------|-------|------------------|
| `"block"` | Bloque l'action si le hook echoue | Securite, validation critique |
| `"ignore"` | Continue meme si le hook echoue | Logging, notification |
| (absent) | Continue par defaut | Actions non-critiques |

IMPORTANT : les hooks de securite (gitleaks, protection main, tests pre-commit) doivent utiliser `"onFailure": "block"`. Les hooks de logging et notification doivent utiliser `"async": true` et `"onFailure": "ignore"`.

#### Hooks asynchrones

La propriete `"async": true` execute le hook en arriere-plan sans bloquer Claude Code :

```json
{
  "type": "command",
  "command": "bash -c 'echo \"$(date) - Session terminee\" >> /tmp/claude-sessions.log'",
  "async": true,
  "onFailure": "ignore"
}
```

Regle : securite = synchrone, logging/notification = asynchrone.

#### Variables d'environnement de controle

Le socle expose des variables pour desactiver les hooks si necessaire :

| Variable | Hook desactive |
|----------|----------------|
| `ALLOW_MAIN_EDIT=1` | Protection branche main |
| `SKIP_PRE_COMMIT_TESTS=1` | Tests avant commit |
| `SKIP_COMMAND_VALIDATOR=1` | Validation securite des commandes |
| `SKIP_PRE_PUSH_CI=1` | CI locale avant push |
| `SKIP_DESTRUCTIVE_CHECK=1` | Protection operations destructives |
| `ENABLE_RTK=1` | Activer l'optimisation tokens RTK |

Configurez ces variables dans `settings.local.json` (gitignore) pour votre environnement personnel.

#### Exercice : ajouter un hook personnalise

Ajoutez un hook `PostToolUse` qui verifie automatiquement la couverture de tests apres chaque modification d'un fichier source (non-test). Il doit afficher un warning si la couverture tombe sous 80% mais ne pas bloquer.

---

### 4.5 MCP Servers

Le **Model Context Protocol (MCP)** permet a Claude Code d'interagir avec des services externes : bases de donnees, APIs, outils de gestion de projet. C'est une extension du contexte disponible pour Claude.

#### Configuration dans .mcp.json

Tous les serveurs MCP sont definis dans `.mcp.json` a la racine du projet. Dans le socle, tous sont desactives par defaut (`"enabled": false`) par securite :

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      },
      "description": "Integration GitHub (issues, PRs, repos)",
      "enabled": false
    }
  }
}
```

Pour activer un serveur, passez `"enabled": true` et configurez les variables d'environnement dans votre `.env` (jamais dans `.mcp.json` directement).

#### Serveurs disponibles dans le socle

| Serveur | Usage | Token env |
|---------|-------|-----------|
| `filesystem` | Acces avance au systeme de fichiers | - |
| `memory` | Memoire persistante entre sessions | - |
| `fetch` | Requetes HTTP vers APIs externes | - |
| `github` | Issues, PRs, repos GitHub | `GITHUB_TOKEN` |
| `postgres` | Requetes et migrations PostgreSQL | `DATABASE_URL` |
| `sqlite` | Base SQLite locale | - |
| `puppeteer` | Browser automation, screenshots | - |
| `slack` | Recherche de bugs, threads equipe | `SLACK_BOT_TOKEN` |
| `sentry` | Analyse d'erreurs et monitoring | `SENTRY_AUTH_TOKEN` |
| `bigquery` | Requetes analytics directes | `GOOGLE_APPLICATION_CREDENTIALS` |
| `linear` | Gestion de projet et issues | `LINEAR_API_KEY` |
| `notion` | Documentation et bases de connaissances | `NOTION_API_KEY` |

Boris Cherny recommande particulierement Slack, Sentry et BigQuery pour eliminer les allers-retours manuels entre Claude Code et ces outils.

#### MCP Channels (Research Preview)

Avec `claude --channels`, les serveurs compatibles (Slack, Sentry, Linear) peuvent pousser des messages dans votre session en temps reel : alerte Sentry pendant le dev, message Slack d'un collegue, mise a jour Linear.

#### Considerations de securite

- NEVER mettre des credentials directement dans `.mcp.json`
- Utiliser `${VARIABLE}` pour referencer les variables d'environnement
- Ajouter `.env` a `.gitignore`
- Activer uniquement les serveurs dont vous avez besoin
- Le fichier `.mcp.json` est versionne dans git : verifier son contenu avant chaque commit

#### Exercice : configurer et utiliser un serveur MCP

Activez le serveur `github` dans `.mcp.json`. Configurez `GITHUB_TOKEN` dans votre `.env`. Testez en demandant a Claude Code de lister les issues ouvertes de votre repository.

---

### 4.6 Output Styles

Les **Output Styles** permettent d'adapter le format des reponses de Claude Code a votre contexte : apprentissage, revue de code, production d'un rapport, debugging.

#### Les 10 styles disponibles

| Style | Commande | Cas d'usage |
|-------|----------|-------------|
| `teaching` | `/output-style teaching` | Apprentissage, formation, onboarding |
| `explanatory` | `/output-style explanatory` | Comprendre le pourquoi, debug approfondi |
| `concise` | `/output-style concise` | Dev experimente, fix rapide |
| `technical` | `/output-style technical` | Architecture, decisions techniques |
| `review` | `/output-style review` | Code review, PR, audits |
| `emoji` | `/output-style emoji` | Presentations, documentation client |
| `minimal` | `/output-style minimal` | Terminal, logs, CI/CD |
| `structured` | `/output-style structured` | Rapports, analyses formelles |
| `debug` | `/output-style debug` | Debugging methodique |
| `metrics` | `/output-style metrics` | Performance, benchmarks |

Le style `explanatory` est recommande par Boris Cherny pour les phases d'apprentissage : il force Claude a expliquer le raisonnement derriere chaque decision.

#### Creer un style projet specifique

Creez `.claude/output-styles/mon-style.md` :

```markdown
---
name: Mon Style Equipe
description: Format standardise pour les rapports d'equipe
keep-coding-instructions: true
---

# Style Rapport Equipe

## Principes
- Toujours commencer par un resume executif en 3 lignes
- Utiliser des tableaux pour les comparaisons
- Terminer par les actions concretes recommandees

## Format
[Description du format avec exemples]
```

Activez avec `/output-style mon-style`.

---

## Niveau 5 : Expert (2h)

Ce niveau s'adresse aux utilisateurs qui veulent comprendre les decisions d'architecture du socle, optimiser leurs couts, maitriser les fonctionnalites experimentales, et contribuer au projet.

---

### 5.1 Decisions d'architecture

#### Pourquoi claude-socle est concu ainsi

Le socle repond a un probleme concret : par defaut, Claude Code demarre sans contexte, sans conventions, et sans workflow. Chaque session repart de zero. Le socle resout cela en fournissant une configuration complete et maintenable.

Les trois contraintes de conception :

1. **Minimalisme du contexte de base** : le fichier `CLAUDE.md` ne charge que 175 lignes par session (avant optimisation : 1 322 lignes). Tout le reste est charge a la demande via `@imports`.

2. **Modularite** : chaque brique (commande, agent, skill, rule, hook) est independante et remplacable. Vous pouvez supprimer tous les agents `growth-*` si vous n'en avez pas besoin.

3. **Securite par defaut** : `.mcp.json` desactive tout, les hooks bloquent le `git push --force`, la detection de secrets est activee sur chaque ecriture.

#### Commands vs Agents vs Skills : principes de conception

| Concept | Contexte | Outils | Declenchement | Quand l'utiliser |
|---------|----------|--------|---------------|------------------|
| **Command** | Partage | Tous | Manuel (`/cmd`) | Workflow interactif, modifications directes |
| **Agent** | Isole | Restreints | Automatique ou manuel | Analyse, tache repetitive, isolation |
| **Skill** | Fork ou partage | Definis | Automatique | Instructions specialisees, contenu detaille |

Un agent doit avoir un corps minimal (30-55 lignes) et deleguer au skill. Un skill peut aller jusqu'a 500 lignes mais doit deporter le contenu volumineux dans `examples/` et `references/`.

#### Le ratio et son importance

Le socle contient actuellement : 126 commandes, 62 skills, 44 agents, 24 rules (chiffres indicatifs, verifier avec `docs/reference/`). Ce ratio reflecte une philosophie : les commandes sont le point d'entree principal, les agents sont specialises et contraints, les skills fournissent la substance.

#### CLAUDE.md et les @imports

Le `CLAUDE.md` du socle n'inclut que deux imports toujours charges :

```
@docs/reference/best-practices.md
@docs/reference/project-structures.md
```

Les autres references (commands, agents-catalog, hooks, skills, advanced-features) sont documentees dans le tableau `## Documentation et References` mais ne sont PAS auto-importees. Claude les lit a la demande. Cette distinction est fondamentale pour maitriser les couts.

Pour voir les imports actifs dans une session : `/memory`.

---

### 5.2 Optimisation des tokens

Les tokens sont la principale source de cout avec Claude Code. L'optimisation a deux dimensions : reduire la consommation par session, et choisir le bon modele pour chaque tache.

#### Comprendre la consommation

Chaque session Claude Code consomme des tokens pour :
- Le contexte initial (CLAUDE.md + imports + rules actives)
- Chaque echange (prompt + reponse)
- Les lectures de fichiers (chaque `Read` ajoute des tokens au contexte)
- Les resultats de commandes bash

Le contexte grossit au fil de la session et ne diminue jamais (sauf avec `/compact` ou `/clear`).

#### RTK : reduction de 60-90% sur les sorties de commandes

[RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) est un proxy CLI qui compresse les sorties de commandes avant qu'elles n'atteignent le contexte LLM.

Installation :
```bash
brew install rtk
# ou
cargo install --git https://github.com/rtk-ai/rtk
```

Activation dans le socle (desactive par defaut) :

```json
{
  "env": {
    "ENABLE_RTK": "1"
  }
}
```

Le hook `PreToolUse` du socle reecrit automatiquement les commandes si RTK est installe :
- `git status` devient `rtk git status` (~10 tokens au lieu de ~200)
- `cargo test` devient `rtk cargo test` (-90% sur les sorties de test)

Commandes de mesure :
```bash
rtk gain       # Voir les economies realisees
rtk discover   # Identifier les commandes non optimisees
```

#### Strategies /compact et /clear

| Commande | Effet | Quand utiliser |
|----------|-------|----------------|
| `/compact` | Resume le contexte, conserve les decisions et conventions | Entre phases longues (Explore → Plan → TDD) |
| `/clear` | Efface tout le contexte | Changement de sujet complet, nouvelle tache sans rapport |

Preferer `/compact` a `/clear` : la compaction conserve l'essentiel (decisions prises, patterns detectes) tandis que `/clear` efface tout et fait recommencer de zero.

#### Effort levels pour la gestion des couts

| Niveau | Commande | Tokens approximatifs | Quand |
|--------|----------|---------------------|-------|
| `low` | `/effort low` | Minimum | Exploration, lecture, commits |
| `medium` | `/effort medium` | Standard | Dev standard, corrections |
| `high` | `/effort high` | Eleve | Architecture, refactoring |
| `max` | `/effort max` | Maximum (Opus 4.6 requis) | Audit critique, debug complexe |

#### Choisir le bon modele

| Modele | Usage optimal | Impact cout |
|--------|---------------|-------------|
| Haiku | Taches simples, generation standard, documentation | Tres faible |
| Sonnet | Analyse, debug, decisions | Moyen |
| Opus 4.6 | Audit critique, architecture complexe, `/effort max` | Eleve |

Bonne pratique : utilisez Haiku pour les 70% de taches routinieres (generation de tests, documentation, composants standard), Sonnet pour les 25% qui demandent du raisonnement, et reservez Opus pour les 5% critiques.

#### Mesurer ses couts

```bash
/ops:ops-cost    # Rapport de consommation tokens de la session
ccusage          # Historique de consommation (outil CLI externe)
```

---

### 5.3 Equipes d'agents (Agent Teams)

Agent Teams est une fonctionnalite experimentale qui permet de coordonner plusieurs instances Claude Code travaillant en parallele, avec communication inter-agents.

#### Activation

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Prerequis : Claude Code >= 2.1.19, et optionnellement `tmux` pour le mode split-panes.

#### Modes de fonctionnement

| Mode | Description | Quand |
|------|-------------|-------|
| `auto` (defaut) | Choix automatique selon la tache | Usage standard |
| `in-process` | Agents dans le meme processus | Dev local, debugging |
| `tmux` | Agents dans des panes tmux separes | Visualisation, travail long |

#### Utilisation

```bash
/work:work-team "Implementer l'authentification JWT :
- Agent 1 : routes API (POST /auth/login, POST /auth/refresh)
- Agent 2 : middleware de validation
- Agent 3 : tests d'integration"
```

#### Communication inter-agents

Les agents d'une meme equipe peuvent s'envoyer des messages via le hook `TeammateIdle`. Quand un agent finit sa tache et devient inactif, l'orchestrateur peut lui assigner une nouvelle tache ou consolider les resultats.

#### Quand les equipes aident vs quand elles nuisent

Agent Teams est benefique pour :
- Taches parallelisables independantes (frontend + backend + tests en parallele)
- Revues croisees (un agent code, un autre critique)
- Traitements par lots (analyser 20 fichiers simultanement)

Agent Teams nuit si :
- Les taches sont sequentielles et dependantes
- Le cout de coordination depasse le gain en parallelisme
- La tache est simple et rapide (overhead non justifie)

Pour les taches parallelisables sans communication entre agents, preferer les sous-agents classiques via le skill `parallel-agents` ou `git-worktrees`.

---

### 5.4 Workflows automatises complets

Le socle fournit des commandes de workflow qui enchainent automatiquement plusieurs phases du cycle Explore → Specify → Plan → TDD → Audit → Commit.

#### /work:work-flow-feature de bout en bout

```bash
/work:work-flow-feature "Ajouter un systeme de notifications push"
```

Ce workflow execute automatiquement :
1. Exploration du code existant (work-explore)
2. Creation de la specification (work-specify)
3. Planification (work-plan, avec validation avant de coder)
4. TDD (dev-tdd, cycle Red-Green-Refactor)
5. Audit qualite (qa-loop "score 90")
6. Commit et PR (work-pr)

#### /work:work-flow-bugfix

```bash
/work:work-flow-bugfix "Erreur 500 sur /api/users quand l'email contient des majuscules"
```

Pipeline : debug (dev-debug) → test de non-regression (dev-test) → fix → audit rapide (qa-review) → commit (work-commit avec reference issue).

#### /work:work-flow-release

```bash
/work:work-flow-release "v2.1.0"
```

Gere le versioning semantique, la mise a jour du CHANGELOG, les tags git, et la creation de la release GitHub. Inclut une verification que tous les tests passent avant de tagger.

#### /work:work-batch

```bash
/work:work-batch "backlog.json"
```

Traite un backlog de User Stories en lot. Chaque story passe par le workflow complet. Utile pour les sprints avec de nombreuses petites taches.

#### Construire un workflow personnalise

Creez `.claude/commands/mon-workflow.md` en enchainant les instructions :

```markdown
# Workflow Mon Projet

Workflow personnalise pour les features du projet X.

## Etapes

1. Explorer le code avec focus sur $ARGUMENTS
2. Verifier les conventions dans `docs/conventions.md`
3. Implementer en TDD avec couverture minimum 85%
4. Verifier la conformite RGPD si traitement de donnees personnelles
5. Creer la PR avec le template de l'equipe

IMPORTANT: Ne jamais skipper l'etape RGPD pour les features de profil utilisateur.
```

---

### 5.5 Contribuer au socle

#### Comprendre le systeme de validation

Le script `scripts/validate.sh` verifie l'integrite de la configuration. Il valide :
- La presence des fichiers obligatoires
- Le format des frontmatter YAML
- La coherence des comptes (commandes, agents, skills)
- La securite de base (pas de secrets dans les fichiers commites)

```bash
./scripts/validate.sh .              # Valider le repertoire courant
./scripts/validate.sh --format json  # Sortie JSON pour CI
./scripts/validate.sh --format score # Sortie score uniquement
```

#### Ajouter une commande

1. Creer `.claude/commands/[categorie]/ma-commande.md`
2. Suivre la structure standard (titre, description, contexte `$ARGUMENTS`, instructions, output attendu)
3. Mettre a jour le compte dans `docs/reference/commands.md`
4. Tester avec `/[categorie]:ma-commande "test"`

#### Ajouter un agent

1. Creer `.claude/agents/mon-agent.md` avec frontmatter complet
2. Garder le corps minimal (30-55 lignes), creer un skill si besoin
3. Choisir `haiku` ou `sonnet` selon la complexite
4. Mettre a jour `docs/reference/agents-catalog.md` et `WHEN-TO-USE-WHICH-AGENT.md`
5. Mettre a jour le compte dans `docs/reference/agents-catalog.md`

#### Ajouter un skill

1. Creer `.claude/skills/mon-skill/SKILL.md`
2. Rester sous 500 lignes ; deporter dans `examples/` si besoin
3. Definir des mots-cles de declenchement precis dans `description`
4. Mettre a jour `docs/reference/skills-catalog.md`

#### Le pipeline CI

Le pipeline CI du socle execute dans l'ordre :
1. **Lint** : shellcheck sur les scripts bash, yamllint sur les fichiers YAML
2. **Security** : gitleaks pour detecter les secrets commites accidentellement
3. **Validate-counts** : verifie que les comptes dans la documentation correspondent aux fichiers reels

Si `validate-counts` echoue, mettez a jour les fichiers de reference avant de pusher.

#### Workflow de contribution

```bash
# 1. Creer une branche
git checkout -b feature/mon-agent-specialise

# 2. Developper en TDD
/dev:dev-tdd "ajouter l'agent mon-agent-specialise"

# 3. Valider
./scripts/validate.sh .

# 4. Audit
/qa:qa-loop "score 90"

# 5. PR
/work:work-pr
```

---

### 5.6 Checklist du Pro

Vous avez parcouru les 5 niveaux. Voici le resume operationnel.

#### Workflow quotidien recommande

**Debut de journee :**
```bash
claude -n "sprint-$(date +%Y%m%d)"  # Session nommee
/ops:ops-health                       # Health check rapide
```

**Nouvelle tache :**
```
1. /work:work-explore    (comprendre avant de toucher)
2. /work:work-specify    (clarifier avant de planner)
3. /work:work-plan       (planner avant de coder)
4. /dev:dev-tdd          (tests avant le code)
5. /qa:qa-loop "score 90"  (auditer avant de commiter)
6. /work:work-pr         (commit + push + PR)
```

**Fin de session :**
```bash
/compact    # Entre phases longues
/clear      # Nouvelle tache sans rapport
```

#### Reglages a configurer une fois

Dans `.claude/settings.local.json` (gitignore, personnel) :

```json
{
  "env": {
    "ENABLE_RTK": "1",
    "SKIP_PRE_PUSH_CI": "0"
  }
}
```

Dans `~/.claude/settings.json` (global, tous projets) :
- Preferences de modele par defaut
- Hooks personnels (notifications, logging)

#### Quand devier du workflow

Le workflow Explore → Specify → Plan → TDD → Audit → Commit est optimal pour les features de taille moyenne. Il existe des exceptions legitimes :

| Situation | Adaptation |
|-----------|------------|
| Fix de typo, correction de commentaire | `/work:work-quick` directement |
| Bug critique en production | `/work:work-flow-bugfix` sans Specify ni Plan |
| Prototype jetable | TDD optionnel, mais audit toujours |
| Refactoring pur (pas de logique) | Pas besoin de Specify, TDD alleges |

La regle fondamentale : ne jamais sauter l'**Audit** avant un commit sur main, et ne jamais coder sans avoir **lu** le code existant d'abord.

#### Amelioration continue

```bash
/qa:qa-kaizen    # Identifie les patterns d'amelioration dans votre workflow
/qa:qa-audit     # Audit complet periodique (securite + RGPD + a11y + perf)
/ops:ops-deps    # Vulnerabilites dans les dependances
```

Revisitez votre `CLAUDE.md` apres chaque sprint : ajoutez les conventions emergentes, les pieges decouverts, les patterns d'equipe. Un bon `CLAUDE.md` est un document vivant qui reflete l'intelligence collective de l'equipe.

#### Les 10 principes du Pro

1. Lire avant d'ecrire (`/work:work-explore` en premier)
2. Specifier avant de planner, planner avant de coder
3. Tests avant le code, toujours (TDD)
4. Donner a Claude un moyen de verifier son travail (hooks, suites de tests)
5. Auditer avant de commiter (`/qa:qa-loop "score 90"`)
6. Commits atomiques : 1 commit = 1 changement logique
7. Ne jamais commiter de secrets (gitleaks est la pour ca)
8. Etre specifique dans les prompts (anti-pattern : "fix this bug")
9. Adapter le modele a la tache (Haiku pour le routinier, Sonnet pour le complexe)
10. Iterer en boucle courte plutot qu'en session geante (max 10 fichiers par session)
