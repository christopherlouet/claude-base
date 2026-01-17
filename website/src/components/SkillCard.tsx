import React from 'react';
import Link from '@docusaurus/Link';
import clsx from 'clsx';

export type Context = 'fork' | 'shared';

export interface SkillCardProps {
  name: string;
  description: string;
  keywords: string[];
  context: Context;
  href?: string;
}

export default function SkillCard({
  name,
  description,
  keywords,
  context,
  href,
}: SkillCardProps): JSX.Element {
  const content = (
    <div className="skill-card">
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
        <span
          className="badge"
          style={{
            backgroundColor: context === 'fork' ? 'var(--model-haiku)' : 'var(--model-sonnet)',
            color: 'white'
          }}
        >
          {context === 'fork' ? 'Fork' : 'Shared'}
        </span>
        <span style={{ fontFamily: 'var(--ifm-font-family-monospace)', fontWeight: 600 }}>
          {name}
        </span>
      </div>
      <p style={{ fontSize: '0.875rem', color: 'var(--ifm-color-content-secondary)', margin: '0.5rem 0' }}>
        {description}
      </p>
      {keywords.length > 0 && (
        <div className="skill-card__keywords">
          {keywords.map((keyword) => (
            <span key={keyword} className="skill-card__keyword">
              {keyword}
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
export function SkillGrid({ children }: { children: React.ReactNode }): JSX.Element {
  return <div className="command-grid">{children}</div>;
}
