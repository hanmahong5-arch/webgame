<script setup lang="ts">
import { ref } from 'vue'

interface EcoNode {
  id: string
  name: string
  desc: string
  color: string
  layer: 'infra' | 'app'
  /** Grid position: col-start / row-start */
  gridArea: string
}

const nodes: EcoNode[] = [
  { id: 'identity', name: 'Identity', desc: '认证 · 计费 · 订阅', color: '#8B6B7D', layer: 'infra', gridArea: '1 / 1' },
  { id: 'api', name: 'Lurus API', desc: '50+ AI 模型统一网关', color: '#6B8BA4', layer: 'infra', gridArea: '1 / 2' },
  { id: 'memx', name: 'MemX', desc: '跨会话持久记忆', color: '#8B7A5C', layer: 'infra', gridArea: '1 / 3' },
  { id: 'notify', name: 'Notification', desc: '多渠道消息触达', color: '#A89B8B', layer: 'infra', gridArea: '1 / 4' },
  { id: 'acest', name: 'ACEST', desc: 'AI 桌面助手', color: '#5C7A8B', layer: 'app', gridArea: '2 / 1' },
  { id: 'switch', name: 'Switch', desc: 'AI 工具管理器', color: '#C67B5C', layer: 'app', gridArea: '2 / 2' },
  { id: 'lucrum', name: 'Lucrum', desc: 'AI 量化交易', color: '#7D8B6A', layer: 'app', gridArea: '2 / 3' },
]

const activeNode = ref<string | null>(null)

/** Connections between nodes (from infra to app) */
const connections: Array<{ from: string; to: string }> = [
  { from: 'identity', to: 'acest' },
  { from: 'identity', to: 'lucrum' },
  { from: 'identity', to: 'switch' },
  { from: 'api', to: 'acest' },
  { from: 'api', to: 'switch' },
  { from: 'api', to: 'lucrum' },
  { from: 'memx', to: 'acest' },
  { from: 'memx', to: 'switch' },
  { from: 'notify', to: 'lucrum' },
]

const isNodeHighlighted = (nodeId: string): boolean => {
  if (!activeNode.value) return true
  if (nodeId === activeNode.value) return true
  return connections.some(
    (c) =>
      (c.from === activeNode.value && c.to === nodeId) ||
      (c.to === activeNode.value && c.from === nodeId),
  )
}
</script>

<template>
  <section class="section-dark py-20" aria-label="Product Ecosystem">
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section header -->
      <div class="text-center mb-12 reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-[var(--color-text-primary)] mb-5 font-semibold">一个生态，无限可能</h2>
        <p class="text-phi-lg text-[var(--color-text-secondary)] max-w-2xl mx-auto">每个产品独立强大，组合使用更加强大</p>
      </div>

      <!-- Layer labels + node grid -->
      <div class="space-y-8 reveal-fade-up" @mouseleave="activeNode = null">
        <!-- Infrastructure layer -->
        <div>
          <p class="text-xs text-[var(--color-text-muted)] uppercase tracking-wider mb-5 font-semibold">基础设施层</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div
              v-for="node in nodes.filter(n => n.layer === 'infra')"
              :key="node.id"
              class="eco-node border border-[var(--color-surface-border)] rounded-xl p-6 transition-all duration-300 cursor-pointer"
              :class="isNodeHighlighted(node.id) ? 'bg-[var(--color-surface-raised)] opacity-100' : 'bg-[var(--color-surface-base)] opacity-30'"
              @mouseenter="activeNode = node.id"
            >
              <div class="flex items-center gap-2 mb-2">
                <div
                  class="w-3 h-3 rounded-full shrink-0"
                  :style="{ backgroundColor: node.color }"
                ></div>
                <span class="text-sm font-bold text-[var(--color-text-primary)]">{{ node.name }}</span>
              </div>
              <p class="text-xs text-[var(--color-text-muted)]">{{ node.desc }}</p>
            </div>
          </div>
        </div>

        <!-- Connection indicator -->
        <div class="flex justify-center">
          <div class="flex items-center gap-2 text-[var(--color-text-muted)]">
            <div class="w-8 h-px bg-[var(--color-surface-border)]"></div>
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
            </svg>
            <span class="text-xs">驱动</span>
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
            </svg>
            <div class="w-8 h-px bg-[var(--color-surface-border)]"></div>
          </div>
        </div>

        <!-- Application layer -->
        <div>
          <p class="text-xs text-[var(--color-text-muted)] uppercase tracking-wider mb-5 font-semibold">应用产品层</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div
              v-for="node in nodes.filter(n => n.layer === 'app')"
              :key="node.id"
              class="eco-node border border-[var(--color-surface-border)] rounded-xl p-6 transition-all duration-300 cursor-pointer"
              :class="isNodeHighlighted(node.id) ? 'bg-[var(--color-surface-raised)] opacity-100' : 'bg-[var(--color-surface-base)] opacity-30'"
              @mouseenter="activeNode = node.id"
            >
              <div class="flex items-center gap-2 mb-2">
                <div
                  class="w-3 h-3 rounded-full shrink-0"
                  :style="{ backgroundColor: node.color }"
                ></div>
                <span class="text-sm font-bold text-[var(--color-text-primary)]">{{ node.name }}</span>
              </div>
              <p class="text-xs text-[var(--color-text-muted)]">{{ node.desc }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Hint text -->
      <p class="text-center text-xs text-[var(--color-text-muted)] mt-6 reveal-fade-up">
        Hover 任意节点查看关联关系
      </p>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.eco-node {
  border-radius: 0.5rem;
}

.eco-node:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.3);
  border-color: var(--color-ochre);
}
</style>
