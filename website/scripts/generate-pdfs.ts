#!/usr/bin/env tsx
import * as fs from 'node:fs';
import * as path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

interface PdfTarget {
  readonly slug: string;
  readonly htmlPath: string;
}

export const PDF_TARGETS: ReadonlyArray<PdfTarget> = [
  { slug: 'quick-start', htmlPath: 'docs/intro/quick-start.html' },
  { slug: 'installation', htmlPath: 'docs/intro/installation.html' },
  { slug: 'architecture', htmlPath: 'docs/intro/architecture.html' },
  { slug: 'claude-code-training', htmlPath: 'docs/guides/claude-code-training.html' },
  { slug: 'learning-path', htmlPath: 'docs/guides/learning-path.html' },
  { slug: 'prompting-guide', htmlPath: 'docs/guides/prompting-guide.html' },
  { slug: 'infra-guide', htmlPath: 'docs/guides/infra-guide.html' },
  { slug: 'observability-guide', htmlPath: 'docs/guides/observability-guide.html' },
  { slug: 'troubleshooting-guide', htmlPath: 'docs/guides/troubleshooting-guide.html' },
];

export function checkPrinceAvailable(): boolean {
  const result = spawnSync('prince', ['--version'], { stdio: 'ignore' });
  return result.status === 0;
}

export function checkBuildExists(buildDir: string): boolean {
  try {
    return fs.statSync(buildDir).isDirectory();
  } catch {
    return false;
  }
}

const SAFE_SLUG = /^[a-z0-9-]+$/;

export function resolveOutputPath(outDir: string, slug: string): string {
  if (!SAFE_SLUG.test(slug)) {
    throw new Error(`invalid slug: "${slug}" (must match ${SAFE_SLUG})`);
  }
  return path.join(outDir, `${slug}.pdf`);
}

export function generatePdf(
  htmlFile: string,
  outputPdf: string,
  cssFile: string,
): void {
  execFileSync(
    'prince',
    ['--style', cssFile, '--no-warn-css', '--output', outputPdf, htmlFile],
    { stdio: 'inherit' },
  );
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

async function main(): Promise<void> {
  const scriptDir = path.dirname(fileURLToPath(import.meta.url));
  const websiteDir = path.resolve(scriptDir, '..');
  const buildDir = path.join(websiteDir, 'build');
  const outDir = path.join(websiteDir, 'pdf');
  const cssFile = path.join(scriptDir, 'print.css');

  if (!checkPrinceAvailable()) {
    console.error('[error] PrinceXML not found in PATH.');
    console.error('        Install Prince from https://www.princexml.com/download/');
    console.error('        Ubuntu 24.04: sudo dpkg -i prince_*_ubuntu24.04_amd64.deb');
    process.exit(1);
  }

  if (!checkBuildExists(buildDir)) {
    console.error(`[error] ${buildDir} not found.`);
    console.error('        Run "npm run build" before generating the PDFs.');
    process.exit(1);
  }

  if (!fs.existsSync(cssFile)) {
    console.error(`[error] print CSS not found: ${cssFile}`);
    process.exit(1);
  }

  fs.mkdirSync(outDir, { recursive: true });

  let totalBytes = 0;
  let generated = 0;
  const failures: string[] = [];

  for (let i = 0; i < PDF_TARGETS.length; i++) {
    const target = PDF_TARGETS[i];
    const htmlFile = path.join(buildDir, target.htmlPath);
    const outputPdf = resolveOutputPath(outDir, target.slug);

    const progress = `[${i + 1}/${PDF_TARGETS.length}]`;

    if (!fs.existsSync(htmlFile)) {
      console.warn(`${progress} skip ${target.slug} (${target.htmlPath} missing from build)`);
      failures.push(target.slug);
      continue;
    }

    console.log(`${progress} ${target.slug}.pdf`);

    try {
      generatePdf(htmlFile, outputPdf, cssFile);
      const size = fs.statSync(outputPdf).size;
      totalBytes += size;
      generated++;
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      console.error(`        failure: ${msg}`);
      failures.push(target.slug);
    }
  }

  console.log('');
  console.log(`Generated : ${generated}/${PDF_TARGETS.length} PDFs (${formatBytes(totalBytes)})`);
  console.log(`Output    : ${path.relative(process.cwd(), outDir)}/`);

  if (failures.length > 0) {
    console.error(`Failures  : ${failures.join(', ')}`);
    process.exit(1);
  }
}

const isDirectRun = process.argv[1] === fileURLToPath(import.meta.url);
if (isDirectRun) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
