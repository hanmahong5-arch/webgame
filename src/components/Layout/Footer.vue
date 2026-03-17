<script setup lang="ts">
const currentYear = new Date().getFullYear()

const explorers = [
  { name: 'GuShen 谷神', href: 'https://gushen.lurus.cn' },
  { name: 'Lurus Creator', href: '/download' },
  { name: 'Lurus Switch', href: '/download' },
  { name: 'MemX', href: '/download#memx' },
]

const entrepreneurs = [
  { name: 'Lurus API', href: 'https://api.lurus.cn' },
  { name: 'GuShen Pro', href: 'https://gushen.lurus.cn' },
]

const builders = [
  { name: 'Kova SDK', href: '/for-builders' },
  { name: 'Lumen', href: '/for-builders' },
  { name: 'Lurus Identity', href: 'https://identity.lurus.cn' },
  { name: 'MemX SDK', href: '/download#memx' },
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

function isExternal(href: string) {
  return href.startsWith('http') || href.startsWith('mailto:')
}
</script>

<template>
  <footer class="footer-dark">
    <div class="max-w-7xl mx-auto px-6 sm:px-8 lg:px-12">
      <!-- Main grid -->
      <div class="footer-grid">
        <!-- Brand column -->
        <div class="footer-brand-col">
          <div class="footer-logo">
            <div class="footer-logo-mark">L</div>
            <span class="footer-logo-text">Lurus</span>
          </div>
          <p class="footer-brand-desc">
            AI 基础设施生态 — 从个人桌面到企业平台，为每一种可能提供底座。
          </p>
          <div class="footer-badge">
            <span class="footer-badge-dot"></span>
            服务稳定运行中
          </div>
        </div>

        <!-- Explorers -->
        <div>
          <h3 class="footer-col-heading">探索者</h3>
          <ul class="footer-link-list">
            <li v-for="item in explorers" :key="item.name">
              <a
                :href="item.href"
                :target="isExternal(item.href) ? '_blank' : undefined"
                :rel="isExternal(item.href) ? 'noopener noreferrer' : undefined"
                class="footer-link"
              >{{ item.name }}</a>
            </li>
          </ul>
        </div>

        <!-- Entrepreneurs + Builders combined -->
        <div>
          <h3 class="footer-col-heading">创业者</h3>
          <ul class="footer-link-list mb-6">
            <li v-for="item in entrepreneurs" :key="item.name">
              <a
                :href="item.href"
                :target="isExternal(item.href) ? '_blank' : undefined"
                :rel="isExternal(item.href) ? 'noopener noreferrer' : undefined"
                class="footer-link"
              >{{ item.name }}</a>
            </li>
          </ul>
          <h3 class="footer-col-heading">构建者</h3>
          <ul class="footer-link-list">
            <li v-for="item in builders" :key="item.name">
              <a
                :href="item.href"
                :target="isExternal(item.href) ? '_blank' : undefined"
                :rel="isExternal(item.href) ? 'noopener noreferrer' : undefined"
                class="footer-link"
              >{{ item.name }}</a>
            </li>
          </ul>
        </div>

        <!-- Resources + Company -->
        <div>
          <h3 class="footer-col-heading">资源</h3>
          <ul class="footer-link-list mb-6">
            <li v-for="item in resources" :key="item.name">
              <a
                :href="item.href"
                :target="isExternal(item.href) ? '_blank' : undefined"
                :rel="isExternal(item.href) ? 'noopener noreferrer' : undefined"
                class="footer-link"
              >{{ item.name }}</a>
            </li>
          </ul>
          <h3 class="footer-col-heading">公司</h3>
          <ul class="footer-link-list">
            <li v-for="item in company" :key="item.name">
              <router-link
                v-if="item.href.startsWith('/')"
                :to="item.href"
                class="footer-link"
              >{{ item.name }}</router-link>
              <a
                v-else
                :href="item.href"
                class="footer-link"
              >{{ item.name }}</a>
            </li>
          </ul>
        </div>
      </div>

      <!-- Bottom bar -->
      <div class="footer-bottom">
        <div class="footer-bottom-left">
          <span>&copy; {{ currentYear }} Lurus Technology. All rights reserved.</span>
          <a
            href="https://beian.miit.gov.cn/"
            target="_blank"
            rel="noopener noreferrer"
            class="footer-legal-link"
          >{{ ICP_NUMBER }}</a>
          <a
            href="https://www.beian.gov.cn/portal/registerSystemInfo?recordcode=37060002001239"
            target="_blank"
            rel="noopener noreferrer"
            class="footer-legal-link inline-flex items-center gap-1"
          >
            <svg class="w-3 h-3 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            鲁公网安备37060002001239号
          </a>
        </div>
      </div>
    </div>
  </footer>
</template>

<style scoped>
@reference "../../styles/main.css";

.footer-dark {
  background-color: var(--color-surface-raised);
  border-top: 1px solid var(--color-surface-border);
}

.footer-grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  gap: 48px;
  padding: 64px 0;
}

@media (max-width: 1023px) {
  .footer-grid {
    grid-template-columns: 1fr 1fr;
    gap: 40px;
  }
  .footer-brand-col {
    grid-column: span 2;
  }
}

@media (max-width: 639px) {
  .footer-grid {
    grid-template-columns: 1fr;
    gap: 32px;
    padding: 48px 0;
  }
  .footer-brand-col {
    grid-column: span 1;
  }
}

/* Brand */
.footer-brand-col {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 10px;
}

.footer-logo-mark {
  width: 36px;
  height: 36px;
  border-radius: 9px;
  background-color: var(--color-ochre);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #0D0B09;
  font-weight: 800;
  font-size: 1.125rem;
  letter-spacing: -0.02em;
  flex-shrink: 0;
}

.footer-logo-text {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-text-primary);
  letter-spacing: -0.02em;
}

.footer-brand-desc {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  line-height: 1.65;
  max-width: 280px;
}

.footer-badge {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.footer-badge-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: #4ade80;
  flex-shrink: 0;
}

/* Columns */
.footer-col-heading {
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: var(--color-text-secondary);
  margin-bottom: 14px;
}

.footer-link-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.footer-link {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  text-decoration: none;
  transition: color 0.15s;
}

.footer-link:hover {
  color: var(--color-text-secondary);
}

/* Bottom bar */
.footer-bottom {
  border-top: 1px solid var(--color-surface-border);
  padding: 24px 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

@media (min-width: 640px) {
  .footer-bottom {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
}

.footer-bottom-left {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 16px;
  font-size: 0.8rem;
  color: var(--color-text-muted);
}

.footer-legal-link {
  color: var(--color-text-muted);
  text-decoration: none;
  transition: color 0.15s;
}

.footer-legal-link:hover {
  color: var(--color-text-secondary);
}
</style>
