import { describe, it } from 'node:test';
import assert from 'node:assert/strict';

import { rewriteUnsyncedRepoLinks } from './rewrite-links.js';

const BLOB = 'https://github.com/christopherlouet/claude-base/blob/main';

describe('rewriteUnsyncedRepoLinks', () => {
  it('rewrites a docs/recipes link (3 levels up) to a GitHub blob URL', () => {
    const out = rewriteUnsyncedRepoLinks(
      'See [recipe](../../../docs/recipes/recommended-vendor-skills.md) for depth.',
    );
    assert.equal(
      out,
      `See [recipe](${BLOB}/docs/recipes/recommended-vendor-skills.md) for depth.`,
    );
  });

  it('rewrites a specs/ link to a GitHub blob URL', () => {
    const out = rewriteUnsyncedRepoLinks(
      '[rationale](../../../specs/foundation-positioning-review/spec.md)',
    );
    assert.equal(out, `[rationale](${BLOB}/specs/foundation-positioning-review/spec.md)`);
  });

  it('handles varying relative depths (one or more ../)', () => {
    const out = rewriteUnsyncedRepoLinks('[x](../specs/a.md) [y](../../specs/b.md)');
    assert.equal(out, `[x](${BLOB}/specs/a.md) [y](${BLOB}/specs/b.md)`);
  });

  it('leaves synced docs links and external URLs untouched', () => {
    const input =
      '[ref](../reference/best-practices.md) and [ext](https://example.com/specs/x.md)';
    assert.equal(rewriteUnsyncedRepoLinks(input), input);
  });

  it('is a no-op on content without matching links', () => {
    const input = 'Plain text with [a local](./other.md) link.';
    assert.equal(rewriteUnsyncedRepoLinks(input), input);
  });
});
