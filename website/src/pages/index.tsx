import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';
import counts from '../../../counts.json';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro/quick-start">
            Quick Start - 5min
          </Link>
        </div>
      </div>
    </header>
  );
}

type FeatureItem = {
  title: string;
  description: JSX.Element;
  emoji: string;
};

const FeatureList: FeatureItem[] = [
  {
    title: `${counts.commands} Commands`,
    emoji: '🎯',
    description: (
      <>
        Slash commands for every situation: workflow, dev, QA, ops, docs, business, growth, data and legal.
      </>
    ),
  },
  {
    title: `${counts.agents} Sub-Agents`,
    emoji: '🤖',
    description: (
      <>
        Autonomous agents with isolated context for audits, explorations and complex analyses.
      </>
    ),
  },
  {
    title: `${counts.skills} Skills`,
    emoji: '⚡',
    description: (
      <>
        Skills auto-triggered by keywords for TDD, commits, debugging, reviews and more.
      </>
    ),
  },
  {
    title: `${counts.rules} Rules`,
    emoji: '📏',
    description: (
      <>
        Modular rules per language: TypeScript, React, Flutter, Python, Go, Rust and more.
      </>
    ),
  },
];

function Feature({title, emoji, description}: FeatureItem) {
  return (
    <div className={clsx('col col--3')}>
      <div className="text--center">
        <span style={{fontSize: '3rem'}}>{emoji}</span>
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}

function HomepageWorkflow(): JSX.Element {
  return (
    <section className={styles.workflow}>
      <div className="container">
        <Heading as="h2" className="text--center margin-bottom--lg">
          Recommended Workflow
        </Heading>
        <div className={styles.workflowDiagram}>
          <div className={styles.workflowStep}>
            <span className={styles.stepNumber}>1</span>
            <span className={styles.stepName}>EXPLORE</span>
            <code>/work:work-explore</code>
          </div>
          <span className={styles.arrow}>→</span>
          <div className={styles.workflowStep}>
            <span className={styles.stepNumber}>2</span>
            <span className={styles.stepName}>SPECIFY</span>
            <code>/work:work-specify</code>
          </div>
          <span className={styles.arrow}>→</span>
          <div className={styles.workflowStep}>
            <span className={styles.stepNumber}>3</span>
            <span className={styles.stepName}>PLAN</span>
            <code>/work:work-plan</code>
          </div>
          <span className={styles.arrow}>→</span>
          <div className={styles.workflowStep}>
            <span className={styles.stepNumber}>4</span>
            <span className={styles.stepName}>TDD</span>
            <code>/dev:dev-tdd</code>
          </div>
          <span className={styles.arrow}>→</span>
          <div className={styles.workflowStep}>
            <span className={styles.stepNumber}>5</span>
            <span className={styles.stepName}>COMMIT</span>
            <code>/work:work-pr</code>
          </div>
        </div>
      </div>
    </section>
  );
}

function HomepageCTA(): JSX.Element {
  return (
    <section className={styles.cta}>
      <div className="container">
        <div className="row">
          <div className="col col--6 col--offset-3 text--center">
            <Heading as="h2">Ready to get started?</Heading>
            <p>
              From beginner to expert in 5 progressive levels, or get started in 5 minutes.
            </p>
            <div className={styles.buttons}>
              <Link
                className="button button--primary button--lg margin-right--md"
                to="/docs/guides/learning-path">
                Learning path
              </Link>
              <Link
                className="button button--secondary button--lg"
                to="/docs/intro/quick-start">
                Quick Start (5 min)
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Home(): JSX.Element {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title="Home"
      description={siteConfig.tagline}>
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <HomepageWorkflow />
        <HomepageCTA />
      </main>
    </Layout>
  );
}
