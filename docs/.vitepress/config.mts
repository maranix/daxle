import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Daxle",
  description: "A functional programming library for Dart with comprehensive documentation, guides, and API reference.",
  lastUpdated: true,
  cleanUrls: true,
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Documentation', link: '/getting-started/introduction' },
      { text: 'Guides', link: '/guides/error-handling' },
      { text: 'Cookbook', link: '/cookbook/api-examples' },
    ],

    sidebar: [
      {
        text: 'Getting Started',
        collapsed: false,
        items: [
          {
            text: 'Introduction',
            link: '/getting-started/introduction',
          },
          {
            text: 'Installation',
            link: '/getting-started/installation',
          },
          {
            text: 'Quick Start',
            link: '/getting-started/quick-start',
          },
        ],
      },

      {
        text: 'Core Types',
        collapsed: false,
        items: [
          {
            text: 'Unit',
            link: '/core-types/unit',
          },
          {
            text: 'Option',
            link: '/core-types/option',
          },
          {
            text: 'Either',
            link: '/core-types/either',
          },
          {
            text: 'Result',
            link: '/core-types/result',
          },
          {
            text: 'Task',
            link: '/core-types/task',
          },
          {
            text: 'TaskEither',
            link: '/core-types/task-either',
          },
        ],
      },

      {
        text: 'Guides',
        collapsed: true,
        items: [
          {
            text: 'Error Handling',
            link: '/guides/error-handling',
          },
          {
            text: 'Asynchronous Programming',
            link: '/guides/async-programming',
          },
          {
            text: 'Functional Composition',
            link: '/guides/functional-composition',
          },
          {
            text: 'Best Practices',
            link: '/guides/best-practices',
          },
        ],
      },

      {
        text: 'Cookbook',
        collapsed: true,
        items: [
          {
            text: 'API',
            link: '/cookbook/api-examples',
          },
          {
            text: 'Markdown',
            link: '/cookbook/markdown-examples',
          },
          {
            text: 'Validation',
            link: '/cookbook/validation',
          },
          {
            text: 'Networking',
            link: '/cookbook/networking',
          },
          {
            text: 'Repository Pattern',
            link: '/cookbook/repository-pattern',
          },
          {
            text: 'State Management',
            link: '/cookbook/state-management',
          },
        ],
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/maranix/daxle' },
      { icon: 'x', link: 'https://x.com/its_maranix' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: `Copyright © ${new Date().getFullYear()} Raman Verma`,
    },

    search: {
      provider: 'local',
    },

    outline: {
      level: [2, 3],
      label: 'On this page',
    },


    docFooter: {
      prev: 'Previous',
      next: 'Next',
    },

    editLink: {
      pattern: 'https://github.com/maranix/daxle/edit/main/docs/:path',
      text: 'Edit this page on GitHub',
    },
  }
})
