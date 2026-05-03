#!/usr/bin/env ts-node
/**
 * Generate rule documentation pages from .claude/rules
 */

import * as path from 'path';
import {
  scanDirectory,
  readFileContent,
  writeFileContent,
  ensureDir,
} from './utils/file-scanner.js';
import {
  parseFrontmatter,
  extractFirstHeading,
  extractDescription,
  generateFrontmatter,
  escapeMdx,
} from './utils/parse-frontmatter.js';
import { escapeMdxContent } from './utils/escape-mdx-content.js';

const CLAUDE_DIR = path.resolve(__dirname, '../../.claude');
const RULES_DIR = path.join(CLAUDE_DIR, 'rules');
const DOCS_DIR = path.resolve(__dirname, '../docs/rules');

interface RuleFrontmatter {
  paths?: string[];
}

interface RuleInfo {
  name: string;
  description: string;
  paths: string[];
  content: string;
}

/**
 * Parse a rule file and extract metadata
 */
function parseRuleFile(filePath: string): RuleInfo | null {
  try {
    const content = readFileContent(filePath);
    const fileName = path.basename(filePath, '.md');

    const { data, content: markdownContent } = parseFrontmatter<RuleFrontmatter>(content);

    const heading = extractFirstHeading(markdownContent);
    const description = extractDescription(markdownContent);

    return {
      name: fileName,
      description: description || heading || `Rules ${fileName}`,
      paths: data.paths || [],
      content: markdownContent,
    };
  } catch (error) {
    console.error(`Error parsing ${filePath}:`, error);
    return null;
  }
}

/**
 * Generate the Docusaurus page content for a rule
 */
function generateRulePage(rule: RuleInfo, position: number): string {
  // Escape description for frontmatter (no curly braces allowed)
  const safeDescription = rule.description
    .replace(/[{}<>]/g, '')
    .slice(0, 150);

  const frontmatter = generateFrontmatter({
    sidebar_position: position,
    title: rule.name,
    description: safeDescription,
    tags: ['rule', rule.name],
  });

  const pathsList = rule.paths.length > 0
    ? rule.paths.map((p) => `- \`${p}\``).join('\n')
    : '_All files_';

  // Escape content outside code blocks
  const safeContent = escapeMdxContent(rule.content);
  const safeDesc = escapeMdx(rule.description);

  return `${frontmatter}

# Rules: ${rule.name}

> ${safeDesc}

## Affected files

These rules apply to files matching the following patterns:

${pathsList}

## Detailed rules

${safeContent}

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
`;
}

/**
 * Generate rules index page
 */
function generateRulesIndex(rules: RuleInfo[]): string {
  const frontmatter = generateFrontmatter({
    sidebar_position: 1,
    title: 'Rules',
    description: `Catalog of ${rules.length} rules by technology`,
  });

  const rulesTable = rules
    .map(
      (r) => {
        const desc = escapeMdx(r.description.slice(0, 50)) + (r.description.length > 50 ? '...' : '');
        const pathsDisplay = r.paths.length > 0
          ? r.paths.slice(0, 2).map((p) => `\`${p}\``).join(', ') + (r.paths.length > 2 ? '...' : '')
          : '-';
        return `| [\`${r.name}\`](/docs/rules/${r.name}) | ${desc} | ${pathsDisplay} |`;
      }
    )
    .join('\n');

  return `${frontmatter}

import Stats from '@site/src/components/Stats';

# Rules Catalog

> **${rules.length} rules** automatically applied by file path

<Stats items={[
  { number: ${rules.length}, label: 'Rules' },
  { number: ${rules.reduce((acc, r) => acc + r.paths.length, 0)}, label: 'Patterns' },
]} />

## What is a Rule?

**Rules** are conventions applied automatically:

- **Apply by path**: Activated according to the file path
- **Code conventions**: TypeScript, React, Flutter, etc.
- **Best practices**: Security, tests, API
- **Transparency**: Always visible in suggestions

## List of rules

| Rule | Description | Paths |
|------|-------------|-------|
${rulesTable}

## Categories

### Languages

${rules.filter((r) => ['typescript', 'python', 'go', 'rust', 'java', 'php', 'ruby', 'csharp'].includes(r.name)).map((r) => `- [${r.name}](/docs/rules/${r.name})`).join('\n')}

### Frameworks

${rules.filter((r) => ['react', 'flutter'].includes(r.name)).map((r) => `- [${r.name}](/docs/rules/${r.name})`).join('\n')}

### Practices

${rules.filter((r) => ['testing', 'security', 'api', 'git', 'workflow'].includes(r.name)).map((r) => `- [${r.name}](/docs/rules/${r.name})`).join('\n')}

## How to add a custom rule

Create a file \`.claude/rules/my-rule.md\`:

\`\`\`markdown
---
paths:
  - "**/my-folder/**"
  - "**/*.custom"
---

# My custom rules

- Rule 1
- Rule 2
\`\`\`

---

## See also

- [Architecture](/docs/intro/architecture) - Understand the components
- [Commands](/docs/commands) - Manual commands
- [Skills](/docs/skills) - Auto-triggered skills
`;
}

/**
 * Main generation function
 */
async function generateRuleDocs(): Promise<void> {
  console.log('Generating rule documentation...');

  // Scan rule files
  const files = scanDirectory(RULES_DIR, {
    extensions: ['.md'],
    recursive: false,
  });

  console.log(`Found ${files.length} rule files`);

  // Parse rules
  const rules: RuleInfo[] = [];
  for (const file of files) {
    if (file.name === 'index' || file.name === 'README') {
      continue;
    }

    const rule = parseRuleFile(file.path);
    if (rule) {
      rules.push(rule);
    }
  }

  console.log(`Parsed ${rules.length} rules`);

  // Sort rules by name
  rules.sort((a, b) => a.name.localeCompare(b.name));

  // Generate documentation
  ensureDir(DOCS_DIR);

  // Generate index
  const index = generateRulesIndex(rules);
  writeFileContent(path.join(DOCS_DIR, 'index.md'), index);
  console.log('Generated: docs/rules/index.md');

  // Generate individual rule pages
  let position = 2;
  for (const rule of rules) {
    const page = generateRulePage(rule, position);
    writeFileContent(path.join(DOCS_DIR, `${rule.name}.md`), page);
    position++;
  }

  console.log(`\nGenerated ${rules.length} rule pages`);
}

// Run if called directly
generateRuleDocs().catch(console.error);

export { generateRuleDocs };
