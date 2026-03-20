import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'

const BASE_TITLE = 'Lurus — AI 基础设施生态'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Home',
    meta: {
      hideSidebar: true,
      title: BASE_TITLE,
      description: '一套完整的 AI 基础设施 — API 网关、Agent SDK、量化交易、桌面工具，7 款产品覆盖全场景，开箱即用。',
    },
    component: () => import('../pages/Home.vue')
  },
  {
    path: '/pricing',
    name: 'Pricing',
    meta: {
      pageSidebar: true,
      title: `定价方案 — ${BASE_TITLE}`,
      description: 'Lurus 按量付费，无订阅陷阱。查看 API 调用、桌面工具和开发者套餐的完整定价。',
    },
    component: () => import('../pages/Pricing.vue')
  },
  {
    path: '/download',
    name: 'Download',
    meta: {
      pageSidebar: true,
      title: `下载中心 — ${BASE_TITLE}`,
      description: '下载 Lurus Creator、Switch、MemX 等桌面工具。Windows / macOS 全平台支持，免费开始。',
    },
    component: () => import('../pages/Download.vue')
  },
  {
    path: '/about',
    name: 'About',
    meta: {
      pageSidebar: true,
      title: `关于我们 — ${BASE_TITLE}`,
      description: 'Lurus 是专注于 AI 基础设施的团队，致力于让每个开发者都能轻松构建和部署 AI 产品。',
    },
    component: () => import('../pages/About.vue')
  },
  {
    path: '/solutions',
    name: 'Solutions',
    meta: {
      pageSidebar: true,
      title: `解决方案 — ${BASE_TITLE}`,
      description: '面向金融、医疗、法律、工程等行业的 AI 解决方案，由 Lurus 基础设施驱动。',
    },
    component: () => import('../pages/Solutions.vue')
  },
  {
    path: '/for-explorers',
    name: 'ForExplorers',
    meta: {
      pageSidebar: true,
      title: `个人探索者 — ${BASE_TITLE}`,
      description: '免费下载 Lurus 桌面工具套件，让 AI 融入你的每日工作流 — Creator、Switch、MemX 全部免费。',
    },
    component: () => import('../pages/ForExplorers.vue')
  },
  {
    path: '/for-entrepreneurs',
    name: 'ForEntrepreneurs',
    meta: {
      pageSidebar: true,
      title: `创业者方案 — ${BASE_TITLE}`,
      description: '3 分钟接入 50+ AI 模型，按量付费，无最低消费。快速上线 AI 产品，从 Lurus API 开始。',
    },
    component: () => import('../pages/ForEntrepreneurs.vue')
  },
  {
    path: '/for-builders',
    name: 'ForBuilders',
    meta: {
      pageSidebar: true,
      title: `开发者工具 — ${BASE_TITLE}`,
      description: 'Kova SDK、Lumen、MemX SDK、Lurus Identity — 一站式 AI 开发者基础设施，构建下一代应用。',
    },
    component: () => import('../pages/ForBuilders.vue')
  },
  {
    path: '/releases',
    name: 'Releases',
    meta: {
      pageSidebar: true,
      title: `Release History — ${BASE_TITLE}`,
      description: 'Track updates across all Lurus products — changelogs, downloads, and version history.',
    },
    component: () => import('../pages/Releases.vue')
  },
  {
    path: '/terms',
    name: 'Terms',
    meta: {
      pageSidebar: true,
      title: `服务条款 — ${BASE_TITLE}`,
      description: 'Lurus 平台服务条款，使用前请仔细阅读。',
    },
    component: () => import('../pages/Terms.vue')
  },
  {
    path: '/privacy',
    name: 'Privacy',
    meta: {
      pageSidebar: true,
      title: `隐私政策 — ${BASE_TITLE}`,
      description: 'Lurus 隐私政策：我们如何收集、使用和保护你的数据。',
    },
    component: () => import('../pages/Privacy.vue')
  },
  {
    path: '/auth/callback',
    name: 'AuthCallback',
    meta: { hideSidebar: true },
    component: () => import('../pages/AuthCallback.vue')
  },
  // Catch-all redirect to home for unknown routes
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, _from, savedPosition) {
    // Handle hash links (e.g., #pricing, #download)
    if (to.hash) {
      return {
        el: to.hash,
        behavior: 'smooth'
      }
    }
    // Restore position when navigating back
    if (savedPosition) {
      return savedPosition
    }
    // Scroll to top for new navigation
    return { top: 0 }
  }
})

// Update document title and meta description on each navigation
router.afterEach((to) => {
  const title = to.meta.title as string | undefined
  if (title) document.title = title

  const description = to.meta.description as string | undefined
  if (description) {
    let metaDesc = document.querySelector<HTMLMetaElement>('meta[name="description"]')
    if (!metaDesc) {
      metaDesc = document.createElement('meta')
      metaDesc.name = 'description'
      document.head.appendChild(metaDesc)
    }
    metaDesc.content = description
  }
})

export default router
