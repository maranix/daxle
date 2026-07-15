import type { DefaultTheme } from 'vitepress';
import { Routes } from './routes';

export const navigation: DefaultTheme.NavItem[] = [
  { text: 'Documentation', link: Routes.gettingStarted.introduction.link },
  { text: 'Guides', link: Routes.guides.errorHandling.link },
  { text: 'Cookbooks', link: Routes.cookbooks.apiExamples.link },
];
