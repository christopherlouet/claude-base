#!/usr/bin/env ts-node
/**
 * Main script to generate all documentation
 */

import { generateCommandDocs } from './generate-command-docs.js';
import { generateAgentDocs } from './generate-agent-docs.js';
import { generateSkillDocs } from './generate-skill-docs.js';
import { generateRuleDocs } from './generate-rule-docs.js';
import { syncDocs } from './sync-docs.js';

interface GenerationStats {
  commands: number;
  agents: number;
  skills: number;
  rules: number;
  totalTime: number;
}

async function generateAll(): Promise<GenerationStats> {
  const startTime = Date.now();

  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║          claude-socle Documentation Generator              ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('');

  const stats: GenerationStats = {
    commands: 0,
    agents: 0,
    skills: 0,
    rules: 0,
    totalTime: 0,
  };

  try {
    // Generate command docs
    console.log('\n📚 Generating command documentation...');
    console.log('─'.repeat(50));
    await generateCommandDocs();

    // Generate agent docs
    console.log('\n🤖 Generating agent documentation...');
    console.log('─'.repeat(50));
    await generateAgentDocs();

    // Generate skill docs
    console.log('\n🎯 Generating skill documentation...');
    console.log('─'.repeat(50));
    await generateSkillDocs();

    // Generate rule docs
    console.log('\n📏 Generating rule documentation...');
    console.log('─'.repeat(50));
    await generateRuleDocs();

    // Sync docs/ to website/docs/
    console.log('\n📄 Syncing docs/ to website/docs/...');
    console.log('─'.repeat(50));
    await syncDocs();

    const endTime = Date.now();
    stats.totalTime = (endTime - startTime) / 1000;

    console.log('\n');
    console.log('╔════════════════════════════════════════════════════════════╗');
    console.log('║                    Generation Complete!                    ║');
    console.log('╠════════════════════════════════════════════════════════════╣');
    console.log(`║  Total time: ${stats.totalTime.toFixed(2)}s`.padEnd(61) + '║');
    console.log('╚════════════════════════════════════════════════════════════╝');
    console.log('');
    console.log('Next steps:');
    console.log('  npm run start   - Start development server');
    console.log('  npm run build   - Build for production');
    console.log('');

  } catch (error) {
    console.error('\n❌ Generation failed:', error);
    process.exit(1);
  }

  return stats;
}

// Run
generateAll().catch(console.error);
