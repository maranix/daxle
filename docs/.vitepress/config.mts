import { defineConfig } from 'vitepress'
import { navigation } from './navigation'
import { sidebar } from './sidebar'
import { socialLinks } from './socials'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Daxle",
  description: "A functional programming library for Dart with comprehensive documentation, guides, and API reference.",
  lastUpdated: true,
  cleanUrls: true,
  srcExclude: ['**/AGENTS.md', '**/graphify-out/**'],
  head: [
    ['link', { rel: 'icon', href: '/favicon.png' }]
  ],
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: navigation,
    sidebar,
    socialLinks,

    footer: {
      message: 'Released under the MIT License.',
      copyright: `Copyright © ${new Date().getFullYear()} Raman Verma`,
    },

    search: {
      provider: 'local',
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
