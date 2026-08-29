#!/usr/bin/env ts-node
/**
 * Generate counts.json — the single source of truth for all counter
 * numbers (commands, agents, skills, rules, domain subtotals)
 * referenced across TS components, Markdown docs and CI configuration.
 *
 * Output: counts.json at the repo root.
 *
 * Idempotent: running it on a clean repo leaves no diff. CI uses
 * `git diff --exit-code` after this script to fail PRs that ship
 * stale counts.
 */

import * as fs from 'fs';
import * as path from 'path';
import { Counts } from './utils/counts-types.js';

const REPO_ROOT = path.resolve(__dirname, '../..');
const CLAUDE_DIR = path.join(REPO_ROOT, '.claude');
const OUTPUT_PATH = path.join(REPO_ROOT, 'counts.json');
const RECIPE_PATH = path.join(REPO_ROOT, 'docs/recipes/recommended-vendor-skills.md');
const AUDIT_DIR = path.join(REPO_ROOT, 'specs/marketplace-audit');

function countMarkdownFiles(dir: string, opts: { excludeReadme?: boolean } = {}): number {
  if (!fs.existsSync(dir)) return 0;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  let total = 0;
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      total += countMarkdownFiles(full, opts);
    } else if (entry.isFile() && entry.name.endsWith('.md')) {
      if (opts.excludeReadme && entry.name === 'README.md') continue;
      total += 1;
    }
  }
  return total;
}

function countSkills(dir: string): number {
  if (!fs.existsSync(dir)) return 0;
  let total = 0;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      const skillFile = path.join(dir, entry.name, 'SKILL.md');
      if (fs.existsSync(skillFile)) total += 1;
    }
  }
  return total;
}

function countCommandsByDomain(commandsDir: string): Record<string, number> {
  const byDomain: Record<string, number> = {};
  if (!fs.existsSync(commandsDir)) return byDomain;
  for (const entry of fs.readdirSync(commandsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const domainDir = path.join(commandsDir, entry.name);
    byDomain[entry.name] = countMarkdownFiles(domainDir, { excludeReadme: true });
  }
  return byDomain;
}

/**
 * Count `.json` files at the top level of `dir`. NOT recursive — keeps
 * subdirectories (e.g. .claude/presets/community/) out of the official
 * preset count. Returns 0 for missing directories.
 */
export function countJsonFiles(dir: string): number {
  if (!fs.existsSync(dir)) return 0;
  let total = 0;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isFile() && entry.name.endsWith('.json')) total += 1;
  }
  return total;
}

/**
 * Count files whose name matches `pattern` at the top level of `dir`.
 * NOT recursive. Directories are skipped even when their name matches.
 * Returns 0 for missing directories.
 */
export function countFilesMatching(dir: string, pattern: RegExp): number {
  if (!fs.existsSync(dir)) return 0;
  let total = 0;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isFile() && pattern.test(entry.name)) total += 1;
  }
  return total;
}

/**
 * Count vendor entries in the "Recommended vendor skills (by domain)"
 * section of the recipe markdown. An entry is any `### ` heading
 * (exactly H3) between that section's H2 heading and the next H2. The
 * "Stack-specific" and "Vendors evaluated and NOT recommended" sections
 * are deliberately excluded — they live under their own H2s and stop
 * the scan when reached.
 *
 * Pure function: takes the markdown content as a string for testability.
 */
export function countVendorSkillsInRecipe(markdown: string): number {
  const SECTION_PREFIX = '## Recommended vendor skills';
  let inSection = false;
  let count = 0;
  for (const line of markdown.split('\n')) {
    if (line.startsWith(SECTION_PREFIX)) {
      inSection = true;
      continue;
    }
    if (!inSection) continue;
    if (line.startsWith('## ')) break; // next H2 closes the section
    if (line.startsWith('### ')) count += 1;
  }
  return count;
}

function countVendorSkillsValidatedFromFile(recipePath: string): number {
  if (!fs.existsSync(recipePath)) return 0;
  return countVendorSkillsInRecipe(fs.readFileSync(recipePath, 'utf-8'));
}

/**
 * Module-owned item totals, summed from the horizontal module bundles under
 * scripts/lib/modules/*.txt (one repo-relative path per line; # comments and
 * blank lines ignored; a trailing / marks a directory). Used to derive the
 * "core" (default-install) counts as full − module-owned.
 */
export function countModuleOwned(
  modulesDir: string = path.join(REPO_ROOT, 'scripts/lib/modules'),
): { commands: number; agents: number; skills: number } {
  const owned = { commands: 0, agents: 0, skills: 0 };
  if (!fs.existsSync(modulesDir)) return owned;
  for (const entry of fs.readdirSync(modulesDir, { withFileTypes: true })) {
    if (!entry.isFile() || !entry.name.endsWith('.txt')) continue;
    for (const raw of fs.readFileSync(path.join(modulesDir, entry.name), 'utf-8').split('\n')) {
      const line = raw.trim();
      if (!line || line.startsWith('#')) continue;
      if (line.startsWith('.claude/commands/')) owned.commands += 1;
      else if (line.startsWith('.claude/agents/')) owned.agents += 1;
      else if (line.startsWith('.claude/skills/')) owned.skills += 1;
    }
  }
  return owned;
}

export function computeCounts(): Counts {
  const commands = countMarkdownFiles(path.join(CLAUDE_DIR, 'commands'), { excludeReadme: true });
  const agents = countMarkdownFiles(path.join(CLAUDE_DIR, 'agents'), { excludeReadme: true });
  const skills = countSkills(path.join(CLAUDE_DIR, 'skills'));
  const moduleOwned = countModuleOwned();
  return {
    commands,
    agents,
    skills,
    core: {
      commands: commands - moduleOwned.commands,
      agents: agents - moduleOwned.agents,
      skills: skills - moduleOwned.skills,
    },
    rules: countMarkdownFiles(path.join(CLAUDE_DIR, 'rules'), { excludeReadme: true }),
    byDomain: countCommandsByDomain(path.join(CLAUDE_DIR, 'commands')),
    presets: countJsonFiles(path.join(CLAUDE_DIR, 'presets')),
    vendorSkillsValidated: countVendorSkillsValidatedFromFile(RECIPE_PATH),
    marketplaceAuditPilots: countFilesMatching(AUDIT_DIR, /-pilot-.*\.md$/),
  };
}

export function generateCounts(): Counts {
  const counts = computeCounts();
  const json = JSON.stringify(counts, null, 2) + '\n';
  fs.writeFileSync(OUTPUT_PATH, json, 'utf-8');
  console.log(`📊 counts.json written: ${counts.commands} commands, ${counts.agents} agents, ${counts.skills} skills, ${counts.rules} rules, ${counts.presets} presets, ${counts.vendorSkillsValidated} vendor skills validated, ${counts.marketplaceAuditPilots} audit pilots`);
  return counts;
}

// CLI entry point: run when invoked directly
if (require.main === module) {
  generateCounts();
}
