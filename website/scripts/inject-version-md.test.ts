/**
 * Tests for inject-version-md.ts — the version-marker injection mirror
 * of inject-counts-md.ts. Pure logic only; fs orchestration is exercised
 * indirectly via the existing generate pipeline.
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';

import { replaceVersionMarkers } from './inject-version-md.js';

describe('replaceVersionMarkers', () => {
  it('replaces a single marker with the provided version', () => {
    const input = 'Version: <!-- version -->1.36.1<!-- /version -->';
    const out = replaceVersionMarkers(input, '1.38.0');
    assert.equal(out, 'Version: <!-- version -->1.38.0<!-- /version -->');
  });

  it('replaces every occurrence in a multi-marker file', () => {
    const input = [
      'Header: <!-- version -->1.0.0<!-- /version -->',
      'Body line unrelated',
      'Footer: <!-- version -->1.0.0<!-- /version -->',
    ].join('\n');
    const out = replaceVersionMarkers(input, '2.0.0');
    assert.ok(out.includes('Header: <!-- version -->2.0.0<!-- /version -->'));
    assert.ok(out.includes('Footer: <!-- version -->2.0.0<!-- /version -->'));
    assert.ok(!out.includes('1.0.0'));
  });

  it('is idempotent when every marker already holds the target version', () => {
    const input = 'Version: <!-- version -->1.38.0<!-- /version -->';
    const out = replaceVersionMarkers(input, '1.38.0');
    assert.equal(out, input);
  });

  it('tolerates whitespace variations inside the marker tag', () => {
    const input = 'Version: <!--version-->1.36.1<!--/version-->';
    const out = replaceVersionMarkers(input, '1.38.0');
    assert.ok(out.includes('1.38.0'));
    assert.ok(!out.includes('1.36.1'));
  });

  it('does not touch unrelated HTML comments', () => {
    const input = '<!-- author: chris --> Version: <!-- version -->1.0.0<!-- /version -->';
    const out = replaceVersionMarkers(input, '2.0.0');
    assert.ok(out.includes('<!-- author: chris -->'));
    assert.ok(out.includes('<!-- version -->2.0.0<!-- /version -->'));
  });

  it('returns input unchanged when no version marker is present', () => {
    const input = '# Heading\n\nNo markers here, just prose.';
    const out = replaceVersionMarkers(input, '9.9.9');
    assert.equal(out, input);
  });

  it('does not touch count markers (different namespace)', () => {
    const input = 'Commands: <!-- count:commands -->131<!-- /count -->';
    const out = replaceVersionMarkers(input, '2.0.0');
    assert.equal(out, input);
  });

  it('handles non-semver-looking content between the tags (just replaces it)', () => {
    const input = 'Version: <!-- version -->whatever was there<!-- /version -->';
    const out = replaceVersionMarkers(input, '1.38.0');
    assert.equal(out, 'Version: <!-- version -->1.38.0<!-- /version -->');
  });
});
