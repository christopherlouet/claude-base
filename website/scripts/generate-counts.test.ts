/**
 * Tests for generate-counts.ts — the canonical counts.json producer.
 * Covers the three counts added in the "counts expansion" PR:
 *   - presets:                  count JSON files under .claude/presets/
 *   - marketplaceAuditPilots:   count *-pilot-*.md under specs/marketplace-audit/
 *   - vendorSkillsValidated:    count `### ` entries in the "Recommended
 *                               vendor skills (by domain)" section of
 *                               docs/recipes/recommended-vendor-skills.md
 *
 * The existing helpers (countMarkdownFiles, countSkills, countBatsTests,
 * countCommandsByDomain) are NOT covered here — they predate this batch
 * and are validated indirectly by validate-counts.bats.
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import {
  countVendorSkillsInRecipe,
  countJsonFiles,
  countFilesMatching,
} from './generate-counts.js';

function withTempDir(fn: (dir: string) => void): void {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'counts-test-'));
  try {
    fn(dir);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

describe('countVendorSkillsInRecipe', () => {
  it('returns 0 when the section heading is absent', () => {
    const md = '# Recipe\n\nSome prose, no headings.';
    assert.equal(countVendorSkillsInRecipe(md), 0);
  });

  it('counts every "### " entry between the section heading and the next H2', () => {
    const md = [
      '## Other',
      '### Should not count',
      '',
      '## Recommended vendor skills (by domain)',
      '### Vendor A — pkg',
      '### Vendor B — pkg',
      '### Vendor C — pkg',
      '',
      '## Stack-specific',
      '### Stack-only — not counted',
    ].join('\n');
    assert.equal(countVendorSkillsInRecipe(md), 3);
  });

  it('terminates at the next H2 even when followed by more H3s', () => {
    const md = [
      '## Recommended vendor skills (by domain)',
      '### A',
      '### B',
      '## Vendors evaluated and NOT recommended',
      '### C',
      '### D',
    ].join('\n');
    assert.equal(countVendorSkillsInRecipe(md), 2);
  });

  it('matches the section heading by its prefix (tolerates trailing punctuation/text)', () => {
    const md = [
      '## Recommended vendor skills (by domain) — last reviewed 2026-05',
      '### Only one',
    ].join('\n');
    assert.equal(countVendorSkillsInRecipe(md), 1);
  });

  it('ignores H4 and deeper headings within the section', () => {
    const md = [
      '## Recommended vendor skills (by domain)',
      '### Vendor A',
      '#### Sub-detail of A',
      '### Vendor B',
      '#### Sub-detail of B',
    ].join('\n');
    assert.equal(countVendorSkillsInRecipe(md), 2);
  });

  it('returns 0 when the section is present but empty', () => {
    const md = [
      '## Recommended vendor skills (by domain)',
      '',
      '## Stack-specific',
      '### Should not count',
    ].join('\n');
    assert.equal(countVendorSkillsInRecipe(md), 0);
  });
});

describe('countJsonFiles', () => {
  it('returns 0 when the directory does not exist', () => {
    assert.equal(countJsonFiles('/nonexistent/path/that/does/not/exist'), 0);
  });

  it('returns 0 for an empty directory', () => {
    withTempDir((dir) => {
      assert.equal(countJsonFiles(dir), 0);
    });
  });

  it('counts only .json files at the top level (not recursive)', () => {
    withTempDir((dir) => {
      fs.writeFileSync(path.join(dir, 'a.json'), '{}');
      fs.writeFileSync(path.join(dir, 'b.json'), '{}');
      fs.writeFileSync(path.join(dir, 'README.md'), '');
      fs.mkdirSync(path.join(dir, 'subdir'));
      fs.writeFileSync(path.join(dir, 'subdir', 'c.json'), '{}');
      assert.equal(countJsonFiles(dir), 2);
    });
  });

  it('ignores non-.json files even if they have similar extensions', () => {
    withTempDir((dir) => {
      fs.writeFileSync(path.join(dir, 'a.json'), '{}');
      fs.writeFileSync(path.join(dir, 'b.jsonc'), '{}');
      fs.writeFileSync(path.join(dir, 'c.json.bak'), '{}');
      assert.equal(countJsonFiles(dir), 1);
    });
  });
});

describe('countFilesMatching', () => {
  it('returns 0 when the directory does not exist', () => {
    assert.equal(countFilesMatching('/nope', /-pilot-.*\.md$/), 0);
  });

  it('counts only files matching the regex', () => {
    withTempDir((dir) => {
      fs.writeFileSync(path.join(dir, 'cli-pilot-2026-05-05.md'), '');
      fs.writeFileSync(path.join(dir, 'dev-pilot-2026-05-05.md'), '');
      fs.writeFileSync(path.join(dir, 'spec.md'), '');
      fs.writeFileSync(path.join(dir, 'not-a-pilot.md'), '');
      assert.equal(countFilesMatching(dir, /-pilot-.*\.md$/), 2);
    });
  });

  it('ignores directories even when their name matches', () => {
    withTempDir((dir) => {
      fs.mkdirSync(path.join(dir, 'foo-pilot-x.md'));
      fs.writeFileSync(path.join(dir, 'bar-pilot-y.md'), '');
      assert.equal(countFilesMatching(dir, /-pilot-.*\.md$/), 1);
    });
  });
});
