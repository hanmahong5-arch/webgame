<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

interface ArchNode {
  id: string
  name: string
  sub?: string
  port?: string
  ns?: string
  detail: string
  color: string
}

interface ArchLayer {
  label: string
  sublabel: string
  nodes: ArchNode[]
}

const containerRef = ref<HTMLElement | null>(null)
const isVisible = ref(false)
const selectedNode = ref<ArchNode | null>(null)
let observer: IntersectionObserver | null = null

const layers: ArchLayer[] = [
  {
    label: '用户入口',
    sublabel: 'User Entry',
    nodes: [
      {
        id: 'www',
        name: 'www.lurus.cn',
        detail: '官方网站，营销落地页，Vue 3 SPA 静态构建，nginx 服务',
        color: '#C9A227',
      },
      {
        id: 'auth-ui',
        name: 'auth.lurus.cn',
        detail: 'Zitadel OIDC 统一认证中心，PKCE 授权流程入口',
        color: '#6B8BA4',
      },
      {
        id: 'lucrum-ui',
        name: 'gushen.lurus.cn',
        port: '8870',
        detail: 'AI 量化交易平台前端，实时行情与策略管理',
        color: '#7D8B6A',
      },
      {
        id: 'newapi-ui',
        name: 'newapi.lurus.cn',
        port: '3000',
        detail: 'API 管理控制台，Key 管理 / 用量监控 / 模型路由配置',
        color: '#8B6B7D',
      },
    ],
  },
  {
    label: '服务层',
    sublabel: 'Services',
    nodes: [
      {
        id: 'api-svc',
        name: 'lurus-api',
        sub: 'API Gateway',
        port: '8850',
        ns: 'lurus-system',
        detail: 'LLM 统一接入网关，支持 50+ 模型，OpenAI-compatible API，速率限制 + 计费',
        color: '#6B8BA4',
      },
      {
        id: 'platform-svc',
        name: 'lurus-platform',
        sub: 'Platform',
        port: '18104',
        ns: 'lurus-platform',
        detail: '统一账户认证与计费平台，/internal/v1/* 接口供各服务调用，含 Temporal 工作流',
        color: '#6B8BA4',
      },
      {
        id: 'lucrum-svc',
        name: 'lurus-lucrum',
        sub: 'Lucrum',
        port: '8870',
        ns: 'lucrum',
        detail: 'AI 量化引擎，Go + Python vnpy，实时策略执行与回测',
        color: '#7D8B6A',
      },
      {
        id: 'webmail-svc',
        name: 'lurus-webmail',
        sub: 'Webmail',
        port: '3000/3001',
        ns: 'lurus-webmail',
        detail: 'Stalwart 邮件服务 + Roundcube WebUI，mail.lurus.cn',
        color: '#C67B5C',
      },
    ],
  },
  {
    label: '基础设施',
    sublabel: 'Infrastructure',
    nodes: [
      {
        id: 'pg',
        name: 'PostgreSQL',
        sub: 'lurus-pg-rw',
        port: '5432',
        detail: 'CloudNativePG 集群，多 schema 隔离：lurus_api / identity / billing / lucrum / webmail',
        color: '#5A7A9B',
      },
      {
        id: 'redis',
        name: 'Redis',
        sub: 'redis.messaging',
        port: '6379',
        detail: 'DB 分配：api=0 / lucrum=1 / ratelimit=2 / identity=3，5min entitlement 缓存',
        color: '#C9A227',
      },
      {
        id: 'nats',
        name: 'NATS',
        sub: 'nats.messaging',
        port: '4222',
        detail: 'Streams: LLM_EVENTS / LUCRUM_EVENTS / IDENTITY_EVENTS，事件驱动通信',
        color: '#7D8B6A',
      },
      {
        id: 'minio',
        name: 'MinIO',
        sub: '100.79.24.40',
        port: '9000',
        detail: '对象存储，分 bucket 隔离，console 9001，用于文件上传与 release 分发',
        color: '#C67B5C',
      },
    ],
  },
]

function selectNode(node: ArchNode) {
  selectedNode.value = selectedNode.value?.id === node.id ? null : node
}

function handleKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') selectedNode.value = null
}

onMounted(() => {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    isVisible.value = true
    return
  }
  observer = new IntersectionObserver(
    ([entry]) => {
      if (entry.isIntersecting) {
        isVisible.value = true
        observer?.disconnect()
      }
    },
    { threshold: 0.1 }
  )
  if (containerRef.value) observer.observe(containerRef.value)
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  observer?.disconnect()
  observer = null
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <section class="py-fib-6 bg-cream-50" data-testid="tech-architecture">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <h2 class="text-phi-2xl font-hand font-bold text-ink-900 mb-fib-3 text-center reveal-fade-up">
        平台架构
      </h2>
      <p class="text-ink-400 text-sm text-center mb-fib-5 reveal-fade-up">
        点击节点查看详情 · K3s 单主节点部署 · 100.98.57.55
      </p>

      <div
        ref="containerRef"
        class="arch-container"
        :class="{ 'is-visible': isVisible }"
      >
        <!-- Layers -->
        <div
          v-for="(layer, layerIdx) in layers"
          :key="layer.label"
          class="arch-layer"
          :style="{ '--layer-delay': `${layerIdx * 150}ms` }"
        >
          <!-- Layer label -->
          <div class="arch-layer-label">
            <span class="arch-layer-label-main">{{ layer.label }}</span>
            <span class="arch-layer-label-sub">{{ layer.sublabel }}</span>
          </div>

          <!-- Nodes -->
          <div class="arch-nodes">
            <button
              v-for="(node, nodeIdx) in layer.nodes"
              :key="node.id"
              class="arch-node"
              :class="{ 'is-active': selectedNode?.id === node.id }"
              :style="{
                '--node-color': node.color,
                '--node-delay': `${layerIdx * 150 + nodeIdx * 60}ms`,
              }"
              @click="selectNode(node)"
              :aria-pressed="selectedNode?.id === node.id"
              :aria-label="`${node.name}${node.sub ? ' — ' + node.sub : ''}`"
            >
              <span class="arch-node-name">{{ node.name }}</span>
              <span v-if="node.sub" class="arch-node-sub">{{ node.sub }}</span>
              <span v-if="node.port" class="arch-node-port">:{{ node.port }}</span>
            </button>
          </div>

          <!-- Connector dots between layers -->
          <div v-if="layerIdx < layers.length - 1" class="arch-connector" aria-hidden="true">
            <span v-for="i in 5" :key="i" class="arch-connector-dot"></span>
          </div>
        </div>

        <!-- Detail Panel -->
        <Transition name="detail-panel">
          <div
            v-if="selectedNode"
            class="arch-detail"
            role="region"
            :aria-label="`${selectedNode.name} 详情`"
          >
            <div class="arch-detail-header" :style="{ '--node-color': selectedNode.color }">
              <div>
                <p class="arch-detail-name">{{ selectedNode.name }}</p>
                <p v-if="selectedNode.sub" class="arch-detail-sub">{{ selectedNode.sub }}</p>
              </div>
              <div class="arch-detail-meta">
                <span v-if="selectedNode.port" class="arch-detail-badge">
                  port {{ selectedNode.port }}
                </span>
                <span v-if="selectedNode.ns" class="arch-detail-badge">
                  ns: {{ selectedNode.ns }}
                </span>
              </div>
              <button
                class="arch-detail-close"
                @click="selectedNode = null"
                aria-label="关闭详情"
              >
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <p class="arch-detail-body">{{ selectedNode.detail }}</p>
          </div>
        </Transition>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

/* ── Container ── */
.arch-container {
  border: 2px solid var(--color-ink-300);
  background: var(--color-cream-100);
  padding: 2rem;
  border-radius: 3px 12px 5px 10px / 10px 5px 12px 3px;
}

/* ── Layer ── */
.arch-layer {
  opacity: 0;
  transform: translateY(12px);
}

.is-visible .arch-layer {
  animation: layer-in 0.5s ease-out forwards;
  animation-delay: var(--layer-delay);
}

/* ── Layer label ── */
.arch-layer-label {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.arch-layer-label-main {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--color-ink-400);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.arch-layer-label-sub {
  font-size: 0.65rem;
  color: var(--color-ink-200);
  font-style: italic;
}

/* ── Nodes row ── */
.arch-nodes {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 0.25rem;
}

/* ── Individual node ── */
.arch-node {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0.5rem 0.75rem;
  border: 2px solid var(--node-color);
  background: var(--color-cream-50);
  cursor: pointer;
  transition: background 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
  border-radius: 2px 8px 3px 9px / 9px 3px 8px 2px;
  min-width: 7rem;
  text-align: left;
}

.arch-node:hover {
  background: color-mix(in srgb, var(--node-color) 8%, var(--color-cream-50));
  transform: translateY(-2px);
  box-shadow: 2px 4px 0 var(--color-ink-100);
}

.arch-node.is-active {
  background: color-mix(in srgb, var(--node-color) 15%, var(--color-cream-50));
  box-shadow: 2px 4px 0 var(--node-color);
  transform: translateY(-2px);
}

.arch-node-name {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--node-color);
  line-height: 1.3;
  word-break: break-all;
}

.arch-node-sub {
  font-size: 0.65rem;
  color: var(--color-ink-400);
  margin-top: 1px;
}

.arch-node-port {
  font-size: 0.6rem;
  color: var(--color-ink-300);
  font-family: monospace;
  margin-top: 2px;
}

/* ── Connector ── */
.arch-connector {
  display: flex;
  justify-content: center;
  gap: 4px;
  padding: 0.4rem 0;
}

.arch-connector-dot {
  width: 3px;
  height: 3px;
  border-radius: 50%;
  background: var(--color-ink-200);
}

/* ── Detail Panel ── */
.arch-detail {
  margin-top: 1rem;
  border: 2px solid var(--node-color, var(--color-ink-100));
  background: var(--color-cream-50);
  border-radius: 2px 8px 3px 9px / 9px 3px 8px 2px;
  overflow: hidden;
}

.arch-detail-header {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  background: color-mix(in srgb, var(--node-color) 10%, var(--color-cream-100));
  border-bottom: 1px solid color-mix(in srgb, var(--node-color) 20%, var(--color-ink-100));
}

.arch-detail-name {
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--node-color);
  font-family: monospace;
}

.arch-detail-sub {
  font-size: 0.75rem;
  color: var(--color-ink-400);
  margin-top: 1px;
}

.arch-detail-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 0.375rem;
  margin-left: auto;
  flex-shrink: 0;
}

.arch-detail-badge {
  font-size: 0.65rem;
  padding: 1px 6px;
  border: 1px solid color-mix(in srgb, var(--node-color) 40%, transparent);
  color: var(--node-color);
  background: color-mix(in srgb, var(--node-color) 8%, var(--color-cream-50));
  border-radius: 2px;
  font-family: monospace;
  white-space: nowrap;
}

.arch-detail-close {
  flex-shrink: 0;
  width: 1.5rem;
  height: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-ink-300);
  transition: color 0.15s ease;
  margin-left: 0.25rem;
}

.arch-detail-close:hover {
  color: var(--color-ink-700);
}

.arch-detail-body {
  padding: 0.75rem 1rem;
  font-size: 0.8125rem;
  color: var(--color-ink-500);
  line-height: 1.6;
}

/* ── Animations ── */
@keyframes layer-in {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.detail-panel-enter-active,
.detail-panel-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.detail-panel-enter-from,
.detail-panel-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

@media (prefers-reduced-motion: reduce) {
  .arch-layer {
    opacity: 1;
    transform: none;
    animation: none !important;
  }

  .arch-node {
    transition: none;
  }

  .detail-panel-enter-active,
  .detail-panel-leave-active {
    transition: none;
  }
}
</style>
