# Spécification : Consolidation Documentation docs/ ↔ website/

**Branche**: `feature/docs-website-consolidation`
**Date**: 2026-03-21
**Statut**: Ready

---

## Résumé

La documentation du socle est maintenue à deux endroits (`docs/` et `website/docs/`) avec un risque de drift. Les agents/commands/skills/rules sont auto-générés par `website/scripts/generate-all.ts`, mais les guides et références sont copiés manuellement avec 30-60% de perte de contenu. L'objectif est d'établir `/docs/` comme source de vérité unique et d'automatiser la synchronisation vers le website.

---

## User Stories (prioritisées)

### US1 - Synchronisation automatique des guides (Priorité: P1) 🎯 MVP

**En tant que** mainteneur du socle
**Je veux** que les guides dans `docs/guides/` soient automatiquement intégrés au website
**Afin de** ne plus maintenir deux copies divergentes

**Pourquoi P1**: 8 guides existent dans `/docs/guides/` mais les versions website sont tronquées de 30-60%. Chaque mise à jour nécessite une double édition manuelle.

**Critères d'acceptation**:

1. **Étant donné** que je modifie `docs/guides/WEB-GUIDE.md`, **Quand** le website est buildé (`npm run build`), **Alors** la page website reflète le contenu à jour
2. **Étant donné** que `npm run generate` est lancé, **Quand** je compare docs/guides/ et website/docs/guides/, **Alors** le contenu est identique (aux ajouts frontmatter Docusaurus près)
3. **Étant donné** un nouveau guide ajouté dans `docs/guides/`, **Quand** le build s'exécute, **Alors** le guide apparaît automatiquement dans le sidebar du website

---

### US2 - Synchronisation des références (Priorité: P1) 🎯 MVP

**En tant que** mainteneur du socle
**Je veux** que les fichiers de référence (`docs/reference/`) soient synchronisés vers le website
**Afin de** éviter les incohérences entre best-practices.md source et la version website

**Critères d'acceptation**:

1. **Étant donné** que je modifie `docs/reference/advanced-features.md`, **Quand** le website est buildé, **Alors** la page website est à jour
2. **Étant donné** les 7 fichiers de référence, **Quand** le build s'exécute, **Alors** tous sont présents dans le website

---

### US3 - Synchronisation des docs racine (Priorité: P2)

**En tant que** utilisateur du socle
**Je veux** retrouver les docs principales (ARCHITECTURE, WORKFLOWS, CUSTOMIZATION) sur le website
**Afin de** ne pas devoir chercher dans le repo GitHub

**Pourquoi P2**: Ces fichiers manquent du website mais sont volumineux — à intégrer proprement.

**Critères d'acceptation**:

1. **Étant donné** que `docs/ARCHITECTURE.md` existe (464 lignes), **Quand** je navigue sur le website, **Alors** je trouve une page Architecture complète
2. **Étant donné** que `docs/WORKFLOWS.md` existe (580 lignes), **Quand** le build s'exécute, **Alors** une page Workflows est générée
3. **Étant donné** que `docs/CUSTOMIZATION.md` existe, **Quand** le build s'exécute, **Alors** une page Personnalisation est générée

---

### US4 - Script de sync dans le pipeline generate (Priorité: P1) 🎯 MVP

**En tant que** développeur du socle
**Je veux** un script qui synchronise docs/ → website/docs/ avec ajout de frontmatter
**Afin de** que la synchronisation soit automatique et déterministe

**Critères d'acceptation**:

1. **Étant donné** que je lance `npm run generate`, **Quand** le script termine, **Alors** les guides, références et docs racine sont copiés avec frontmatter Docusaurus ajouté
2. **Étant donné** un fichier markdown sans frontmatter, **Quand** le script le copie, **Alors** un frontmatter `---\nsidebar_position: N\n---` est ajouté automatiquement
3. **Étant donné** un fichier avec du contenu identique, **Quand** le script est relancé, **Alors** aucune modification n'est faite (idempotent)

---

## Exigences Fonctionnelles

| ID | Exigence | Vérification |
|----|----------|--------------|
| EF-01 | Script de sync dans `website/scripts/` intégré à `npm run generate` | `npm run generate` copie guides + references |
| EF-02 | Frontmatter Docusaurus ajouté automatiquement aux fichiers copiés | Vérifier les `---` en tête de chaque fichier généré |
| EF-03 | Sidebars.ts inclut les pages synchronisées | Build Docusaurus sans erreur |
| EF-04 | `docs/` reste la source de vérité — jamais de modification dans `website/docs/guides/` ou `website/docs/reference/` | Fichiers générés marqués avec commentaire "auto-generated" |
| EF-05 | Build Docusaurus passe sans erreur après sync | `npm run build` OK dans CI |

---

## Cas Limites

| Cas | Comportement attendu |
|-----|---------------------|
| Fichier docs/ supprimé | Le fichier website correspondant est supprimé à la prochaine sync |
| Fichier avec frontmatter existant dans docs/ | Le frontmatter existant est préservé, pas de doublon |
| Liens relatifs dans docs/ (ex: `../guides/WEB-GUIDE.md`) | Réécrits automatiquement en chemins Docusaurus via table de mapping dans sync-docs.ts |
| Fichier docs/ avec caractères spéciaux dans le nom | Slug généré automatiquement (kebab-case) |

---

## Critères de Succès

| ID | Critère | Mesure |
|----|---------|--------|
| CS-01 | 0 fichier maintenu manuellement en double | Aucun guide/reference avec copie divergente |
| CS-02 | Build Docusaurus passe | `npm run build` exit 0 |
| CS-03 | CI docs.yml intègre la sync | Pipeline vert |

---

## Hors Scope

- Refonte du design ou du thème Docusaurus
- Migration des pages website-only (concepts/, tutorials/, examples/) vers docs/
- Synchronisation bidirectionnelle (website → docs)
- Traduction automatique (GUIDE-UTILISATEUR.md reste hors website)

---

## Points de Clarification

Tous résolus :
1. ~~Faut-il supprimer les copies manuelles dans website/docs/guides/?~~ → **Oui**, remplacées par les copies auto-générées
2. ~~Quel format de frontmatter?~~ → Identique aux fichiers auto-générés existants (title, sidebar_position)
3. ~~Les docs racine (ARCHITECTURE, WORKFLOWS) vont dans quelle section?~~ → Section "Concepts" du sidebar existant
4. ~~Langage du script de sync?~~ → **TypeScript**, cohérent avec les 4 générateurs existants dans `website/scripts/generate-*.ts`. Fichier : `website/scripts/sync-docs.ts`, appelé par `generate-all.ts`.
5. ~~Transformation des liens relatifs?~~ → **Réécriture automatique** : le script TS détecte les liens `../` et les transforme en chemins Docusaurus valides (ex: `../ARCHITECTURE.md` → `/docs/concepts/architecture`). Table de mapping dans le script.

---

**Version**: 1.1 | **Créé par**: /work:work-specify | **Mis à jour**: 2026-03-21
