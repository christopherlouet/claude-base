/**
 * File scanner utility for recursive directory traversal
 */

import * as fs from 'fs';
import * as path from 'path';

export interface ScanOptions {
  extensions?: string[];
  exclude?: string[];
  recursive?: boolean;
}

export interface ScannedFile {
  path: string;
  name: string;
  dir: string;
  ext: string;
}

/**
 * Recursively scan a directory for files matching criteria
 */
export function scanDirectory(
  dirPath: string,
  options: ScanOptions = {}
): ScannedFile[] {
  const {
    extensions = ['.md'],
    exclude = ['node_modules', '.git', 'build', 'dist'],
    recursive = true,
  } = options;

  const results: ScannedFile[] = [];

  if (!fs.existsSync(dirPath)) {
    console.warn(`Directory not found: ${dirPath}`);
    return results;
  }

  const entries = fs.readdirSync(dirPath, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dirPath, entry.name);

    // Skip excluded directories
    if (exclude.includes(entry.name)) {
      continue;
    }

    if (entry.isDirectory() && recursive) {
      // Recurse into subdirectory
      results.push(...scanDirectory(fullPath, options));
    } else if (entry.isFile()) {
      // Check extension
      const ext = path.extname(entry.name);
      if (extensions.includes(ext)) {
        results.push({
          path: fullPath,
          name: path.basename(entry.name, ext),
          dir: path.dirname(fullPath),
          ext,
        });
      }
    }
  }

  return results;
}

/**
 * Read file content
 */
export function readFileContent(filePath: string): string {
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }
  return fs.readFileSync(filePath, 'utf-8');
}

/**
 * Write file content, creating directories if needed
 */
export function writeFileContent(filePath: string, content: string): void {
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(filePath, content, 'utf-8');
}

/**
 * Ensure directory exists
 */
export function ensureDir(dirPath: string): void {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

/**
 * Get relative path from base
 */
export function getRelativePath(filePath: string, basePath: string): string {
  return path.relative(basePath, filePath);
}

/**
 * Extract domain from file path (e.g., .claude/commands/work/... -> work)
 */
export function extractDomain(filePath: string): string {
  const parts = filePath.split(path.sep);
  const commandsIndex = parts.indexOf('commands');
  if (commandsIndex >= 0 && parts.length > commandsIndex + 1) {
    return parts[commandsIndex + 1];
  }
  return 'other';
}
