#!/usr/bin/env ts-node
/**
 * Sync documentation from docs/ to website/docs/
 * Copies guides, references, and root docs with Docusaurus frontmatter
 */

import * as fs from 'fs';
import * as path from 'path';
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
  escapeMdx,
} from './utils/parse-frontmatter.js';

const DOCS_DIR = path.resolve(__dirname, '../../docs');
const WEBSITE_DOCS_DIR = path.resolve(__dirname, '../docs');

const AUTO_GENERATED_COMMENT = '<!-- Auto-generated from docs/ - DO NOT EDIT -->';

// =============================================================================
// Link rewriting
// =============================================================================

/** Map of relative links in docs/ to Docusaurus paths */
const LINK_MAP: Record<string, string> = {
  // Root docs -> concepts
  'ARCHITECTURE.md': '/docs/concepts/architecture',
  '../ARCHITECTURE.md': '/docs/concepts/architecture',
  'WORKFLOWS.md': '/docs/concepts/workflows',
  '../WORKFLOWS.md': '/docs/concepts/workflows',
  'CUSTOMIZATION.md': '/docs/concepts/customization',
  '../CUSTOMIZATION.md': '/docs/concepts/customization',
  'CHEATSHEET.md': '/docs/reference/cheatsheet',
  '../CHEATSHEET.md': '/docs/reference/cheatsheet',
  // Guides cross-references (4 guides remaining after stack guides consolidation)
  'EXTENDING-GUIDE.md': '/docs/guides/extending-guide',
  'TEAM-GUIDE.md': '/docs/guides/team-guide',
  'PROMPTING-GUIDE.md': '/docs/guides/prompting-guide',
  'TROUBLESHOOTING-GUIDE.md': '/docs/guides/troubleshooting-guide',
  // Stack recipes (replaces 13 stack-specific guides)
  'STACK-RECIPES.md': '/docs/stack-recipes',
  '../STACK-RECIPES.md': '/docs/stack-recipes',
  // Reference cross-references
  'best-practices.md': '/docs/reference/best-practices',
  'advanced-features.md': '/docs/reference/advanced-features',
  'agents-catalog.md': '/docs/reference/agents-catalog',
  'commands.md': '/docs/reference/commands',
  'hooks-reference.md': '/docs/reference/hooks-reference',
  'project-structures.md': '/docs/reference/project-structures',
  'skills-catalog.md': '/docs/reference/skills-catalog',
  // Relative paths from guides/
  '../reference/best-practices.md': '/docs/reference/best-practices',
  '../reference/advanced-features.md': '/docs/reference/advanced-features',
  '../reference/hooks-reference.md': '/docs/reference/hooks-reference',
  '../reference/commands.md': '/docs/reference/commands',
  '../reference/agents-catalog.md': '/docs/reference/agents-catalog',
  '../reference/skills-catalog.md': '/docs/reference/skills-catalog',
  '../reference/project-structures.md': '/docs/reference/project-structures',
  // Relative paths from reference/
  '../guides/EXTENDING-GUIDE.md': '/docs/guides/extending-guide',
  '../guides/TEAM-GUIDE.md': '/docs/guides/team-guide',
  '../guides/PROMPTING-GUIDE.md': '/docs/guides/prompting-guide',
  '../guides/TROUBLESHOOTING-GUIDE.md': '/docs/guides/troubleshooting-guide',
  '../STACK-RECIPES.md': '/docs/stack-recipes',
};

/**
 * Rewrite relative markdown links to Docusaurus paths
 */
function rewriteLinks(content: string): string {
  // Match [text](link) patterns
  return content.replace(/\[([^\]]*)\]\(([^)]+)\)/g, (_match, text, link) => {
    // Skip external links and anchors
    if (link.startsWith('http') || link.startsWith('#') || link.startsWith('/docs/')) {
      return `[${text}](${link})`;
    }

    // Check direct match in LINK_MAP
    const mapped = LINK_MAP[link];
    if (mapped) {
      return `[${text}](${mapped})`;
    }

    // Try without anchor
    const [linkPath, anchor] = link.split('#');
    const mappedPath = LINK_MAP[linkPath];
    if (mappedPath) {
      return anchor ? `[${text}](${mappedPath}#${anchor})` : `[${text}](${mappedPath})`;
    }

    // Keep as-is if no mapping found
    return `[${text}](${link})`;
  });
}

// =============================================================================
// Slug helpers
// =============================================================================

/**
 * Convert filename to kebab-case slug
 * WEB-GUIDE.md -> web-guide
 * ARCHITECTURE.md -> architecture
 */
function slugify(filename: string): string {
  return filename
    .replace(/\.md$/, '')
    .toLowerCase()
    .replace(/[^a-z0-9-]/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

// =============================================================================
// Escape helpers
// =============================================================================

/**
 * Escape content outside of code blocks for MDX safety
 */
function escapeNonCodeContent(content: string): string {
  const parts: string[] = [];
  let lastIndex = 0;

  const codeBlockRegex = /```[\s\S]*?```/g;
  let match;

  while ((match = codeBlockRegex.exec(content)) !== null) {
    if (match.index > lastIndex) {
      parts.push(escapeMdx(content.slice(lastIndex, match.index)));
    }
    parts.push(match[0]);
    lastIndex = match.index + match[0].length;
  }

  if (lastIndex < content.length) {
    parts.push(escapeMdx(content.slice(lastIndex)));
  }

  return parts.join('');
}

// =============================================================================
// Sync logic
// =============================================================================

interface SyncConfig {
  sourceDir: string;
  destDir: string;
  category: string;
  tags: string[];
  startPosition: number;
  /** Files to preserve in dest (website-only content) */
  preserve: string[];
}

/**
 * Sync a directory of markdown files
 */
function syncDirectory(config: SyncConfig): number {
  const { sourceDir, destDir, category, tags, startPosition, preserve } = config;

  if (!fs.existsSync(sourceDir)) {
    console.warn(`  Source directory not found: ${sourceDir}`);
    return 0;
  }

  ensureDir(destDir);

  const sourceFiles = fs.readdirSync(sourceDir)
    .filter(f => f.endsWith('.md'))
    .sort();

  let synced = 0;
  let position = startPosition;

  for (const file of sourceFiles) {
    const sourcePath = path.join(sourceDir, file);
    const slug = slugify(file);
    const destPath = path.join(destDir, `${slug}.md`);

    const rawContent = readFileContent(sourcePath);
    const { content: bodyContent } = parseFrontmatter(rawContent);

    const title = extractFirstHeading(bodyContent) || slug;
    const description = extractDescription(bodyContent)
      .replace(/[{}<>]/g, '')
      .slice(0, 150);

    const frontmatter = generateFrontmatter({
      sidebar_position: position,
      title: title.replace(/[{}<>]/g, ''),
      description,
      tags,
    });

    const rewrittenContent = rewriteLinks(bodyContent);
    const safeContent = escapeNonCodeContent(rewrittenContent);

    const output = `${frontmatter}\n\n${AUTO_GENERATED_COMMENT}\n\n${safeContent}\n`;
    writeFileContent(destPath, output);

    console.log(`  ${category}/${slug}.md`);
    synced++;
    position++;
  }

  // Clean stale files (files in dest that have no source, except preserved)
  const destFiles = fs.readdirSync(destDir).filter(f => f.endsWith('.md'));
  const generatedSlugs = sourceFiles.map(f => `${slugify(f)}.md`);
  const preserveSet = new Set(preserve);

  for (const destFile of destFiles) {
    if (!generatedSlugs.includes(destFile) && !preserveSet.has(destFile)) {
      const destPath = path.join(destDir, destFile);
      // Only remove if it was auto-generated by us
      try {
        const content = readFileContent(destPath);
        if (content.includes(AUTO_GENERATED_COMMENT)) {
          fs.unlinkSync(destPath);
          console.log(`  [removed] ${category}/${destFile}`);
        }
      } catch {
        // Skip files we can't read
      }
    }
  }

  return synced;
}

/**
 * Sync a single file to a destination
 */
function syncFile(
  sourcePath: string,
  destPath: string,
  position: number,
  tags: string[]
): boolean {
  if (!fs.existsSync(sourcePath)) {
    return false;
  }

  const rawContent = readFileContent(sourcePath);
  const { content: bodyContent } = parseFrontmatter(rawContent);

  const title = extractFirstHeading(bodyContent) || path.basename(sourcePath, '.md');
  const description = extractDescription(bodyContent)
    .replace(/[{}<>]/g, '')
    .slice(0, 150);

  const frontmatter = generateFrontmatter({
    sidebar_position: position,
    title: title.replace(/[{}<>]/g, ''),
    description,
    tags,
  });

  const rewrittenContent = rewriteLinks(bodyContent);
  const safeContent = escapeNonCodeContent(rewrittenContent);

  const output = `${frontmatter}\n\n${AUTO_GENERATED_COMMENT}\n\n${safeContent}\n`;
  writeFileContent(destPath, output);

  return true;
}

// =============================================================================
// Main
// =============================================================================

async function syncDocs(): Promise<void> {
  console.log('Syncing documentation from docs/ to website/docs/...');

  let totalSynced = 0;

  // Sync guides
  console.log('\n  Guides:');
  totalSynced += syncDirectory({
    sourceDir: path.join(DOCS_DIR, 'guides'),
    destDir: path.join(WEBSITE_DOCS_DIR, 'guides'),
    category: 'guides',
    tags: ['guide'],
    startPosition: 10,
    preserve: ['index.md', 'faq.md', 'troubleshooting.md', 'migration.md', 'startup.md'],
  });

  // Sync references
  console.log('\n  Reference:');
  totalSynced += syncDirectory({
    sourceDir: path.join(DOCS_DIR, 'reference'),
    destDir: path.join(WEBSITE_DOCS_DIR, 'reference'),
    category: 'reference',
    tags: ['reference'],
    startPosition: 10,
    preserve: ['index.md', 'commands-matrix.md', 'agents-matrix.md', 'scripts.md'],
  });

  // Sync root docs -> concepts
  console.log('\n  Concepts (root docs):');
  const conceptsDir = path.join(WEBSITE_DOCS_DIR, 'concepts');
  ensureDir(conceptsDir);

  const rootDocs: Array<{ source: string; dest: string; position: number }> = [
    { source: 'ARCHITECTURE.md', dest: 'architecture.md', position: 20 },
    { source: 'WORKFLOWS.md', dest: 'workflows.md', position: 21 },
    { source: 'CUSTOMIZATION.md', dest: 'customization.md', position: 22 },
    { source: 'STACK-RECIPES.md', dest: 'stack-recipes.md', position: 23 },
  ];

  for (const doc of rootDocs) {
    const sourcePath = path.join(DOCS_DIR, doc.source);
    const destPath = path.join(conceptsDir, doc.dest);
    if (syncFile(sourcePath, destPath, doc.position, ['concept'])) {
      console.log(`  concepts/${doc.dest}`);
      totalSynced++;
    }
  }

  console.log(`\nSynced ${totalSynced} documentation files`);
}

// Run if called directly
syncDocs().catch(console.error);

export { syncDocs };
