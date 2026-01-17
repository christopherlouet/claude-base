# Spécification : [NOM DE LA FEATURE]

**Branche**: `feature/[nom-court]`
**Date**: [DATE]
**Statut**: Draft | En review | Validé
**Input**: Description utilisateur: "$ARGUMENTS"

---

## Résumé

[1-3 phrases décrivant ce que la feature apporte à l'utilisateur, focalisé sur la VALEUR]

---

## User Stories (prioritisées)

<!--
  IMPORTANT: Les User Stories doivent être PRIORITISÉES comme des parcours utilisateur.
  Chaque story doit être INDÉPENDAMMENT TESTABLE - si vous n'implémentez QU'UNE seule,
  vous devez avoir un MVP fonctionnel qui apporte de la valeur.

  Priorités: P1 = MVP essentiel, P2 = Important, P3 = Nice-to-have

  Chaque story doit être:
  - Développable indépendamment
  - Testable indépendamment
  - Déployable indépendamment
  - Démontrable aux utilisateurs
-->

### US1 - [Titre court] (Priorité: P1) 🎯 MVP

**En tant que** [type d'utilisateur]
**Je veux** [action/fonctionnalité]
**Afin de** [bénéfice/valeur]

**Pourquoi P1**: [Explication de la valeur et pourquoi cette priorité]

**Test indépendant**: [Comment cette story peut être testée seule]

**Critères d'acceptation**:

1. **Étant donné** [état initial], **Quand** [action], **Alors** [résultat attendu]
2. **Étant donné** [état initial], **Quand** [action], **Alors** [résultat attendu]

---

### US2 - [Titre court] (Priorité: P2)

**En tant que** [type d'utilisateur]
**Je veux** [action/fonctionnalité]
**Afin de** [bénéfice/valeur]

**Pourquoi P2**: [Explication]

**Test indépendant**: [Description]

**Critères d'acceptation**:

1. **Étant donné** [état initial], **Quand** [action], **Alors** [résultat attendu]

---

### US3 - [Titre court] (Priorité: P3)

**En tant que** [type d'utilisateur]
**Je veux** [action/fonctionnalité]
**Afin de** [bénéfice/valeur]

**Pourquoi P3**: [Explication]

**Test indépendant**: [Description]

**Critères d'acceptation**:

1. **Étant donné** [état initial], **Quand** [action], **Alors** [résultat attendu]

---

## Cas Limites (Edge Cases)

<!--
  ACTION REQUISE: Remplacer ces placeholders par les vrais cas limites.
-->

- Que se passe-t-il quand [condition limite] ?
- Comment le système gère-t-il [scénario d'erreur] ?
- Comportement avec [données vides/invalides] ?

---

## Exigences Fonctionnelles

<!--
  ACTION REQUISE: Remplacer ces placeholders par les vraies exigences.
  Chaque exigence doit être TESTABLE et VÉRIFIABLE.
-->

- **EF-001**: Le système DOIT [capacité spécifique, ex: "permettre la création de comptes"]
- **EF-002**: Le système DOIT [capacité spécifique, ex: "valider les adresses email"]
- **EF-003**: L'utilisateur DOIT pouvoir [interaction clé, ex: "réinitialiser son mot de passe"]
- **EF-004**: Le système DOIT [exigence données, ex: "persister les préférences utilisateur"]
- **EF-005**: Le système DOIT [comportement, ex: "journaliser les événements de sécurité"]

*Exemple de marquage des exigences peu claires:*

- **EF-006**: Le système DOIT authentifier les utilisateurs via [CLARIFICATION NÉCESSAIRE: méthode non spécifiée - email/password, SSO, OAuth?]

---

## Entités Clés (si données impliquées)

<!--
  Inclure UNIQUEMENT si la feature implique des données persistées.
  Décrire les entités sans détails d'implémentation (pas de types de colonnes, pas de SQL).
-->

| Entité | Ce qu'elle représente | Attributs clés | Relations |
|--------|----------------------|----------------|-----------|
| [Entité 1] | [Description] | id, nom, ... | [Lien vers Entité 2] |
| [Entité 2] | [Description] | ... | ... |

---

## Critères de Succès (mesurables)

<!--
  ACTION REQUISE: Définir des critères MESURABLES.
  Doivent être technology-agnostic et vérifiables.

  ✅ Bon: "L'utilisateur peut compléter l'inscription en moins de 2 minutes"
  ❌ Mauvais: "L'inscription est rapide" (vague)
  ❌ Mauvais: "L'API répond en < 200ms" (trop technique, utiliser perspective utilisateur)
-->

- **CS-001**: [Métrique mesurable, ex: "Utilisateurs peuvent compléter la tâche principale en < 2 minutes"]
- **CS-002**: [Métrique système, ex: "Support de 1000 utilisateurs simultanés sans dégradation"]
- **CS-003**: [Métrique satisfaction, ex: "90% des utilisateurs réussissent la tâche au premier essai"]
- **CS-004**: [Métrique business, ex: "Réduction de 50% des tickets support liés à [X]"]

---

## Hors Scope (explicitement exclus)

<!--
  Lister ce qui N'EST PAS inclus dans cette feature.
  Aide à éviter le scope creep.
-->

- [Fonctionnalité X] - sera traitée dans une future itération
- [Cas d'usage Y] - hors périmètre de cette version
- [Intégration Z] - phase 2

---

## Hypothèses et Dépendances

### Hypothèses

- [Hypothèse 1 sur le contexte ou les utilisateurs]
- [Hypothèse 2 sur l'environnement]

### Dépendances

- [Dépendance interne: autre feature/module]
- [Dépendance externe: service tiers, API]

---

## Points de Clarification

<!--
  Maximum 3 points de clarification.
  Utiliser UNIQUEMENT pour des décisions qui impactent significativement le scope ou l'UX.
  Pour le reste, faire des choix éclairés basés sur les bonnes pratiques.
-->

- [CLARIFICATION NÉCESSAIRE: question spécifique qui impacte le scope]
- [CLARIFICATION NÉCESSAIRE: choix significatif entre plusieurs options]

---

## Checklist de validation

### Complétude
- [ ] Toutes les user stories ont des critères d'acceptation
- [ ] Aucun détail d'implémentation (langages, frameworks, APIs)
- [ ] Focus sur la valeur utilisateur et les besoins métier
- [ ] Compréhensible par un non-développeur

### Exigences
- [ ] Pas de marqueur [CLARIFICATION NÉCESSAIRE] non résolu (max 3 autorisés)
- [ ] Exigences testables et non ambiguës
- [ ] Critères de succès mesurables
- [ ] Critères technology-agnostic

### Prêt pour planification
- [ ] Toutes les exigences fonctionnelles ont des critères clairs
- [ ] User stories couvrent les flux principaux
- [ ] La feature apporte une valeur mesurable

---

**Version**: 1.0 | **Créé**: [DATE] | **Dernière modification**: [DATE]
