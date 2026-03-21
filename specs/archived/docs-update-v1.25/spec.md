# Specification : Mise a jour Documentation Docusaurus v1.25.0

**Branche**: `feature/docs-update-v1.25`
**Date**: 2026-02-06
**Statut**: Draft

## Resume

La documentation Docusaurus du socle Claude Code est en retard par rapport aux fonctionnalites livrees en v1.25.0. Les utilisateurs ne peuvent pas decouvrir ni comprendre les nouvelles capacites majeures : orchestration d'equipes d'agents, bonnes pratiques du createur de Claude Code, et capacites avancees du modele Opus 4.6. Cette mise a jour vise a combler tous les ecarts identifies pour que la documentation reflète fidelement l'etat actuel du socle.

---

## User Stories (prioritisees)

### US1 - Documenter Agent Teams (Priorite: P1) MVP

**En tant que** utilisateur du socle Claude Code
**Je veux** comprendre comment utiliser les equipes d'agents coordonnees
**Afin de** paralléliser mes taches complexes (audits, features, debug) avec plusieurs agents collaborant ensemble

**Pourquoi P1**: Feature majeure de la v1.25.0, completement absente de la documentation. Les utilisateurs ne peuvent pas decouvrir cette fonctionnalite sans documentation.

**Test independant**: Un nouvel utilisateur peut trouver, comprendre et activer Agent Teams uniquement via la documentation Docusaurus.

**Criteres d'acceptation**:

1. **Etant donne** un utilisateur sur le site de documentation, **Quand** il navigue dans les commandes WORK, **Alors** il trouve la page `/work:work-team` avec ses cas d'usage et exemples
2. **Etant donne** un utilisateur cherchant "agent teams" dans la documentation, **Quand** il consulte la page du skill `agent-teams`, **Alors** il comprend les prerequis, l'activation, les modes d'affichage et les patterns pre-configures
3. **Etant donne** un utilisateur sur la page d'index des skills, **Quand** il consulte la liste, **Alors** le skill `agent-teams` apparait dans le tableau avec sa description
4. **Etant donne** un utilisateur sur la page d'index des commandes WORK, **Quand** il consulte la liste, **Alors** la commande `/work:work-team` apparait avec sa description

---

### US2 - Creer la page Bonnes Pratiques Boris Cherny (Priorite: P1) MVP

**En tant que** utilisateur du socle Claude Code
**Je veux** acceder aux recommandations du createur de Claude Code
**Afin de** maximiser la qualite et la productivite de mon travail avec Claude Code

**Pourquoi P1**: Les bonnes pratiques (verification, prompting avance, sessions paralleles) sont des multiplicateurs de qualite majeurs. Sans cette page, les utilisateurs passent a cote d'optimisations significatives.

**Test independant**: Un utilisateur peut acceder aux recommandations de Boris Cherny depuis la navigation principale et appliquer les techniques decrites.

**Criteres d'acceptation**:

1. **Etant donne** un utilisateur sur le site de documentation, **Quand** il navigue dans les Guides, **Alors** il trouve une page "Bonnes Pratiques (Boris Cherny)" accessible depuis le menu
2. **Etant donne** un utilisateur sur cette page, **Quand** il la lit, **Alors** il trouve les sections : verification comme multiplicateur de qualite, recommandations de modele, techniques de prompting, sessions paralleles, et commande commit-push-pr
3. **Etant donne** un utilisateur cherchant a ameliorer sa productivite, **Quand** il consulte la section sessions paralleles, **Alors** il comprend comment utiliser les git worktrees avec plusieurs sessions Claude

---

### US3 - Documenter les capacites Opus 4.6 (Priorite: P1) MVP

**En tant que** utilisateur du socle Claude Code
**Je veux** comprendre les capacites avancees du modele Opus 4.6
**Afin de** tirer parti de l'Adaptive Thinking, de la fenetre de contexte etendue et des sorties longues

**Pourquoi P1**: Opus 4.6 est le modele recommande pour toutes les taches. Ses nouvelles capacites (4 niveaux d'effort, 1M tokens de contexte, 128k tokens de sortie) changent fondamentalement la facon d'utiliser Claude Code.

**Test independant**: Un utilisateur peut comprendre et configurer les niveaux d'Adaptive Thinking apres avoir lu la documentation.

**Criteres d'acceptation**:

1. **Etant donne** un utilisateur sur le site de documentation, **Quand** il navigue dans les Concepts ou la Reference, **Alors** il trouve une page dediee aux fonctionnalites avancees incluant Opus 4.6
2. **Etant donne** un utilisateur sur cette page, **Quand** il lit la section Opus 4.6, **Alors** il comprend les 4 niveaux d'Adaptive Thinking, la fenetre de 1M tokens, la sortie de 128k tokens et le Context Compaction
3. **Etant donne** un developpeur utilisant l'API, **Quand** il consulte la section Opus 4.6, **Alors** il trouve un exemple de code pour configurer l'Adaptive Thinking

---

### US4 - Ajouter le style de sortie Explanatory (Priorite: P2)

**En tant que** utilisateur du socle Claude Code
**Je veux** decouvrir et comprendre le style de sortie "explanatory"
**Afin de** obtenir des reponses avec raisonnement detaille quand j'ai besoin de comprendre le "pourquoi"

**Pourquoi P2**: Style recommande par Boris Cherny mais absent de la page des styles. Impact modere car les autres styles sont documentes.

**Test independant**: Un utilisateur peut trouver le style explanatory dans la liste des styles et comprendre quand l'utiliser.

**Criteres d'acceptation**:

1. **Etant donne** un utilisateur sur la page des styles de sortie, **Quand** il consulte la liste, **Alors** il voit 8 styles (incluant "explanatory") au lieu de 7
2. **Etant donne** un utilisateur consultant le style explanatory, **Quand** il lit la description, **Alors** il comprend que ce style fournit un raisonnement detaille et est recommande par Boris Cherny
3. **Etant donne** un utilisateur consultant le style explanatory, **Quand** il lit les exemples, **Alors** il voit au moins un exemple concret d'utilisation

---

### US5 - Corriger les compteurs obsoletes (Priorite: P2)

**En tant que** utilisateur du socle Claude Code
**Je veux** voir des chiffres corrects dans la navigation et les pages d'index
**Afin de** avoir confiance dans la fiabilite et l'actualite de la documentation

**Pourquoi P2**: Les compteurs incorrects (41 au lieu de 42 skills, 21 au lieu de 22 rules) donnent une impression de documentation non maintenue.

**Test independant**: Tous les compteurs affiches dans la navigation, le footer et les pages d'index correspondent aux valeurs reelles.

**Criteres d'acceptation**:

1. **Etant donne** un utilisateur sur le site, **Quand** il voit le menu "Composants", **Alors** il lit "Skills (42)" et non "Skills (41)"
2. **Etant donne** un utilisateur sur le site, **Quand** il voit le footer, **Alors** il lit "Skills (42)" et non "Skills (41)"
3. **Etant donne** un utilisateur sur la page d'index des skills, **Quand** il lit le compteur, **Alors** il voit "42 skills" et non "41 skills"
4. **Etant donne** un utilisateur sur le menu Composants, **Quand** il lit l'entree Rules, **Alors** il voit toujours "Rules (21)" (le README.md n'est pas une regle)

---

### US6 - Creer la section Fonctionnalites Avancees (Priorite: P2)

**En tant que** utilisateur avance du socle Claude Code
**Je veux** trouver une page regroupant toutes les fonctionnalites avancees
**Afin de** decouvrir les capacites avancees (Agent Teams, Plugins, LSP, MCP, imports) en un seul endroit

**Pourquoi P2**: Certaines fonctionnalites avancees (Plugins, LSP, @imports) sont mentionnees dans les fichiers de reference mais n'ont pas de page dediee dans Docusaurus.

**Test independant**: Un utilisateur avance peut naviguer vers une page "Fonctionnalites Avancees" et y trouver toutes les capacites avancees du socle.

**Criteres d'acceptation**:

1. **Etant donne** un utilisateur sur le site, **Quand** il navigue dans la section Concepts, **Alors** il trouve une page "Fonctionnalites Avancees" parmi les autres pages conceptuelles (hooks, MCP, templates...)
2. **Etant donne** un utilisateur sur cette page, **Quand** il la consulte, **Alors** il trouve des sections sur : Agent Teams, Opus 4.6, Plugins, LSP, MCP, @imports, Context Compaction
3. **Etant donne** un utilisateur consultant la section Plugins, **Quand** il lit la documentation, **Alors** il comprend la structure d'un plugin et la difference avec les skills standalone

---

### US7 - Mettre a jour les pages d'index des commandes WORK (Priorite: P3)

**En tant que** utilisateur du socle Claude Code
**Je veux** que la page d'index des commandes WORK mentionne la commande work-team
**Afin de** decouvrir toutes les commandes disponibles sans en manquer

**Pourquoi P3**: L'impact est faible car la commande sera documentee dans sa propre page (US1), mais l'index doit etre coherent.

**Test independant**: La page d'index des commandes WORK liste 12 commandes incluant work-team.

**Criteres d'acceptation**:

1. **Etant donne** un utilisateur sur la page d'index des commandes WORK, **Quand** il consulte le tableau, **Alors** il voit `/work:work-team` avec la description "Lancer une equipe d'agents coordonnes"

---

## Exigences Fonctionnelles

- **EF-001**: Le site DOIT contenir une page de commande pour `/work:work-team` avec description, prerequis, exemples d'utilisation et patterns pre-configures
- **EF-002**: Le site DOIT contenir une page de skill pour `agent-teams` avec activation, modes d'affichage, architecture et comparaison avec les sub-agents
- **EF-003**: Le site DOIT contenir une page "Bonnes Pratiques" dans les Guides reprenant les recommandations de Boris Cherny
- **EF-004**: Le site DOIT contenir une documentation des capacites Opus 4.6 (Adaptive Thinking, 1M contexte, 128k sortie, Context Compaction)
- **EF-005**: La page des styles de sortie DOIT documenter les 8 styles incluant "explanatory"
- **EF-006**: Tous les compteurs dans la navigation (navbar, footer) et les pages d'index DOIVENT refleter les valeurs reelles (42 skills, 21 rules inchange)
- **EF-007**: Le sidebar DOIT inclure les nouvelles pages dans les sections appropriees
- **EF-008**: Chaque nouvelle page DOIT suivre le format et le ton des pages existantes du site Docusaurus

## Cas Limites (Edge Cases)

- Que se passe-t-il si un utilisateur cherche "Agent Teams" dans la recherche Docusaurus ? La page doit etre indexee correctement avec les bons mots-cles.
- Comment gerer les references croisees entre la page Agent Teams (concept), la commande work-team et le skill agent-teams ? Des liens bidirectionnels doivent etre places.
- Que faire si le compteur change a nouveau lors d'une prochaine release ? Documenter ou centraliser les compteurs pour faciliter les mises a jour futures.

## Entites Cles

| Entite | Description | Attributs cles |
|--------|-------------|----------------|
| Page de commande | Documentation d'une commande du socle | titre, description, usage, exemples, agents lies |
| Page de skill | Documentation d'un skill automatique | nom, declencheurs, outils autorises, exemples |
| Page de concept | Documentation d'un concept transverse | titre, sections, exemples, liens croises |
| Page de guide | Guide pratique oriente utilisateur | titre, etapes, recommandations, exemples |

## Criteres de Succes (mesurables)

- **CS-001**: 100% des compteurs affiches correspondent aux valeurs reelles du socle
- **CS-002**: 100% des commandes du socle ont une page de documentation correspondante (121/121)
- **CS-003**: 100% des skills du socle ont une page de documentation correspondante (42/42)
- **CS-004**: Les 3 fonctionnalites majeures manquantes (Agent Teams, Best Practices, Opus 4.6) ont chacune une page dediee accessible depuis la navigation
- **CS-005**: Le build Docusaurus (`npm run build` dans website/) passe sans erreur apres toutes les modifications

## Hors Scope (explicitement exclus)

- Refonte graphique ou changement de theme Docusaurus
- Ajout de nouvelles fonctionnalites au socle (uniquement documentation de l'existant)
- Traduction de la documentation en d'autres langues
- Migration vers une version plus recente de Docusaurus
- Documentation de fonctionnalites non encore mergees dans main

## Hypotheses et Dependances

### Hypotheses
- La structure actuelle de Docusaurus (sidebars, navbar) peut accueillir les nouvelles pages sans refonte majeure
- Le contenu des fichiers de reference (`docs/reference/advanced-features.md`, `docs/reference/best-practices.md`) est la source de verite pour les nouvelles pages
- Le format des pages existantes (frontmatter, structure markdown) doit etre suivi pour la coherence

### Dependances
- Les fichiers source dans `.claude/commands/work/work-team.md`, `.claude/skills/agent-teams/SKILL.md`, `.claude/output-styles/explanatory.md` doivent etre a jour (verifies OK)
- La configuration Docusaurus (`docusaurus.config.ts`, `sidebars.ts`) doit etre modifiable

## Points de Clarification

> Questions ouvertes pour `/work:work-clarify` si necessaire

- ~~[CLARIFICATION NECESSAIRE]: Ou placer la page "Fonctionnalites Avancees"~~ → **Resolu** : Dans la section **Concepts** (coherent avec les pages voisines, pas de modification de navbar)
- ~~[CLARIFICATION NECESSAIRE]: La page "Bonnes Pratiques" doit-elle aller dans les Guides ?~~ → **Resolu** : Dans la section **Guides** (coherent avec les guides existants, pas de modification de navbar)
- ~~[CLARIFICATION NECESSAIRE]: Faut-il mettre a jour le compteur Rules de 21 a 22~~ → **Resolu** : Non, le README.md n'est pas une regle. Le compteur reste a 21 (21 regles dans `.claude/rules/` hors README, 21 pages dans `website/docs/rules/` hors index). Seul le compteur Skills passe de 41 a 42.

## Clarifications

### Session 2026-02-06
- Q: Ou placer la page "Fonctionnalites Avancees" ? → **R: Section Concepts** (coherent avec hooks, MCP, templates)
- Q: Compteur Rules 21 ou 22 ? → **R: Reste a 21** (README.md n'est pas une regle)
- Q: Ou placer la page "Bonnes Pratiques (Boris Cherny)" ? → **R: Section Guides** (coherent avec les guides existants)

---

**Version**: 1.1 | **Cree par**: /work:work-specify | **Mis a jour**: 2026-02-06
