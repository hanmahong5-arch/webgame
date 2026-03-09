import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../pages/Home.vue')
  },
  {
    path: '/pricing',
    name: 'Pricing',
    component: () => import('../pages/Pricing.vue')
  },
  {
    path: '/download',
    name: 'Download',
    component: () => import('../pages/Download.vue')
  },
  {
    path: '/about',
    name: 'About',
    component: () => import('../pages/About.vue')
  },
  {
    path: '/solutions',
    name: 'Solutions',
    component: () => import('../pages/Solutions.vue')
  },
  {
    path: '/for-explorers',
    name: 'ForExplorers',
    component: () => import('../pages/ForExplorers.vue')
  },
  {
    path: '/for-entrepreneurs',
    name: 'ForEntrepreneurs',
    component: () => import('../pages/ForEntrepreneurs.vue')
  },
  {
    path: '/for-builders',
    name: 'ForBuilders',
    component: () => import('../pages/ForBuilders.vue')
  },
  {
    path: '/terms',
    name: 'Terms',
    component: () => import('../pages/Terms.vue')
  },
  {
    path: '/privacy',
    name: 'Privacy',
    component: () => import('../pages/Privacy.vue')
  },
  {
    path: '/auth/callback',
    name: 'AuthCallback',
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

export default router
