import React from 'react';

interface StatItem {
  number: string | number;
  label: string;
}

export interface StatsProps {
  items: StatItem[];
}

export default function Stats({ items }: StatsProps): JSX.Element {
  return (
    <div className="stats-grid">
      {items.map((item) => (
        <div key={item.label} className="stat-card">
          <div className="stat-card__number">{item.number}</div>
          <div className="stat-card__label">{item.label}</div>
        </div>
      ))}
    </div>
  );
}

// Pre-defined stats for claude-socle
export const SOCLE_STATS: StatItem[] = [
  { number: 100, label: 'Commands' },
  { number: 37, label: 'Agents' },
  { number: 24, label: 'Skills' },
  { number: 15, label: 'Rules' },
];
