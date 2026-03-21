# Spécification : Veille Automatique Claude Code et Skills

**Branche**: `feature/check-updates`
**Date**: 2026-03-21 (mis à jour, créé 2026-02-05)
**Statut**: Ready

---

## Résumé

Permettre aux utilisateurs du socle claude-socle de savoir automatiquement quand des mises à jour sont disponibles, que ce soit pour Claude Code CLI, les nouveaux skills de la communauté, ou des évolutions du socle lui-même. L'objectif est de maintenir le socle à jour sans effort de veille manuelle.

---

## User Stories (prioritisées)

### US1 - Vérification de version Claude Code CLI (Priorité: P1) 🎯 MVP

**En tant que** développeur utilisant le socle
**Je veux** savoir si une nouvelle version de Claude Code CLI est disponible
**Afin de** bénéficier des dernières fonctionnalités et corrections

**Pourquoi P1**: Sans Claude Code à jour, les nouveaux hooks, skills et features du socle peuvent ne pas fonctionner.

**Test indépendant**: Exécuter la vérification sur une machine avec une ancienne version de Claude Code.

**Critères d'acceptation**:

1. **Étant donné** que Claude Code CLI est installé, **Quand** je lance la vérification, **Alors** je vois ma version locale et la dernière version disponible
2. **Étant donné** que ma version est à jour, **Quand** je lance la vérification, **Alors** je vois un message de confirmation "À jour"
3. **Étant donné** qu'une nouvelle version existe, **Quand** je lance la vérification, **Alors** je vois clairement la différence de version et un lien vers les notes de version
4. **Étant donné** que je suis hors ligne, **Quand** je lance la vérification, **Alors** je vois un message d'erreur explicite et non bloquant

---

### US2 - Rapport de veille structuré (Priorité: P1) 🎯 MVP

**En tant que** mainteneur du socle
**Je veux** un rapport clair des mises à jour disponibles
**Afin de** décider rapidement quoi mettre à jour

**Pourquoi P1**: Sans rapport lisible, l'information brute est difficile à exploiter.

**Test indépendant**: Générer un rapport et vérifier sa lisibilité.

**Critères d'acceptation**:

1. **Étant donné** que je lance une vérification complète, **Quand** le script termine, **Alors** je vois un résumé avec le nombre de mises à jour par catégorie
2. **Étant donné** des mises à jour disponibles, **Quand** je consulte le rapport, **Alors** chaque mise à jour indique: source, version actuelle, nouvelle version, importance
3. **Étant donné** aucune mise à jour, **Quand** je consulte le rapport, **Alors** je vois "Tout est à jour" avec la date de dernière vérification

---

### US3 - Découverte de nouveaux skills communautaires (Priorité: P2)

**En tant que** développeur curieux
**Je veux** découvrir les nouveaux skills publiés sur skills.sh
**Afin d'** enrichir mon workflow avec des skills communautaires

**Pourquoi P2**: Valeur ajoutée mais pas bloquante pour le fonctionnement du socle.

**Test indépendant**: Vérifier qu'au moins 5 skills récents sont listés.

**Critères d'acceptation**:

1. **Étant donné** skills.sh accessible, **Quand** je lance la vérification, **Alors** je vois les skills publiés depuis ma dernière vérification
2. **Étant donné** un nouveau skill intéressant, **Quand** je le consulte, **Alors** je vois son nom, sa description courte et un lien pour l'installer
3. **Étant donné** skills.sh inaccessible, **Quand** je lance la vérification, **Alors** les autres vérifications continuent sans blocage

---

### US4 - Intégration dans le workflow de maintenance (Priorité: P2)

**En tant que** utilisateur régulier de Claude Code
**Je veux** être notifié des mises à jour au bon moment
**Afin de** ne pas interrompre mon travail mais ne pas rater les mises à jour importantes

**Pourquoi P2**: Améliore l'expérience mais la vérification manuelle suffit initialement.

**Test indépendant**: Lancer `claude --maintenance` et vérifier que la vérification s'exécute.

**Critères d'acceptation**:

1. **Étant donné** que je lance `claude --maintenance`, **Quand** le hook s'exécute, **Alors** la vérification de mises à jour est incluse
2. **Étant donné** une mise à jour critique disponible, **Quand** je démarre une session, **Alors** je vois une notification discrète (optionnel, configurable)
3. **Étant donné** que je veux ignorer les notifications, **Quand** je configure cette option, **Alors** aucune notification n'apparaît

---

### US5 - Sortie machine-readable pour CI/CD (Priorité: P3)

**En tant qu'** équipe DevOps
**Je veux** une sortie exploitable par des scripts
**Afin d'** automatiser les alertes de mise à jour

**Pourquoi P3**: Cas d'usage avancé pour équipes avec pipelines CI/CD.

**Test indépendant**: Parser la sortie JSON avec jq sans erreur.

**Critères d'acceptation**:

1. **Étant donné** que je demande un format structuré, **Quand** le script termine, **Alors** la sortie est un JSON valide
2. **Étant donné** une intégration CI, **Quand** des mises à jour critiques existent, **Alors** le code de sortie est non-zéro

---

### US6 - Cache et optimisation réseau (Priorité: P3)

**En tant que** utilisateur avec connexion lente
**Je veux** éviter des requêtes réseau inutiles
**Afin de** ne pas ralentir mon workflow

**Pourquoi P3**: Optimisation, pas critique pour le fonctionnement.

**Test indépendant**: Exécuter deux vérifications consécutives et mesurer le temps.

**Critères d'acceptation**:

1. **Étant donné** une vérification récente (< 24h), **Quand** je relance, **Alors** le cache est utilisé sauf si je force le rafraîchissement
2. **Étant donné** un mode hors-ligne, **Quand** je lance la vérification, **Alors** le dernier état connu est affiché avec sa date

---

## Exigences Fonctionnelles

### Sources de données

- **EF-001**: Le système DOIT vérifier la dernière version de Claude Code CLI via les releases GitHub
- **EF-002**: Le système DOIT vérifier les nouveaux skills sur skills.sh
- **EF-003**: Le système DOIT comparer avec la version locale installée

### Rapport et notifications

- **EF-004**: Le système DOIT afficher un résumé lisible en mode texte par défaut
- **EF-005**: Le système DOIT supporter un mode silencieux (aucune sortie si tout à jour)
- **EF-006**: Le système DOIT supporter une sortie JSON pour l'automatisation

### Robustesse

- **EF-007**: Le système DOIT fonctionner même si une source est inaccessible
- **EF-008**: Le système DOIT respecter un timeout configurable (défaut: 10 secondes par source)
- **EF-009**: Le système NE DOIT PAS bloquer le démarrage de session en cas d'échec

### Configuration

- **EF-010**: L'utilisateur DOIT pouvoir désactiver certaines sources de vérification
- **EF-011**: L'utilisateur DOIT pouvoir définir la fréquence de vérification automatique

---

## Cas Limites (Edge Cases)

| Situation | Comportement attendu |
|-----------|---------------------|
| Pas de connexion internet | Afficher "Vérification impossible (hors ligne)" et continuer |
| GitHub API rate limit atteint | Utiliser le cache si disponible, sinon avertir |
| skills.sh en maintenance | Ignorer cette source et continuer |
| Claude Code CLI non installé | Afficher un message d'aide pour l'installation |
| Version locale inconnue | Afficher "Version locale: inconnue" et comparer quand même |
| Première exécution (pas de cache) | Créer le cache et afficher tous les résultats |
| Token GitHub expiré | Fonctionner sans authentification (rate limit réduit) |

---

## Entités Clés

| Entité | Description | Attributs clés |
|--------|-------------|----------------|
| **VersionInfo** | Information de version d'un composant | source, version_locale, version_distante, date_release, changelog_url |
| **SkillInfo** | Information sur un skill communautaire | nom, description, auteur, date_publication, url_installation |
| **CheckResult** | Résultat d'une vérification | source, statut (à_jour/mise_à_jour/erreur), message |
| **CacheEntry** | Entrée du cache local | source, données, timestamp, ttl |

---

## Critères de Succès (mesurables)

| ID | Critère | Cible |
|----|---------|-------|
| **CS-001** | Temps d'exécution total | < 5 secondes avec cache, < 15 secondes sans cache |
| **CS-002** | Taux de succès des vérifications | > 95% (au moins 1 source sur 2 accessible) |
| **CS-003** | Taille du cache | < 100 Ko |
| **CS-004** | Précision des versions | 100% (aucun faux positif sur les versions) |
| **CS-005** | Adoption par les utilisateurs | > 50% utilisent la maintenance mensuelle |

---

## Hors Scope (explicitement exclus)

| Exclusion | Raison |
|-----------|--------|
| Mise à jour automatique | Risque trop élevé, l'utilisateur doit décider |
| Parsing du changelog complet | Complexité excessive, un lien suffit |
| Notification push/email | Hors périmètre CLI |
| Vérification des dépendances npm du socle | Déjà couvert par `npm audit` dans maintenance |
| Support Windows natif (hors WSL) | Le socle cible Linux/macOS/WSL |
| Multilangue | Le socle est en français, les messages aussi |
| Vérification releases claude-socle | Les utilisateurs gèrent manuellement via git pull |

---

## Hypothèses et Dépendances

### Hypothèses

1. **GitHub API publique accessible** - Les releases Claude Code sont publiques sur github.com/anthropics/claude-code
2. **skills.sh structure stable** - La structure du site permet l'extraction des skills récents
3. **Bash 4+ disponible** - Cohérent avec le reste du socle
4. **jq ou équivalent** - Pour le parsing JSON (vérification optionnelle)
5. **curl disponible** - Pour les requêtes HTTP

### Infrastructure existante à réutiliser

| Composant | Fichier | Ce qu'il fournit |
|-----------|---------|------------------|
| `version_gte()` | `scripts/lib/common.sh` | Comparaison semver (déjà battle-tested dans doctor.sh) |
| `info()`, `success()`, `warning()`, `error()` | `scripts/lib/common.sh` | Logging standardisé avec couleurs |
| `doctor.sh` | `scripts/doctor.sh` | Pattern de health-check, détection Claude CLI, gestion erreurs réseau |
| `update.sh` | `scripts/update.sh` | Pattern dry-run, backup, rapport structuré, changelog |
| Comptage en cache | `scripts/new-project.sh` | Pattern de cache en mémoire (à étendre en cache persistant) |
| VERSION | `VERSION` | Version du socle (1.27.0) |
| SessionStart hooks | `.claude/settings.json` | Point d'intégration pour notification au démarrage |

### Dépendances

| Dépendance | Type | Critique |
|------------|------|----------|
| `scripts/lib/common.sh` | Interne | Oui - fonctions utilitaires + `version_gte()` |
| GitHub API | Externe | Oui - source principale |
| skills.sh | Externe | Non - source secondaire |
| Fichier `VERSION` | Interne | Oui - version du socle |
| `~/.cache/claude-socle/` | Local | Non - créé automatiquement au premier lancement |

---

## Points de Clarification

> Questions à résoudre avant planification

1. ~~**[CLARIFICATION NÉCESSAIRE]** : Faut-il vérifier aussi les releases du repo claude-socle lui-même ?~~ → **Résolu** : Non, Claude Code CLI uniquement

2. ~~**[CLARIFICATION NÉCESSAIRE]** : Préférence pour le stockage du cache ?~~ → **Résolu** : `~/.cache/claude-socle/` (persistant entre reboots, conforme XDG, cohérent avec `~/.claude/`)

3. ~~**[CLARIFICATION NÉCESSAIRE]** : Niveau de détail pour les skills de skills.sh ?~~ → **Résolu** : Liste simple (nom + description courte + lien d'installation). Les descriptions complètes alourdiraient le rapport et le cache.

---

---

## Clarifications

### Session 2026-02-05
- Q: Faut-il vérifier les releases du repo claude-socle lui-même ? → **R: Non, Claude Code CLI uniquement** (les utilisateurs gèrent le socle via git pull)

### Session 2026-03-21
- Q: Préférence pour le stockage du cache ? → **R: `~/.cache/claude-socle/`** (persistant entre reboots, conforme XDG)
- Q: Niveau de détail pour les skills de skills.sh ? → **R: Liste simple** (nom + description courte + lien d'installation)
- Mise à jour des dépendances : ajout de l'infrastructure existante à réutiliser (`version_gte()`, `doctor.sh` patterns, `update.sh` patterns)
- Statut : Draft → **Ready** (3/3 clarifications résolues)

---

**Version**: 1.2 | **Créé par**: /work:work-specify | **Mis à jour**: 2026-03-21
