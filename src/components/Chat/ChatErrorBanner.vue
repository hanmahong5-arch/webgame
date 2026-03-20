<script setup lang="ts">
/**
 * ChatErrorBanner - Persistent error banner for Chat sidebar
 * Displayed when all API retry attempts are exhausted.
 * Provides specific guidance: what happened, what to do, and a fallback link.
 */

defineProps<{
  docsUrl: string
}>()

defineEmits<{
  retry: []
}>()
</script>

<template>
  <div class="error-banner" role="alert" aria-live="assertive">
    <div class="error-content">
      <svg class="warning-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path
          d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
      <div class="error-text">
        <p class="error-title">AI 对话暂时不可用</p>
        <p class="error-message">服务可能正在承受高负载。你可以稍后重试，或查看文档了解 API 状态。</p>
        <div class="error-actions">
          <a
            :href="docsUrl"
            class="docs-link"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="查看文档获取帮助"
          >
            <svg class="link-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path
                d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              />
            </svg>
            文档
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.error-banner {
  padding: 12px 16px;
  background: rgba(120, 53, 15, 0.15);
  border-bottom: 1px solid rgba(201, 162, 39, 0.25);
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-100%);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.error-content {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.warning-icon {
  width: 18px;
  height: 18px;
  color: var(--color-ochre);
  flex-shrink: 0;
  margin-top: 1px;
}

.error-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.error-title {
  margin: 0;
  font-size: 13px;
  font-weight: 600;
  color: var(--color-text-primary);
  line-height: 1.4;
}

.error-message {
  margin: 0;
  font-size: 12px;
  color: var(--color-text-secondary);
  line-height: 1.4;
}

.error-actions {
  display: flex;
  gap: 12px;
  margin-top: 4px;
}

.docs-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 500;
  color: var(--color-ochre);
  text-decoration: none;
  transition: opacity 0.2s ease;
}

.docs-link:hover {
  opacity: 0.8;
  text-decoration: underline;
}

.docs-link:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px var(--color-ochre);
  border-radius: 2px;
}

.link-icon {
  width: 13px;
  height: 13px;
}

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  .error-banner {
    animation: none;
  }
}
</style>
