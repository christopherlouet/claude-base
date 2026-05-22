#!/usr/bin/env ts-node
/**
 * Auto-generate the per-stack matrix in
 * docs/recipes/recommended-vendor-skills.md from each preset's
 * `recommendedVendorSkills[]` field.
 *
 * The matrix replaces the content between the markers:
 *   <!-- recipe-matrix:start -->
 *   <!-- recipe-matrix:end -->
 *
 * Eliminates the drift risk between hand-maintained per-stack matrix
 * and the per-preset recommendations. Phase 6 item per
 * specs/foundation-positioning-review/phase-6-curator-bindings.md.
 *
 * Idempotent: a second `npm run generate` after a clean one produces
 * no diff. Wired into website/scripts/generate-all.ts.
 */

import * as fs from 'fs';
import * as path from 'path';

const REPO_ROOT = path.resolve(__dirname, '../..');
const PRESETS_DIR = path.join(REPO_ROOT, '.claude/presets');
const RECIPE_PATH = path.join(REPO_ROOT, 'docs/recipes/recommended-vendor-skills.md');

const START_MARKER = '<!-- recipe-matrix:start -->';
const END_MARKER = '<!-- recipe-matrix:end -->';

export interface VendorSkillEntry {
  id: string;
  condition: string;
}

export interface PresetInfo {
  name: string;
  displayName: string;
  recommendedVendorSkills: VendorSkillEntry[];
}

// Matches the bash CLI prefix matching in scripts/lib/preset-recommendations.sh
// (case "$rcond" in always*) — `always (extra context)` still counts as always.
function isAlways(condition: string): boolean {
  return condition.startsWith('always');
}

function formatEntryList(entries: VendorSkillEntry[], includeCondition: boolean): string {
  if (entries.length === 0) return '—';
  return entries
    .map((e) => {
      const id = `\`${e.id}\``;
      if (includeCondition && !isAlways(e.condition)) {
        return `${id} (${e.condition})`;
      }
      return id;
    })
    .join(', ');
}

export function buildMatrixMarkdown(presets: PresetInfo[]): string {
  const header = '| Preset | Always pair | Conditional |';
  const sep = '|---|---|---|';
  const rows = presets.map((p) => {
    const always = p.recommendedVendorSkills.filter((e) => isAlways(e.condition));
    const conditional = p.recommendedVendorSkills.filter((e) => !isAlways(e.condition));
    return `| \`${p.name}\` (${p.displayName}) | ${formatEntryList(always, false)} | ${formatEntryList(conditional, true)} |`;
  });
  return [header, sep, ...rows].join('\n');
}

export function replaceMatrixBlock(content: string, matrix: string): string {
  const startIdx = content.indexOf(START_MARKER);
  if (startIdx === -1) {
    throw new Error(`Recipe matrix start marker not found: ${START_MARKER}`);
  }
  const endIdx = content.indexOf(END_MARKER, startIdx);
  if (endIdx === -1) {
    throw new Error(`Recipe matrix end marker not found after start: ${END_MARKER}`);
  }
  const before = content.slice(0, startIdx + START_MARKER.length);
  const after = content.slice(endIdx);
  return `${before}\n${matrix}\n${after}`;
}

function loadPreset(filePath: string): PresetInfo {
  const raw = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  const recommended: VendorSkillEntry[] = Array.isArray(raw.recommendedVendorSkills)
    ? raw.recommendedVendorSkills.map((e: { id: string; condition: string }) => ({
        id: e.id,
        condition: e.condition,
      }))
    : [];
  return {
    name: raw.name,
    displayName: raw.displayName ?? raw.name,
    recommendedVendorSkills: recommended,
  };
}

function loadAllPresets(): PresetInfo[] {
  const files = fs
    .readdirSync(PRESETS_DIR)
    .filter((f) => f.endsWith('.json'))
    .sort();
  return files.map((f) => loadPreset(path.join(PRESETS_DIR, f)));
}

export function generateRecipeMatrix(): { updated: boolean; presetCount: number } {
  const presets = loadAllPresets();
  const matrix = buildMatrixMarkdown(presets);

  if (!fs.existsSync(RECIPE_PATH)) {
    throw new Error(`Recipe file not found: ${RECIPE_PATH}`);
  }
  const original = fs.readFileSync(RECIPE_PATH, 'utf-8');
  const next = replaceMatrixBlock(original, matrix);

  if (next !== original) {
    fs.writeFileSync(RECIPE_PATH, next, 'utf-8');
    console.log(`  ✏️  docs/recipes/recommended-vendor-skills.md (${presets.length} presets)`);
    return { updated: true, presetCount: presets.length };
  }

  console.log(`📝 generate-recipe-matrix: ${presets.length} presets, no change`);
  return { updated: false, presetCount: presets.length };
}

if (require.main === module) {
  generateRecipeMatrix();
}
