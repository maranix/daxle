import type { DefaultTheme } from 'vitepress';
import { Routes } from './routes';

export const sidebar: DefaultTheme.Sidebar = [
  {
    text: 'Getting Started',
    collapsed: false,
    items: Object.values(Routes.gettingStarted),
  },
  {
    text: 'Core Types',
    collapsed: false,
    items: Object.values(Routes.coreTypes),
  },
  {
    text: 'Utilities',
    collapsed: true,
    items: Object.values(Routes.utilities),
  },
  {
    text: 'Guides',
    collapsed: true,
    items: Object.values(Routes.guides),
  },
  {
    text: 'Cookbooks',
    collapsed: true,
    items: Object.values(Routes.cookbooks),
  },
];
