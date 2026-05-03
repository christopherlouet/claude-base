#!/usr/bin/env ts-node
/**
 * Inject counts from counts.json into Markdown files instrumented
 * with `<!-- count:KEY -->NNN<!-- /count -->` markers.
 *
 * KEY is a dot-path into counts.json (e.g. `commands`, `agents`,
 * `byDomain.work`, `tests`, `testFiles`).
 *
 * The script is idempotent: if every marker already holds the right
 * value, no file is touched (so `git diff --exit-code` stays clean).
 *
 * Files to process are listed in MD_FILES below — extend the list
 * when instrumenting a new file.
 */

import * as fs from 'fs';
import * as path from 'path';
import { Counts } from './utils/counts-types.js';

const REPO_ROOT = path.resolve(__dirname, '../..');
const COUNTS_PATH = path.join(REPO_ROOT, 'counts.json');

const MD_FILES: string[] = [
  // Website docs
  'website/docs/intro/index.md',
  'website/docs/intro/architecture.md',
  // Repo root
  'README.md',
  'CLAUDE.md',
  // Foundation docs
  'docs/CHEATSHEET.md',
  'docs/ARCHITECTURE.md',
];

const MARKER_RE = /<!--\s*count:([\w.]+)\s*-->[^<]*<!--\s*\/count\s*-->/g;

function resolveKey(counts: Counts, key: string): number | null {
  const parts = key.split('.');
  let value: unknown = counts;
  for (const part of parts) {
    if (value && typeof value === 'object' && part in (value as Record<string, unknown>)) {
      value = (value as Record<string, unknown>)[part];
    } else {
      return null;
    }
  }
  return typeof value === 'number' ? value : null;
}

export function injectCountsMd(): { processed: number; updated: number; missingKeys: string[] } {
  if (!fs.existsSync(COUNTS_PATH)) {
    throw new Error(`counts.json not found at ${COUNTS_PATH} — run generate-counts first`);
  }
  const counts: Counts = JSON.parse(fs.readFileSync(COUNTS_PATH, 'utf-8'));

  let processed = 0;
  let updated = 0;
  const missingKeys: string[] = [];

  for (const relPath of MD_FILES) {
    const absPath = path.join(REPO_ROOT, relPath);
    if (!fs.existsSync(absPath)) {
      console.warn(`⚠️  skip (not found): ${relPath}`);
      continue;
    }
    processed += 1;

    const original = fs.readFileSync(absPath, 'utf-8');
    const next = original.replace(MARKER_RE, (match, key: string) => {
      const value = resolveKey(counts, key);
      if (value === null) {
        if (!missingKeys.includes(key)) missingKeys.push(key);
        return match;
      }
      return `<!-- count:${key} -->${value}<!-- /count -->`;
    });

    if (next !== original) {
      fs.writeFileSync(absPath, next, 'utf-8');
      updated += 1;
      console.log(`  ✏️  ${relPath}`);
    }
  }

  if (missingKeys.length > 0) {
    throw new Error(`Unknown count keys: ${missingKeys.join(', ')} — check counts-types.ts`);
  }

  console.log(`📝 inject-counts-md: processed ${processed} files, updated ${updated}`);
  return { processed, updated, missingKeys };
}

if (require.main === module) {
  injectCountsMd();
}
