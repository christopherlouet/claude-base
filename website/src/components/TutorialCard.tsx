import React from 'react';
import Link from '@docusaurus/Link';
import DifficultyBadge, { Difficulty } from './DifficultyBadge';

export interface TutorialCardProps {
  title: string;
  description: string;
  duration: string;
  difficulty: Difficulty;
  href: string;
  prerequisites?: string[];
}

export default function TutorialCard({
  title,
  description,
  duration,
  difficulty,
  href,
  prerequisites = [],
}: TutorialCardProps): JSX.Element {
  return (
    <Link to={href} className="tutorial-card">
      <div className="tutorial-card__header">
        <DifficultyBadge level={difficulty} />
        <span className="tutorial-card__duration">{duration}</span>
      </div>
      <h3 className="tutorial-card__title">{title}</h3>
      <p className="tutorial-card__description">{description}</p>
      {prerequisites.length > 0 && (
        <div className="tutorial-card__prerequisites">
          <span className="tutorial-card__prerequisites-label">Prérequis:</span>
          {prerequisites.map((prereq) => (
            <span key={prereq} className="tutorial-card__prerequisite">
              {prereq}
            </span>
          ))}
        </div>
      )}
    </Link>
  );
}

export function TutorialGrid({ children }: { children: React.ReactNode }): JSX.Element {
  return <div className="tutorial-grid">{children}</div>;
}
