<script setup lang="ts">
import { ref, defineAsyncComponent } from 'vue'
import { RouterLink } from 'vue-router'
import { useAuth } from '../composables/useAuth'
import { useTracking } from '../composables/useTracking'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useCountUp } from '../composables/useCountUp'
import { stats } from '../data/stats'

// Lazy-load all diagram components — each becomes its own chunk, loaded in parallel
// without blocking initial parse. All have their own IntersectionObserver for animation timing.
const ApiFlowDiagram    = defineAsyncComponent(() => import('../components/Illustrations/ApiFlowDiagram.vue'))
const KovaDiagram       = defineAsyncComponent(() => import('../components/Illustrations/KovaDiagram.vue'))
const LucrumChartDiagram = defineAsyncComponent(() => import('../components/Illustrations/LucrumChartDiagram.vue'))
const MemxGraphDiagram  = defineAsyncComponent(() => import('../components/Illustrations/MemxGraphDiagram.vue'))
const CreatorDiagram    = defineAsyncComponent(() => import('../components/Illustrations/CreatorDiagram.vue'))
const SwitchDiagram     = defineAsyncComponent(() => import('../components/Illustrations/SwitchDiagram.vue'))
const LumenDiagram      = defineAsyncComponent(() => import('../components/Illustrations/LumenDiagram.vue'))

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { login } = useAuth()
const { track } = useTracking()

// Hero product tags
const heroTags = [
  { name: 'Lurus API', color: '#4A9EFF', href: 'https://api.lurus.cn' },
  { name: 'Kova',      color: '#B08EFF', href: '/for-builders' },
  { name: 'Lucrum',   color: '#7AFF89', href: 'https://gushen.lurus.cn' },
  { name: 'Creator',  color: '#FFB86C', href: '/download' },
  { name: 'Lumen',    color: '#FFE566', href: '/for-builders' },
  { name: 'Switch',   color: '#FF8C69', href: '/download' },
  { name: 'MemX',     color: '#4AFFCB', href: '/download#memx' },
]

// Stats count-up refs
const statRef0 = ref<HTMLElement | null>(null)
const statRef1 = ref<HTMLElement | null>(null)
const statRef2 = ref<HTMLElement | null>(null)
const statRef3 = ref<HTMLElement | null>(null)
const { displayValue: statVal0 } = useCountUp(statRef0, stats[0].value)
const { displayValue: statVal1 } = useCountUp(statRef1, stats[1].value)
const { displayValue: statVal2 } = useCountUp(statRef2, stats[2].value)
const { displayValue: statVal3 } = useCountUp(statRef3, stats[3].value)
const statValues = [statVal0, statVal1, statVal2, statVal3]
const statRefs  = [statRef0, statRef1, statRef2, statRef3]

// Product feature lists
const apiFeatures = [
  'OpenAI SDK 直接兼容，零改造成本',
  '自动负载均衡 & 智能故障转移',
  '统一账单，多模型用量一览',
]

const kovaFeatures = [
  'WAL 持久化状态，掉电不丢失',
  'Rust 零 GC 延迟，μs 级响应',
  'Agent Loop 断点自动恢复',
]

const lucrumFeatures = [
  '自然语言描述 → AI 生成策略代码',
  '实时行情接入，毫秒级数据更新',
  '内置回测引擎，一键历史验证',
]

const memxFeatures = [
  '跨会话持久记忆，零重复上下文',
  '语义向量检索，精准召回历史',
  'SDK / REST API，3 行代码接入',
]

// API code example
const apiCode = `curl https://api.lurus.cn/v1/chat/completions \\
  -H "Authorization: Bearer $LURUS_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "claude-3-5-sonnet",
    "messages": [{"role":"user","content":"Hello"}]
  }'`

// Path cards
const paths = [
  {
    audience: '个人探索者',
    action: '下载桌面工具',
    description: '免费体验 Creator、Switch、MemX 全套桌面工具，AI 融入每个工作场景',
    href: '/for-explorers',
    color: '#FF8C69',
    badge: '免费',
  },
  {
    audience: '创业者',
    action: '接入 Lurus API',
    description: '3 分钟，50+ 模型，按量付费，即刻上线 AI 产品',
    href: '/for-entrepreneurs',
    color: '#4A9EFF',
    badge: '按量付费',
  },
  {
    audience: '技术构建者',
    action: '探索开发者工具',
    description: 'Kova SDK · Lumen · MemX · Identity，一站式 AI 基础设施',
    href: '/for-builders',
    color: '#B08EFF',
    badge: '开发者',
  },
]

// Switch & Lumen features
const switchFeatures = ['Claude Code / Codex / Gemini CLI 统一管理', 'API Key 集中分发', 'MCP 预设一键同步', '代理与环境快照']
const lumenFeatures  = ['实时 Agent 追踪', '断点调试注入', '状态树可视化', 'CLI 日志导出']
</script>

<template>
  <div ref="pageRef">

    <!-- S1: Hero -->
    <section class="home-hero" aria-label="Hero">
      <div class="hero-grid" aria-hidden="true"></div>
      <!-- Multi-color neon aura spots -->
      <div class="hero-aura" aria-hidden="true">
        <div class="hero-aura-spot" style="background:#4A9EFF;top:5%;left:8%;width:420px;height:320px;"></div>
        <div class="hero-aura-spot" style="background:#B08EFF;top:20%;right:10%;width:360px;height:280px;"></div>
        <div class="hero-aura-spot" style="background:#7AFF89;bottom:10%;left:20%;width:300px;height:260px;"></div>
        <div class="hero-aura-spot" style="background:#4AFFCB;bottom:5%;right:25%;width:280px;height:220px;"></div>
      </div>

      <div class="relative max-w-5xl mx-auto px-6 sm:px-8 lg:px-12 py-32 sm:py-44 text-center">
        <div class="hero-eyebrow reveal-fade-up">
          <span class="hero-eyebrow-dot"></span>
          AI 基础设施生态 · 7 款产品覆盖全场景
        </div>

        <h1 class="hero-title reveal-fade-up">
          构建下一代 AI，<br>
          <span class="text-gradient-gold">从这里开始</span>
        </h1>

        <p class="hero-subtitle reveal-fade-up">
          一套完整的 AI 基础设施 —— 从 API 接入到 Agent 运行，无需拼凑，开箱即用。
        </p>

        <div class="hero-cta-row reveal-fade-up">
          <button
            class="btn-primary"
            style="padding:12px 32px;font-size:1rem"
            @click="track('cta_click', { label: 'hero_register' }); login({ prompt: 'create' })"
          >
            免费开始 →
          </button>
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-outline"
            style="padding:12px 32px;font-size:1rem"
            @click="track('cta_click', { label: 'hero_docs' })"
          >
            查看文档
          </a>
        </div>

        <!-- 7-color product tag cloud -->
        <div class="hero-product-tags reveal-fade-up" role="list" aria-label="产品线">
          <component
            v-for="tag in heroTags"
            :is="tag.href.startsWith('http') ? 'a' : RouterLink"
            :key="tag.name"
            :href="tag.href.startsWith('http') ? tag.href : undefined"
            :to="!tag.href.startsWith('http') ? tag.href : undefined"
            :target="tag.href.startsWith('http') ? '_blank' : undefined"
            :rel="tag.href.startsWith('http') ? 'noopener noreferrer' : undefined"
            class="product-tag"
            :style="{ '--tag-color': tag.color }"
            role="listitem"
            @click="track('product_tag_click', { label: tag.name })"
          >
            <span class="product-tag-dot" :style="{ background: tag.color }"></span>
            {{ tag.name }}
          </component>
        </div>
      </div>
    </section>

    <!-- S2: Stats bar -->
    <section class="stats-bar" aria-label="平台数据">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="stats-grid">
          <div
            v-for="(stat, i) in stats"
            :key="stat.label"
            class="stat-item"
          >
            <span
              :ref="(el) => { statRefs[i].value = el as HTMLElement | null }"
              class="stat-value"
              :class="stat.color"
            >{{ statValues[i].value }}</span>
            <span class="stat-label">{{ stat.label }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- S3: Core Triangle — How It Fits Together -->
    <section class="section-dark py-20" aria-label="核心架构">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <h2 class="home-section-title">三大支柱，完整闭环</h2>
          <p class="home-section-subtitle">接入模型 → 运行 Agent → 管理工具，一个平台全覆盖</p>
        </div>

        <div class="triad-grid reveal-fade-up">
          <a href="https://api.lurus.cn" target="_blank" rel="noopener noreferrer" class="triad-node" style="--node-color:#4A9EFF">
            <div class="triad-icon">
              <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="#4A9EFF" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </div>
            <h3 class="triad-title">Lurus API</h3>
            <p class="triad-tagline">50+ AI 模型统一网关</p>
            <p class="triad-desc">一个 Key，OpenAI 兼容，自动故障转移</p>
          </a>

          <div class="triad-connector" aria-hidden="true">
            <svg width="40" height="24" viewBox="0 0 40 24" fill="none"><path d="M0 12h40" stroke="var(--color-surface-border)" stroke-width="1.5" stroke-dasharray="4 3"/><path d="M32 6l8 6-8 6" stroke="var(--color-text-muted)" stroke-width="1.5" fill="none" opacity="0.4"/></svg>
          </div>

          <router-link to="/for-builders" class="triad-node" style="--node-color:#B08EFF">
            <div class="triad-icon">
              <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="#B08EFF" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 3H7a2 2 0 00-2 2v2M9 3h6M9 3v2m6-2h2a2 2 0 012 2v2m0 0V7m0 0h2M3 9v6m0 0v2a2 2 0 002 2h2m-4-4h2M21 9v6m0 0v2a2 2 0 01-2 2h-2m4-4h-2M9 21h6M9 21v-2m6 2v-2" />
              </svg>
            </div>
            <h3 class="triad-title">Kova</h3>
            <p class="triad-tagline">Agent 持久执行引擎</p>
            <p class="triad-desc">Rust WAL，崩溃自动恢复，零 GC</p>
          </router-link>

          <div class="triad-connector" aria-hidden="true">
            <svg width="40" height="24" viewBox="0 0 40 24" fill="none"><path d="M0 12h40" stroke="var(--color-surface-border)" stroke-width="1.5" stroke-dasharray="4 3"/><path d="M32 6l8 6-8 6" stroke="var(--color-text-muted)" stroke-width="1.5" fill="none" opacity="0.4"/></svg>
          </div>

          <router-link to="/download" class="triad-node" style="--node-color:#FF8C69">
            <div class="triad-icon">
              <svg width="28" height="28" fill="none" viewBox="0 0 24 24" stroke="#FF8C69" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </div>
            <h3 class="triad-title">Switch</h3>
            <p class="triad-tagline">AI 工具管理器</p>
            <p class="triad-desc">管理所有 AI CLI 的配置、密钥、MCP</p>
          </router-link>
        </div>
      </div>
    </section>

    <!-- S4: Lurus API -->
    <section class="section-dark-raised py-24" aria-label="Lurus API">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="product-section-grid reveal-fade-up">
          <!-- Copy -->
          <div class="product-copy">
            <span class="neon-badge" style="color:#4A9EFF">
              <span class="neon-dot" style="color:#4A9EFF"></span>
              LLM 统一网关
            </span>
            <h2 class="product-headline">
              一个 Key，<br><span style="color:#4A9EFF">接入 50+ 模型</span>
            </h2>
            <p class="product-desc">
              OpenAI 兼容接口，修改 base_url 即可切换到 Lurus 网关。自动负载均衡、故障转移、统一账单，企业级稳定性开箱即用。
            </p>
            <ul class="product-feature-list" role="list">
              <li v-for="feat in apiFeatures" :key="feat">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#4A9EFF" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>
            <a
              href="https://api.lurus.cn"
              target="_blank"
              rel="noopener noreferrer"
              class="btn-primary"
              style="align-self:flex-start;padding:10px 28px"
              @click="track('cta_click', { label: 'api_section' })"
            >
              注册获取 API Key →
            </a>
          </div>

          <!-- Diagram + code stacked -->
          <div class="api-right-col">
            <div class="diagram-wrapper">
              <ApiFlowDiagram />
            </div>
            <!-- Inline code preview -->
            <div class="api-code-block">
              <div class="api-code-bar">
                <span class="api-code-lang">bash</span>
              </div>
              <pre class="api-code-pre">{{ apiCode }}</pre>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- S4: Kova -->
    <section class="section-dark py-24" aria-label="Kova Agent SDK">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="product-section-grid product-section-grid--reverse reveal-fade-up">
          <!-- Copy first in DOM (a11y + mobile) -->
          <div class="product-copy">
            <span class="neon-badge" style="color:#B08EFF">
              <span class="neon-dot" style="color:#B08EFF"></span>
              Rust Agent SDK
            </span>
            <h2 class="product-headline">
              崩溃无所畏惧，<br><span style="color:#B08EFF">自动断点续跑</span>
            </h2>
            <p class="product-desc">
              Kova 将 WAL 预写日志引入 Agent 执行引擎。掉电重启后从断点继续，Rust 零 GC 保障 μs 级确定性响应，生产环境真正可靠。
            </p>
            <ul class="product-feature-list" role="list">
              <li v-for="feat in kovaFeatures" :key="feat">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#B08EFF" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>
            <a
              href="/for-builders"
              class="btn-outline"
              style="align-self:flex-start;padding:10px 28px;border-color:#B08EFF;color:#B08EFF"
              @click="track('cta_click', { label: 'kova_section' })"
            >
              了解 Kova →
            </a>
          </div>
          <!-- Diagram second in DOM, CSS order:-1 moves it visually left -->
          <div class="diagram-wrapper">
            <KovaDiagram />
          </div>
        </div>
      </div>
    </section>

    <!-- S5: Lucrum -->
    <section class="section-dark-raised py-24" aria-label="Lucrum AI量化交易">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="product-section-grid reveal-fade-up">
          <!-- Copy -->
          <div class="product-copy">
            <span class="neon-badge" style="color:#7AFF89">
              <span class="neon-dot" style="color:#7AFF89"></span>
              AI 量化交易
            </span>
            <h2 class="product-headline">
              自然语言描述，<br><span style="color:#7AFF89">AI 生成策略</span>
            </h2>
            <p class="product-desc">
              告别手写量化代码。用中文描述你的交易逻辑，谷神 AI 自动生成可执行策略，内置回测引擎即时验证，风险控制全自动化。
            </p>
            <ul class="product-feature-list" role="list">
              <li v-for="feat in lucrumFeatures" :key="feat">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#7AFF89" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>
            <a
              href="https://gushen.lurus.cn"
              target="_blank"
              rel="noopener noreferrer"
              class="btn-primary"
              style="align-self:flex-start;padding:10px 28px;background:#7AFF89;color:#0D0B09"
              @click="track('cta_click', { label: 'lucrum_section' })"
            >
              进入谷神 →
            </a>
          </div>

          <!-- Diagram -->
          <div class="diagram-wrapper">
            <LucrumChartDiagram />
          </div>
        </div>
      </div>
    </section>

    <!-- S6: MemX -->
    <section class="section-dark py-24" aria-label="MemX AI记忆引擎">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="product-section-grid product-section-grid--reverse reveal-fade-up">
          <!-- Copy first in DOM (a11y + mobile) -->
          <div class="product-copy">
            <span class="neon-badge" style="color:#4AFFCB">
              <span class="neon-dot" style="color:#4AFFCB"></span>
              AI 记忆引擎
            </span>
            <h2 class="product-headline">
              AI 真正记住你，<br><span style="color:#4AFFCB">无需重复上下文</span>
            </h2>
            <p class="product-desc">
              MemX 为 AI 建立持久记忆层。你的偏好、历史上下文跨工具跨会话保存，下次对话直接延续 —— 不再从零开始解释。
            </p>
            <ul class="product-feature-list" role="list">
              <li v-for="feat in memxFeatures" :key="feat">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#4AFFCB" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>
            <a
              href="/download#memx"
              class="btn-outline"
              style="align-self:flex-start;padding:10px 28px;border-color:#4AFFCB;color:#4AFFCB"
              @click="track('cta_click', { label: 'memx_section' })"
            >
              下载 MemX →
            </a>
          </div>
          <!-- Diagram second in DOM, CSS order:-1 moves it visually left -->
          <div class="diagram-wrapper">
            <MemxGraphDiagram />
          </div>
        </div>
      </div>
    </section>

    <!-- S7: Lurus Creator (centered + full-width pipeline) -->
    <section class="section-dark-raised py-24" aria-label="Lurus Creator内容工厂">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <span class="neon-badge" style="color:#FFB86C">
            <span class="neon-dot" style="color:#FFB86C"></span>
            桌面内容工厂
          </span>
          <h2 class="product-headline" style="margin-top:16px">
            视频 → AI 转录 → 多平台，<br>
            <span style="color:#FFB86C">3 步完成发布</span>
          </h2>
          <p class="product-desc" style="margin:0 auto 32px;text-align:center">
            yt-dlp 抓取任意视频，Whisper 高精度转录，LLM 优化文案，一键同步到微信视频号、抖音、YouTube —— 全程无需手动操作。
          </p>
        </div>

        <!-- Full-width pipeline diagram -->
        <div class="creator-diagram-wrapper reveal-fade-up">
          <CreatorDiagram />
        </div>

        <div class="text-center mt-10 reveal-fade-up">
          <a
            href="/download"
            class="btn-primary"
            style="padding:12px 36px;font-size:1rem;background:#FFB86C;color:#0D0B09"
            @click="track('cta_click', { label: 'creator_section' })"
          >
            下载 Lurus Creator →
          </a>
        </div>
      </div>
    </section>

    <!-- S8: Switch + Lumen dual cards -->
    <section class="section-dark py-24" aria-label="Lurus Switch 和 Lumen">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <h2 class="home-section-title">
            开发者工具箱
          </h2>
          <p class="home-section-subtitle">
            Switch 统一管理 AI 工具，Lumen 让 Agent 执行透明可控
          </p>
        </div>

        <div class="dual-product-grid reveal-fade-up">
          <!-- Lurus Switch card -->
          <div class="dual-card" :style="{ '--card-accent': '#FF8C69' }">
            <span class="neon-badge" style="color:#FF8C69;margin-bottom:16px;display:inline-flex">
              <span class="neon-dot" style="color:#FF8C69"></span>
              AI 工具管理器
            </span>
            <h3 class="dual-card-title">Lurus Switch</h3>
            <p class="dual-card-desc">Claude Code、Codex、Gemini CLI —— 所有 AI 命令行工具的配置、密钥、MCP，一个面板搞定</p>
            <div class="dual-diagram-wrapper">
              <SwitchDiagram />
            </div>
            <ul class="product-feature-list" style="margin-bottom:20px" role="list">
              <li v-for="feat in switchFeatures" :key="feat">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#FF8C69" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>
            <a
              href="/download"
              class="btn-outline"
              style="padding:8px 20px;font-size:0.875rem;border-color:#FF8C69;color:#FF8C69"
              @click="track('cta_click', { label: 'switch_card' })"
            >
              下载 Switch →
            </a>
          </div>

          <!-- Lumen card -->
          <div class="dual-card" :style="{ '--card-accent': '#FFE566' }">
            <span class="neon-badge" style="color:#FFE566;margin-bottom:16px;display:inline-flex">
              <span class="neon-dot" style="color:#FFE566"></span>
              Agent 调试器
            </span>
            <h3 class="dual-card-title">Lumen</h3>
            <p class="dual-card-desc">Agent 开发者专用调试 CLI，实时可视化执行轨迹，断点注入与状态树检查一体化</p>
            <div class="dual-diagram-wrapper">
              <LumenDiagram />
            </div>
            <ul class="product-feature-list" style="margin-bottom:20px" role="list">
              <li v-for="feat in lumenFeatures" :key="feat">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#FFE566" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>
            <a
              href="/for-builders"
              class="btn-outline"
              style="padding:8px 20px;font-size:0.875rem;border-color:#FFE566;color:#FFE566"
              @click="track('cta_click', { label: 'lumen_card' })"
            >
              了解 Lumen →
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- S9: Path Cards -->
    <section class="section-dark-raised py-24" aria-label="选择你的起点">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-16 reveal-fade-up">
          <h2 class="home-section-title">选择你的起点</h2>
          <p class="home-section-subtitle">无论你是探索者、创业者还是构建者，都有专属方案</p>
        </div>

        <div class="paths-grid reveal-fade-up">
          <router-link
            v-for="path in paths"
            :key="path.audience"
            :to="path.href"
            class="path-card group"
            :style="{ '--path-color': path.color }"
            @click="track('cta_click', { label: `path_${path.audience}` })"
          >
            <div class="path-card-top-line" aria-hidden="true"></div>
            <span class="path-badge">{{ path.badge }}</span>
            <p class="path-audience">{{ path.audience }}</p>
            <p class="path-action">{{ path.action }}</p>
            <p class="path-desc">{{ path.description }}</p>
            <span class="path-arrow" aria-hidden="true">→</span>
          </router-link>
        </div>
      </div>
    </section>

    <!-- S10: Final CTA -->
    <section class="section-dark py-36 text-center" aria-label="立即开始">
      <div class="max-w-3xl mx-auto px-6 reveal-fade-up">
        <h2 class="home-section-title" style="font-size:clamp(2.25rem,5vw,3.25rem)">
          准备好了吗？
        </h2>
        <p class="home-section-subtitle mt-4 mb-10">
          加入开发者，用 7 款产品构建你的下一代 AI 应用
        </p>
        <div class="flex flex-wrap items-center justify-center gap-4">
          <button
            class="btn-primary"
            style="padding:14px 40px;font-size:1.1rem"
            @click="track('cta_click', { label: 'final_cta' }); login({ prompt: 'create' })"
          >
            免费注册 →
          </button>
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-outline"
            style="padding:14px 40px;font-size:1.1rem"
          >
            查看文档
          </a>
        </div>
        <div class="cta-trust-row">
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            数据安全加密
          </span>
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            无需信用卡
          </span>
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            即时开通
          </span>
        </div>
      </div>
    </section>

  </div>
</template>

<style scoped>
@reference "../styles/main.css";

/* ── Hero ─────────────────────────────────────── */
.home-hero {
  position: relative;
  overflow: hidden;
  background-color: var(--color-surface-base);
}

.hero-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.018) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.018) 1px, transparent 1px);
  background-size: 52px 52px;
  pointer-events: none;
}

.hero-aura {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.hero-aura-spot {
  position: absolute;
  border-radius: 50%;
  filter: blur(100px);
  opacity: 0.07;
}

.hero-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 16px;
  border-radius: 999px;
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  color: var(--color-text-secondary);
  font-size: 0.78rem;
  margin-bottom: 28px;
}

.hero-eyebrow-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: var(--color-ochre);
  flex-shrink: 0;
  animation: dot-pulse 2s ease-in-out infinite;
}

@keyframes dot-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

.hero-title {
  font-size: clamp(2.5rem, 5vw, 4.5rem);
  font-weight: 800;
  color: var(--color-text-primary);
  line-height: 1.08;
  letter-spacing: -0.03em;
  margin-bottom: 20px;
}

.hero-subtitle {
  color: var(--color-text-secondary);
  font-size: 1.15rem;
  max-width: 520px;
  margin: 0 auto 36px;
  line-height: 1.65;
}

.hero-cta-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin-bottom: 52px;
}

/* Product tag cloud */
.hero-product-tags {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.product-tag {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 7px 16px;
  border-radius: 999px;
  border: 1px solid var(--tag-color, var(--color-surface-border));
  background: color-mix(in srgb, var(--tag-color, transparent) 8%, transparent);
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: background-color 0.2s ease, color 0.2s ease, transform 0.15s ease;
  cursor: pointer;
}

.product-tag:hover {
  background: color-mix(in srgb, var(--tag-color, transparent) 18%, transparent);
  color: var(--color-text-primary);
  transform: translateY(-1px);
}

.product-tag-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  flex-shrink: 0;
  animation: dot-pulse 2.5s ease-in-out infinite;
}

/* ── Stats ────────────────────────────────────── */
.stats-bar {
  background-color: var(--color-surface-raised);
  border-top: 1px solid var(--color-surface-border);
  border-bottom: 1px solid var(--color-surface-border);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  background-color: var(--color-surface-border);
  gap: 1px;
}

@media (min-width: 640px) {
  .stats-grid { grid-template-columns: repeat(4, 1fr); }
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 28px 16px;
  background-color: var(--color-surface-raised);
}

.stat-value {
  font-size: 2rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  line-height: 1;
  font-variant-numeric: tabular-nums;
}

.stat-label {
  font-size: 0.8rem;
  color: var(--color-text-muted);
}

/* ── Section headings ─────────────────────────── */
.home-section-title {
  font-size: clamp(2rem, 4.5vw, 3rem);
  font-weight: 800;
  color: var(--color-text-primary);
  letter-spacing: -0.03em;
  line-height: 1.1;
}

.home-section-subtitle {
  font-size: 1.1rem;
  color: var(--color-text-secondary);
  max-width: 520px;
  margin: 12px auto 0;
  line-height: 1.65;
}

/* ── API section right column ─────────────────── */
.api-right-col {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.api-code-block {
  background-color: #0A0908;
  border: 1px solid var(--color-surface-border);
  border-radius: 10px;
  overflow: hidden;
}

.api-code-bar {
  display: flex;
  align-items: center;
  padding: 8px 14px;
  border-bottom: 1px solid var(--color-surface-border);
  background-color: rgba(255,255,255,0.02);
}

.api-code-lang {
  font-family: ui-monospace, monospace;
  font-size: 0.72rem;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.api-code-pre {
  margin: 0;
  padding: 16px 18px;
  font-family: ui-monospace, 'Cascadia Code', Consolas, monospace;
  font-size: 0.78rem;
  line-height: 1.7;
  color: var(--color-text-secondary);
  white-space: pre;
  overflow-x: auto;
}

/* ── Creator full-width diagram ─────────────────── */
.creator-diagram-wrapper {
  width: 100%;
  aspect-ratio: 16 / 5;
  max-height: 200px;
}

.creator-diagram-wrapper svg {
  width: 100%;
  height: 100%;
}

/* ── Dual cards ──────────────────────────────── */
.dual-card-title {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--color-text-primary);
  letter-spacing: -0.02em;
  margin-bottom: 8px;
}

.dual-card-desc {
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin-bottom: 20px;
}

.dual-diagram-wrapper {
  aspect-ratio: 16 / 9;
  width: 100%;
  margin-bottom: 20px;
}

.dual-diagram-wrapper svg {
  width: 100%;
  height: 100%;
}


/* ── Path cards ───────────────────────────────── */
.paths-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

@media (max-width: 767px) {
  .paths-grid { grid-template-columns: 1fr; }
}

.path-card {
  position: relative;
  display: block;
  padding: 28px 24px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  border-radius: 16px;
  overflow: hidden;
  text-decoration: none;
  transition: border-color 0.2s, transform 0.2s;
  cursor: pointer;
}

.path-card:hover {
  border-color: var(--path-color, var(--color-ochre));
  transform: translateY(-2px);
}

.path-card-top-line {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--path-color, var(--color-ochre)), transparent);
  opacity: 0;
  transition: opacity 0.2s;
}

.path-card:hover .path-card-top-line { opacity: 1; }

.path-badge {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 999px;
  font-size: 0.68rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  color: var(--path-color, var(--color-ochre));
  border: 1px solid var(--path-color, var(--color-ochre));
  margin-bottom: 16px;
  opacity: 0.75;
}

.path-audience {
  font-size: 0.78rem;
  color: var(--color-text-muted);
  margin-bottom: 6px;
}

.path-action {
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 8px;
  line-height: 1.3;
}

.path-desc {
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  line-height: 1.55;
}

.path-arrow {
  display: block;
  margin-top: 20px;
  color: var(--color-text-muted);
  font-size: 1rem;
  transition: color 0.2s, transform 0.2s;
}

.path-card:hover .path-arrow {
  color: var(--path-color, var(--color-ochre));
  transform: translateX(5px);
}

/* ── Final CTA ────────────────────────────────── */
.cta-trust-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 24px;
  margin-top: 28px;
}

.cta-trust-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

/* ── Core Triad ──────────────────────────────── */
.triad-grid {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0;
}

.triad-node {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 28px 24px;
  border-radius: 16px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  text-decoration: none;
  transition: border-color 0.2s, transform 0.2s;
  cursor: pointer;
  min-width: 180px;
}

.triad-node:hover {
  border-color: var(--node-color, var(--color-ochre));
  transform: translateY(-3px);
}

.triad-icon {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  background: color-mix(in srgb, var(--node-color, transparent) 10%, transparent);
  border: 1px solid color-mix(in srgb, var(--node-color, transparent) 20%, transparent);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 14px;
}

.triad-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.triad-tagline {
  font-size: 0.78rem;
  color: var(--node-color, var(--color-text-muted));
  font-weight: 500;
  margin-bottom: 8px;
}

.triad-desc {
  font-size: 0.78rem;
  color: var(--color-text-muted);
  line-height: 1.5;
  max-width: 180px;
}

.triad-connector {
  flex-shrink: 0;
  padding: 0 8px;
}

@media (max-width: 767px) {
  .triad-grid {
    flex-direction: column;
    gap: 12px;
  }
  .triad-connector {
    transform: rotate(90deg);
    padding: 0;
  }
  .triad-node {
    min-width: unset;
    width: 100%;
    max-width: 280px;
  }
}

/* ── Reverse layout: diagram visually left, copy right ────── */
/* DOM order is copy-first for a11y; CSS moves diagram to left on desktop */
.product-section-grid--reverse > .diagram-wrapper {
  order: -1;
}

/* Mobile: single column — diagram falls naturally after copy (DOM order) */
@media (max-width: 767px) {
  .product-section-grid--reverse > .diagram-wrapper {
    order: 0;
  }
}
</style>
