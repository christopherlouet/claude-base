# Spécification : Migration des docs socle vers `.claude/docs/`

**Date** : 2026-04-28
**Auteur** : Chris
**Statut** : Validé (décisions A + 2B confirmées)

---

## Contexte

Aujourd'hui, l'installation du socle (`new-project.sh --simple` et `update.sh`) copie quatre groupes de fichiers dans le dossier `docs/` du projet utilisateur :

- `docs/reference/` (catalogues @import-és par CLAUDE.md)
- `docs/guides/` (17 guides référencés en table CLAUDE.md)
- `docs/ARCHITECTURE.md` (meta-doc du socle)
- `docs/WORKFLOWS.md` (meta-doc du socle)

**Problème** : `docs/` est le territoire du projet utilisateur. La collision est frontale : pve-home a son propre `docs/ARCHITECTURE.md` (Mermaid, infra Terraform/Proxmox) qui s'est fait écraser par celui du socle pendant l'install. Toute mise à jour du socle peut clobberer la doc du user.

## Décision

- **(A)** Retirer `ARCHITECTURE.md` et `WORKFLOWS.md` de l'install — ce sont des meta-docs du socle, accessibles via le repo GitHub et le website Docusaurus. Pas de raison de les copier.
- **(2B)** Source duale : le **repo socle** conserve `docs/` comme source de vérité (cohérent avec website Docusaurus + autres docs `CHEATSHEET.md`, `GUIDE.md` etc.). L'**install / update** place les fichiers sous `.claude/docs/` chez l'utilisateur. Le **CLAUDE.md généré** pour l'utilisateur référence `@.claude/docs/...`.

## User Stories

### US1 — Install simple vers `.claude/docs/` (P1 — MVP)

**En tant que** utilisateur installant le socle dans un projet existant
**Je veux** que `new-project.sh --simple` copie la doc socle sous `.claude/docs/` (et non plus sous `docs/`)
**Afin de** ne pas polluer ni écraser ma propre arborescence `docs/`.

#### Critères d'acceptation

1. **Étant donné** un projet vierge sans `docs/`, **Quand** `new-project.sh --simple .` est exécuté, **Alors** `docs/` n'est pas créé et `.claude/docs/reference/`, `.claude/docs/guides/` existent avec le contenu attendu.
2. **Étant donné** un projet avec un `docs/ARCHITECTURE.md` existant, **Quand** `new-project.sh --simple .` est exécuté, **Alors** `docs/ARCHITECTURE.md` n'est PAS modifié.
3. **Étant donné** une install qui réussit, **Quand** je lis `CLAUDE.md`, **Alors** les `@imports` pointent vers `@.claude/docs/reference/...` et la table de références utilise `.claude/docs/...`.
4. **Étant donné** une install qui réussit, **Quand** je cherche `ARCHITECTURE.md` ou `WORKFLOWS.md` dans le projet, **Alors** ces fichiers ne sont PAS présents (ni dans `docs/`, ni dans `.claude/docs/`).

### US2 — Update et migration legacy (P2)

**En tant que** utilisateur ayant déjà installé le socle (layout legacy `docs/reference/`)
**Je veux** que `update.sh` détecte l'ancien layout et migre proprement vers `.claude/docs/`
**Afin de** ne pas perdre mes personnalisations et garder un projet cohérent.

#### Critères d'acceptation

1. **Étant donné** un projet avec `docs/reference/` legacy et `CLAUDE.md` contenant `@docs/reference/...`, **Quand** `update.sh` est exécuté, **Alors** le contenu est déplacé sous `.claude/docs/reference/`, les `@imports` sont réécrits vers `@.claude/docs/reference/...`, et l'ancien `docs/reference/` est supprimé (sauf si l'utilisateur a personnalisé : voir CA-3).
2. **Étant donné** un projet sans `.claude/docs/` ni `docs/reference/`, **Quand** `update.sh` est exécuté, **Alors** `.claude/docs/` est créé avec le contenu du socle et `CLAUDE.md` est mis à jour avec les nouveaux `@imports`.
3. **Étant donné** un fichier `docs/guides/WEB-GUIDE.md` modifié localement (diff vs socle), **Quand** `update.sh` migre, **Alors** la version locale est préservée sous `.claude/docs/guides/WEB-GUIDE.md` (pas écrasée).
4. **Étant donné** des fichiers `docs/ARCHITECTURE.md` et `docs/WORKFLOWS.md` issus d'une install antérieure du socle, **Quand** `update.sh` est exécuté, **Alors** un message informe l'utilisateur que ces fichiers ne sont plus gérés par le socle et lui suggère de les supprimer ou les conserver volontairement (pas de suppression auto).
5. **Étant donné** une migration réussie, **Quand** je lance `claude` dans le projet, **Alors** les `@imports` se résolvent correctement (pas d'erreur de fichier manquant).

### US3 — Mode minimal aligné (P3)

**En tant que** utilisateur installant le socle en mode `--minimal`
**Je veux** que les fichiers du manifest soient placés sous `.claude/docs/`
**Afin de** rester cohérent avec le mode `--simple`.

#### Critères d'acceptation

1. **Étant donné** un projet vierge, **Quand** `new-project.sh --minimal .` est exécuté, **Alors** `.claude/docs/reference/best-practices.md`, `.claude/docs/reference/project-structures.md` et `.claude/docs/guides/learning-path.md` existent.
2. **Étant donné** une install minimale, **Quand** je lis `CLAUDE.md`, **Alors** `@imports` et table références utilisent `.claude/docs/...`.
3. **Étant donné** `scripts/lib/minimal-manifest.txt`, **Quand** je le relis, **Alors** les destinations sont explicitement remappées sous `.claude/docs/...`.

## Hors scope

- Migration du **repo socle lui-même** (le socle continue d'utiliser `docs/` localement pour son propre CLAUDE.md et son website Docusaurus).
- Modification du sync website (`specs/docs-website-consolidation/`) — il continue de lire depuis `docs/` source.
- Suppression de `ARCHITECTURE.md` / `WORKFLOWS.md` du repo socle (ils restent disponibles pour les contributeurs et le website).

## Exigences fonctionnelles

| ID | Exigence |
|----|----------|
| EF-01 | `new-project.sh --simple` ne touche jamais `docs/` du projet utilisateur |
| EF-02 | `new-project.sh --simple` ne copie pas `ARCHITECTURE.md` ni `WORKFLOWS.md` |
| EF-03 | `update.sh` détecte le layout legacy et migre automatiquement |
| EF-04 | `update.sh` préserve les fichiers `.claude/docs/guides/*.md` modifiés localement |
| EF-05 | `CLAUDE.md` généré référence `@.claude/docs/reference/...` (et non plus `@docs/reference/...`) |
| EF-06 | Les rules `socle-maintenance.md` ne sont PAS modifiées (elles parlent du repo socle, pas du projet user) |
| EF-07 | Tests `update.bats` adaptés et passant |
| EF-08 | Mode `--minimal` aligné (manifest + template) |
| EF-09 | CHANGELOG documente le breaking change avec guide de migration |

## Critères de succès

- pve-home (et autres projets infra) peuvent installer/mettre à jour le socle sans collision avec leur propre `docs/`
- Les utilisateurs existants en layout legacy migrent automatiquement via `update.sh`
- Aucun test régression dans `tests/update.bats` ou `tests/smoke.bats`
- Bump version mineur v1.30.0 avec note de breaking change

## Risques

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Migration auto casse un projet user en cours d'usage | Élevé | Moyenne | Backup automatique avant migration (`update.sh` le fait déjà), dry-run par défaut sur la migration |
| Utilisateurs ont personnalisé `docs/reference/*.md` | Moyen | Faible | Détecter le diff vs socle, alerter, ne pas écraser silencieusement |
| `socle-maintenance.md` rule cassée par confusion socle/user | Moyen | Faible | Audit explicite de la rule pendant l'implémentation, clarifier si nécessaire |
| Spec en cours `docs-website-consolidation` impactée | Faible | Faible | Hors scope mais coordonner : le sync website lit depuis `docs/` (source socle), pas depuis `.claude/docs/` projet user — pas de conflit |

---

**Version** : 1.0 | **Créé** : 2026-04-28
