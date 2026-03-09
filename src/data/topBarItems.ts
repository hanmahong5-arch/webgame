/**
 * TopBar Navigation Data
 * Function-level navigation: Docs / Pricing / About
 */

export interface TopBarLink {
  name: string
  path: string
  external?: boolean
}

export const topBarLinks: TopBarLink[] = [
  { name: '文档', path: 'https://docs.lurus.cn', external: true },
  { name: '定价', path: '/pricing' },
  { name: '关于', path: '/about' },
]
