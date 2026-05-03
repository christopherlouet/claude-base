/**
 * Escape MDX-special characters in content while preserving code regions.
 *
 * MDX would interpret raw `<X>` as a JSX component and raw `{...}` as a
 * JS expression, so non-code prose must be HTML-encoded for these chars.
 * But code regions (fenced ```...``` and inline `...`) render verbatim
 * in Markdown — HTML entities inside them appear LITERALLY (`&lt;`)
 * instead of decoding back to `<`. So those regions MUST be skipped.
 *
 * Previous implementations of this helper (duplicated across
 * generate-command-docs.ts, generate-rule-docs.ts, sync-docs.ts) only
 * skipped fenced code blocks. Inline code spans were silently corrupted
 * — `\`<arguments>\`` rendered as `\`&lt;arguments&gt;\``. This module
 * is the consolidated, tested replacement.
 */

import { escapeMdx } from './parse-frontmatter.js';

/**
 * Match either:
 *   - a fenced code block ```...``` (multi-line, lazy)
 *   - an inline code span `...` (single line, no nested backtick)
 *
 * Order matters: fenced first, otherwise the inline pattern would eat
 * the opening triple-backtick of a fenced block.
 */
const CODE_REGION_RE = /```[\s\S]*?```|`[^`\n]+`/g;

export function escapeMdxContent(content: string): string {
  if (!content) return '';

  const parts: string[] = [];
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  CODE_REGION_RE.lastIndex = 0;
  while ((match = CODE_REGION_RE.exec(content)) !== null) {
    if (match.index > lastIndex) {
      parts.push(escapeMdx(content.slice(lastIndex, match.index)));
    }
    parts.push(match[0]);
    lastIndex = match.index + match[0].length;
  }

  if (lastIndex < content.length) {
    parts.push(escapeMdx(content.slice(lastIndex)));
  }

  return parts.join('');
}
