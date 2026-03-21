# Plan d'implémentation : Consolidation Documentation docs/ ↔ website/

**Spec**: `specs/docs-website-consolidation/spec.md`
**Date**: 2026-03-21
**Complexité globale**: Moyenne (1 script TS + remplacement fichiers manuels + sidebar update)

---

## Résumé

Créer `website/scripts/sync-docs.ts` qui copie `docs/guides/`, `docs/reference/` et docs racine vers `website/docs/` avec ajout automatique de frontmatter Docusaurus et réécriture des liens relatifs. Intégrer dans le pipeline `npm run generate` existant. Supprimer les copies manuelles.

---

## Contexte technique

### Pipeline existant

```
npm run generate → generate-all.ts
  ├── generateCommandDocs()     → website/docs/commands/
  ├── generateAgentDocs()       → website/docs/agents/
  ├── generateSkillDocs()       → website/docs/skills/
  └── generateRuleDocs()        → website/docs/rules/
  ┌────────────────────────────────────────────────┐
  │ NOUVEAU: syncDocs()         → website/docs/guides/     │
  │                             → website/docs/reference/   │
  │                             → website/docs/concepts/    │
  └────────────────────────────────────────────────┘
```

### Pattern TypeScript des générateurs existants

Chaque générateur :
1. Définit les répertoires source/destination
2. Lit les fichiers .md avec `fs.readdirSync()`
3. Parse le contenu avec `extractFirstHeading()` et `extractDescription()`
4. Génère le frontmatter avec `generateFrontmatter({ sidebar_position, title, description })`
5. Écrit les fichiers avec `writeFileContent()`

### Utilitaires disponibles (`website/scripts/utils/`)

| Utilitaire | Fonction |
|---|---|
| `generateFrontmatter()` | Crée le header YAML Docusaurus |
| `parseFrontmatter()` | Parse le frontmatter existant |
| `extractFirstHeading()` | Extrait le `# Titre` |
| `extractDescription()` | Extrait le premier paragraphe |
| `escapeMdx()` | Échappe `{ } < >` pour MDX |
| `writeFileContent()` | Écrit un fichier avec création de répertoire |

### Fichiers source → destination

| Source | Destination website | Sidebar |
|--------|-------------------|---------|
| `docs/guides/*.md` (8 fichiers) | `website/docs/guides/` | Section Guides |
| `docs/reference/*.md` (7 fichiers) | `website/docs/reference/` | Section Reference |
| `docs/ARCHITECTURE.md` | `website/docs/concepts/architecture.md` | Section Concepts |
| `docs/WORKFLOWS.md` | `website/docs/concepts/workflows.md` | Section Concepts |
| `docs/CUSTOMIZATION.md` | `website/docs/concepts/customization.md` | Section Concepts |

### Copies manuelles à supprimer

| Fichier website actuel | Remplacé par |
|---|---|
| `website/docs/guides/web-development.md` | Auto-sync de `docs/guides/WEB-GUIDE.md` |
| `website/docs/guides/mobile-development.md` | Auto-sync de `docs/guides/MOBILE-GUIDE.md` |
| `website/docs/guides/api-development.md` | Auto-sync de `docs/guides/API-GUIDE.md` |
| `website/docs/guides/data-engineering.md` | Auto-sync de `docs/guides/DATA-GUIDE.md` |
| `website/docs/guides/best-practices.md` | Auto-sync de `docs/reference/best-practices.md` |
| `website/docs/reference/cheatsheet.md` | Auto-sync de `docs/CHEATSHEET.md` |

### Table de mapping des liens

```typescript
const LINK_MAP: Record<string, string> = {
  '../ARCHITECTURE.md': '/docs/concepts/architecture',
  '../WORKFLOWS.md': '/docs/concepts/workflows',
  '../CUSTOMIZATION.md': '/docs/concepts/customization',
  'WEB-GUIDE.md': '/docs/guides/web-guide',
  'MOBILE-GUIDE.md': '/docs/guides/mobile-guide',
  'API-GUIDE.md': '/docs/guides/api-guide',
  // ... etc
};
```

### Slug convention

`WEB-GUIDE.md` → `web-guide.md` (kebab-case lowercase, strip `.md` extension dans les liens)

---

## Fichiers impactés

| Fichier | Action | US |
|---------|--------|-----|
| `website/scripts/sync-docs.ts` | CRÉER | US1, US2, US3, US4 |
| `website/scripts/generate-all.ts` | MODIFIER | US4 |
| `website/package.json` | MODIFIER | US4 |
| `website/sidebars.ts` | MODIFIER | US1, US2, US3 |
| `website/docs/guides/*.md` | SUPPRIMER manuels, GÉNÉRER auto | US1 |
| `website/docs/reference/*.md` | SUPPRIMER manuels, GÉNÉRER auto | US2 |
| `website/docs/concepts/architecture.md` | GÉNÉRER | US3 |
| `website/docs/concepts/workflows.md` | GÉNÉRER | US3 |
| `website/docs/concepts/customization.md` | GÉNÉRER | US3 |

---

## Phases

### Phase 1 — P1 : Script sync-docs.ts [US4]

Créer le script de sync suivant le pattern des générateurs existants. Gère guides + references.

### Phase 2 — P1 : Intégrer et remplacer les guides [US1]

Supprimer les copies manuelles dans `website/docs/guides/`, exécuter la sync, mettre à jour sidebars.ts.

### Phase 3 — P1 : Synchroniser les références [US2]

Même chose pour `website/docs/reference/`.

### Phase 4 — P2 : Docs racine → Concepts [US3]

Ajouter ARCHITECTURE, WORKFLOWS, CUSTOMIZATION dans la section Concepts.

### Phase 5 — Vérification

Build Docusaurus, vérification visuelle, CI.

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Liens relatifs cassés après réécriture | Pages avec 404 | Table de mapping exhaustive, tester chaque lien |
| MDX parsing errors (accolades non échappées) | Build échoue | Utiliser `escapeMdx()` déjà disponible |
| Sidebar items hardcodés ne matchent pas les nouveaux slugs | Pages non navigables | Mettre à jour sidebars.ts avec les nouveaux noms |
| Perte de contenu website-only (faq, troubleshooting, migration) | Pages disparaissent | Ne supprimer QUE les fichiers qui ont un équivalent dans docs/ |

---

## Vérification

```bash
cd website
npm run generate           # Sync + tous les générateurs
npm run build              # Build Docusaurus complet
# Vérifier visuellement: guides, reference, concepts
```
