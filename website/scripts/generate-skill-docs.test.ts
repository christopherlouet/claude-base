/**
 * Tests for generate-skill-docs.ts — specifically the `disable-model-invocation`
 * branch.
 *
 * Why this file exists. A skill carrying `disable-model-invocation: true` cannot
 * be loaded by the model at all (measured: the Skill tool refuses it outright).
 * The generator used to emit a hard-coded "## Automatic triggering" section on
 * every page, so twelve pages advertised keywords for a skill the harness
 * refuses. Nothing could catch that: `website/docs/skills/` is not versioned, so
 * the counts gate's `git diff` never sees these pages.
 *
 * Both a fixture pair (the two branches, isolated) and a self-application case
 * (the real `.claude/skills` tree), because a fixture proves the runner logic
 * and only the real tree proves the behaviour.
 */

import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { parseSkillFile, generateSkillPage } from './generate-skill-docs.js';

const CLAUDE_SKILLS = path.resolve(__dirname, '../../.claude/skills');

function writeSkill(root: string, name: string, manualOnly: boolean): string {
  const dir = path.join(root, name);
  fs.mkdirSync(dir, { recursive: true });
  const flag = manualOnly ? 'disable-model-invocation: true\n' : '';
  fs.writeFileSync(
    path.join(dir, 'SKILL.md'),
    `---\nname: ${name}\ndescription: Probe skill for tests.\ncontext: fork\nbackground: false\n${flag}---\n\n# Probe\n\nBody.\n`
  );
  return dir;
}

describe('generate-skill-docs: the manual-only branch', () => {
  it('a model-disabled skill gets "Manual invocation only", never "Automatic triggering"', () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'skilldocs-'));
    try {
      const skill = parseSkillFile(writeSkill(tmp, 'probe-manual', true));
      assert.ok(skill, 'the fixture skill must parse');
      assert.equal(skill!.manualOnly, true);

      const page = generateSkillPage(skill!, 1);
      assert.match(page, /## Manual invocation only/);
      assert.doesNotMatch(page, /## Automatic triggering/);
      assert.match(page, /\*\*manual only\*\* — run `\/probe-manual`/);
      assert.doesNotMatch(page, /### Triggering examples/);
    } finally {
      fs.rmSync(tmp, { recursive: true, force: true });
    }
  });

  it('an ordinary skill keeps the automatic-triggering section', () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'skilldocs-'));
    try {
      const skill = parseSkillFile(writeSkill(tmp, 'probe-auto', false));
      assert.ok(skill, 'the fixture skill must parse');
      assert.equal(skill!.manualOnly, false);

      const page = generateSkillPage(skill!, 1);
      assert.match(page, /## Automatic triggering/);
      assert.doesNotMatch(page, /## Manual invocation only/);
    } finally {
      fs.rmSync(tmp, { recursive: true, force: true });
    }
  });

  it('self-application: every real model-disabled skill renders as manual only', () => {
    const names = fs
      .readdirSync(CLAUDE_SKILLS, { withFileTypes: true })
      .filter((e) => e.isDirectory())
      .map((e) => e.name);

    const manual: string[] = [];
    for (const name of names) {
      const skill = parseSkillFile(path.join(CLAUDE_SKILLS, name));
      if (!skill) continue;
      const page = generateSkillPage(skill, 1);
      if (skill.manualOnly) {
        manual.push(name);
        assert.match(page, /## Manual invocation only/, `${name} must not promise auto-trigger`);
        assert.doesNotMatch(page, /## Automatic triggering/, `${name} still promises auto-trigger`);
      } else {
        assert.match(page, /## Automatic triggering/, `${name} lost its trigger section`);
      }
    }

    // Not vacuous: the day nothing carries the flag, the loop above would pass
    // by checking nothing.
    assert.ok(manual.length > 0, 'no skill carries disable-model-invocation — guard is vacuous');
  });
});
