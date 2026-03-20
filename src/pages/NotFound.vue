<script setup lang="ts">
/**
 * 404 Not Found page
 * Shows the attempted path so users know what went wrong,
 * plus clear navigation options to recover.
 */
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

const attemptedPath = computed(() => route.fullPath)

const suggestedPages = [
  { label: '首页', path: '/', icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6' },
  { label: '下载中心', path: '/download', icon: 'M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4' },
  { label: '定价', path: '/pricing', icon: 'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z' },
  { label: '文档', path: 'https://docs.lurus.cn', icon: 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253' },
]

function goBack() {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/')
  }
}

function navigateTo(path: string) {
  if (path.startsWith('http')) {
    window.open(path, '_blank', 'noopener')
  } else {
    router.push(path)
  }
}
</script>

<template>
  <div class="not-found">
    <div class="not-found-content">
      <!-- 404 visual -->
      <div class="error-code" aria-hidden="true">404</div>

      <h1 class="not-found-title">页面未找到</h1>

      <p class="not-found-desc">
        路径 <code class="attempted-path">{{ attemptedPath }}</code> 不存在。
        该页面可能已被移动，或链接有误。
      </p>

      <!-- Primary actions -->
      <div class="primary-actions">
        <button class="btn-primary" @click="goBack">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <path d="M10 19l-7-7m0 0l7-7m-7 7h18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
          返回上页
        </button>
        <button class="btn-outline" @click="router.push('/')">
          回到首页
        </button>
      </div>

      <!-- Quick links -->
      <div class="suggested-section">
        <p class="suggested-label">或者尝试以下页面：</p>
        <div class="suggested-links">
          <button
            v-for="page in suggestedPages"
            :key="page.path"
            class="suggested-link"
            @click="navigateTo(page.path)"
          >
            <svg class="suggested-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path :d="page.icon" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
            {{ page.label }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";

.not-found {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 64px);
  padding: 32px 16px;
  text-align: center;
}

.not-found-content {
  max-width: 480px;
}

.error-code {
  font-size: clamp(80px, 15vw, 140px);
  font-weight: 800;
  line-height: 1;
  color: var(--color-surface-border);
  letter-spacing: -0.04em;
  margin-bottom: 8px;
  user-select: none;
}

.not-found-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 12px;
}

.not-found-desc {
  font-size: 14px;
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin: 0 0 28px;
}

.attempted-path {
  display: inline-block;
  padding: 2px 8px;
  background: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 4px;
  font-family: 'Cascadia Code', 'Fira Code', monospace;
  font-size: 13px;
  color: var(--color-ochre);
  word-break: break-all;
}

.primary-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-bottom: 36px;
  flex-wrap: wrap;
}

.primary-actions .btn-primary,
.primary-actions .btn-outline {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  font-size: 14px;
}

.btn-icon {
  width: 16px;
  height: 16px;
}

.suggested-section {
  padding-top: 24px;
  border-top: 1px solid var(--color-surface-border);
}

.suggested-label {
  font-size: 12px;
  color: var(--color-text-muted);
  margin: 0 0 12px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.suggested-links {
  display: flex;
  justify-content: center;
  gap: 8px;
  flex-wrap: wrap;
}

.suggested-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  font-size: 13px;
  color: var(--color-text-secondary);
  background: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  border-radius: 8px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.suggested-link:hover {
  border-color: var(--color-ochre);
  color: var(--color-text-primary);
}

.suggested-link:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px var(--color-ochre);
}

.suggested-icon {
  width: 16px;
  height: 16px;
}
</style>
