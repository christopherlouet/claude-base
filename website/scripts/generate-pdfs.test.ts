import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import * as path from 'node:path';
import * as os from 'node:os';
import * as fs from 'node:fs';

import {
  PDF_TARGETS,
  checkBuildExists,
  resolveOutputPath,
} from './generate-pdfs.js';

describe('PDF_TARGETS', () => {
  it('contains exactly 9 targets', () => {
    assert.equal(PDF_TARGETS.length, 9);
  });

  it('has unique slugs', () => {
    const slugs = PDF_TARGETS.map((t) => t.slug);
    assert.equal(new Set(slugs).size, slugs.length);
  });

  it('has unique html paths', () => {
    const paths = PDF_TARGETS.map((t) => t.htmlPath);
    assert.equal(new Set(paths).size, paths.length);
  });

  it('all html paths follow docs/<section>/<slug>.html pattern', () => {
    for (const target of PDF_TARGETS) {
      assert.match(
        target.htmlPath,
        /^docs\/(intro|guides)\/[a-z0-9-]+\.html$/,
        `Invalid path: ${target.htmlPath}`,
      );
    }
  });

  it('slug matches html basename', () => {
    for (const target of PDF_TARGETS) {
      const basename = path.basename(target.htmlPath, '.html');
      assert.equal(target.slug, basename);
    }
  });

  it('includes formation content', () => {
    const slugs = PDF_TARGETS.map((t) => t.slug);
    assert.ok(slugs.includes('quick-start'));
    assert.ok(slugs.includes('claude-code-training'));
    assert.ok(slugs.includes('prompting-guide'));
  });

  it('includes ops content', () => {
    const slugs = PDF_TARGETS.map((t) => t.slug);
    assert.ok(slugs.includes('infra-guide'));
    assert.ok(slugs.includes('observability-guide'));
    assert.ok(slugs.includes('troubleshooting-guide'));
  });
});

describe('checkBuildExists', () => {
  it('returns false when directory does not exist', () => {
    const nonexistent = path.join(os.tmpdir(), `pdf-test-${Date.now()}-nope`);
    assert.equal(checkBuildExists(nonexistent), false);
  });

  it('returns true when directory exists', () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'pdf-test-'));
    try {
      assert.equal(checkBuildExists(tmp), true);
    } finally {
      fs.rmSync(tmp, { recursive: true, force: true });
    }
  });

  it('returns false when path is a file, not a directory', () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'pdf-test-'));
    const file = path.join(tmp, 'not-a-dir');
    fs.writeFileSync(file, '');
    try {
      assert.equal(checkBuildExists(file), false);
    } finally {
      fs.rmSync(tmp, { recursive: true, force: true });
    }
  });
});

describe('resolveOutputPath', () => {
  it('combines outDir and slug with .pdf extension', () => {
    const result = resolveOutputPath('/tmp/pdf', 'web-guide');
    assert.equal(result, path.join('/tmp/pdf', 'web-guide.pdf'));
  });

  it('does not double-append .pdf', () => {
    const result = resolveOutputPath('/tmp/pdf', 'web-guide');
    assert.ok(result.endsWith('.pdf'));
    assert.ok(!result.endsWith('.pdf.pdf'));
  });

  it('rejects slugs with path traversal', () => {
    assert.throws(() => resolveOutputPath('/tmp/pdf', '../etc/passwd'));
    assert.throws(() => resolveOutputPath('/tmp/pdf', '..'));
    assert.throws(() => resolveOutputPath('/tmp/pdf', 'foo/bar'));
  });

  it('rejects slugs with special characters', () => {
    assert.throws(() => resolveOutputPath('/tmp/pdf', 'web guide'));
    assert.throws(() => resolveOutputPath('/tmp/pdf', 'web_guide'));
    assert.throws(() => resolveOutputPath('/tmp/pdf', 'WebGuide'));
    assert.throws(() => resolveOutputPath('/tmp/pdf', ''));
  });
});
