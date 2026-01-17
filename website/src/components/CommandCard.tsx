import React from 'react';
import Link from '@docusaurus/Link';
import clsx from 'clsx';

export type Domain = 'work' | 'dev' | 'qa' | 'ops' | 'doc' | 'biz' | 'growth' | 'data' | 'legal' | 'assistant';

export interface CommandCardProps {
  name: string;
  description: string;
  domain: Domain;
  tags?: string[];
  href?: string;
}

const domainLabels: Record<Domain, string> = {
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

export default function CommandCard({
  name,
  description,
  domain,
  tags = [],
  href,
}: CommandCardProps): JSX.Element {
  const content = (
    <div className="command-card">
      <div className="command-card__header">
        <span className={clsx('badge', `badge--${domain}`)}>
          {domainLabels[domain]}
        </span>
        <span className="command-card__name">/{name}</span>
      </div>
      <p className="command-card__description">{description}</p>
      {tags.length > 0 && (
        <div className="command-card__tags">
          {tags.map((tag) => (
            <span key={tag} className="command-card__tag">
              {tag}
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
export function CommandGrid({ children }: { children: React.ReactNode }): JSX.Element {
  return <div className="command-grid">{children}</div>;
}
