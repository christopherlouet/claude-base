import React from 'react';

interface ComparisonRow {
  aspect: string;
  commands: string;
  agents: string;
  skills: string;
}

const comparisonData: ComparisonRow[] = [
  {
    aspect: 'Declenchement',
    commands: 'Manuel (/nom)',
    agents: 'Automatique (delegation)',
    skills: 'Automatique (mots-cles)',
  },
  {
    aspect: 'Contexte',
    commands: 'Partage',
    agents: 'Isole',
    skills: 'Fork ou partage',
  },
  {
    aspect: 'Modele',
    commands: 'Herite du parent',
    agents: 'Haiku ou Sonnet',
    skills: 'Herite du parent',
  },
  {
    aspect: 'Outils',
    commands: 'Tous disponibles',
    agents: 'Restreints',
    skills: 'Restreints (allowed-tools)',
  },
  {
    aspect: 'Cas d\'usage',
    commands: 'Actions explicites',
    agents: 'Taches autonomes',
    skills: 'Declenchement contextuel',
  },
  {
    aspect: 'Nombre',
    commands: '119',
    agents: '57',
    skills: '41',
  },
];

export default function FeatureComparison(): JSX.Element {
  return (
    <div className="feature-comparison">
      <table>
        <thead>
          <tr>
            <th>Aspect</th>
            <th>Commands</th>
            <th>Agents</th>
            <th>Skills</th>
          </tr>
        </thead>
        <tbody>
          {comparisonData.map((row) => (
            <tr key={row.aspect}>
              <td><strong>{row.aspect}</strong></td>
              <td>{row.commands}</td>
              <td>{row.agents}</td>
              <td>{row.skills}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
