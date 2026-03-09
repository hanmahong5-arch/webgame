<script setup lang="ts">
const currentYear = new Date().getFullYear()

const explorers = [
  { name: 'ACEST Desktop', href: '/download', description: 'AI 桌面助手' },
  { name: 'GuShen 谷神', href: 'https://gushen.lurus.cn', description: 'AI 量化交易' },
  { name: 'Lurus Switch', href: '/download', description: 'AI 工具管理器' },
  { name: 'MemX', href: '/download#memx', description: 'AI 记忆扩展' },
]

const entrepreneurs = [
  { name: 'Lurus API', href: 'https://api.lurus.cn', description: 'LLM 统一网关' },
  { name: 'Lurus Mail', href: 'https://mail.lurus.cn', description: '企业邮件' },
  { name: 'GuShen Pro', href: 'https://gushen.lurus.cn', description: '机构量化服务' },
]

const builders = [
  { name: 'Lurus Identity', href: 'https://identity.lurus.cn', description: '身份与计费平台' },
  { name: 'MemX SDK', href: '/download#memx', description: 'AI 记忆基础设施' },
  { name: 'API (OEM)', href: 'https://api.lurus.cn', description: '白标 LLM 网关' },
]

const resources = [
  { name: 'API 文档', href: 'https://docs.lurus.cn' },
  { name: '快速入门', href: 'https://docs.lurus.cn/guide/quickstart' },
  { name: '定价方案', href: '/pricing' },
  { name: '下载中心', href: '/download' },
]

const company = [
  { name: '关于我们', href: '/about' },
  { name: '联系我们', href: 'mailto:support@lurus.cn' },
  { name: '服务条款', href: '/terms' },
  { name: '隐私政策', href: '/privacy' },
]

const ICP_NUMBER = import.meta.env.VITE_ICP_NUMBER || '鲁ICP备2026000242号'
</script>

<template>
  <footer class="relative bg-cream-100 border-t-2 border-ink-100 overflow-hidden">
    <!-- Decorative elements -->
    <div class="absolute top-8 left-8 doodle-corner opacity-40"></div>
    <div class="absolute bottom-8 right-8 doodle-corner rotate-180 opacity-40"></div>

    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Main Footer Content -->
      <div class="py-fib-6 grid grid-cols-2 md:grid-cols-6 gap-fib-5 lg:gap-fib-5">
        <!-- Brand Column -->
        <div class="col-span-2 md:col-span-2">
          <div class="flex items-center gap-3 mb-fib-4">
            <div class="w-10 h-10 rounded-lg bg-ochre flex items-center justify-center border-2 border-ink-300">
              <span class="text-cream-50 font-hand font-bold text-xl">L</span>
            </div>
            <span class="text-ink-900 font-hand font-bold text-2xl">Lurus</span>
          </div>
          <p class="text-ink-500 mb-fib-4 max-w-sm leading-relaxed text-sm">
            AI 基础设施生态 — 从个人桌面到企业平台，为每一种可能提供底座。
          </p>
        </div>

        <!-- Explorers Column -->
        <div>
          <h3 class="text-sm text-ink-900 mb-fib-3 font-semibold">探索者</h3>
          <ul class="space-y-2.5">
            <li v-for="item in explorers" :key="item.name">
              <a
                :href="item.href"
                :target="item.href.startsWith('http') ? '_blank' : undefined"
                :rel="item.href.startsWith('http') ? 'noopener noreferrer' : undefined"
                class="group"
              >
                <span class="text-sm text-ink-500 group-hover:text-ink-900 transition-colors">{{ item.name }}</span>
              </a>
            </li>
          </ul>
        </div>

        <!-- Entrepreneurs Column -->
        <div>
          <h3 class="text-sm text-ink-900 mb-fib-3 font-semibold">创业者</h3>
          <ul class="space-y-2.5">
            <li v-for="item in entrepreneurs" :key="item.name">
              <a
                :href="item.href"
                :target="item.href.startsWith('http') ? '_blank' : undefined"
                :rel="item.href.startsWith('http') ? 'noopener noreferrer' : undefined"
                class="group"
              >
                <span class="text-sm text-ink-500 group-hover:text-ink-900 transition-colors">{{ item.name }}</span>
              </a>
            </li>
            <li>
              <h3 class="text-sm text-ink-900 mt-fib-3 mb-2 font-semibold">构建者</h3>
              <ul class="space-y-2.5">
                <li v-for="item in builders" :key="item.name">
                  <a
                    :href="item.href"
                    :target="item.href.startsWith('http') ? '_blank' : undefined"
                    :rel="item.href.startsWith('http') ? 'noopener noreferrer' : undefined"
                    class="group"
                  >
                    <span class="text-sm text-ink-500 group-hover:text-ink-900 transition-colors">{{ item.name }}</span>
                  </a>
                </li>
              </ul>
            </li>
          </ul>
        </div>

        <!-- Resources Column -->
        <div>
          <h3 class="text-sm text-ink-900 mb-fib-3 font-semibold">资源</h3>
          <ul class="space-y-2.5">
            <li v-for="item in resources" :key="item.name">
              <a
                :href="item.href"
                :target="item.href.startsWith('http') ? '_blank' : undefined"
                :rel="item.href.startsWith('http') ? 'noopener noreferrer' : undefined"
                class="text-sm text-ink-500 hover:text-ink-900 transition-colors"
              >
                {{ item.name }}
              </a>
            </li>
          </ul>
        </div>

        <!-- Company Column -->
        <div>
          <h3 class="text-sm text-ink-900 mb-fib-3 font-semibold">公司</h3>
          <ul class="space-y-2.5">
            <li v-for="item in company" :key="item.name">
              <router-link
                v-if="item.href.startsWith('/')"
                :to="item.href"
                class="text-sm text-ink-500 hover:text-ink-900 transition-colors"
              >
                {{ item.name }}
              </router-link>
              <a
                v-else
                :href="item.href"
                class="text-sm text-ink-500 hover:text-ink-900 transition-colors"
              >
                {{ item.name }}
              </a>
            </li>
          </ul>
        </div>
      </div>

      <!-- Bottom Bar -->
      <div class="py-fib-4 border-t-2 border-ink-100 flex flex-col sm:flex-row items-center justify-between gap-fib-3">
        <div class="flex flex-col sm:flex-row items-center gap-2 sm:gap-4 text-ink-300 text-sm">
          <p>&copy; {{ currentYear }} Lurus Technology. All rights reserved.</p>
          <a
            href="https://beian.miit.gov.cn/"
            target="_blank"
            rel="noopener noreferrer"
            class="hover:text-ink-500 transition-colors"
          >
            {{ ICP_NUMBER }}
          </a>
          <a
            href="https://www.beian.gov.cn/portal/registerSystemInfo?recordcode=37060002001239"
            target="_blank"
            rel="noopener noreferrer"
            class="hover:text-ink-500 transition-colors inline-flex items-center gap-1"
          >
            <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
            鲁公网安备37060002001239号
          </a>
        </div>
      </div>
    </div>
  </footer>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
