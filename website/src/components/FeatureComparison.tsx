import React from 'react';

export interface ComparisonRow {
  aspect: string;
  [key: string]: string | number;
}

export interface FeatureComparisonProps {
  columns?: string[];
  data?: ComparisonRow[];
}

const DEFAULT_COLUMNS = ['Commands', 'Agents', 'Skills'];

const DEFAULT_DATA: ComparisonRow[] = [
  {
    aspect: 'Declenchement',
    Commands: 'Manuel (/nom)',
    Agents: 'Automatique (delegation)',
    Skills: 'Automatique (mots-cles)',
  },
  {
    aspect: 'Contexte',
    Commands: 'Partage',
    Agents: 'Isole',
    Skills: 'Fork ou partage',
  },
  {
    aspect: 'Modele',
    Commands: 'Herite du parent',
    Agents: 'Haiku ou Sonnet',
    Skills: 'Herite du parent',
  },
  {
    aspect: 'Outils',
    Commands: 'Tous disponibles',
    Agents: 'Restreints',
    Skills: 'Restreints (allowed-tools)',
  },
  {
    aspect: "Cas d'usage",
    Commands: 'Actions explicites',
    Agents: 'Taches autonomes',
    Skills: 'Declenchement contextuel',
  },
  {
    aspect: 'Nombre',
    Commands: '121',
    Agents: '57',
    Skills: '42',
  },
];

export default function FeatureComparison({
  columns = DEFAULT_COLUMNS,
  data = DEFAULT_DATA,
}: FeatureComparisonProps): JSX.Element {
  return (
    <div className="feature-comparison">
      <table>
        <thead>
          <tr>
            <th>Aspect</th>
            {columns.map((col) => (
              <th key={col}>{col}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row) => (
            <tr key={row.aspect}>
              <td><strong>{row.aspect}</strong></td>
              {columns.map((col) => (
                <td key={col}>{row[col] ?? ''}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
