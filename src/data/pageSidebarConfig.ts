/**
 * Page Sidebar Configuration — single source of truth for all page sidebars
 * Keyed by route name from src/router/index.ts
 */

import type { PageSidebarConfig } from '../types/sidebar'

export const pageSidebarConfigs: Record<string, PageSidebarConfig> = {
  Pricing: {
    toc: {
      label: '目录',
      items: [
        { label: '定价方案', anchor: 'pricing-hero' },
        { label: '受众选择', anchor: 'audience-selector' },
        { label: '产品定价', anchor: 'pricing-cards' },
        { label: '功能对比', anchor: 'comparison' },
        { label: '常见问题', anchor: 'faq' },
      ],
    },
    products: {
      label: '相关产品',
      collapsed: true,
      items: [
        { productId: 'api', label: 'Lurus API', color: '#4A9EFF', href: 'https://api.lurus.cn', external: true },
        { productId: 'switch', label: 'Lurus Switch', color: '#FF8C69', href: '/download' },
        { productId: 'lucrum', label: 'Lucrum', color: '#7AFF89', href: 'https://gushen.lurus.cn', external: true },
      ],
    },
    cta: [
      { label: '免费注册', href: '', variant: 'primary', action: 'login' },
      { label: '查看文档', href: 'https://docs.lurus.cn', variant: 'outline', external: true },
    ],
  },

  ForExplorers: {
    toc: {
      label: '目录',
      items: [
        { label: '概览', anchor: 'hero' },
        { label: 'Lurus Creator', anchor: 'creator' },
        { label: 'Lucrum', anchor: 'lucrum' },
        { label: 'Lurus Switch', anchor: 'switch' },
        { label: 'MemX', anchor: 'memx' },
        { label: '定价预览', anchor: 'pricing-preview' },
        { label: '个人套餐', anchor: 'bundle' },
      ],
    },
    links: {
      label: '快捷链接',
      items: [
        { label: '下载中心', href: '/download' },
        { label: '完整定价', href: '/pricing' },
        { label: '文档', href: 'https://docs.lurus.cn', external: true },
      ],
    },
    cta: [
      { label: '下载工具', href: '/download', variant: 'primary' },
    ],
  },

  ForEntrepreneurs: {
    toc: {
      label: '目录',
      items: [
        { label: '概览', anchor: 'hero' },
        { label: 'Lurus API', anchor: 'api' },
        { label: 'Lurus Switch', anchor: 'switch' },
        { label: 'Lucrum', anchor: 'lucrum' },
        { label: '行业方案', anchor: 'industries' },
        { label: '企业套餐', anchor: 'bundle' },
      ],
    },
    products: {
      label: '核心产品',
      items: [
        { productId: 'api', label: 'Lurus API', color: '#4A9EFF', href: 'https://api.lurus.cn', external: true },
        { productId: 'switch', label: 'Lurus Switch', color: '#FF8C69', href: '/download' },
        { productId: 'lucrum', label: 'Lucrum', color: '#7AFF89', href: 'https://gushen.lurus.cn', external: true },
      ],
    },
    cta: [
      { label: '获取 API Key', href: 'https://api.lurus.cn', variant: 'primary', external: true },
      { label: '联系销售', href: 'mailto:support@lurus.cn', variant: 'outline', external: true },
    ],
  },

  ForBuilders: {
    toc: {
      label: '目录',
      items: [
        { label: '概览', anchor: 'hero' },
        { label: '集成路径', anchor: 'integration-path' },
        { label: 'Kova SDK', anchor: 'kova' },
        { label: 'Lumen', anchor: 'lumen' },
        { label: 'MemX SDK', anchor: 'memx' },
        { label: 'Lurus API', anchor: 'api' },
        { label: 'Forge', anchor: 'forge' },
        { label: 'Identity', anchor: 'identity' },
        { label: '开发者套餐', anchor: 'bundle' },
      ],
    },
    links: {
      label: '开发资源',
      items: [
        { label: 'API 文档', href: 'https://docs.lurus.cn', external: true },
        { label: 'SDK 参考', href: 'https://docs.lurus.cn/kova/', external: true },
      ],
    },
    cta: [
      { label: '查看文档', href: 'https://docs.lurus.cn', variant: 'primary', external: true },
    ],
  },

  About: {
    toc: {
      label: '目录',
      items: [
        { label: '关于 Lurus', anchor: 'hero' },
        { label: '使命与愿景', anchor: 'mission' },
        { label: '关键数据', anchor: 'stats' },
        { label: '核心价值观', anchor: 'values' },
        { label: '优势', anchor: 'advantages' },
        { label: '发展历程', anchor: 'timeline' },
        { label: '技术架构', anchor: 'technology' },
        { label: '团队', anchor: 'team' },
        { label: '招聘', anchor: 'careers' },
        { label: '联系', anchor: 'contact' },
      ],
    },
    links: {
      label: '探索更多',
      collapsed: true,
      items: [
        { label: '解决方案', href: '/solutions' },
        { label: '开发者工具', href: '/for-builders' },
        { label: '文档', href: 'https://docs.lurus.cn', external: true },
      ],
    },
    cta: [
      { label: '联系我们', href: 'mailto:support@lurus.cn', variant: 'outline', external: true },
    ],
  },

  Solutions: {
    toc: {
      label: '目录',
      items: [
        { label: '概览', anchor: 'hero' },
        { label: '学术研究', anchor: 'academic' },
        { label: '金融分析', anchor: 'finance' },
        { label: '医疗健康', anchor: 'medical' },
        { label: '法律服务', anchor: 'legal' },
        { label: '软件工程', anchor: 'engineering' },
        { label: '技术优势', anchor: 'tech-advantages' },
        { label: '安全保障', anchor: 'security' },
      ],
    },
    products: {
      label: '驱动产品',
      items: [
        { productId: 'api', label: 'Lurus API', color: '#4A9EFF', href: 'https://api.lurus.cn', external: true },
        { productId: 'memx', label: 'MemX', color: '#4AFFCB', href: '/download#memx' },
        { productId: 'lucrum', label: 'Lucrum', color: '#7AFF89', href: 'https://gushen.lurus.cn', external: true },
      ],
    },
    cta: [
      { label: '免费注册', href: '', variant: 'primary', action: 'login' },
      { label: '查看定价', href: '/pricing', variant: 'outline' },
    ],
  },

  Download: {
    toc: {
      label: '目录',
      items: [
        { label: '下载中心', anchor: 'hero' },
        { label: 'ACEST Desktop', anchor: 'acest' },
        { label: 'MemX', anchor: 'memx' },
        { label: '所有产品', anchor: 'all-releases' },
      ],
    },
    links: {
      label: '相关',
      items: [
        { label: '版本历史', href: '/releases' },
        { label: '使用文档', href: 'https://docs.lurus.cn', external: true },
        { label: '个人探索者', href: '/for-explorers' },
      ],
    },
    cta: [
      { label: '查看版本历史', href: '/releases', variant: 'outline' },
    ],
  },

  Releases: {
    toc: {
      label: '目录',
      items: [
        { label: '版本历史', anchor: 'top' },
        { label: '筛选器', anchor: 'filters' },
      ],
    },
    links: {
      label: '相关',
      items: [
        { label: '下载中心', href: '/download' },
      ],
    },
    cta: [
      { label: '下载最新版', href: '/download', variant: 'primary' },
    ],
  },

  Terms: {
    toc: {
      label: '目录',
      items: [
        { label: '服务概述', anchor: 'sec-1' },
        { label: '账户注册与安全', anchor: 'sec-2' },
        { label: '服务使用规范', anchor: 'sec-3' },
        { label: '付费与退款', anchor: 'sec-4' },
        { label: '服务等级承诺', anchor: 'sec-5' },
        { label: '免责声明', anchor: 'sec-6' },
        { label: '条款修改', anchor: 'sec-7' },
        { label: '联系方式', anchor: 'sec-8' },
      ],
    },
    links: {
      label: '相关',
      items: [
        { label: '隐私政策', href: '/privacy' },
        { label: '关于我们', href: '/about' },
      ],
    },
  },

  Privacy: {
    toc: {
      label: '目录',
      items: [
        { label: '概述', anchor: 'sec-overview' },
        { label: '收集的信息', anchor: 'sec-1' },
        { label: '不收集的信息', anchor: 'sec-2' },
        { label: '信息使用目的', anchor: 'sec-3' },
        { label: '数据存储与安全', anchor: 'sec-4' },
        { label: '第三方共享', anchor: 'sec-5' },
        { label: '您的权利', anchor: 'sec-6' },
        { label: 'Cookie 使用', anchor: 'sec-7' },
        { label: '未成年人保护', anchor: 'sec-8' },
        { label: '政策更新', anchor: 'sec-9' },
        { label: '联系我们', anchor: 'sec-10' },
      ],
    },
    links: {
      label: '相关',
      items: [
        { label: '服务条款', href: '/terms' },
        { label: '关于我们', href: '/about' },
      ],
    },
  },
}
