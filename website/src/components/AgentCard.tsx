import React from 'react';
import Link from '@docusaurus/Link';
import clsx from 'clsx';

export type Model = 'haiku' | 'sonnet' | 'opus';

export interface AgentCardProps {
  name: string;
  description: string;
  model: Model;
  tools: string[];
  href?: string;
}

const modelLabels: Record<Model, string> = {
  haiku: 'Haiku',
  sonnet: 'Sonnet',
  opus: 'Opus',
};

const modelDescriptions: Record<Model, string> = {
  haiku: 'Rapide et economique',
  sonnet: 'Equilibre performance/cout',
  opus: 'Maximum de capacites',
};

export default function AgentCard({
  name,
  description,
  model,
  tools,
  href,
}: AgentCardProps): JSX.Element {
  const content = (
    <div className="agent-card">
      <div className="agent-card__header">
        <div className="agent-card__model">
          <span className={clsx('badge', `badge--${model}`)}>
            {modelLabels[model]}
          </span>
          <span className="agent-card__name" style={{ fontFamily: 'var(--ifm-font-family-monospace)', fontWeight: 600 }}>
            {name}
          </span>
        </div>
      </div>
      <p style={{ fontSize: '0.875rem', color: 'var(--ifm-color-content-secondary)', margin: '0.5rem 0' }}>
        {description}
      </p>
      {tools.length > 0 && (
        <div className="agent-card__tools">
          {tools.map((tool) => (
            <span key={tool} className="agent-card__tool">
              {tool}
            </span>
          ))}
        </div>
      )}
    </div>
  );

  if (href) {
    return (
      <Link to={href} style={{ textDecoration: 'none', color: 'inherit' }}>
        {content}
      </Link>
    );
  }

  return content;
}

// Grid wrapper component
export function AgentGrid({ children }: { children: React.ReactNode }): JSX.Element {
  return <div className="command-grid">{children}</div>;
}
