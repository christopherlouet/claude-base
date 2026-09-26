/**
 * A frontmatter tools field (`tools`, `disallowedTools`, `allowed-tools`) is
 * either a YAML list or an inline string, comma- OR space-separated
 * ("Read, Grep" or "Read Bash(npm test:*)"). Split outside parentheses only, so
 * `Bash(npm test:*)` stays one item. Shared by the agent and skill generators:
 * the skill one assumed a list and crashed on the inline form.
 */
export function parseToolsField(tools: unknown): string[] {
  if (!tools) return [];
  if (Array.isArray(tools)) return tools.map(String);
  if (typeof tools === 'string') {
    const items: string[] = [];
    let depth = 0;
    let current = '';
    for (const c of tools) {
      if (c === '(') depth++;
      if (c === ')' && depth > 0) depth--;
      if (depth === 0 && (c === ',' || /\s/.test(c))) {
        if (current) items.push(current);
        current = '';
      } else {
        current += c;
      }
    }
    if (current) items.push(current);
    return items;
  }
  return [];
}
