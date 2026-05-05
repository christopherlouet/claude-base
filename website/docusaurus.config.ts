import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import counts from '../counts.json';

const config: Config = {
  // Enable Mermaid diagrams
  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'throw',
    },
  },
  plugins: [
    [
      '@docusaurus/plugin-client-redirects',
      {
        redirects: [
          {from: '/docs/tutorials/premier-projet', to: '/docs/tutorials/first-project'},
          {from: '/docs/tutorials/audit-securite', to: '/docs/tutorials/security-audit'},
          {from: '/docs/tutorials/projet-complet', to: '/docs/tutorials/complete-project'},
        ],
      },
    ],
  ],
  themes: [
    '@docusaurus/theme-mermaid',
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        language: ['fr', 'en'],
        highlightSearchTermsOnTargetPage: true,
        explicitSearchResultPath: true,
        indexDocs: true,
        indexBlog: false,
        indexPages: false,
        docsRouteBasePath: '/docs',
        searchResultLimits: 10,
        searchResultContextMaxLength: 50,
      },
    ],
  ],
  title: 'claude-base',
  tagline: 'Claude Code configuration template for an optimal workflow: Explore → Specify → Plan → TDD → Commit',
  favicon: 'img/favicon.svg',

  // GitHub Pages configuration
  url: 'https://christopherlouet.github.io',
  baseUrl: '/claude-base/',
  organizationName: 'christopherlouet',
  projectName: 'claude-base',
  trailingSlash: false,

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'fr',
    locales: ['fr'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/christopherlouet/claude-base/tree/main/website/',
          showLastUpdateTime: true,
          showLastUpdateAuthor: true,
        },
        blog: false, // Disabled for v1
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/social-card.svg',

    colorMode: {
      defaultMode: 'light',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },

    navbar: {
      title: 'claude-base',
      logo: {
        alt: 'claude-base Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'introSidebar',
          position: 'left',
          label: 'Introduction',
        },
        {
          type: 'doc',
          docId: 'guides/learning-path',
          position: 'left',
          label: 'Path',
        },
        {
          type: 'docSidebar',
          sidebarId: 'conceptsSidebar',
          position: 'left',
          label: 'Concepts',
        },
        {
          type: 'docSidebar',
          sidebarId: 'workflowSidebar',
          position: 'left',
          label: 'Workflows',
        },
        {
          type: 'docSidebar',
          sidebarId: 'tutorialsSidebar',
          position: 'left',
          label: 'Tutorials',
        },
        {
          type: 'docSidebar',
          sidebarId: 'commandsSidebar',
          position: 'left',
          label: 'Commands',
        },
        {
          type: 'dropdown',
          label: 'Components',
          position: 'left',
          items: [
            {
              type: 'docSidebar',
              sidebarId: 'agentsSidebar',
              label: `Agents (${counts.agents})`,
            },
            {
              type: 'docSidebar',
              sidebarId: 'skillsSidebar',
              label: `Skills (${counts.skills})`,
            },
            {
              type: 'docSidebar',
              sidebarId: 'rulesSidebar',
              label: `Rules (${counts.rules})`,
            },
          ],
        },
        {
          type: 'docSidebar',
          sidebarId: 'examplesSidebar',
          position: 'left',
          label: 'Examples',
        },
        {
          type: 'docSidebar',
          sidebarId: 'guidesSidebar',
          position: 'left',
          label: 'Guides',
        },
        {
          type: 'docSidebar',
          sidebarId: 'referenceSidebar',
          position: 'left',
          label: 'Reference',
        },
        {
          href: 'https://github.com/christopherlouet/claude-base',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },

    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {
              label: 'Quick Start',
              to: '/docs/intro/quick-start',
            },
            {
              label: 'Claude Code Concepts',
              to: '/docs/concepts',
            },
            {
              label: 'Architecture',
              to: '/docs/intro/architecture',
            },
            {
              label: 'Workflows',
              to: '/docs/workflow',
            },
          ],
        },
        {
          title: 'Components',
          items: [
            {
              label: `Commands (${counts.commands})`,
              to: '/docs/commands',
            },
            {
              label: `Agents (${counts.agents})`,
              to: '/docs/agents',
            },
            {
              label: `Skills (${counts.skills})`,
              to: '/docs/skills',
            },
          ],
        },
        {
          title: 'Resources',
          items: [
            {
              label: 'Guides',
              to: '/docs/guides',
            },
            {
              label: 'Reference',
              to: '/docs/reference',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/christopherlouet/claude-base',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} claude-base. Built with Docusaurus.`,
    },

    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'typescript', 'dart', 'yaml', 'json'],
    },

    docs: {
      sidebar: {
        hideable: true,
        autoCollapseCategories: true,
      },
    },

    tableOfContents: {
      minHeadingLevel: 2,
      maxHeadingLevel: 4,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
