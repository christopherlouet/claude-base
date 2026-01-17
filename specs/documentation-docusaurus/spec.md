# Spécification : Documentation Docusaurus pour claude-socle

**Branche**: `feature/documentation-docusaurus`
**Date**: 2025-01-17
**Statut**: Draft
**Input**: "Créer un guide complet au format Docusaurus publiable sur GitHub Pages (privé)"

---

## Résumé

Créer une documentation complète et interactive pour le projet claude-socle, publiable sur GitHub Pages en privé, permettant aux utilisateurs de découvrir, comprendre et utiliser efficacement les 100 commandes, 37 agents, 24 skills et autres composants du socle.

---

## User Stories (prioritisées)

### US1 - Découvrir et démarrer rapidement (Priorité: P1) 🎯 MVP

**En tant que** nouvel utilisateur de claude-socle
**Je veux** comprendre rapidement ce qu'est le socle et comment démarrer
**Afin de** être productif en moins de 5 minutes

**Pourquoi P1**: Sans onboarding rapide, les utilisateurs abandonnent avant de voir la valeur.

**Test indépendant**: Un utilisateur peut installer et lancer sa première commande en suivant uniquement la doc.

**Critères d'acceptation**:

1. **Étant donné** un utilisateur sur la page d'accueil, **Quand** il lit l'introduction, **Alors** il comprend la valeur du socle en moins de 30 secondes
2. **Étant donné** un utilisateur motivé, **Quand** il suit le Quick Start, **Alors** il exécute sa première commande en moins de 5 minutes
3. **Étant donné** un utilisateur curieux, **Quand** il consulte l'architecture, **Alors** il comprend la différence entre Commands/Agents/Skills

---

### US2 - Trouver la bonne commande (Priorité: P1) 🎯 MVP

**En tant que** utilisateur cherchant une fonctionnalité
**Je veux** trouver rapidement la commande adaptée à mon besoin
**Afin de** ne pas perdre de temps à chercher dans 100 commandes

**Pourquoi P1**: C'est le use case principal de la documentation.

**Test indépendant**: Un utilisateur trouve la commande appropriée en moins de 30 secondes.

**Critères d'acceptation**:

1. **Étant donné** un utilisateur cherchant "sécurité", **Quand** il utilise la recherche, **Alors** il trouve `/qa-security` et `/qa-audit` en premier
2. **Étant donné** un utilisateur sur la page Commands, **Quand** il navigue par domaine, **Alors** il voit les 9 catégories avec descriptions
3. **Étant donné** un utilisateur consultant une commande, **Quand** il lit la page, **Alors** il voit description, usage, exemples et commandes liées

---

### US3 - Comprendre les workflows complets (Priorité: P2)

**En tant que** développeur souhaitant adopter le workflow complet
**Je veux** voir des exemples de workflows de bout en bout
**Afin de** appliquer les bonnes pratiques Explore→Plan→Code→Commit

**Pourquoi P2**: Important pour l'adoption mais pas bloquant pour démarrer.

**Test indépendant**: Un utilisateur peut reproduire un workflow complet feature/bugfix/release.

**Critères d'acceptation**:

1. **Étant donné** un utilisateur sur la page Workflows, **Quand** il choisit "Nouvelle Feature", **Alors** il voit le diagramme et les étapes détaillées
2. **Étant donné** un utilisateur suivant un workflow, **Quand** il clique sur chaque étape, **Alors** il accède à la documentation de la commande correspondante

---

### US4 - Référence technique complète (Priorité: P2)

**En tant que** utilisateur avancé
**Je veux** accéder à une référence exhaustive de toutes les commandes/agents/skills
**Afin de** maîtriser toutes les capacités du socle

**Pourquoi P2**: Nécessaire pour les power users mais pas pour l'onboarding.

**Test indépendant**: Toutes les 100 commandes sont documentées avec le même format.

**Critères d'acceptation**:

1. **Étant donné** un utilisateur sur la page Reference, **Quand** il consulte la matrice des commandes, **Alors** il voit les 100 commandes avec domaine, description et tags
2. **Étant donné** un utilisateur consultant une commande, **Quand** il lit la page complète, **Alors** il trouve: description, usage, processus, exemples, best practices, pièges, commandes liées

---

### US5 - Guides par technologie (Priorité: P3)

**En tant que** développeur spécialisé (Web/Mobile/API/Data)
**Je veux** un guide adapté à ma stack technologique
**Afin de** voir les commandes pertinentes pour mon contexte

**Pourquoi P3**: Nice-to-have, les guides existent déjà partiellement.

**Test indépendant**: Un développeur Flutter trouve toutes les commandes Flutter-spécifiques.

**Critères d'acceptation**:

1. **Étant donné** un développeur Flutter, **Quand** il consulte le guide Mobile, **Alors** il voit `/dev-flutter`, `/dev-supabase`, `/qa-mobile` et le workflow recommandé

---

## Cas Limites (Edge Cases)

- Que se passe-t-il si l'utilisateur cherche une commande qui n'existe pas ? → Suggestions de commandes similaires
- Comment gérer les commandes dépréciées à l'avenir ? → Bandeau "deprecated" + redirection
- Comportement avec JavaScript désactivé ? → Contenu statique lisible, recherche non fonctionnelle

---

## Exigences Fonctionnelles

### Navigation et Structure

- **EF-001**: Le site DOIT avoir une sidebar navigable avec toutes les catégories
- **EF-002**: Le site DOIT supporter la recherche full-text (Algolia DocSearch ou local)
- **EF-003**: Chaque page DOIT avoir un fil d'Ariane (breadcrumb)
- **EF-004**: Le site DOIT être responsive (mobile-friendly)

### Contenu

- **EF-005**: Chaque commande (100) DOIT avoir sa propre page avec format standardisé
- **EF-006**: Chaque agent (37) DOIT être documenté avec son modèle, outils et déclencheurs
- **EF-007**: Chaque skill (24) DOIT être documenté avec mots-clés et exemples
- **EF-008**: Chaque règle (15) DOIT être documentée avec fichiers concernés et exemples

### Technique

- **EF-009**: Le site DOIT être généré avec Docusaurus 3.x
- **EF-010**: Le site DOIT être déployable sur GitHub Pages
- **EF-011**: Le site DOIT supporter le versioning de la documentation
- **EF-012**: Le build DOIT être automatisé via GitHub Actions

### SEO et Accessibilité

- **EF-013**: Chaque page DOIT avoir des meta tags (title, description, keywords)
- **EF-014**: Le site DOIT être accessible (WCAG 2.1 AA)
- **EF-015**: Le site DOIT avoir un sitemap.xml

---

## Entités Clés

| Entité | Ce qu'elle représente | Attributs clés | Relations |
|--------|----------------------|----------------|-----------|
| Command | Une commande /xxx | nom, description, domaine, usage, exemples | → Agents, Skills |
| Agent | Un sub-agent isolé | nom, modèle, outils, déclencheurs | → Commands |
| Skill | Un skill auto-déclenché | nom, mots-clés, context, allowed-tools | → Commands |
| Rule | Une règle par path | nom, paths, conventions | → Technologies |
| Workflow | Un flux de travail | nom, étapes, commandes | → Commands |
| Guide | Un guide thématique | nom, technologie, commandes recommandées | → Commands, Workflows |

---

## Critères de Succès (mesurables)

- **CS-001**: 100% des commandes documentées avec format standardisé
- **CS-002**: Temps moyen pour trouver une commande < 30 secondes (via recherche)
- **CS-003**: Quick Start complété en < 5 minutes par un nouvel utilisateur
- **CS-004**: Score Lighthouse Performance > 90
- **CS-005**: Score Lighthouse Accessibility > 90
- **CS-006**: Build time < 2 minutes
- **CS-007**: Déploiement automatique sur push main

---

## Hors Scope (explicitement exclus)

- Traduction i18n (anglais) - sera traitée dans une future itération
- Blog intégré - pas nécessaire pour v1
- Authentification pour accès privé - GitHub Pages privé suffit
- Analytics avancés - Google Analytics basique suffit
- Tutoriels vidéo - phase 2

---

## Hypothèses et Dépendances

### Hypothèses

- Le contenu des fichiers .md existants est utilisable avec adaptations mineures
- Docusaurus 3.x est stable et adapté au besoin
- GitHub Pages privé est disponible (repo privé)

### Dépendances

- Node.js 18+ pour Docusaurus
- GitHub Actions pour CI/CD
- Algolia DocSearch (optionnel, peut utiliser recherche locale)

---

## Architecture Technique

### Stack

| Composant | Technologie |
|-----------|-------------|
| Framework | Docusaurus 3.x |
| Langage | TypeScript/React |
| Styling | CSS Modules / Infima |
| Search | @docusaurus/plugin-search-local |
| Hosting | GitHub Pages |
| CI/CD | GitHub Actions |

### Structure des fichiers

```
website/
├── docusaurus.config.ts      # Configuration principale
├── sidebars.ts               # Configuration sidebar
├── src/
│   ├── components/           # Composants React custom
│   ├── css/                  # Styles custom
│   └── pages/                # Pages custom (landing)
├── docs/
│   ├── intro/                # Introduction (4 pages)
│   ├── workflow/             # Workflows (8 pages)
│   ├── commands/             # Commandes (100 pages)
│   │   ├── work/
│   │   ├── dev/
│   │   ├── qa/
│   │   ├── ops/
│   │   ├── doc/
│   │   ├── biz/
│   │   ├── growth/
│   │   ├── data/
│   │   └── legal/
│   ├── agents/               # Agents (37 pages)
│   ├── skills/               # Skills (24 pages)
│   ├── rules/                # Rules (15 pages)
│   ├── guides/               # Guides thématiques
│   └── reference/            # Référence (matrices)
├── static/
│   └── img/                  # Images et diagrammes
└── scripts/
    └── generate-docs.ts      # Script de génération auto
```

---

## Checklist de validation

### Complétude
- [x] Toutes les user stories ont des critères d'acceptation
- [x] Aucun détail d'implémentation technique excessif
- [x] Focus sur la valeur utilisateur et les besoins métier
- [x] Compréhensible par un non-développeur

### Exigences
- [x] Pas de marqueur [CLARIFICATION NÉCESSAIRE] non résolu
- [x] Exigences testables et non ambiguës
- [x] Critères de succès mesurables
- [x] Critères technology-agnostic (sauf stack choisie)

### Prêt pour planification
- [x] Toutes les exigences fonctionnelles ont des critères clairs
- [x] User stories couvrent les flux principaux
- [x] La feature apporte une valeur mesurable

---

**Version**: 1.0 | **Créé**: 2025-01-17 | **Dernière modification**: 2025-01-17
