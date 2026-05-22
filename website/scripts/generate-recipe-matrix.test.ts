/**
 * Tests for generate-recipe-matrix.ts — auto-generates the per-stack
 * matrix in docs/recipes/recommended-vendor-skills.md from preset JSON
 * data. Pure-logic functions tested directly; fs orchestration is
 * exercised indirectly via the existing generate pipeline.
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';

import {
  buildMatrixMarkdown,
  replaceMatrixBlock,
  type PresetInfo,
} from './generate-recipe-matrix.js';

const STUB_NEXTJS: PresetInfo = {
  name: 'nextjs',
  displayName: 'Next.js full-stack',
  recommendedVendorSkills: [
    { id: 'vercel-labs/agent-skills', condition: 'always' },
    { id: 'frontend-design@claude-plugins-official', condition: 'always' },
    { id: 'supabase/agent-skills', condition: 'if using Supabase' },
    { id: 'prisma/skills', condition: 'if using Prisma' },
  ],
};

const STUB_CLI_TOOLS: PresetInfo = {
  name: 'cli-tools',
  displayName: 'CLI tools / automation scripts',
  recommendedVendorSkills: [],
};

const STUB_PHASER: PresetInfo = {
  name: 'phaser',
  displayName: 'Phaser game',
  recommendedVendorSkills: [
    { id: 'phaserjs/phaser', condition: 'always' },
  ],
};

const STUB_PROXMOX: PresetInfo = {
  name: 'homelab-proxmox',
  displayName: 'Proxmox VE homelab',
  recommendedVendorSkills: [
    { id: 'antonbabenko/terraform-skill', condition: 'always (Terraform is core to this preset)' },
    { id: 'pulumi/agent-skills', condition: 'if using Pulumi instead of Terraform' },
  ],
};

describe('buildMatrixMarkdown', () => {
  it('renders a row per preset with name + always column + conditional column', () => {
    const out = buildMatrixMarkdown([STUB_NEXTJS]);
    assert.match(out, /\| Preset \| Always pair \| Conditional \|/);
    assert.match(out, /\| `nextjs` \(Next\.js full-stack\) \|/);
    assert.ok(out.includes('vercel-labs/agent-skills'));
    assert.ok(out.includes('supabase/agent-skills'));
  });

  it('lists only "always" entries in the always column', () => {
    const out = buildMatrixMarkdown([STUB_NEXTJS]);
    const rows = out.split('\n').filter((l) => l.startsWith('| `nextjs`'));
    assert.equal(rows.length, 1);
    const cells = rows[0].split('|').map((c) => c.trim());
    // cells: ['', 'preset-name', 'always', 'conditional', '']
    assert.equal(cells.length, 5);
    const always = cells[2];
    const conditional = cells[3];
    assert.ok(always.includes('vercel-labs/agent-skills'));
    assert.ok(always.includes('frontend-design@claude-plugins-official'));
    assert.ok(!always.includes('supabase'));
    assert.ok(!always.includes('prisma'));
    assert.ok(conditional.includes('supabase/agent-skills'));
    assert.ok(conditional.includes('prisma/skills'));
  });

  it('annotates conditional entries with their condition string', () => {
    const out = buildMatrixMarkdown([STUB_NEXTJS]);
    assert.match(out, /supabase\/agent-skills.*if using Supabase/);
    assert.match(out, /prisma\/skills.*if using Prisma/);
  });

  it('renders an empty preset with em-dashes (cli-tools intentionally empty)', () => {
    const out = buildMatrixMarkdown([STUB_CLI_TOOLS]);
    const row = out.split('\n').find((l) => l.startsWith('| `cli-tools`'));
    assert.ok(row);
    const cells = row.split('|').map((c) => c.trim());
    assert.equal(cells[2], '—');
    assert.equal(cells[3], '—');
  });

  it('renders a preset with only "always" entries (no conditional column content)', () => {
    const out = buildMatrixMarkdown([STUB_PHASER]);
    const row = out.split('\n').find((l) => l.startsWith('| `phaser`'));
    assert.ok(row);
    const cells = row.split('|').map((c) => c.trim());
    assert.ok(cells[2].includes('phaserjs/phaser'));
    assert.equal(cells[3], '—');
  });

  it('treats `always (...)` (with parenthetical context) as always — matches bash CLI prefix matching', () => {
    const out = buildMatrixMarkdown([STUB_PROXMOX]);
    const row = out.split('\n').find((l) => l.startsWith('| `homelab-proxmox`'));
    assert.ok(row);
    const cells = row.split('|').map((c) => c.trim());
    assert.ok(cells[2].includes('antonbabenko/terraform-skill'));
    assert.ok(!cells[3].includes('antonbabenko/terraform-skill'));
    assert.ok(cells[3].includes('pulumi/agent-skills'));
  });

  it('preserves preset order (input array order)', () => {
    const out = buildMatrixMarkdown([STUB_PHASER, STUB_NEXTJS, STUB_CLI_TOOLS]);
    const phaserIdx = out.indexOf('| `phaser`');
    const nextjsIdx = out.indexOf('| `nextjs`');
    const cliIdx = out.indexOf('| `cli-tools`');
    assert.ok(phaserIdx < nextjsIdx);
    assert.ok(nextjsIdx < cliIdx);
  });

  it('returns a markdown table with header + separator + at least one row', () => {
    const out = buildMatrixMarkdown([STUB_NEXTJS]);
    const lines = out.split('\n').filter((l) => l.startsWith('|'));
    assert.ok(lines.length >= 3); // header, separator, ≥1 data row
    assert.match(lines[1], /^\|[\s\-:|]+\|$/); // separator row of dashes
  });
});

describe('replaceMatrixBlock', () => {
  const MARKERS_ONLY = [
    '# Recipe',
    '',
    '<!-- recipe-matrix:start -->',
    '<!-- recipe-matrix:end -->',
    '',
    '## Next section',
  ].join('\n');

  it('inserts the matrix between the start/end markers', () => {
    const matrix = '| header |\n|---|\n| data |';
    const out = replaceMatrixBlock(MARKERS_ONLY, matrix);
    assert.ok(out.includes('<!-- recipe-matrix:start -->'));
    assert.ok(out.includes('<!-- recipe-matrix:end -->'));
    assert.ok(out.includes('| data |'));
    // Matrix content lands BETWEEN the markers, not outside
    const startIdx = out.indexOf('<!-- recipe-matrix:start -->');
    const endIdx = out.indexOf('<!-- recipe-matrix:end -->');
    const dataIdx = out.indexOf('| data |');
    assert.ok(startIdx < dataIdx);
    assert.ok(dataIdx < endIdx);
  });

  it('replaces existing matrix content between markers', () => {
    const existing = [
      '# Recipe',
      '',
      '<!-- recipe-matrix:start -->',
      '| OLD HEADER |',
      '|---|',
      '| OLD DATA |',
      '<!-- recipe-matrix:end -->',
      '',
      '## Next section',
    ].join('\n');
    const matrix = '| NEW HEADER |\n|---|\n| NEW DATA |';
    const out = replaceMatrixBlock(existing, matrix);
    assert.ok(out.includes('NEW DATA'));
    assert.ok(!out.includes('OLD DATA'));
  });

  it('is idempotent when content already matches', () => {
    const matrix = '| header |\n|---|\n| data |';
    const once = replaceMatrixBlock(MARKERS_ONLY, matrix);
    const twice = replaceMatrixBlock(once, matrix);
    assert.equal(twice, once);
  });

  it('preserves content outside the markers', () => {
    const matrix = '| header |\n|---|\n| data |';
    const out = replaceMatrixBlock(MARKERS_ONLY, matrix);
    assert.ok(out.startsWith('# Recipe'));
    assert.ok(out.includes('## Next section'));
  });

  it('throws when the start marker is missing', () => {
    const malformed = '# Recipe\n\n<!-- recipe-matrix:end -->';
    assert.throws(() => replaceMatrixBlock(malformed, '| matrix |'), /start marker/);
  });

  it('throws when the end marker is missing', () => {
    const malformed = '# Recipe\n\n<!-- recipe-matrix:start -->';
    assert.throws(() => replaceMatrixBlock(malformed, '| matrix |'), /end marker/);
  });
});
