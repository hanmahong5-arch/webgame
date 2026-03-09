/**
 * Sidebar Navigation Data
 * Business-level navigation: Products / Solutions / Resources
 */

export interface SidebarSection {
  key: string
  label: string
  items: SidebarNavItem[]
}

export interface SidebarNavItem {
  name: string
  path: string
  icon: string
  external?: boolean
  badge?: string
}

export const sidebarSections: SidebarSection[] = [
  {
    key: 'products',
    label: '产品',
    items: [
      { name: 'ACEST Desktop', path: '/download', icon: 'brain' },
      { name: 'Lurus Switch', path: '/download', icon: 'desktop' },
      { name: 'Lurus API', path: 'https://api.lurus.cn', icon: 'api', external: true },
      { name: 'GuShen', path: 'https://gushen.lurus.cn', icon: 'chart', external: true },
      { name: 'MemX', path: '/download#memx', icon: 'database', badge: '即将' },
      { name: 'Lurus Mail', path: 'https://mail.lurus.cn', icon: 'mail', external: true },
    ],
  },
  {
    key: 'solutions',
    label: '方案',
    items: [
      { name: '个人用户', path: '/for-explorers', icon: 'user' },
      { name: '团队方案', path: '/for-entrepreneurs', icon: 'users' },
      { name: '平台集成', path: '/for-builders', icon: 'building' },
    ],
  },
  {
    key: 'resources',
    label: '资源',
    items: [
      { name: '文档中心', path: 'https://docs.lurus.cn', icon: 'book', external: true },
      { name: '下载客户端', path: '/download', icon: 'download' },
      { name: 'API 控制台', path: 'https://api.lurus.cn/console', icon: 'terminal', external: true },
    ],
  },
]
