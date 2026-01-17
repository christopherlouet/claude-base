/**
 * Types for documentation generation
 */

export interface CommandMetadata {
  name: string;
  domain: string;
  description: string;
  usage?: string;
  tags?: string[];
  relatedCommands?: string[];
  content: string;
}

export interface AgentMetadata {
  name: string;
  model: 'haiku' | 'sonnet' | 'opus';
  description: string;
  tools: string[];
  permissionMode?: 'plan' | 'default';
  skills?: string[];
  content: string;
}

export interface SkillMetadata {
  name: string;
  description: string;
  keywords: string[];
  context: 'fork' | 'shared';
  allowedTools?: string[];
  content: string;
}

export interface RuleMetadata {
  name: string;
  paths: string[];
  description: string;
  content: string;
}

export interface GenerationResult {
  success: boolean;
  filesGenerated: number;
  errors: string[];
}

export type Domain = 'work' | 'dev' | 'qa' | 'ops' | 'doc' | 'biz' | 'growth' | 'data' | 'legal' | 'assistant';

export const DOMAIN_LABELS: Record<Domain, string> = {
  work: 'WORK',
  dev: 'DEV',
  qa: 'QA',
  ops: 'OPS',
  doc: 'DOC',
  biz: 'BIZ',
  growth: 'GROWTH',
  data: 'DATA',
  legal: 'LEGAL',
  assistant: 'ASSISTANT',
};

export const DOMAIN_DESCRIPTIONS: Record<Domain, string> = {
  work: 'Workflow principal (explore, plan, commit, PR)',
  dev: 'Developpement (TDD, API, composants, debug)',
  qa: 'Qualite (review, securite, performance, accessibilite)',
  ops: 'Operations (CI/CD, Docker, monitoring, GitFlow)',
  doc: 'Documentation (changelog, README, architecture)',
  biz: 'Business (model, MVP, pricing, pitch)',
  growth: 'Croissance (SEO, analytics, landing, funnel)',
  data: 'Donnees (pipeline, analytics, modeling)',
  legal: 'Legal (RGPD, CGU, paiement)',
  assistant: 'Orchestrateur (point d\'entree unique)',
};
