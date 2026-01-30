import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  // Enable Mermaid diagrams
  markdown: {
    mermaid: true,
  },
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
  title: 'claude-socle',
  tagline: 'Template de configuration Claude Code pour un workflow optimal : Explore → Plan → TDD → Commit',
  favicon: 'img/favicon.ico',

  // GitHub Pages configuration
  url: 'https://christopherlouet.github.io',
  baseUrl: '/claude-socle/',
  organizationName: 'christopherlouet',
  projectName: 'claude-socle',
  trailingSlash: false,

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

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
          editUrl: 'https://github.com/christopherlouet/claude-socle/tree/main/website/',
          showLastUpdateTime: true,
          showLastUpdateAuthor: true,
        },
        blog: false, // Désactivé pour la v1
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/social-card.png',

    colorMode: {
      defaultMode: 'light',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },

    navbar: {
      title: 'claude-socle',
      logo: {
        alt: 'claude-socle Logo',
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
          label: 'Tutoriels',
        },
        {
          type: 'docSidebar',
          sidebarId: 'commandsSidebar',
          position: 'left',
          label: 'Commands',
        },
        {
          type: 'dropdown',
          label: 'Composants',
          position: 'left',
          items: [
            {
              type: 'docSidebar',
              sidebarId: 'agentsSidebar',
              label: 'Agents (57)',
            },
            {
              type: 'docSidebar',
              sidebarId: 'skillsSidebar',
              label: 'Skills (41)',
            },
            {
              type: 'docSidebar',
              sidebarId: 'rulesSidebar',
              label: 'Rules (21)',
            },
          ],
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
          label: 'Référence',
        },
        {
          href: 'https://github.com/christopherlouet/claude-socle',
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
              label: 'Concepts Claude Code',
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
          title: 'Composants',
          items: [
            {
              label: 'Commands (119)',
              to: '/docs/commands',
            },
            {
              label: 'Agents (57)',
              to: '/docs/agents',
            },
            {
              label: 'Skills (41)',
              to: '/docs/skills',
            },
          ],
        },
        {
          title: 'Ressources',
          items: [
            {
              label: 'Guides',
              to: '/docs/guides',
            },
            {
              label: 'Référence',
              to: '/docs/reference',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/christopherlouet/claude-socle',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} claude-socle. Built with Docusaurus.`,
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
