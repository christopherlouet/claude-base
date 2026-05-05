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
} from './utils/parse-frontmatter.js';
import { escapeMdxContent } from './utils/escape-mdx-content.js';
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
      description: description || `Command ${name}`,
      filePath,
      content,
    };
  } catch (error) {
    console.error(`Error parsing ${filePath}:`, error);
    return null;
  }
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
    title: command.domain === 'other' ? `/${command.name}` : `/${command.domain}:${command.name}`,
    description: safeDescription,
    tags: [command.domain, 'command'],
  });

  // Clean up the original content
  let content = command.content;

  // Remove the $ARGUMENTS placeholder
  content = content.replace(/\$ARGUMENTS/g, '`<arguments>`');

  // Escape MDX-problematic characters outside code regions
  content = escapeMdxContent(content);

  // Add badges and metadata
  const header = `
import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--${command.domain}">${DOMAIN_LABELS[command.domain]}</span>

`;

  return `${frontmatter}

${header}
${content}

---

## See also

- [Back to ${DOMAIN_LABELS[command.domain]} commands](/docs/commands/${command.domain})
- [All commands](/docs/commands)
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
    description: `${label} commands - ${description}`,
  });

  const commandsList = commands
    .map(
      (cmd) => {
        const cmdLabel = domain === 'other' ? `/${cmd.name}` : `/${domain}:${cmd.name}`;
        return `| [\`${cmdLabel}\`](/docs/commands/${domain}/${cmd.name}) | ${cmd.description} |`;
      }
    )
    .join('\n');

  return `${frontmatter}

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# ${label} Commands

> ${description}

## Overview

This domain contains **${commands.length} commands** for ${description.toLowerCase()}.

## Commands list

| Command | Description |
|----------|-------------|
${commandsList}

## Commands in detail

<CommandGrid>
${commands.map((cmd) => `  <CommandCard
    name="${cmd.name}"
    description="${cmd.description.replace(/"/g, '&quot;')}"
    domain="${domain}"
    href="/docs/commands/${domain}/${cmd.name}"
  />`).join('\n')}
</CommandGrid>

---

[Back to all commands](/docs/commands)
`;
}

/**
 * Generate main commands index page
 */
function generateMainIndex(commandsByDomain: Map<Domain, CommandInfo[]>): string {
  const totalForDescription = Array.from(commandsByDomain.values()).reduce(
    (sum, cmds) => sum + cmds.length,
    0
  );

  const frontmatter = generateFrontmatter({
    sidebar_position: 1,
    title: 'Commands',
    description: `Catalog of ${totalForDescription} claude-base commands`,
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

${commands.slice(0, 5).map((cmd) => {
    const cmdLabel = domain === 'other' ? `/${cmd.name}` : `/${domain}:${cmd.name}`;
    return `- [\`${cmdLabel}\`](/docs/commands/${domain}/${cmd.name})`;
  }).join('\n')}
${commands.length > 5 ? `- [... and ${commands.length - 5} more](/docs/commands/${domain})` : ''}
`);
  }

  return `${frontmatter}

import Stats from '@site/src/components/Stats';

# Commands Catalog

> **${totalCommands} commands** organized in **${commandsByDomain.size} domains**

<Stats items={[
  { number: ${totalCommands}, label: 'Commands' },
  { number: ${commandsByDomain.size}, label: 'Domains' },
]} />

## How to use commands

Commands are triggered manually with the \`/\` prefix:

\`\`\`bash
/work:work-explore
/dev:dev-tdd "Feature description"
/qa:qa-security
\`\`\`

## Domains

${domainSections.join('\n')}

## Quick choice guide

| Need | Recommended command |
|--------|---------------------|
| Explore the code | \`/work:work-explore\` |
| Specify the need | \`/work:work-specify\` |
| Plan a change | \`/work:work-plan\` |
| Develop with TDD | \`/dev:dev-tdd\` |
| Create a commit | \`/work:work-commit\` |
| Security audit | \`/qa:qa-security\` |
| Full audit | \`/qa:qa-audit\` |
| Create a PR | \`/work:work-pr\` |
| Release | \`/ops:ops-release\` |

---

Use \`/assistant\` to get personalized recommendations.
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
