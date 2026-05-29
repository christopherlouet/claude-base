#!/usr/bin/env ts-node
/**
 * Generate skill documentation pages from .claude/skills
 */

import * as path from 'path';
import * as fs from 'fs';
import {
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
import { rewriteUnsyncedRepoLinks } from './utils/rewrite-links.js';

const CLAUDE_DIR = path.resolve(__dirname, '../../.claude');
const SKILLS_DIR = path.join(CLAUDE_DIR, 'skills');
const DOCS_DIR = path.resolve(__dirname, '../docs/skills');

interface SkillFrontmatter {
  name?: string;
  description?: string;
  'allowed-tools'?: string[];
  context?: string;
}

interface SkillExample {
  name: string;
  title: string;
  content: string;
}

interface SkillInfo {
  name: string;
  description: string;
  allowedTools: string[];
  context: 'fork' | 'shared';
  keywords: string[];
  content: string;
  examples: SkillExample[];
}

/**
 * Extract keywords from skill content
 */
function extractKeywords(content: string, name: string): string[] {
  const keywords: string[] = [];

  // Add name-based keywords
  const nameParts = name.split('-');
  keywords.push(...nameParts.filter((p) => p.length > 2));

  // Look for trigger patterns in content
  const triggerMatch = content.match(/trigger[^\n]*:\s*([^\n]+)/i);
  if (triggerMatch) {
    const triggers = triggerMatch[1].split(/[,;]/);
    keywords.push(...triggers.map((t) => t.trim().toLowerCase()).filter((t) => t.length > 2));
  }

  // Look for quoted keywords — strip code blocks first to avoid extracting code
  const contentWithoutCode = content
    .replace(/```[\s\S]*?```/g, '')
    .replace(/`[^`]*`/g, '');
  const quotedMatches = contentWithoutCode.match(/"([^"]+)"/g);
  if (quotedMatches) {
    keywords.push(
      ...quotedMatches
        .map((m) => m.replace(/"/g, '').toLowerCase())
        .filter(
          (k) =>
            k.length > 2 &&
            k.length < 30 &&
            // Reject MDX-breaking characters in keywords
            !/[<>{}`/\\]/.test(k)
        )
        .slice(0, 5)
    );
  }

  // Deduplicate and return
  return [...new Set(keywords)].slice(0, 10);
}

/**
 * Read examples from the examples/ directory of a skill
 */
function readSkillExamples(dirPath: string): SkillExample[] {
  const examplesDir = path.join(dirPath, 'examples');
  const examples: SkillExample[] = [];

  if (!fs.existsSync(examplesDir)) {
    return examples;
  }

  try {
    const files = fs.readdirSync(examplesDir).filter((f) => f.endsWith('.md'));

    for (const file of files) {
      const filePath = path.join(examplesDir, file);
      const content = readFileContent(filePath);
      const name = path.basename(file, '.md');

      // Extract title from first heading
      const titleMatch = content.match(/^#\s+(.+)$/m);
      const title = titleMatch ? titleMatch[1] : name;

      examples.push({
        name,
        title,
        content,
      });
    }
  } catch (error) {
    console.error(`Error reading examples from ${examplesDir}:`, error);
  }

  return examples;
}

/**
 * Parse a skill file and extract metadata
 */
function parseSkillFile(dirPath: string): SkillInfo | null {
  try {
    const skillFile = path.join(dirPath, 'SKILL.md');
    if (!fs.existsSync(skillFile)) {
      return null;
    }

    const content = readFileContent(skillFile);
    const skillName = path.basename(dirPath);

    const { data, content: markdownContent } = parseFrontmatter<SkillFrontmatter>(content);

    const heading = extractFirstHeading(markdownContent);
    const description = extractDescription(markdownContent);

    return {
      name: data.name || skillName,
      description: data.description || description || heading || `Skill ${skillName}`,
      allowedTools: data['allowed-tools'] || [],
      context: (data.context as 'fork' | 'shared') || 'fork',
      keywords: extractKeywords(markdownContent, skillName),
      content: markdownContent,
      examples: readSkillExamples(dirPath),
    };
  } catch (error) {
    console.error(`Error parsing ${dirPath}:`, error);
    return null;
  }
}

/**
 * Rewrite relative references/ links to GitHub absolute URLs.
 * Reference files live under .claude/skills/<name>/references/ which
 * isn't synced to the Docusaurus site — link to the source on GitHub.
 */
function rewriteReferenceLinks(content: string, skillName: string): string {
  const baseUrl = `https://github.com/christopherlouet/claude-base/blob/main/.claude/skills/${skillName}/references`;
  return content.replace(
    /\]\(references\/([^)]+)\)/g,
    (_, file) => `](${baseUrl}/${file})`,
  );
}

/**
 * Generate the Docusaurus page content for a skill
 */
function generateSkillPage(skill: SkillInfo, position: number): string {
  const frontmatter = generateFrontmatter({
    sidebar_position: position,
    title: skill.name,
    description: skill.description,
    tags: ['skill', skill.context],
  });

  const contextBadge = `<span className="badge" style={{backgroundColor: '${skill.context === 'fork' ? 'var(--model-haiku)' : 'var(--model-sonnet)'}', color: 'white'}}>${skill.context === 'fork' ? 'Fork' : 'Shared'}</span>`;

  const toolsList = skill.allowedTools.length > 0
    ? skill.allowedTools.map((t) => `\`${t}\``).join(', ')
    : '_All tools_';

  const keywordsList = skill.keywords.length > 0
    ? skill.keywords.map((k) => `\`${k}\``).join(', ')
    : '_Auto-detection_';

  return `${frontmatter}

# Skill: ${skill.name}

${contextBadge}

> ${skill.description}

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | ${skill.context} |
| **Allowed tools** | ${toolsList} |
| **Keywords** | ${keywordsList} |

## Detailed description

${rewriteUnsyncedRepoLinks(rewriteReferenceLinks(skill.content, skill.name))}

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

${skill.keywords.slice(0, 3).map((k) => `- _"I want to ${k}..."_`).join('\n')}

## Context ${skill.context}

${skill.context === 'fork' ? `
**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks
` : `
**Shared** means the skill shares the conversation context:
- Access to the full history
- Changes visible immediately
- Ideal for interactive tasks
`}
${skill.examples.length > 0 ? `
---

## Practical examples

${skill.examples.map((ex, idx) => `
### ${idx + 1}. ${ex.title}

${ex.content}
`).join('\n---\n')}
` : ''}
---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
`;
}

/**
 * Generate skills index page
 */
function generateSkillsIndex(skills: SkillInfo[]): string {
  const frontmatter = generateFrontmatter({
    sidebar_position: 1,
    title: 'Skills',
    description: `Catalog of ${skills.length} auto-triggered skills`,
  });

  const forkSkills = skills.filter((s) => s.context === 'fork');
  const sharedSkills = skills.filter((s) => s.context === 'shared');

  const generateTable = (skillList: SkillInfo[]) =>
    skillList
      .map(
        (s) =>
          `| [\`${s.name}\`](/docs/skills/${s.name}) | ${s.description.slice(0, 50)}${s.description.length > 50 ? '...' : ''} | ${s.keywords.slice(0, 3).join(', ')} |`
      )
      .join('\n');

  return `${frontmatter}

import Stats from '@site/src/components/Stats';
import { SkillGrid } from '@site/src/components/SkillCard';
import SkillCard from '@site/src/components/SkillCard';

# Skills Catalog

> **${skills.length} skills** auto-triggered by keywords

<Stats items={[
  { number: ${forkSkills.length}, label: 'Fork Skills' },
  { number: ${sharedSkills.length}, label: 'Shared Skills' },
  { number: ${skills.length}, label: 'Total' },
]} />

## What is a Skill?

**Skills** are auto-triggered behaviors:

- **Automatic triggering**: Activated by keywords in the conversation
- **Configurable context**: Fork (isolated) or Shared (shared)
- **Restricted tools**: Limited access via \`allowed-tools\`
- **Transparency**: The user sees when a skill is activated

## Skills by context

### Fork (${forkSkills.length} skills)

Skills with isolated context.

| Skill | Description | Keywords |
|-------|-------------|-----------|
${generateTable(forkSkills)}

${sharedSkills.length > 0 ? `
### Shared (${sharedSkills.length} skills)

Skills with shared context.

| Skill | Description | Keywords |
|-------|-------------|-----------|
${generateTable(sharedSkills)}
` : ''}

## Card view

<SkillGrid>
${skills.slice(0, 12).map((s) => `  <SkillCard
    name="${s.name}"
    description="${s.description.replace(/"/g, '&quot;').slice(0, 80)}"
    keywords={${JSON.stringify(s.keywords.slice(0, 4))}}
    context="${s.context}"
    href="/docs/skills/${s.name}"
  />`).join('\n')}
</SkillGrid>

[See all skills...](#skills-by-context)

---

## See also

- [Architecture](/docs/intro/architecture) - Understand Commands vs Agents vs Skills
- [Commands](/docs/commands) - Manual commands
- [Agents](/docs/agents) - Autonomous sub-agents
`;
}

/**
 * Main generation function
 */
async function generateSkillDocs(): Promise<void> {
  console.log('Generating skill documentation...');

  // Scan skill directories
  const skillDirs = fs
    .readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter((d) => d.isDirectory())
    .map((d) => path.join(SKILLS_DIR, d.name));

  console.log(`Found ${skillDirs.length} skill directories`);

  // Parse skills
  const skills: SkillInfo[] = [];
  for (const dir of skillDirs) {
    const skill = parseSkillFile(dir);
    if (skill) {
      skills.push(skill);
    }
  }

  console.log(`Parsed ${skills.length} skills`);

  // Sort skills by name
  skills.sort((a, b) => a.name.localeCompare(b.name));

  // Generate documentation
  ensureDir(DOCS_DIR);

  // Generate index
  const index = generateSkillsIndex(skills);
  writeFileContent(path.join(DOCS_DIR, 'index.md'), index);
  console.log('Generated: docs/skills/index.md');

  // Generate individual skill pages
  let position = 2;
  for (const skill of skills) {
    const page = generateSkillPage(skill, position);
    writeFileContent(path.join(DOCS_DIR, `${skill.name}.md`), page);
    position++;
  }

  console.log(`\nGenerated ${skills.length} skill pages`);
}

// Run if called directly
generateSkillDocs().catch(console.error);

export { generateSkillDocs };
