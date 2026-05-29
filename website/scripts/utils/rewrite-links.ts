/**
 * Rewrite relative Markdown links that point at repo trees NOT synced into
 * the Docusaurus site (docs/recipes/, specs/) to absolute GitHub URLs.
 *
 * Generated command/skill pages live deep under website/docs/, so a source
 * link like `[...](../../../docs/recipes/recommended-vendor-skills.md)` does
 * not resolve to any Docusaurus page and makes the production build fail with
 * "broken markdown link". sync-docs.ts already routes these trees to GitHub
 * for the synced reference/guides docs; this helper does the same for the
 * command/skill generators.
 */

const REPO_BLOB = 'https://github.com/christopherlouet/claude-base/blob/main';

// Repo-root subtrees that exist in git but have no Docusaurus equivalent.
const UNSYNCED_TREES = ['docs/recipes', 'specs'];

/**
 * Replace `](<one-or-more ../>(docs/recipes|specs)/<rest>)` with an absolute
 * GitHub blob URL. Leaves every other link untouched.
 */
export function rewriteUnsyncedRepoLinks(content: string): string {
  const trees = UNSYNCED_TREES.join('|');
  const pattern = new RegExp(`\\]\\((?:\\.\\./)+((?:${trees})/[^)]+)\\)`, 'g');
  return content.replace(pattern, (_match, repoPath) => `](${REPO_BLOB}/${repoPath})`);
}
