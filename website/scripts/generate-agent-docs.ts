#!/usr/bin/env ts-node
/**
 * Generate agent documentation pages from .claude/agents
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
} from './utils/parse-frontmatter.js';

const CLAUDE_DIR = path.resolve(__dirname, '../../.claude');
const AGENTS_DIR = path.join(CLAUDE_DIR, 'agents');
const DOCS_DIR = path.resolve(__dirname, '../docs/agents');

interface AgentFrontmatter {
  model?: string;
  tools?: string[];
  permissionMode?: string;
  disallowedTools?: string[];
  skills?: string[];
}

interface AgentInfo {
  name: string;
  model: 'haiku' | 'sonnet' | 'opus';
  description: string;
  tools: string[];
  permissionMode: string;
  disallowedTools: string[];
  skills: string[];
  content: string;
}

/**
 * Parse an agent file and extract metadata
 */
function parseAgentFile(filePath: string): AgentInfo | null {
  try {
    const content = readFileContent(filePath);
    const fileName = path.basename(filePath, '.md');

    const { data, content: markdownContent } = parseFrontmatter<AgentFrontmatter>(content);

    // Extract title from first heading
    const heading = extractFirstHeading(markdownContent);
    const description = extractDescription(markdownContent);

    // Tools can be a string "Read, Grep" or an array ["Read", "Grep"]
    const parseToolsField = (tools: string | string[] | undefined): string[] => {
      if (!tools) return [];
      if (Array.isArray(tools)) return tools;
      if (typeof tools === 'string') {
        return tools.split(',').map((t) => t.trim()).filter(Boolean);
      }
      return [];
    };

    return {
      name: fileName,
      model: (data.model as 'haiku' | 'sonnet' | 'opus') || 'haiku',
      description: description || heading || `Agent ${fileName}`,
      tools: parseToolsField(data.tools as string | string[] | undefined),
      permissionMode: data.permissionMode || 'default',
      disallowedTools: parseToolsField(data.disallowedTools as string | string[] | undefined),
      skills: Array.isArray(data.skills) ? data.skills : [],
      content: markdownContent,
    };
  } catch (error) {
    console.error(`Error parsing ${filePath}:`, error);
    return null;
  }
}

/**
 * Generate the Docusaurus page content for an agent
 */
function generateAgentPage(agent: AgentInfo, position: number): string {
  const frontmatter = generateFrontmatter({
    sidebar_position: position,
    title: agent.name,
    description: agent.description,
    tags: ['agent', agent.model],
  });

  const modelBadge = `<span className="badge badge--${agent.model}">${agent.model.charAt(0).toUpperCase() + agent.model.slice(1)}</span>`;

  const toolsList = agent.tools.length > 0
    ? agent.tools.map((t) => `\`${t}\``).join(', ')
    : '_No tool specified_';

  const disallowedList = agent.disallowedTools.length > 0
    ? agent.disallowedTools.map((t) => `\`${t}\``).join(', ')
    : '_None_';

  const skillsList = agent.skills.length > 0
    ? agent.skills.map((s) => `\`${s}\``).join(', ')
    : '_None_';

  return `${frontmatter}

# Agent: ${agent.name}

${modelBadge}

> ${agent.description}

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | ${agent.model} |
| **Permission Mode** | ${agent.permissionMode} |
| **Allowed tools** | ${toolsList} |
| **Disallowed tools** | ${disallowedList} |
| **Injected skills** | ${skillsList} |

## Detailed description

${agent.content}

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the ${agent.model} model

${agent.model === 'haiku' ? `
**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only
` : agent.model === 'sonnet' ? `
**Sonnet** is optimized for:
- Complex tasks requiring analysis
- Performance/cost balance
- Audits and diagnostics
` : `
**Opus** is optimized for:
- Tasks requiring maximum capabilities
- Very complex analyses
- Critical cases
`}

---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
`;
}

/**
 * Generate agents index page
 */
function generateAgentsIndex(agents: AgentInfo[]): string {
  const frontmatter = generateFrontmatter({
    sidebar_position: 1,
    title: 'Agents',
    description: `Catalog of ${agents.length} claude-socle sub-agents`,
  });

  const haikuAgents = agents.filter((a) => a.model === 'haiku');
  const sonnetAgents = agents.filter((a) => a.model === 'sonnet');
  const opusAgents = agents.filter((a) => a.model === 'opus');

  const generateTable = (agentList: AgentInfo[]) =>
    agentList
      .map(
        (a) => {
          const desc = a.description || '';
          const tools = a.tools || [];
          const truncatedDesc = desc.slice(0, 60) + (desc.length > 60 ? '...' : '');
          const toolsDisplay = tools.length > 0
            ? tools.slice(0, 3).join(', ') + (tools.length > 3 ? '...' : '')
            : '-';
          return `| [\`${a.name}\`](/docs/agents/${a.name}) | ${truncatedDesc} | ${toolsDisplay} |`;
        }
      )
      .join('\n');

  return `${frontmatter}

import Stats from '@site/src/components/Stats';
import { AgentGrid } from '@site/src/components/AgentCard';
import AgentCard from '@site/src/components/AgentCard';

# Agent Catalog

> **${agents.length} sub-agents** with isolated context for autonomous tasks

<Stats items={[
  { number: ${haikuAgents.length}, label: 'Haiku agents' },
  { number: ${sonnetAgents.length}, label: 'Sonnet agents' },
  { number: ${agents.length}, label: 'Total' },
]} />

## What is an Agent?

**Agents** are autonomous sub-agents with an isolated context:

- **Automatic triggering**: Claude delegates based on context
- **Isolated context**: Does not pollute the main conversation
- **Restricted tools**: Limited access based on the task
- **Specific model**: Haiku (fast) or Sonnet (complex)

## Agents by model

### Haiku (${haikuAgents.length} agents)

Fast and economical agents for simple tasks.

| Agent | Description | Tools |
|-------|-------------|--------|
${generateTable(haikuAgents)}

### Sonnet (${sonnetAgents.length} agents)

Agents for complex tasks requiring in-depth analysis.

| Agent | Description | Tools |
|-------|-------------|--------|
${generateTable(sonnetAgents)}

${opusAgents.length > 0 ? `
### Opus (${opusAgents.length} agents)

Agents for critical tasks.

| Agent | Description | Tools |
|-------|-------------|--------|
${generateTable(opusAgents)}
` : ''}

## Card view

<AgentGrid>
${agents.slice(0, 12).map((a) => `  <AgentCard
    name="${a.name}"
    description="${a.description.replace(/"/g, '&quot;').slice(0, 80)}"
    model="${a.model}"
    tools={${JSON.stringify(a.tools.slice(0, 4))}}
    href="/docs/agents/${a.name}"
  />`).join('\n')}
</AgentGrid>

[See all agents...](#agents-by-model)

---

## See also

- [Architecture](/docs/intro/architecture) - Understand Commands vs Agents vs Skills
- [Commands](/docs/commands) - Manual commands
- [Skills](/docs/skills) - Auto-triggered skills
`;
}

/**
 * Main generation function
 */
async function generateAgentDocs(): Promise<void> {
  console.log('Generating agent documentation...');

  // Scan agent files
  const files = scanDirectory(AGENTS_DIR, {
    extensions: ['.md'],
    recursive: false,
  });

  console.log(`Found ${files.length} agent files`);

  // Parse agents
  const agents: AgentInfo[] = [];
  for (const file of files) {
    if (file.name === 'index' || file.name === 'README') {
      continue;
    }

    const agent = parseAgentFile(file.path);
    if (agent) {
      agents.push(agent);
    }
  }

  console.log(`Parsed ${agents.length} agents`);

  // Sort agents by name
  agents.sort((a, b) => a.name.localeCompare(b.name));

  // Generate documentation
  ensureDir(DOCS_DIR);

  // Generate index
  const index = generateAgentsIndex(agents);
  writeFileContent(path.join(DOCS_DIR, 'index.md'), index);
  console.log('Generated: docs/agents/index.md');

  // Generate individual agent pages
  let position = 2;
  for (const agent of agents) {
    const page = generateAgentPage(agent, position);
    writeFileContent(path.join(DOCS_DIR, `${agent.name}.md`), page);
    position++;
  }

  console.log(`\nGenerated ${agents.length} agent pages`);
}

// Run if called directly
generateAgentDocs().catch(console.error);

export { generateAgentDocs };
