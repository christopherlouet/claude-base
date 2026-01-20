import React from 'react';
import clsx from 'clsx';

export type Difficulty = 'beginner' | 'intermediate' | 'advanced';

export interface DifficultyBadgeProps {
  level: Difficulty;
  showLabel?: boolean;
}

const difficultyLabels: Record<Difficulty, string> = {
  beginner: 'Débutant',
  intermediate: 'Intermédiaire',
  advanced: 'Avancé',
};

const difficultyIcons: Record<Difficulty, string> = {
  beginner: '🟢',
  intermediate: '🟠',
  advanced: '🔴',
};

export default function DifficultyBadge({
  level,
  showLabel = true,
}: DifficultyBadgeProps): JSX.Element {
  return (
    <span className={clsx('difficulty-badge', `difficulty-badge--${level}`)}>
      <span className="difficulty-badge__icon">{difficultyIcons[level]}</span>
      {showLabel && (
        <span className="difficulty-badge__label">{difficultyLabels[level]}</span>
      )}
    </span>
  );
}
