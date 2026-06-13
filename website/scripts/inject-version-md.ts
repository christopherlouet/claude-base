#!/usr/bin/env ts-node
/**
 * Inject the foundation `VERSION` into Markdown files instrumented
 * with `<!-- version -->X.Y.Z<!-- /version -->` markers.
 *
 * Mirror of inject-counts-md.ts but single-purpose (version is a string,
 * not a count). Source of truth is the `VERSION` file at the repo root,
 * read fresh on every invocation.
 *
 * The script is idempotent: if every marker already holds the right
 * value, no file is touched (so `git diff --exit-code` stays clean).
 *
 * Files to process are listed in MD_FILES below — extend the list
 * when instrumenting a new file.
 */

import * as fs from 'fs';
import * as path from 'path';

const REPO_ROOT = path.resolve(__dirname, '../..');
const VERSION_PATH = path.join(REPO_ROOT, 'VERSION');

const MD_FILES: string[] = [
  'README.md',
  'website/docs/intro/quick-start.md',
  'website/docs/intro/installation.md',
  'website/docs/guides/learning-path.md',
  'docs/CHEATSHEET.md',
];

// Match <!-- version --> ... <!-- /version --> with whitespace tolerance
// around the tag name (mirrors the count-marker grammar).
const MARKER_RE = /<!--\s*version\s*-->[^<]*<!--\s*\/version\s*-->/g;

/**
 * Pure function: rewrite every version marker in `content` to wrap the
 * given `version` string. Returns the input verbatim when no marker is
 * present, when every marker already holds `version` (idempotency), or
 * when the markers are absent.
 */
export function replaceVersionMarkers(content: string, version: string): string {
  return content.replace(MARKER_RE, () => `<!-- version -->${version}<!-- /version -->`);
}

export function injectVersionMd(): { processed: number; updated: number } {
  if (!fs.existsSync(VERSION_PATH)) {
    throw new Error(`VERSION file not found at ${VERSION_PATH}`);
  }
  const version = fs.readFileSync(VERSION_PATH, 'utf-8').trim();

  let processed = 0;
  let updated = 0;

  for (const relPath of MD_FILES) {
    const absPath = path.join(REPO_ROOT, relPath);
    if (!fs.existsSync(absPath)) {
      console.warn(`⚠️  skip (not found): ${relPath}`);
      continue;
    }
    processed += 1;

    const original = fs.readFileSync(absPath, 'utf-8');
    const next = replaceVersionMarkers(original, version);

    if (next !== original) {
      fs.writeFileSync(absPath, next, 'utf-8');
      updated += 1;
      console.log(`  ✏️  ${relPath}`);
    }
  }

  console.log(`📝 inject-version-md: processed ${processed} files, updated ${updated}`);
  return { processed, updated };
}

if (require.main === module) {
  injectVersionMd();
}
