# Patterns Agent Teams Pre-configures

4 patterns prets a l'emploi pour les cas d'usage les plus courants du socle.

---

## Pattern 1 : Audit Parallele

**Teammates** : 3-4 agents
**Duree typique** : 5-15 minutes
**Cas d'usage** : Audit qualite complet avant release ou deploiement

### Roles

| Role | Focus | Prompt de spawn recommande |
|------|-------|---------------------------|
| **security-reviewer** | OWASP Top 10, injections, auth, donnees sensibles | "Audite le code pour les vulnerabilites OWASP Top 10. Focus sur l'authentification, les injections SQL/XSS, et les donnees sensibles. Produis un rapport avec severite (critique/haute/moyenne/faible)." |
| **perf-analyst** | Core Web Vitals, requetes lentes, bundle size | "Analyse les performances de l'application. Focus sur les requetes lentes, le bundle size, le lazy loading, et les Core Web Vitals. Mesure les metriques si possible." |
| **a11y-checker** | WCAG 2.1 AA, navigation clavier, lecteurs ecran | "Verifie l'accessibilite WCAG 2.1 niveau AA. Focus sur le contraste, la navigation clavier, les attributs ARIA, et la compatibilite lecteurs d'ecran." |
| **design-reviewer** (optionnel) | UI/UX, coherence visuelle, responsive | "Audite le design UI/UX. Verifie la coherence visuelle, le responsive, les espacements, et les bonnes pratiques web." |

### Coordination

- Les 3-4 agents travaillent **independamment** (pas de dependances)
- Chaque agent produit son propre rapport
- Le lead **synthetise** les rapports en un document unique avec priorites

### Prompt de lancement

```
Cree une equipe pour auditer ce projet :
- security-reviewer : audit OWASP Top 10
- perf-analyst : analyse performance et Core Web Vitals
- a11y-checker : accessibilite WCAG 2.1 AA
Chacun produit un rapport. Synthetise les resultats quand tous ont termine.
```

**Complement**: pour les equipes Enterprise/Team, Claude Code Security peut completer cet audit avec un scan de vulnerabilites approfondi (raisonnement sur les flux de donnees et patterns architecturaux).

---

## Pattern 2 : Feature en Equipe

**Teammates** : 2-3 agents
**Duree typique** : 15-45 minutes
**Cas d'usage** : Developpement d'une feature multi-couches (frontend + backend + tests)

### Roles

| Role | Focus | Prompt de spawn recommande |
|------|-------|---------------------------|
| **backend-dev** | API, services, modeles, base de donnees | "Implemente la partie backend de [feature]. Cree les services dans `src/services/`, les modeles, et les endpoints API. Ne touche PAS aux fichiers frontend." |
| **frontend-dev** | Composants UI, hooks, pages | "Implemente la partie frontend de [feature]. Cree les composants dans `src/components/`, les hooks, et les pages. Attends que le backend definisse les types avant de consommer l'API." |
| **test-writer** | Tests unitaires, integration, e2e | "Ecris les tests pour [feature]. Commence par les tests unitaires (TDD), puis les tests d'integration. Couvre les edge cases et les scenarios d'erreur." |

### Coordination

- **backend-dev** commence en premier (definit les types/interfaces partages)
- **frontend-dev** attend les types puis travaille en parallele
- **test-writer** peut commencer les tests unitaires (TDD) immediatement
- Le lead gere les dependances via la task list

### Prompt de lancement

```
Cree une equipe pour implementer [feature] :
- backend-dev : services et API dans src/services/ et src/api/
- frontend-dev : composants et hooks dans src/components/ et src/hooks/
- test-writer : tests dans tests/
Assure-toi que le backend definisse les types en premier.
Le test-writer commence les tests en TDD des le debut.
```

### Gestion des dependances

```
Task 1: [backend-dev] Definir les types/interfaces  → Pas de blocage
Task 2: [test-writer] Ecrire les tests unitaires     → Pas de blocage
Task 3: [backend-dev] Implementer le service          → Depend de Task 1
Task 4: [frontend-dev] Creer les composants           → Depend de Task 1
Task 5: [test-writer] Tests d'integration             → Depend de Task 3, Task 4
```

---

## Pattern 3 : Debug Collaboratif

**Teammates** : 3-5 agents
**Duree typique** : 10-30 minutes
**Cas d'usage** : Investigation de bugs complexes avec hypotheses concurrentes

### Roles

| Role | Focus | Prompt de spawn recommande |
|------|-------|---------------------------|
| **investigator-1** | Hypothese A (ex: probleme de donnees) | "Investigate l'hypothese que le bug vient de [hypothese A]. Cherche des preuves dans [zone du code]. Partage tes decouvertes avec les autres agents." |
| **investigator-2** | Hypothese B (ex: probleme de logique) | "Investigate l'hypothese que le bug vient de [hypothese B]. Cherche des preuves dans [zone du code]. Challenge les decouvertes des autres." |
| **investigator-3** | Hypothese C (ex: probleme d'environnement) | "Investigate l'hypothese que le bug vient de [hypothese C]. Verifie la configuration et l'environnement. Partage tes preuves." |

### Coordination

- Chaque agent explore une **hypothese differente** en parallele
- Les agents **partagent leurs decouvertes** via la messagerie
- Mode **adversarial** : chaque agent tente de **refuter** les hypotheses des autres
- Le lead facilite le **debat** et synthetise le **consensus**

### Prompt de lancement

```
Cree une equipe pour investiguer ce bug : [description du bug]
Spawne 3 agents avec des hypotheses differentes :
- investigator-1 : hypothese que c'est un probleme de [A]
- investigator-2 : hypothese que c'est un probleme de [B]
- investigator-3 : hypothese que c'est un probleme de [C]
Demande-leur de partager leurs preuves et de challenger les hypotheses des autres.
Synthetise le consensus quand un pattern emerge.
```

---

## Pattern 4 : Review Parallele

**Teammates** : 3 agents
**Duree typique** : 5-15 minutes
**Cas d'usage** : Code review approfondie multi-criteres

### Roles

| Role | Focus | Prompt de spawn recommande |
|------|-------|---------------------------|
| **security-reviewer** | Vulnerabilites, auth, donnees sensibles | "Review le code pour les problemes de securite. Focus sur les injections, l'authentification, et les donnees sensibles. Attribue une severite a chaque finding." |
| **perf-reviewer** | Complexite algorithmique, fuites memoire, N+1 | "Review le code pour les problemes de performance. Focus sur la complexite algorithmique, les requetes N+1, et les fuites memoire potentielles." |
| **quality-reviewer** | Couverture tests, lisibilite, patterns | "Review le code pour la qualite generale. Verifie la couverture de tests, la lisibilite, le respect des patterns du projet, et identifie la dette technique." |

### Coordination

- Les 3 agents reviewent **simultanement** les memes fichiers (lecture seule)
- Chaque agent produit une **liste de findings** avec severite
- Le lead **consolide** les reviews en un rapport unique

### Prompt de lancement

```
Cree une equipe pour reviewer les changements de la branche actuelle :
- security-reviewer : focus vulnerabilites et securite
- perf-reviewer : focus performance et complexite
- quality-reviewer : focus qualite, tests et patterns
Chacun produit une liste de findings. Consolide en un rapport unique.
```

---

## Creer un pattern personnalise

Pour les cas non couverts, decrivez la structure en langage naturel :

```
Cree une equipe de [N] agents pour [objectif] :
- [role-1] : [focus et instructions specifiques]
- [role-2] : [focus et instructions specifiques]
- [role-3] : [focus et instructions specifiques]
[Instructions de coordination et de synthese]
```

### Bonnes pratiques pour les patterns custom

- Chaque agent doit avoir un **scope clair et distinct**
- Preciser les **fichiers/zones** que chaque agent doit examiner
- Definir les **dependances** si l'ordre compte
- Indiquer comment le lead doit **synthetiser** les resultats
- Limiter a **2-5 agents** pour maintenir la coordination
