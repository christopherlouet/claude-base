import { describe, it } from 'node:test';
import assert from 'node:assert/strict';

import { escapeMdxContent } from './escape-mdx-content.js';

describe('escapeMdxContent', () => {
  it('escapes < in regular prose (MDX would treat <X> as JSX)', () => {
    const out = escapeMdxContent('See <Component /> for details');
    assert.ok(out.includes('&lt;Component'), `expected &lt;, got: ${out}`);
    assert.ok(!out.includes('<Component'));
  });

  it('does NOT escape > in prose (would break Markdown blockquotes)', () => {
    const out = escapeMdxContent('> This is a blockquote');
    assert.equal(out, '> This is a blockquote');
  });

  it('does NOT escape & in prose (would double-encode entities)', () => {
    const out = escapeMdxContent('foo & bar with &lt; pre-encoded');
    assert.ok(out.includes('foo & bar'));
    assert.ok(out.includes('&lt;'), 'pre-encoded entity must stay');
    assert.ok(!out.includes('&amp;'), 'must not double-encode');
  });

  it('does NOT escape inside fenced code blocks', () => {
    const input = 'Before\n```ts\nconst x: Foo<T> = bar;\n```\nAfter';
    const out = escapeMdxContent(input);
    assert.ok(out.includes('Foo<T>'), 'fenced code content must stay verbatim');
  });

  it('does NOT escape inside inline code spans (the bug)', () => {
    const input = 'Use the placeholder `<arguments>` like this';
    const out = escapeMdxContent(input);
    assert.ok(
      out.includes('`<arguments>`'),
      `inline code must stay verbatim, got: ${out}`
    );
    assert.ok(
      !out.includes('&lt;arguments&gt;'),
      'inline code must not be HTML-encoded'
    );
  });

  it('handles a mix of fenced + inline + prose', () => {
    const input = [
      'Inline `<X>` in prose',
      '',
      '```ts',
      'type T<U> = U;',
      '```',
      '',
      'Then prose with <Y> outside code',
    ].join('\n');
    const out = escapeMdxContent(input);
    assert.ok(out.includes('`<X>`'), 'inline preserved');
    assert.ok(out.includes('type T<U> = U;'), 'fenced preserved');
    assert.ok(out.includes('&lt;Y'), 'prose < escaped');
    assert.ok(out.includes('Y> outside') || out.includes('Y&gt; outside'), 'prose > behaviour');
  });

  it('handles inline code with multiple < > characters', () => {
    const input = 'Type signature: `Map<K, Array<V>>` here';
    const out = escapeMdxContent(input);
    assert.ok(out.includes('`Map<K, Array<V>>`'));
  });

  it('does not break when inline code is at start of line', () => {
    const input = '`<placeholder>` is the syntax';
    const out = escapeMdxContent(input);
    assert.ok(out.startsWith('`<placeholder>`'));
  });

  it('escapes outside but preserves consecutive inline codes', () => {
    const input = 'Use `<a>` and `<b>` and not <c>';
    const out = escapeMdxContent(input);
    assert.ok(out.includes('`<a>`'));
    assert.ok(out.includes('`<b>`'));
    assert.ok(out.includes('&lt;c'), 'outside < is escaped');
  });

  it('still escapes braces { } in prose for MDX safety', () => {
    const input = 'Object literal: {key: value}';
    const out = escapeMdxContent(input);
    assert.ok(out.includes('\\{'));
    assert.ok(out.includes('\\}'));
  });

  it('preserves braces inside fenced code', () => {
    const input = '```ts\nconst o = { a: 1 };\n```';
    const out = escapeMdxContent(input);
    assert.ok(out.includes('{ a: 1 }'), 'fenced braces stay');
  });

  it('preserves braces inside inline code', () => {
    const input = 'Use `{count: 1}` in your config';
    const out = escapeMdxContent(input);
    assert.ok(out.includes('`{count: 1}`'), 'inline braces stay');
  });

  it('handles empty input safely', () => {
    assert.equal(escapeMdxContent(''), '');
  });

  it('handles input with no special chars', () => {
    assert.equal(escapeMdxContent('hello world'), 'hello world');
  });
});
