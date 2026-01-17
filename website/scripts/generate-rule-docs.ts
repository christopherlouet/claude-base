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
      description: description || heading || `Regles ${fileName}`,
      paths: data.paths || [],
      content: markdownContent,
    };
  } catch (error) {
    console.error(`Error parsing ${filePath}:`, error);
    return null;
  }
}

/**
 * Wrap code blocks in markdown to prevent MDX parsing issues
 * Only escape content outside of code blocks
 */
function escapeNonCodeContent(content: string): string {
  const parts: string[] = [];
  let lastIndex = 0;

  // Match code blocks (fenced with ``` or indented)
  const codeBlockRegex = /```[\s\S]*?```/g;
  let match;

  while ((match = codeBlockRegex.exec(content)) !== null) {
    // Escape content before this code block
    if (match.index > lastIndex) {
      parts.push(escapeMdx(content.slice(lastIndex, match.index)));
    }
    // Keep code block as-is
    parts.push(match[0]);
    lastIndex = match.index + match[0].length;
  }

  // Escape remaining content after last code block
  if (lastIndex < content.length) {
    parts.push(escapeMdx(content.slice(lastIndex)));
  }

  return parts.join('');
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
    : '_Toutes les fichiers_';

  // Escape content outside code blocks
  const safeContent = escapeNonCodeContent(rule.content);
  const safeDesc = escapeMdx(rule.description);

  return `${frontmatter}

# Regles: ${rule.name}

> ${safeDesc}

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

${pathsList}

## Regles detaillees

${safeContent}

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
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
    description: 'Catalogue des 15 regles par technologie',
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

# Catalogue des Regles

> **${rules.length} regles** appliquees automatiquement par chemin de fichier

<Stats items={[
  { number: ${rules.length}, label: 'Regles' },
  { number: ${rules.reduce((acc, r) => acc + r.paths.length, 0)}, label: 'Patterns' },
]} />

## Qu'est-ce qu'une Rule ?

Les **rules** sont des conventions appliquees automatiquement :

- **Application par path** : Actives selon le chemin du fichier
- **Conventions de code** : TypeScript, React, Flutter, etc.
- **Bonnes pratiques** : Securite, tests, API
- **Transparence** : Toujours visibles dans les suggestions

## Liste des regles

| Regle | Description | Paths |
|-------|-------------|-------|
${rulesTable}

## Categories

### Langages

${rules.filter((r) => ['typescript', 'python', 'go', 'rust', 'java', 'php', 'ruby', 'csharp'].includes(r.name)).map((r) => `- [${r.name}](/docs/rules/${r.name})`).join('\n')}

### Frameworks

${rules.filter((r) => ['react', 'flutter'].includes(r.name)).map((r) => `- [${r.name}](/docs/rules/${r.name})`).join('\n')}

### Pratiques

${rules.filter((r) => ['testing', 'security', 'api', 'git', 'workflow'].includes(r.name)).map((r) => `- [${r.name}](/docs/rules/${r.name})`).join('\n')}

## Comment ajouter une regle personnalisee

Creez un fichier \`.claude/rules/my-rule.md\` :

\`\`\`markdown
---
paths:
  - "**/my-folder/**"
  - "**/*.custom"
---

# Mes regles personnalisees

- Regle 1
- Regle 2
\`\`\`

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre les composants
- [Commands](/docs/commands) - Les commandes manuelles
- [Skills](/docs/skills) - Les skills auto-declenches
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
