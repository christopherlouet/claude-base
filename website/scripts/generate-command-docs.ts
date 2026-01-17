#!/usr/bin/env ts-node
/**
 * Generate command documentation pages from .claude/commands
 */

import * as path from 'path';
import {
  scanDirectory,
  readFileContent,
  writeFileContent,
  ensureDir,
  extractDomain,
} from './utils/file-scanner.js';
import {
  extractFirstHeading,
  extractDescription,
  generateFrontmatter,
  escapeMdx,
} from './utils/parse-frontmatter.js';
import { Domain, DOMAIN_LABELS, DOMAIN_DESCRIPTIONS } from './utils/types.js';

const CLAUDE_DIR = path.resolve(__dirname, '../../.claude');
const COMMANDS_DIR = path.join(CLAUDE_DIR, 'commands');
const DOCS_DIR = path.resolve(__dirname, '../docs/commands');

interface CommandInfo {
  name: string;
  domain: Domain;
  description: string;
  filePath: string;
  content: string;
}

/**
 * Parse a command file and extract metadata
 */
function parseCommandFile(filePath: string): CommandInfo | null {
  try {
    const content = readFileContent(filePath);
    const fileName = path.basename(filePath, '.md');
    const domain = extractDomain(filePath) as Domain;

    // Extract title from first heading
    const heading = extractFirstHeading(content);
    const name = heading || fileName;

    // Extract description
    const description = extractDescription(content);

    return {
      name: fileName,
      domain,
      description: description || `Commande ${name}`,
      filePath,
      content,
    };
  } catch (error) {
    console.error(`Error parsing ${filePath}:`, error);
    return null;
  }
}

/**
 * Escape content outside of code blocks for MDX safety
 */
function escapeNonCodeContent(content: string): string {
  const parts: string[] = [];
  let lastIndex = 0;

  // Match fenced code blocks
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
 * Generate the Docusaurus page content for a command
 */
function generateCommandPage(command: CommandInfo, position: number): string {
  // Safe description without MDX-breaking characters
  const safeDescription = command.description
    .replace(/[{}<>]/g, '')
    .slice(0, 150);

  const frontmatter = generateFrontmatter({
    sidebar_position: position,
    title: `/${command.name}`,
    description: safeDescription,
    tags: [command.domain, 'command'],
  });

  // Clean up the original content
  let content = command.content;

  // Remove the $ARGUMENTS placeholder
  content = content.replace(/\$ARGUMENTS/g, '`<arguments>`');

  // Escape MDX-problematic characters outside code blocks
  content = escapeNonCodeContent(content);

  // Add badges and metadata
  const header = `
import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--${command.domain}">${DOMAIN_LABELS[command.domain]}</span>

`;

  return `${frontmatter}

${header}
${content}

---

## Voir aussi

- [Retour aux commandes ${DOMAIN_LABELS[command.domain]}](/docs/commands/${command.domain})
- [Toutes les commandes](/docs/commands)
`;
}

/**
 * Generate index page for a domain
 */
function generateDomainIndex(domain: Domain, commands: CommandInfo[]): string {
  const label = DOMAIN_LABELS[domain];
  const description = DOMAIN_DESCRIPTIONS[domain];

  const frontmatter = generateFrontmatter({
    sidebar_position: 1,
    title: label,
    description: `Commandes ${label} - ${description}`,
  });

  const commandsList = commands
    .map(
      (cmd) =>
        `| [\`/${cmd.name}\`](/docs/commands/${domain}/${cmd.name}) | ${cmd.description} |`
    )
    .join('\n');

  return `${frontmatter}

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# Commandes ${label}

> ${description}

## Vue d'ensemble

Ce domaine contient **${commands.length} commandes** pour ${description.toLowerCase()}.

## Liste des commandes

| Commande | Description |
|----------|-------------|
${commandsList}

## Commandes en detail

<CommandGrid>
${commands.map((cmd) => `  <CommandCard
    name="${cmd.name}"
    description="${cmd.description.replace(/"/g, '\\"')}"
    domain="${domain}"
    href="/docs/commands/${domain}/${cmd.name}"
  />`).join('\n')}
</CommandGrid>

---

[Retour a toutes les commandes](/docs/commands)
`;
}

/**
 * Generate main commands index page
 */
function generateMainIndex(commandsByDomain: Map<Domain, CommandInfo[]>): string {
  const frontmatter = generateFrontmatter({
    sidebar_position: 1,
    title: 'Commands',
    description: 'Catalogue des 108 commandes claude-socle',
  });

  let totalCommands = 0;
  const domainSections: string[] = [];

  for (const [domain, commands] of commandsByDomain) {
    totalCommands += commands.length;
    const label = DOMAIN_LABELS[domain];
    const description = DOMAIN_DESCRIPTIONS[domain];

    domainSections.push(`
### [${label}](/docs/commands/${domain}) (${commands.length})

> ${description}

${commands.slice(0, 5).map((cmd) => `- [\`/${cmd.name}\`](/docs/commands/${domain}/${cmd.name})`).join('\n')}
${commands.length > 5 ? `- [... et ${commands.length - 5} autres](/docs/commands/${domain})` : ''}
`);
  }

  return `${frontmatter}

import Stats from '@site/src/components/Stats';

# Catalogue des Commandes

> **${totalCommands} commandes** organisees en **${commandsByDomain.size} domaines**

<Stats items={[
  { number: ${totalCommands}, label: 'Commandes' },
  { number: ${commandsByDomain.size}, label: 'Domaines' },
]} />

## Comment utiliser les commandes

Les commandes sont declenchees manuellement avec le prefixe \`/\` :

\`\`\`bash
/work-explore
/dev-tdd "Description de la feature"
/qa-security
\`\`\`

## Domaines

${domainSections.join('\n')}

## Guide de choix rapide

| Besoin | Commande recommandee |
|--------|---------------------|
| Explorer le code | \`/work-explore\` |
| Planifier une modification | \`/work-plan\` |
| Developper en TDD | \`/dev-tdd\` |
| Creer un commit | \`/work-commit\` |
| Audit de securite | \`/qa-security\` |
| Audit complet | \`/qa-audit\` |
| Creer une PR | \`/work-pr\` |
| Release | \`/ops-release\` |

---

Utilisez \`/assistant\` pour obtenir des recommandations personnalisees.
`;
}

/**
 * Main generation function
 */
async function generateCommandDocs(): Promise<void> {
  console.log('Generating command documentation...');

  // Scan command files
  const files = scanDirectory(COMMANDS_DIR, {
    extensions: ['.md'],
    recursive: true,
  });

  console.log(`Found ${files.length} command files`);

  // Parse commands
  const commands: CommandInfo[] = [];
  for (const file of files) {
    // Skip index files
    if (file.name === 'index' || file.name === 'README') {
      continue;
    }

    const command = parseCommandFile(file.path);
    if (command) {
      commands.push(command);
    }
  }

  console.log(`Parsed ${commands.length} commands`);

  // Group by domain
  const commandsByDomain = new Map<Domain, CommandInfo[]>();
  for (const command of commands) {
    const existing = commandsByDomain.get(command.domain) || [];
    existing.push(command);
    commandsByDomain.set(command.domain, existing);
  }

  // Sort commands within each domain
  for (const [domain, domainCommands] of commandsByDomain) {
    domainCommands.sort((a, b) => a.name.localeCompare(b.name));
  }

  // Generate documentation
  ensureDir(DOCS_DIR);

  // Generate main index
  const mainIndex = generateMainIndex(commandsByDomain);
  writeFileContent(path.join(DOCS_DIR, 'index.md'), mainIndex);
  console.log('Generated: docs/commands/index.md');

  // Generate domain pages
  let generatedCount = 0;
  for (const [domain, domainCommands] of commandsByDomain) {
    const domainDir = path.join(DOCS_DIR, domain);
    ensureDir(domainDir);

    // Generate domain index
    const domainIndex = generateDomainIndex(domain, domainCommands);
    writeFileContent(path.join(domainDir, 'index.md'), domainIndex);
    console.log(`Generated: docs/commands/${domain}/index.md`);

    // Generate individual command pages
    let position = 2;
    for (const command of domainCommands) {
      const page = generateCommandPage(command, position);
      writeFileContent(path.join(domainDir, `${command.name}.md`), page);
      position++;
      generatedCount++;
    }
  }

  console.log(`\nGenerated ${generatedCount} command pages`);
}

// Run if called directly
generateCommandDocs().catch(console.error);

export { generateCommandDocs };
