import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  // Enable Mermaid diagrams
  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'throw',
    },
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
  tagline: 'Claude Code configuration template for an optimal workflow: Explore → Specify → Plan → TDD → Commit',
  favicon: 'img/favicon.svg',

  // GitHub Pages configuration
  url: 'https://christopherlouet.github.io',
  baseUrl: '/claude-socle/',
  organizationName: 'christopherlouet',
  projectName: 'claude-socle',
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
          editUrl: 'https://github.com/christopherlouet/claude-socle/tree/main/website/',
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
              label: 'Agents (63)',
            },
            {
              type: 'docSidebar',
              sidebarId: 'skillsSidebar',
              label: 'Skills (54)',
            },
            {
              type: 'docSidebar',
              sidebarId: 'rulesSidebar',
              label: 'Rules (30)',
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
              label: 'Commands (131)',
              to: '/docs/commands',
            },
            {
              label: 'Agents (63)',
              to: '/docs/agents',
            },
            {
              label: 'Skills (54)',
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
