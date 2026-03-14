# Spécification : Intégration Agent Teams Natif et Documentation Swarm

**Branche**: `feature/agent-teams`
**Date**: 2026-02-06
**Statut**: Completed

---

## Résumé

Permettre aux utilisateurs du socle claude-socle de lancer des équipes d'agents coordonnés (Agent Teams) pour paralléliser leur travail sur des tâches complexes. L'objectif est d'exploiter la fonctionnalité native Agent Teams de Claude Code (TeammateTool) en la rendant accessible via le socle, avec des patterns pré-configurés, une documentation complète et des commandes dédiées.

---

## User Stories (prioritisées)

### US1 - Activer et configurer Agent Teams (Priorité: P1) 🎯 MVP

**En tant que** développeur utilisant le socle
**Je veux** pouvoir activer facilement les Agent Teams dans mon projet
**Afin de** lancer des équipes d'agents coordonnés sans configuration manuelle

**Pourquoi P1**: Sans activation, aucune fonctionnalité Agent Teams n'est utilisable. C'est le prérequis de tout le reste.

**Test indépendant**: Activer la fonctionnalité et vérifier qu'un agent lead peut créer une équipe.

**Critères d'acceptation**:

1. **Étant donné** un projet avec le socle installé, **Quand** j'exécute la commande d'activation, **Alors** les paramètres Agent Teams sont ajoutés à la configuration
2. **Étant donné** Agent Teams activé, **Quand** je demande à Claude de créer une équipe, **Alors** les teammates sont correctement lancés avec leurs rôles
3. **Étant donné** un environnement sans tmux installé, **Quand** j'active Agent Teams, **Alors** le mode in-process est utilisé par défaut avec un message explicatif
4. **Étant donné** que je veux désactiver Agent Teams, **Quand** je modifie ma configuration, **Alors** les équipes ne sont plus proposées

---

### US2 - Lancer un audit parallèle avec une équipe (Priorité: P1) 🎯 MVP

**En tant que** développeur soucieux de la qualité
**Je veux** lancer plusieurs audits simultanément (sécurité, performance, accessibilité)
**Afin de** gagner du temps par rapport à des audits séquentiels

**Pourquoi P1**: C'est le cas d'usage le plus naturel du socle existant (57 agents spécialisés) et celui qui montre le plus de valeur immédiate.

**Test indépendant**: Lancer un audit parallèle et vérifier que les 3 résultats arrivent de manière indépendante.

**Critères d'acceptation**:

1. **Étant donné** un projet avec du code, **Quand** je lance un audit parallèle, **Alors** les audits sécurité, performance et accessibilité s'exécutent simultanément
2. **Étant donné** des audits en cours, **Quand** je consulte l'état de l'équipe, **Alors** je vois l'avancement de chaque auditeur
3. **Étant donné** que tous les audits sont terminés, **Quand** le lead synthétise, **Alors** je reçois un rapport consolidé avec les résultats de chaque domaine
4. **Étant donné** qu'un audit échoue (ex: source inaccessible), **Quand** les autres continuent, **Alors** le rapport final mentionne l'audit en échec sans bloquer les autres

---

### US3 - Développer une feature en équipe (Priorité: P1) 🎯 MVP

**En tant que** développeur travaillant sur une feature complexe multi-couches
**Je veux** répartir le travail entre des agents spécialisés (frontend, backend, tests)
**Afin de** paralléliser le développement tout en gardant la cohérence

**Pourquoi P1**: C'est le cas d'usage le plus ambitieux et celui qui justifie l'intégration d'Agent Teams dans un workflow de développement.

**Test indépendant**: Lancer un développement en équipe et vérifier que chaque agent travaille sur ses fichiers sans conflit.

**Critères d'acceptation**:

1. **Étant donné** une feature à développer, **Quand** je lance le workflow en équipe, **Alors** chaque agent travaille dans des fichiers distincts sans conflit
2. **Étant donné** des agents en parallèle, **Quand** un agent dépend du travail d'un autre, **Alors** la dépendance est gérée via la liste de tâches partagée
3. **Étant donné** que le développement est terminé, **Quand** le lead valide, **Alors** les résultats sont cohérents entre eux
4. **Étant donné** un conflit de fichiers potentiel, **Quand** deux agents tentent de modifier le même fichier, **Alors** le système alerte et le lead arbitre

---

### US4 - Investiguer un bug avec des hypothèses concurrentes (Priorité: P2)

**En tant que** développeur face à un bug complexe
**Je veux** tester plusieurs hypothèses de cause racine en parallèle
**Afin de** trouver la source du problème plus rapidement

**Pourquoi P2**: Cas d'usage puissant mais moins fréquent qu'audit ou développement.

**Test indépendant**: Soumettre un bug et vérifier que les agents explorent des pistes différentes.

**Critères d'acceptation**:

1. **Étant donné** une description de bug, **Quand** je lance l'investigation en équipe, **Alors** chaque agent explore une hypothèse différente
2. **Étant donné** des hypothèses en cours d'exploration, **Quand** un agent trouve des preuves, **Alors** il les partage avec les autres pour affiner leur recherche
3. **Étant donné** qu'un consensus émerge, **Quand** le lead synthétise, **Alors** je reçois la cause racine probable avec les preuves collectées

---

### US5 - Accéder à des patterns pré-configurés (Priorité: P2)

**En tant que** utilisateur du socle
**Je veux** choisir parmi des patterns d'équipe pré-définis (audit, feature, debug, review)
**Afin de** ne pas avoir à définir la composition de l'équipe à chaque fois

**Pourquoi P2**: Simplifie l'usage et capitalise sur l'expertise du socle.

**Test indépendant**: Lancer chaque pattern et vérifier qu'il crée l'équipe avec les bons rôles.

**Critères d'acceptation**:

1. **Étant donné** que je veux un audit, **Quand** je choisis le pattern "audit", **Alors** une équipe avec les auditeurs appropriés est créée
2. **Étant donné** que je veux développer, **Quand** je choisis le pattern "feature", **Alors** une équipe avec les développeurs spécialisés est créée
3. **Étant donné** les patterns disponibles, **Quand** je consulte la documentation, **Alors** chaque pattern décrit ses rôles, ses cas d'usage et ses limitations
4. **Étant donné** un pattern, **Quand** je le personnalise (ex: ajouter un rôle), **Alors** ma modification est prise en compte

---

### US6 - Comprendre et apprendre Agent Teams (Priorité: P2)

**En tant que** nouvel utilisateur du socle
**Je veux** une documentation claire sur Agent Teams avec des exemples concrets
**Afin de** comprendre quand et comment utiliser cette fonctionnalité

**Pourquoi P2**: La documentation est indispensable pour l'adoption mais ne bloque pas les utilisateurs avancés.

**Test indépendant**: Un nouvel utilisateur peut lancer son premier Agent Team en suivant la documentation.

**Critères d'acceptation**:

1. **Étant donné** la documentation, **Quand** je la lis, **Alors** je comprends la différence entre sub-agents, Agent Teams et sessions parallèles manuelles
2. **Étant donné** des exemples documentés, **Quand** je reproduis un exemple, **Alors** il fonctionne comme décrit
3. **Étant donné** les limitations connues, **Quand** je consulte la documentation, **Alors** je sais ce qu'Agent Teams ne peut PAS faire
4. **Étant donné** un problème, **Quand** je consulte le guide de dépannage, **Alors** je trouve une solution pour les cas courants

---

### US7 - Choisir le mode d'affichage (Priorité: P3)

**En tant que** développeur avec un terminal configuré
**Je veux** choisir entre le mode in-process et le mode split-panes (tmux/iTerm2)
**Afin d'** avoir la visibilité adaptée à mon environnement

**Pourquoi P3**: Le mode in-process fonctionne partout, le mode split-panes est un confort visuel.

**Test indépendant**: Basculer entre les deux modes et vérifier le comportement.

**Critères d'acceptation**:

1. **Étant donné** tmux installé, **Quand** je choisis le mode split-panes, **Alors** chaque agent a son propre panneau visible
2. **Étant donné** un terminal sans tmux, **Quand** je lance une équipe, **Alors** le mode in-process est utilisé avec navigation via raccourcis clavier
3. **Étant donné** ma préférence de mode, **Quand** je la configure dans le socle, **Alors** elle est réutilisée pour les prochaines sessions

---

## Exigences Fonctionnelles

### Activation et configuration

- **EF-001**: Le système DOIT activer Agent Teams via une variable d'environnement dans la configuration du socle
- **EF-002**: Le système DOIT détecter automatiquement si tmux est disponible et adapter le mode d'affichage
- **EF-003**: Le système DOIT fournir un paramètre de configuration pour le mode d'affichage préféré (`in-process`, `tmux`, `auto`)

### Orchestration

- **EF-004**: Le système DOIT fournir une commande dédiée pour lancer une équipe d'agents
- **EF-005**: Le système DOIT proposer des patterns d'équipe pré-configurés (audit, feature, debug, review)
- **EF-006**: Le système DOIT permettre la création d'équipes personnalisées en langage naturel
- **EF-007**: Le système DOIT coordonner les agents via la liste de tâches partagée native

### Communication et coordination

- **EF-008**: Les agents DOIVENT pouvoir échanger des informations entre eux via le système de messagerie natif
- **EF-009**: Le lead DOIT synthétiser les résultats de l'équipe en un rapport consolidé
- **EF-010**: Le système DOIT gérer les dépendances entre tâches (une tâche bloquée attend la complétion de ses prérequis)

### Gestion du cycle de vie

- **EF-011**: Le système DOIT permettre l'arrêt propre des agents (graceful shutdown)
- **EF-012**: Le système DOIT nettoyer les ressources d'équipe après utilisation (cleanup)
- **EF-013**: Le système DOIT gérer la défaillance d'un agent sans impacter les autres

### Intégration avec le socle existant

- **EF-014**: Le système DOIT réutiliser les agents existants du socle (qa-security, qa-perf, etc.) comme rôles dans les équipes
- **EF-015**: Le système DOIT respecter les permissions et hooks existants du socle
- **EF-016**: Le système DOIT s'intégrer au workflow Explore -> Specify -> Plan -> TDD -> Commit

---

## Cas Limites (Edge Cases)

| Situation | Comportement attendu |
|-----------|---------------------|
| tmux non installé | Basculer en mode in-process avec message informatif |
| Un agent crashe en cours de mission | Le lead détecte l'absence, relance ou redistribue la tâche |
| Deux agents modifient le même fichier | Alerte au lead, arbitrage avant merge |
| Session reprise après interruption (`/resume`) | Les teammates in-process ne survivent pas, le lead re-crée l'équipe si nécessaire |
| Plus de 5 agents lancés | Avertissement sur la consommation de tokens et la coordination |
| Réseau instable pendant coordination | Les messages en file d'attente sont livrés quand la connexion revient |
| Espace disque insuffisant pour les worktrees | Erreur explicite avec suggestion de nettoyage |
| Terminal VS Code / Windows Terminal | Mode split-panes indisponible, basculer sur in-process |
| Agent Teams déjà actif sur la session | Un seul team par session, demander de nettoyer le précédent |

---

## Entités Clés

| Entité | Description | Attributs clés |
|--------|-------------|----------------|
| **Équipe** | Un groupe d'agents coordonnés | nom, lead, membres, liste_tâches, statut |
| **Agent Lead** | L'agent orchestrateur principal | session_id, mode (coordination/délégation), permissions |
| **Teammate** | Un agent spécialisé dans l'équipe | nom, rôle, agent_type, statut, tâches_assignées |
| **Tâche** | Une unité de travail dans la liste partagée | id, description, statut, assigné_à, dépendances |
| **Pattern** | Un modèle d'équipe pré-configuré | nom, description, rôles, cas_usage |
| **Message** | Communication entre agents | expéditeur, destinataire, contenu, timestamp |

---

## Critères de Succès (mesurables)

| ID | Critère | Cible |
|----|---------|-------|
| **CS-001** | Temps de lancement d'une équipe de 3 agents | < 30 secondes |
| **CS-002** | Gain de temps sur un audit complet (3 audits parallèles vs séquentiel) | > 40% de réduction du temps total |
| **CS-003** | Taux de réussite du cleanup d'équipe | > 95% (pas de sessions orphelines) |
| **CS-004** | Documentation couvre les patterns principaux | 4 patterns documentés (audit, feature, debug, review) |
| **CS-005** | Nombre de commandes/skills ajoutés au socle | 1 commande + 1 skill + documentation |
| **CS-006** | Un nouvel utilisateur peut lancer son premier team | < 5 minutes en suivant la doc |

---

## Hors Scope (explicitement exclus)

| Exclusion | Raison |
|-----------|--------|
| Création d'un outil d'orchestration custom (type claude-flow) | On utilise la fonctionnalité native de Claude Code |
| Équipes imbriquées (un teammate crée sa propre équipe) | Limitation native d'Agent Teams |
| Changement de lead en cours de session | Limitation native, le créateur reste lead |
| Support Windows natif (hors WSL) | Le socle cible Linux/macOS/WSL |
| Coordination inter-projets (agents sur des repos différents) | Complexité excessive, hors périmètre |
| Interface graphique de monitoring | Le monitoring se fait via le terminal (tmux ou in-process) |
| Intégration MCP spécifique pour Agent Teams | Les MCP existants sont déjà partagés avec les teammates |
| Modification des 57 agents existants | Les agents existants sont utilisés tels quels comme rôles |

---

## Hypothèses et Dépendances

### Hypothèses

1. **Claude Code >= 2.1.19** - La fonctionnalité Agent Teams est disponible (experimental)
2. **Git worktrees fonctionnels** - Le système git du projet supporte les worktrees (nécessaire pour l'isolation fichiers)
3. **CLAUDE.md partagé** - Tous les teammates lisent le CLAUDE.md du projet, donc les conventions sont respectées
4. **tmux optionnel** - Le mode in-process fonctionne sans dépendance externe
5. **Opus 4.6 recommandé** - Le lead bénéficie d'Opus 4.6 pour l'orchestration complexe, les teammates peuvent utiliser Sonnet/Haiku

### Dépendances

| Dépendance | Type | Critique |
|------------|------|----------|
| Fonctionnalité `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Externe (Claude Code) | Oui |
| Skill `parallel-agents` existant | Interne (socle) | Non - sera remplacé/enrichi |
| Skill `git-worktrees` existant | Interne (socle) | Non - complémentaire |
| Agents existants (57) dans `.claude/agents/` | Interne (socle) | Oui - réutilisés comme rôles |
| `docs/reference/advanced-features.md` | Interne (docs) | Oui - à enrichir |
| `CLAUDE.md` (instructions projet) | Interne (socle) | Oui - à mettre à jour |

---

## Points de Clarification

> Questions à résoudre avant planification

1. ~~**[CLARIFICATION NECESSAIRE]** : Faut-il créer une commande dédiée `/work:work-team` ou enrichir la commande `/assistant` existante ?~~ → **Résolu** : Les deux. Créer `/work:work-team` pour l'usage direct ET enrichir `/assistant` pour détecter automatiquement quand une équipe serait bénéfique et guider les débutants.

2. ~~**[CLARIFICATION NECESSAIRE]** : Pour les patterns pré-configurés, faut-il les stocker dans `.claude/templates/teams/` ou dans le skill ?~~ → **Résolu** : Dans le skill. Stocker les patterns dans `.claude/skills/agent-teams/patterns.md` comme fichier de référence chargé automatiquement. Cohérent avec l'architecture skills du socle.

3. ~~**[CLARIFICATION NECESSAIRE]** : Faut-il ajouter le mode delegate comme option par défaut ?~~ → **Résolu** : Recommandé mais pas forcé. Le skill suggère le mode delegate comme bonne pratique, la doc l'explique clairement, mais l'utilisateur l'active manuellement via `Shift+Tab` quand il le souhaite.

---

## Clarifications

### Session 2026-02-06
- Q: Commande dédiée `/work:work-team` ou enrichir `/assistant` ? → **R: Les deux.** Commande dédiée pour l'usage direct + détection automatique dans `/assistant` pour guider les débutants.
- Q: Où stocker les patterns d'équipe pré-configurés ? → **R: Dans le skill.** Fichier `patterns.md` dans `.claude/skills/agent-teams/`, chargé automatiquement.
- Q: Mode delegate forcé par défaut ou recommandé ? → **R: Recommandé mais pas forcé.** Documenté comme bonne pratique, activation manuelle via `Shift+Tab`.

---

**Version**: 1.1 | **Créé par**: /work:work-specify | **Mis à jour**: 2026-02-06
