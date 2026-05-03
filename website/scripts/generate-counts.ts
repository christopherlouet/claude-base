#!/usr/bin/env ts-node
/**
 * Generate counts.json — the single source of truth for all counter
 * numbers (commands, agents, skills, rules, domain subtotals, tests)
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
const TESTS_DIR = path.join(REPO_ROOT, 'tests');
const OUTPUT_PATH = path.join(REPO_ROOT, 'counts.json');

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

function countBatsTests(testsDir: string): { tests: number; testFiles: number } {
  if (!fs.existsSync(testsDir)) return { tests: 0, testFiles: 0 };
  let tests = 0;
  let testFiles = 0;
  for (const entry of fs.readdirSync(testsDir, { withFileTypes: true })) {
    if (!entry.isFile() || !entry.name.endsWith('.bats')) continue;
    testFiles += 1;
    const content = fs.readFileSync(path.join(testsDir, entry.name), 'utf-8');
    const matches = content.match(/^@test /gm);
    tests += matches ? matches.length : 0;
  }
  return { tests, testFiles };
}

export function computeCounts(): Counts {
  const { tests, testFiles } = countBatsTests(TESTS_DIR);
  return {
    commands: countMarkdownFiles(path.join(CLAUDE_DIR, 'commands'), { excludeReadme: true }),
    agents: countMarkdownFiles(path.join(CLAUDE_DIR, 'agents'), { excludeReadme: true }),
    skills: countSkills(path.join(CLAUDE_DIR, 'skills')),
    rules: countMarkdownFiles(path.join(CLAUDE_DIR, 'rules'), { excludeReadme: true }),
    tests,
    testFiles,
    byDomain: countCommandsByDomain(path.join(CLAUDE_DIR, 'commands')),
  };
}

export function generateCounts(): Counts {
  const counts = computeCounts();
  const json = JSON.stringify(counts, null, 2) + '\n';
  fs.writeFileSync(OUTPUT_PATH, json, 'utf-8');
  console.log(`📊 counts.json written: ${counts.commands} commands, ${counts.agents} agents, ${counts.skills} skills, ${counts.rules} rules, ${counts.tests} tests in ${counts.testFiles} files`);
  return counts;
}

// CLI entry point: run when invoked directly
if (require.main === module) {
  generateCounts();
}
