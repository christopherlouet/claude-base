# Spécification : Synchronisation Claude Code Q1 2026

**Branche**: `feature/sync-claude-code-2026-q1`
**Date**: 2026-03-14
**Statut**: Draft

---

## Résumé

Mettre à jour le socle claude-socle pour intégrer les nouvelles fonctionnalités de Claude Code CLI sorties entre février et mars 2026 : nouveaux types de hooks (async, HTTP, PostCompact, Elicitation, TeammateIdle, TaskCompleted, InstructionsLoaded), support MCP Elicitation, configuration worktree sparse paths, et renforcement sécurité suite aux vulnérabilités découvertes sur les hooks/MCP. L'objectif est que le socle reste la référence à jour pour tout projet utilisant Claude Code.

---

## User Stories (prioritisées)

### US1 - Nouveaux hooks de cycle de vie (Priorité: P1) 🎯 MVP

**En tant que** développeur utilisant le socle
**Je veux** bénéficier automatiquement des nouveaux hooks disponibles dans Claude Code CLI
**Afin de** avoir une meilleure observabilité et réactivité de mes sessions Claude Code

**Pourquoi P1**: Les hooks sont le coeur du socle. Sans mise à jour, les utilisateurs passent à côté de fonctionnalités qui améliorent directement leur productivité et la fiabilité de leurs sessions.

**Test indépendant**: Démarrer une session Claude Code avec le socle mis à jour et vérifier que les nouveaux hooks se déclenchent correctement dans les logs.

**Critères d'acceptation**:

1. **Étant donné** une session active, **Quand** le contexte est compacté, **Alors** un hook `PostCompact` se déclenche et enregistre l'événement dans les logs
2. **Étant donné** une session avec Agent Teams, **Quand** un agent teammate devient inactif, **Alors** un hook `TeammateIdle` se déclenche et l'événement est tracé
3. **Étant donné** une session avec des tâches, **Quand** une tâche est marquée terminée, **Alors** un hook `TaskCompleted` se déclenche et l'événement est tracé
4. **Étant donné** le démarrage d'une session, **Quand** les fichiers CLAUDE.md et rules sont chargés, **Alors** un hook `InstructionsLoaded` se déclenche et trace les fichiers chargés dans les logs (logging seul, pas de validation active)
5. **Étant donné** les nouveaux hooks configurés, **Quand** je consulte la documentation du socle, **Alors** chaque hook est documenté avec son rôle et son comportement

---

### US2 - Hooks asynchrones pour les opérations non-bloquantes (Priorité: P1) 🎯 MVP

**En tant que** développeur utilisant le socle
**Je veux** que les hooks de logging et notification ne ralentissent pas mon travail
**Afin de** garder une expérience fluide tout en conservant la traçabilité

**Pourquoi P1**: Actuellement, tous les hooks s'exécutent de manière synchrone, ce qui peut ralentir l'expérience. Les hooks de logging (SessionEnd, PreCompact, SubagentStop, Notification) n'ont pas besoin de bloquer.

**Test indépendant**: Mesurer le temps de réponse avant/après passage en async des hooks de logging.

**Critères d'acceptation**:

1. **Étant donné** un hook de logging (SessionEnd, SubagentStop, Notification), **Quand** il se déclenche, **Alors** il s'exécute en arrière-plan sans bloquer la session
2. **Étant donné** un hook critique (détection de secrets, tests pré-commit), **Quand** il se déclenche, **Alors** il reste synchrone et bloquant
3. **Étant donné** la configuration des hooks, **Quand** je consulte le fichier settings.json, **Alors** les hooks non-bloquants portent la propriété `"async": true`
4. **Étant donné** un hook async qui échoue, **Quand** l'erreur survient, **Alors** elle est tracée dans les logs sans impacter la session

---

### US3 - Support HTTP Hooks pour intégrations externes (Priorité: P2)

**En tant que** développeur travaillant en équipe
**Je veux** pouvoir envoyer des notifications à des services externes (Slack, CI/CD) depuis mes hooks
**Afin de** intégrer Claude Code dans mon workflow d'équipe

**Pourquoi P2**: Les HTTP hooks ouvrent le socle aux intégrations d'équipe mais nécessitent une configuration spécifique à chaque projet.

**Test indépendant**: Configurer un HTTP hook vers un endpoint de test et vérifier qu'il reçoit les données attendues.

**Critères d'acceptation**:

1. **Étant donné** le socle mis à jour, **Quand** je consulte la documentation, **Alors** je trouve un guide pour configurer des HTTP hooks avec un exemple de webhook générique
2. **Étant donné** un template HTTP hook, **Quand** je l'active avec mon URL, **Alors** les événements sont envoyés au format attendu par le service
3. **Étant donné** un HTTP hook configuré, **Quand** le service distant est indisponible, **Alors** la session Claude Code n'est pas bloquée
4. **Étant donné** la documentation, **Quand** je cherche comment configurer un HTTP hook, **Alors** je trouve des exemples commentés et désactivés par défaut dans settings.json

---

### US4 - Configuration worktree sparse paths pour monorepos (Priorité: P2)

**En tant que** développeur travaillant sur un monorepo
**Je veux** pouvoir configurer quels chemins sont inclus dans mes worktrees Claude Code
**Afin de** réduire le bruit et accélérer les opérations sur de gros dépôts

**Pourquoi P2**: Le support `worktree.sparsePaths` est une fonctionnalité récente qui améliore significativement l'expérience sur les monorepos, un cas d'usage courant.

**Test indépendant**: Configurer sparsePaths sur un projet multi-packages et vérifier que seuls les chemins configurés sont accessibles dans le worktree.

**Critères d'acceptation**:

1. **Étant donné** le skill `git-worktrees` existant, **Quand** je le consulte, **Alors** je trouve la documentation sur la configuration `worktree.sparsePaths`
2. **Étant donné** un projet monorepo, **Quand** je configure sparsePaths, **Alors** seuls les sous-dossiers pertinents sont inclus dans le worktree
3. **Étant donné** la documentation des bonnes pratiques, **Quand** je cherche comment optimiser les worktrees, **Alors** je trouve des exemples de configuration sparsePaths adaptés (frontend, backend, shared)

---

### US5 - Renforcement sécurité hooks et MCP (Priorité: P1) 🎯 MVP

**En tant que** développeur soucieux de la sécurité
**Je veux** être protégé contre les vulnérabilités connues liées aux hooks, MCP et variables d'environnement
**Afin de** utiliser le socle en toute confiance, même en clonant des dépôts tiers

**Pourquoi P1**: Des vulnérabilités ont été publiquement divulguées (février 2026) permettant l'exécution de commandes arbitraires et l'exfiltration de clés API via hooks et MCP mal configurés. Le socle doit activement protéger ses utilisateurs.

**Test indépendant**: Cloner un dépôt contenant des configurations malveillantes et vérifier que le socle bloque les comportements dangereux.

**Critères d'acceptation**:

1. **Étant donné** le démarrage d'une session, **Quand** des serveurs MCP sont activés, **Alors** un avertissement rappelle de vérifier les permissions accordées
2. **Étant donné** la documentation sécurité du socle, **Quand** je la consulte, **Alors** je trouve un guide sur les risques liés au clonage de dépôts non-fiables avec Claude Code
3. **Étant donné** les bonnes pratiques documentées, **Quand** je configure le socle, **Alors** les serveurs MCP restent désactivés par défaut avec un avertissement clair
4. **Étant donné** un fichier `.env` présent, **Quand** le hook SessionStart se déclenche, **Alors** il vérifie que `.env` est bien dans `.gitignore`
5. **Étant donné** un projet avec des hooks personnalisés dans `.claude/settings.json`, **Quand** la session démarre, **Alors** un avertissement non-bloquant rappelle de vérifier les hooks configurés

---

### US6 - Documentation Claude Code Security (scan de vulnérabilités) (Priorité: P2)

**En tant que** développeur utilisant le socle pour un projet professionnel
**Je veux** savoir comment utiliser Claude Code Security pour scanner mon code
**Afin de** détecter les vulnérabilités avant la mise en production

**Pourquoi P2**: Claude Code Security est un nouvel outil puissant (500+ vulns trouvées en OSS) mais nécessite un plan Enterprise/Team. La documentation permet aux utilisateurs éligibles de l'exploiter.

**Test indépendant**: Consulter la documentation et suivre les étapes pour lancer un scan de sécurité.

**Critères d'acceptation**:

1. **Étant donné** la documentation du socle, **Quand** je cherche "scan sécurité", **Alors** je trouve une section dédiée à Claude Code Security
2. **Étant donné** le workflow `/qa:qa-security`, **Quand** je le lance, **Alors** la documentation mentionne Claude Code Security comme option complémentaire pour les équipes éligibles
3. **Étant donné** le pattern Agent Teams "Audit", **Quand** je le consulte, **Alors** il intègre une mention de Claude Code Security dans sa stratégie

---

### US7 - Support MCP Elicitation (Priorité: P3)

**En tant que** développeur utilisant des serveurs MCP avancés
**Je veux** que le socle documente le support de l'Elicitation MCP
**Afin de** créer des workflows interactifs avec mes serveurs MCP

**Pourquoi P3**: L'Elicitation MCP est très récente (mars 2026) et concerne un cas d'usage avancé. La documentation suffit pour cette itération.

**Test indépendant**: Consulter la documentation et comprendre comment configurer un serveur MCP avec Elicitation.

**Critères d'acceptation**:

1. **Étant donné** la documentation MCP du socle, **Quand** je la consulte, **Alors** je trouve une section expliquant l'Elicitation (demande d'input structuré mid-task)
2. **Étant donné** les hooks Elicitation/ElicitationResult, **Quand** je consulte la doc hooks, **Alors** ils sont documentés avec leur cas d'usage

---

### US8 - Mise à jour compteurs et références (Priorité: P1) 🎯 MVP

**En tant que** utilisateur du socle
**Je veux** que les compteurs, versions et références soient à jour
**Afin de** avoir confiance dans la documentation et les informations affichées

**Pourquoi P1**: Des compteurs incorrects érodent la confiance. Le hook SessionStart affiche ces chiffres à chaque démarrage.

**Test indépendant**: Lancer le script `validate-counts.sh` et vérifier que tous les compteurs sont corrects.

**Critères d'acceptation**:

1. **Étant donné** les nouveaux hooks ajoutés, **Quand** je lance `validate-counts.sh`, **Alors** le compteur de hooks est correct
2. **Étant donné** la documentation hooks-reference.md, **Quand** je la consulte, **Alors** tous les nouveaux hooks sont listés avec leur description
3. **Étant donné** le fichier advanced-features.md, **Quand** je le consulte, **Alors** les nouvelles fonctionnalités (async hooks, HTTP hooks, Elicitation, sparsePaths) sont documentées

---

## Exigences Fonctionnelles

- **EF-001**: Le socle DOIT inclure les hooks `PostCompact`, `TeammateIdle`, `TaskCompleted`, et `InstructionsLoaded` dans sa configuration par défaut
- **EF-002**: Le socle DOIT marquer les hooks de logging/notification comme asynchrones (`"async": true`)
- **EF-003**: Le socle DOIT fournir des exemples commentés de HTTP hooks (désactivés par défaut)
- **EF-004**: Le socle DOIT vérifier au démarrage que `.env` est dans `.gitignore` si le fichier existe
- **EF-005**: Le socle DOIT documenter les risques de sécurité liés aux hooks et MCP dans un guide dédié
- **EF-006**: Le socle DOIT mettre à jour le skill `git-worktrees` avec la configuration `worktree.sparsePaths`
- **EF-007**: Le socle DOIT documenter Claude Code Security et MCP Elicitation dans les références appropriées
- **EF-008**: Le socle DOIT maintenir tous les compteurs à jour après les modifications
- **EF-009**: Les hooks de sécurité (gitleaks, tests pré-commit) DOIVENT rester synchrones et bloquants
- **EF-010**: Tout nouveau hook DOIT avoir un `onFailure: "ignore"` sauf si explicitement bloquant
- **EF-011**: Le socle DOIT rester rétrocompatible — les hooks non supportés par d'anciennes versions de Claude Code CLI ne doivent pas casser la session

## Cas Limites (Edge Cases)

- **Version CLI ancienne**: Que se passe-t-il si l'utilisateur a une version de Claude Code qui ne supporte pas les nouveaux types de hooks ? → Les hooks inconnus sont ignorés silencieusement par Claude Code CLI (comportement vérifié)
- **Hooks async qui échouent**: Comment tracer les erreurs des hooks async ? → Les erreurs sont loggées dans `/tmp/claude-*.log` comme les hooks existants
- **HTTP hooks sans réseau**: Que se passe-t-il si le webhook est injoignable ? → Le hook est en async + `onFailure: "ignore"`, donc aucun impact sur la session
- **MCP Elicitation sans serveur compatible**: Les hooks Elicitation se déclenchent-ils sans serveur MCP actif ? → Non, ils ne se déclenchent que si un serveur MCP utilise l'Elicitation
- **`.env` légitime non dans `.gitignore`**: Certains projets ont un `.env.example` versionné → Le hook vérifie uniquement `.env` exact, pas `.env.example` ou `.env.local`
- **Monorepo sans sparse-checkout**: La configuration sparsePaths est-elle obligatoire ? → Non, c'est une option documentée, pas une valeur par défaut

## Critères de Succès (mesurables)

- **CS-001**: 100% des nouveaux hooks Claude Code (fév-mars 2026) sont configurés ou documentés dans le socle
- **CS-002**: Les hooks de logging existants (5+) sont passés en mode async
- **CS-003**: Le temps de réponse perçu n'est pas dégradé par les nouveaux hooks (hooks non-critiques en async)
- **CS-004**: `validate-counts.sh` passe sans erreur après les modifications
- **CS-005**: La documentation sécurité couvre les 3 vecteurs d'attaque identifiés (hooks, MCP, env vars)
- **CS-006**: Rétrocompatibilité : le socle fonctionne avec Claude Code CLI >= 2.0 sans erreur

## Hors Scope (explicitement exclus)

- **Implémentation de Claude Code Security** comme outil intégré — seule la documentation est incluse (nécessite plan Enterprise/Team)
- **GitHub Copilot integration** — concerne l'écosystème GitHub, pas le socle CLI
- **Migration vers Sonnet 4.6** pour les agents — évaluation à faire séparément
- **Implémentation du check-updates** — spec séparée existante (`specs/check-updates/`)
- **Refonte du système de hooks** — on ajoute aux hooks existants sans restructurer
- **HTTP hooks pré-configurés** avec des URLs spécifiques — seuls des templates commentés sont fournis

## Hypothèses et Dépendances

### Hypothèses
- Les utilisateurs du socle ont Claude Code CLI >= 2.1.x (support des nouveaux hooks)
- Les hooks non reconnus par une version ancienne de CLI sont ignorés sans erreur
- Les hooks async (`"async": true`) sont disponibles depuis février 2026
- Les HTTP hooks (`"type": "http"`) sont disponibles depuis février 2026

### Dépendances
- Claude Code CLI v2.1.70+ pour les hooks async et HTTP
- Claude Code CLI v2.1.76+ pour les hooks Elicitation et PostCompact
- La spec `docs-update-v1.25` pour les mises à jour de la documentation Docusaurus
- Le fichier `hooks-reference.md` existant pour la documentation des hooks

## Clarifications

### Session 2026-03-14

- Q: Hook `InstructionsLoaded` : validation active ou logging seul ? → R: **Logging seul** — trace les fichiers chargés sans validation active, cohérent avec les autres hooks d'observation du socle
- Q: Quels templates HTTP hooks fournir ? → R: **Webhook générique uniquement** — pas de templates spécifiques Slack/Discord, moins de maintenance
- Q: Scan automatique des settings.json de dépôts clonés ? → R: **Warning non-bloquant au SessionStart** — rappel de vérifier les hooks si le projet en contient, sans scan actif bloquant

## Points de Clarification

> Tous les points ont été résolus lors de la session du 2026-03-14. Aucune ambiguïté résiduelle.
