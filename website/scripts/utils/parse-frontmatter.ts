/**
 * YAML frontmatter parser for markdown files
 */

export interface FrontmatterResult<T = Record<string, unknown>> {
  data: T;
  content: string;
}

/**
 * Parse YAML frontmatter from markdown content
 */
export function parseFrontmatter<T = Record<string, unknown>>(
  content: string
): FrontmatterResult<T> {
  const frontmatterRegex = /^---\s*\n([\s\S]*?)\n---\s*\n/;
  const match = content.match(frontmatterRegex);

  if (!match) {
    return {
      data: {} as T,
      content: content.trim(),
    };
  }

  const yamlContent = match[1];
  const markdownContent = content.slice(match[0].length).trim();

  // Simple YAML parser (handles basic key: value pairs)
  const data: Record<string, unknown> = {};
  const lines = yamlContent.split('\n');
  let currentKey: string | null = null;
  let currentArray: string[] = [];

  for (const line of lines) {
    const trimmed = line.trim();

    // Skip empty lines and comments
    if (!trimmed || trimmed.startsWith('#')) {
      continue;
    }

    // Check for array item
    if (trimmed.startsWith('- ')) {
      if (currentKey) {
        currentArray.push(trimmed.slice(2).trim().replace(/^["']|["']$/g, ''));
      }
      continue;
    }

    // Save previous array if any
    if (currentKey && currentArray.length > 0) {
      data[currentKey] = currentArray;
      currentArray = [];
    }

    // Parse key: value
    const colonIndex = trimmed.indexOf(':');
    if (colonIndex > 0) {
      const key = trimmed.slice(0, colonIndex).trim();
      let value = trimmed.slice(colonIndex + 1).trim();

      // Remove quotes
      value = value.replace(/^["']|["']$/g, '');

      if (value === '' || value === '[]') {
        // Array will follow or empty array
        currentKey = key;
        if (value === '[]') {
          data[key] = [];
          currentKey = null;
        }
      } else if (value === 'true') {
        data[key] = true;
        currentKey = null;
      } else if (value === 'false') {
        data[key] = false;
        currentKey = null;
      } else if (!isNaN(Number(value))) {
        data[key] = Number(value);
        currentKey = null;
      } else {
        data[key] = value;
        currentKey = null;
      }
    }
  }

  // Save final array if any
  if (currentKey && currentArray.length > 0) {
    data[currentKey] = currentArray;
  }

  return {
    data: data as T,
    content: markdownContent,
  };
}

/**
 * Generate YAML frontmatter from object
 */
export function generateFrontmatter(data: Record<string, unknown>): string {
  const lines: string[] = ['---'];

  for (const [key, value] of Object.entries(data)) {
    if (Array.isArray(value)) {
      if (value.length === 0) {
        lines.push(`${key}: []`);
      } else {
        lines.push(`${key}:`);
        for (const item of value) {
          lines.push(`  - "${item}"`);
        }
      }
    } else if (typeof value === 'string') {
      // Escape quotes in string values
      const escaped = value.replace(/"/g, '\\"');
      lines.push(`${key}: "${escaped}"`);
    } else if (typeof value === 'boolean' || typeof value === 'number') {
      lines.push(`${key}: ${value}`);
    }
  }

  lines.push('---');
  return lines.join('\n');
}

/**
 * Extract first heading from markdown content
 */
export function extractFirstHeading(content: string): string | null {
  const match = content.match(/^#\s+(.+)$/m);
  return match ? match[1].trim() : null;
}

/**
 * Extract description from markdown (first paragraph after heading)
 */
export function extractDescription(content: string): string {
  // Remove the first heading
  const withoutHeading = content.replace(/^#\s+.+$/m, '').trim();

  // Get first paragraph
  const paragraphs = withoutHeading.split(/\n\n+/);
  for (const para of paragraphs) {
    const trimmed = para.trim();
    // Skip if it's a heading, code block, or list
    if (
      !trimmed.startsWith('#') &&
      !trimmed.startsWith('```') &&
      !trimmed.startsWith('- ') &&
      !trimmed.startsWith('* ') &&
      !trimmed.startsWith('|') &&
      trimmed.length > 0
    ) {
      // Clean up the paragraph
      return trimmed
        .replace(/\n/g, ' ')
        .replace(/\s+/g, ' ')
        .slice(0, 200);
    }
  }

  return '';
}

/**
 * Extract section content by heading
 */
export function extractSection(content: string, heading: string): string | null {
  const regex = new RegExp(`^##\\s+${heading}\\s*$([\\s\\S]*?)(?=^##\\s|$)`, 'mi');
  const match = content.match(regex);
  return match ? match[1].trim() : null;
}

/**
 * Escape special MDX characters in text
 * This prevents MDX from interpreting { } < > as JSX expressions
 */
export function escapeMdx(text: string): string {
  if (!text) return '';
  return text
    .replace(/\{/g, '\\{')
    .replace(/\}/g, '\\}')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}
