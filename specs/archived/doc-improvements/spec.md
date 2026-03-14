# Spécification : Amélioration de la Documentation Docusaurus

**Branche**: `feature/doc-improvements`
**Date**: 2026-01-20
**Statut**: Completed

## Résumé

Enrichir la documentation Docusaurus de claude-socle avec des tutoriels progressifs, une FAQ complète, des exemples de code prêts à l'emploi, des visuels explicatifs et un guide de migration. L'objectif est de transformer une documentation de référence exhaustive en une ressource accessible et actionnable pour tous les niveaux d'utilisateurs.

---

## User Stories (prioritisées)

### US1 - Tutoriels progressifs pour débutants (Priorité: P1) 🎯 MVP

**En tant que** nouvel utilisateur de claude-socle
**Je veux** suivre des tutoriels pas-à-pas avec des exemples concrets
**Afin de** comprendre comment utiliser les commandes sur un vrai projet

**Pourquoi P1**: Les nouveaux utilisateurs sont perdus face aux 111 commandes. Sans tutoriels, l'adoption est freinée car ils ne savent pas par où commencer.

**Test indépendant**: Un utilisateur sans expérience claude-socle peut compléter le tutoriel "Premier projet" en moins de 20 minutes et avoir créé son premier workflow fonctionnel.

**Critères d'acceptation**:

1. **Étant donné** un utilisateur sur la page tutoriels, **Quand** il clique sur "Premier projet", **Alors** il voit un guide structuré avec des étapes numérotées et des résultats attendus à chaque étape
2. **Étant donné** un utilisateur suivant un tutoriel, **Quand** il termine une étape, **Alors** il peut vérifier son résultat avec un exemple de sortie attendue
3. **Étant donné** un tutoriel, **Quand** l'utilisateur le consulte, **Alors** il voit un indicateur de durée estimée et de niveau de difficulté
4. **Étant donné** la fin d'un tutoriel, **Quand** l'utilisateur le termine, **Alors** il voit un lien vers le tutoriel suivant recommandé

---

### US2 - FAQ et résolution de problèmes (Priorité: P1) 🎯 MVP

**En tant qu'** utilisateur rencontrant un problème
**Je veux** trouver rapidement une solution dans une FAQ
**Afin de** débloquer ma situation sans attendre de l'aide externe

**Pourquoi P1**: Les utilisateurs bloqués abandonnent. Une FAQ réduit le taux d'abandon et le besoin de support.

**Test indépendant**: Un utilisateur avec un message d'erreur courant trouve la solution en moins de 2 minutes via la FAQ.

**Critères d'acceptation**:

1. **Étant donné** un utilisateur sur la page FAQ, **Quand** il recherche "commande not found", **Alors** il trouve une réponse expliquant les causes possibles et solutions
2. **Étant donné** une question dans la FAQ, **Quand** l'utilisateur la consulte, **Alors** il voit le problème, la cause et la solution clairement séparés
3. **Étant donné** la page troubleshooting, **Quand** l'utilisateur consulte une erreur, **Alors** il voit des commandes de diagnostic à exécuter
4. **Étant donné** un problème non résolu, **Quand** l'utilisateur ne trouve pas sa réponse, **Alors** il voit un lien pour signaler un nouveau problème

---

### US3 - Exemples de code prêts à l'emploi (Priorité: P1) 🎯 MVP

**En tant que** développeur découvrant une commande
**Je veux** voir des exemples complets avec entrée et sortie
**Afin de** comprendre ce que la commande produit concrètement

**Pourquoi P1**: Sans exemples concrets, les utilisateurs ne comprennent pas ce qu'une commande fait réellement.

**Test indépendant**: Un développeur peut copier un exemple, l'adapter à son projet et obtenir un résultat similaire en moins de 5 minutes.

**Critères d'acceptation**:

1. **Étant donné** une page d'exemple, **Quand** l'utilisateur la consulte, **Alors** il voit le contexte d'utilisation, la commande exécutée et le résultat complet
2. **Étant donné** un bloc de code, **Quand** l'utilisateur clique sur "Copier", **Alors** le code est copié dans son presse-papier
3. **Étant donné** un exemple, **Quand** il contient du code, **Alors** la coloration syntaxique est appliquée selon le langage
4. **Étant donné** les exemples, **Quand** l'utilisateur les parcourt, **Alors** ils sont organisés par domaine (Web, Mobile, API, etc.)

---

### US4 - Visuels et diagrammes explicatifs (Priorité: P1) 🎯 MVP

**En tant qu'** utilisateur visuel
**Je veux** voir des diagrammes et schémas
**Afin de** comprendre rapidement les concepts et workflows

**Pourquoi P1**: La documentation actuelle est dense. Des visuels permettent de scanner rapidement et de comprendre sans lire tout le texte.

**Test indépendant**: Un utilisateur peut identifier quelle commande utiliser en consultant uniquement le diagramme de décision, sans lire le texte.

**Critères d'acceptation**:

1. **Étant donné** la page des workflows, **Quand** l'utilisateur la consulte, **Alors** il voit un diagramme visuel du flux Explore → Plan → Code → Commit
2. **Étant donné** un diagramme de décision, **Quand** l'utilisateur répond aux questions, **Alors** il arrive à la commande recommandée
3. **Étant donné** une page de commande, **Quand** elle a un output caractéristique, **Alors** un screenshot ou ASCII art illustre le résultat
4. **Étant donné** les concepts (Commands vs Agents vs Skills), **Quand** l'utilisateur consulte la page, **Alors** un schéma compare visuellement les trois concepts

---

### US5 - Guide de migration vers claude-socle (Priorité: P2)

**En tant que** développeur avec un projet existant
**Je veux** un guide pour adopter claude-socle sur mon projet
**Afin de** bénéficier du socle sans repartir de zéro

**Pourquoi P2**: Important pour l'adoption sur des projets existants, mais moins urgent que les tutoriels pour nouveaux projets.

**Test indépendant**: Un développeur peut migrer un projet React existant vers claude-socle en suivant le guide en moins de 30 minutes.

**Critères d'acceptation**:

1. **Étant donné** un projet sans claude-socle, **Quand** l'utilisateur suit le guide, **Alors** il obtient une checklist des fichiers à créer/copier
2. **Étant donné** différents types de projets, **Quand** l'utilisateur consulte le guide, **Alors** il trouve une section spécifique à son stack (Web, Mobile, API)
3. **Étant donné** la migration terminée, **Quand** l'utilisateur vérifie son installation, **Alors** il a une commande de validation à exécuter
4. **Étant donné** un projet déjà avec Claude Code standard, **Quand** l'utilisateur migre, **Alors** il voit les différences et améliorations apportées par claude-socle

---

### US6 - Navigation améliorée par niveau (Priorité: P2)

**En tant qu'** utilisateur avec un niveau spécifique
**Je veux** filtrer le contenu par difficulté
**Afin de** trouver rapidement le contenu adapté à mon niveau

**Pourquoi P2**: Améliore l'expérience mais n'est pas bloquant pour l'utilisation.

**Test indépendant**: Un débutant peut filtrer pour ne voir que le contenu "Débutant" et naviguer sans être submergé.

**Critères d'acceptation**:

1. **Étant donné** une page de documentation, **Quand** elle a un niveau de difficulté, **Alors** un badge visible indique "Débutant", "Intermédiaire" ou "Avancé"
2. **Étant donné** la liste des tutoriels, **Quand** l'utilisateur la consulte, **Alors** les tutoriels sont ordonnés par difficulté croissante
3. **Étant donné** la fin d'une page, **Quand** l'utilisateur la termine, **Alors** il voit des suggestions "Voir aussi" vers des pages connexes

---

### US7 - Recherche de commande rapide (Priorité: P3)

**En tant qu'** utilisateur cherchant une commande spécifique
**Je veux** un outil de recherche interactif
**Afin de** trouver la bonne commande parmi les 111 disponibles

**Pourquoi P3**: Nice-to-have, la recherche Docusaurus existante couvre déjà ce besoin partiellement.

**Test indépendant**: Un utilisateur peut trouver la commande pour "créer un composant React" en moins de 10 secondes.

**Critères d'acceptation**:

1. **Étant donné** l'outil de recherche, **Quand** l'utilisateur tape "composant", **Alors** il voit /dev-component en suggestion
2. **Étant donné** une recherche, **Quand** des résultats s'affichent, **Alors** ils montrent le nom de la commande, son domaine et une description courte
3. **Étant donné** un résultat, **Quand** l'utilisateur clique dessus, **Alors** il est redirigé vers la page de documentation de la commande

---

## Exigences Fonctionnelles

### Tutoriels
- **EF-001**: Le système DOIT afficher 8 tutoriels couvrant les cas d'usage principaux
- **EF-002**: Chaque tutoriel DOIT avoir un titre, une durée estimée, un niveau et des prérequis
- **EF-003**: Chaque étape de tutoriel DOIT montrer la commande à exécuter et le résultat attendu
- **EF-004**: Les tutoriels DOIVENT être accessibles depuis le menu principal de navigation

### FAQ
- **EF-005**: La FAQ DOIT contenir au minimum 20 questions organisées par catégorie
- **EF-006**: Chaque réponse DOIT suivre le format Problème → Cause → Solution
- **EF-007**: La page troubleshooting DOIT lister les erreurs courantes avec diagnostics
- **EF-008**: La recherche dans la FAQ DOIT fonctionner sur le texte complet des questions et réponses

### Exemples
- **EF-009**: Le système DOIT proposer au moins 15 exemples de code complets
- **EF-010**: Chaque exemple DOIT avoir un bouton "Copier" fonctionnel
- **EF-011**: Les exemples DOIVENT être organisés par domaine (Web, Mobile, API, Ops)
- **EF-012**: Chaque exemple DOIT montrer l'entrée (contexte/commande) et la sortie (résultat)

### Visuels
- **EF-013**: Le système DOIT inclure un diagramme de décision "Quelle commande utiliser"
- **EF-014**: Le workflow principal DOIT être illustré par un diagramme visuel
- **EF-015**: La comparaison Commands/Agents/Skills DOIT avoir un schéma explicatif
- **EF-016**: Les diagrammes DOIVENT être en SVG ou Mermaid pour être modifiables

### Migration
- **EF-017**: Le guide de migration DOIT couvrir au moins 3 types de projets (Web, Mobile, API)
- **EF-018**: Le guide DOIT inclure une checklist vérifiable
- **EF-019**: Une commande de validation DOIT confirmer que la migration est réussie

### Navigation
- **EF-020**: Les badges de niveau DOIVENT être visibles sur les pages concernées
- **EF-021**: Les liens "Voir aussi" DOIVENT apparaître en fin de page pertinente
- **EF-022**: La sidebar DOIT inclure la nouvelle section Tutoriels

---

## Cas Limites (Edge Cases)

- **CL-001**: Que se passe-t-il si un utilisateur accède à un tutoriel sans avoir les prérequis ? → Afficher clairement les prérequis en haut avec liens
- **CL-002**: Comment gérer les tutoriels obsolètes après une mise à jour de claude-socle ? → Ajouter une date de dernière vérification et un système de revue
- **CL-003**: Que faire si un exemple ne fonctionne plus après une mise à jour ? → Tests automatisés des exemples dans la CI
- **CL-004**: Comment gérer les questions FAQ sans réponse claire ? → Section "Problèmes non résolus" avec lien vers issues GitHub
- **CL-005**: Comportement si l'utilisateur est sur mobile ? → Les diagrammes doivent être responsives ou avoir une version simplifiée

---

## Entités Clés

| Entité | Description | Attributs clés |
|--------|-------------|----------------|
| Tutoriel | Guide pas-à-pas pour accomplir une tâche | id, titre, durée, niveau, prérequis, étapes[] |
| Étape | Une action dans un tutoriel | ordre, instruction, commande, résultat_attendu |
| Question FAQ | Question fréquente avec réponse | catégorie, question, problème, cause, solution |
| Exemple | Code d'exemple complet | domaine, titre, contexte, commande, résultat, langage |
| Diagramme | Visuel explicatif | type (workflow/décision/comparaison), format, alt_text |

---

## Critères de Succès (mesurables)

- **CS-001**: 100% des tutoriels ont une durée estimée vérifiée (± 5 minutes)
- **CS-002**: La FAQ couvre 80% des questions posées dans les issues GitHub existantes
- **CS-003**: Chaque exemple de code est exécutable et produit le résultat documenté
- **CS-004**: Les diagrammes sont visibles et lisibles sur écrans de 320px à 1920px
- **CS-005**: Un nouvel utilisateur peut compléter le tutoriel "Premier projet" en < 20 minutes
- **CS-006**: Le guide de migration est validé sur au moins 3 projets réels de types différents
- **CS-007**: La recherche dans la FAQ retourne des résultats pertinents dans 95% des cas

---

## Hors Scope (explicitement exclus)

- **HS-001**: Vidéos et screencasts - sera traité dans une future itération
- **HS-002**: Traduction en anglais - documentation reste en français pour cette version
- **HS-003**: Tutoriels interactifs avec sandbox intégré - trop complexe pour le MVP
- **HS-004**: Système de feedback/rating sur les pages - sera ajouté après le lancement
- **HS-005**: Génération automatique de tutoriels depuis les commandes - hors périmètre
- **HS-006**: Application mobile de la documentation - hors périmètre

---

## Hypothèses et Dépendances

### Hypothèses
- Les utilisateurs ont déjà Claude Code installé et fonctionnel
- Les utilisateurs ont des connaissances de base en ligne de commande
- La structure actuelle de Docusaurus (sidebars.ts, components) est conservée
- Les scripts de génération existants (generate-all.ts) restent fonctionnels

### Dépendances
- Docusaurus 3.7.0 déjà configuré dans le projet
- Composants React existants (CommandCard, AgentCard, etc.) réutilisables
- Accès au dépôt GitHub pour les liens vers issues
- Mermaid ou SVG supporté par Docusaurus pour les diagrammes

---

## Points de Clarification (RÉSOLUS)

> Décisions prises le 2026-01-20

1. **[RÉSOLU]**: Les tutoriels utilisent un **projet exemple fourni** (repo claude-socle-examples)
   - Avantage : Plus rapide pour l'utilisateur, exemples testés et fonctionnels
   - Les tutoriels débutants utilisent le projet fourni, les avancés peuvent créer from scratch

2. **[RÉSOLU]**: Les diagrammes sont en **Mermaid**
   - Avantage : Modifiables en markdown, versionnables, intégrés à Docusaurus
   - Cohérent avec l'approche documentation-as-code

3. **[RÉSOLU]**: La FAQ est **une seule page avec sections et ancres**
   - Avantage : Recherche facile, tout au même endroit
   - Table des matières en haut pour navigation rapide

---

## Récapitulatif des Priorités

| Priorité | User Stories | Valeur |
|----------|--------------|--------|
| **P1 MVP** | US1 (Tutoriels), US2 (FAQ), US3 (Exemples), US4 (Visuels) | Rend la documentation actionnable |
| **P2** | US5 (Migration), US6 (Navigation niveau) | Améliore l'adoption et l'expérience |
| **P3** | US7 (Recherche rapide) | Nice-to-have, optimisation |

---

## Prochaine étape

Une fois cette spécification validée, utiliser `/work-clarify` pour résoudre les 3 points de clarification, puis `/work-plan` pour créer le plan d'implémentation technique.
