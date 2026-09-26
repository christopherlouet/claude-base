/**
 * A frontmatter tools field (`tools`, `disallowedTools`, `allowed-tools`) is
 * either a YAML list or an inline string "Read, Bash(npm test:*)". Shared by
 * the agent and skill generators: the skill one assumed a list and crashed on
 * the inline form.
 */
export function parseToolsField(tools: unknown): string[] {
  if (!tools) return [];
  if (Array.isArray(tools)) return tools.map(String);
  if (typeof tools === 'string') {
    return tools.split(',').map((t) => t.trim()).filter(Boolean);
  }
  return [];
}
