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
  const triggerMatch = content.match(/declenche[^\n]*:\s*([^\n]+)/i);
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
    : '_Tous les outils_';

  const keywordsList = skill.keywords.length > 0
    ? skill.keywords.map((k) => `\`${k}\``).join(', ')
    : '_Auto-detection_';

  return `${frontmatter}

# Skill: ${skill.name}

${contextBadge}

> ${skill.description}

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | ${skill.context} |
| **Outils autorises** | ${toolsList} |
| **Mots-cles** | ${keywordsList} |

## Description detaillee

${skill.content}

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

${skill.keywords.slice(0, 3).map((k) => `- _"Je veux ${k}..."_`).join('\n')}

## Contexte ${skill.context}

${skill.context === 'fork' ? `
**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes
` : `
**Shared** signifie que le skill partage le contexte de conversation :
- Acces a l'historique complet
- Modifications visibles immediatement
- Ideal pour les taches interactives
`}
${skill.examples.length > 0 ? `
---

## Exemples pratiques

${skill.examples.map((ex, idx) => `
### ${idx + 1}. ${ex.title}

${ex.content}
`).join('\n---\n')}
` : ''}
---

## Voir aussi

- [Retour aux skills](/docs/skills)
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
    description: 'Catalogue des 42 skills auto-declenches',
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

# Catalogue des Skills

> **${skills.length} skills** auto-declenches par mots-cles

<Stats items={[
  { number: ${forkSkills.length}, label: 'Skills Fork' },
  { number: ${sharedSkills.length}, label: 'Skills Shared' },
  { number: ${skills.length}, label: 'Total' },
]} />

## Qu'est-ce qu'un Skill ?

Les **skills** sont des comportements auto-declenches :

- **Declenchement automatique** : Active par mots-cles dans la conversation
- **Contexte configurable** : Fork (isole) ou Shared (partage)
- **Outils restreints** : Acces limite via \`allowed-tools\`
- **Transparence** : L'utilisateur voit quand un skill est active

## Skills par contexte

### Fork (${forkSkills.length} skills)

Skills avec contexte isole.

| Skill | Description | Mots-cles |
|-------|-------------|-----------|
${generateTable(forkSkills)}

${sharedSkills.length > 0 ? `
### Shared (${sharedSkills.length} skills)

Skills avec contexte partage.

| Skill | Description | Mots-cles |
|-------|-------------|-----------|
${generateTable(sharedSkills)}
` : ''}

## Vue en cartes

<SkillGrid>
${skills.slice(0, 12).map((s) => `  <SkillCard
    name="${s.name}"
    description="${s.description.replace(/"/g, '\\"').slice(0, 80)}"
    keywords={${JSON.stringify(s.keywords.slice(0, 4))}}
    context="${s.context}"
    href="/docs/skills/${s.name}"
  />`).join('\n')}
</SkillGrid>

[Voir tous les skills...](#skills-par-contexte)

---

## Voir aussi

- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills
- [Commands](/docs/commands) - Les commandes manuelles
- [Agents](/docs/agents) - Les sub-agents autonomes
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
