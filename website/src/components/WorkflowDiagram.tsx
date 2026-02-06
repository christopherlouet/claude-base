import React from 'react';

export interface WorkflowStep {
  id: string;
  label: string;
  command?: string;
  description?: string;
}

export interface WorkflowDiagramProps {
  steps: WorkflowStep[];
  title?: string;
}

export default function WorkflowDiagram({
  steps,
  title,
}: WorkflowDiagramProps): JSX.Element {
  return (
    <div className="workflow-diagram">
      {title && (
        <h4 style={{ marginBottom: '1.5rem', textAlign: 'center' }}>{title}</h4>
      )}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', flexWrap: 'wrap', gap: '0.5rem' }}>
        {steps.map((step, index) => (
          <React.Fragment key={step.id}>
            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                padding: '1rem',
                minWidth: '120px',
              }}
            >
              <div
                style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '50%',
                  backgroundColor: 'var(--ifm-color-primary)',
                  color: 'white',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontWeight: 700,
                  fontSize: '1.25rem',
                  marginBottom: '0.5rem',
                }}
              >
                {index + 1}
              </div>
              <div style={{ fontWeight: 600, textAlign: 'center' }}>{step.label}</div>
              {step.command && (
                <code
                  style={{
                    fontSize: '0.75rem',
                    marginTop: '0.25rem',
                    padding: '0.125rem 0.5rem',
                    borderRadius: '0.25rem',
                    backgroundColor: 'var(--ifm-color-emphasis-100)',
                  }}
                >
                  {step.command}
                </code>
              )}
              {step.description && (
                <div
                  style={{
                    fontSize: '0.75rem',
                    color: 'var(--ifm-color-content-secondary)',
                    textAlign: 'center',
                    marginTop: '0.25rem',
                  }}
                >
                  {step.description}
                </div>
              )}
            </div>
            {index < steps.length - 1 && (
              <div
                style={{
                  fontSize: '1.5rem',
                  color: 'var(--ifm-color-primary)',
                }}
              >
                →
              </div>
            )}
          </React.Fragment>
        ))}
      </div>
    </div>
  );
}

// Pre-defined workflow configurations
export const MAIN_WORKFLOW: WorkflowStep[] = [
  { id: 'explore', label: 'Explore', command: '/work:work-explore', description: 'Comprendre le code' },
  { id: 'specify', label: 'Specify', command: '/work:work-specify', description: 'Specifier le besoin' },
  { id: 'plan', label: 'Plan', command: '/work:work-plan', description: 'Planifier les changements' },
  { id: 'tdd', label: 'TDD', command: '/dev:dev-tdd', description: 'Tests first (obligatoire)' },
  { id: 'commit', label: 'Commit', command: '/work:work-commit', description: 'Valider' },
];

export const FEATURE_WORKFLOW: WorkflowStep[] = [
  { id: 'explore', label: 'Explore', command: '/work:work-explore' },
  { id: 'specify', label: 'Specify', command: '/work:work-specify' },
  { id: 'plan', label: 'Plan', command: '/work:work-plan' },
  { id: 'tdd', label: 'TDD', command: '/dev:dev-tdd' },
  { id: 'review', label: 'Review', command: '/qa:qa-review' },
  { id: 'pr', label: 'PR', command: '/work:work-pr' },
];

export const BUGFIX_WORKFLOW: WorkflowStep[] = [
  { id: 'debug', label: 'Debug', command: '/dev:dev-debug' },
  { id: 'fix', label: 'Fix', command: '/dev:dev-tdd' },
  { id: 'review', label: 'Review', command: '/qa:qa-review' },
  { id: 'commit', label: 'Commit', command: '/work:work-commit' },
];
