<script setup lang="ts">
import { ref, defineAsyncComponent } from 'vue'
import { RouterLink } from 'vue-router'
import { useAuth } from '../composables/useAuth'
import { useTracking } from '../composables/useTracking'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useCountUp } from '../composables/useCountUp'
import { useMouseGlow } from '../composables/useMouseGlow'
import { stats } from '../data/stats'
import { partners } from '../data/partners'
import { products as allProducts, curlExample } from '../data/products'
import ParticleField from '../components/Effects/ParticleField.vue'
import SectionDividerDark from '../components/Layout/SectionDividerDark.vue'


const ApiFlowDiagram    = defineAsyncComponent(() => import('../components/Illustrations/ApiFlowDiagram.vue'))
const KovaDiagram       = defineAsyncComponent(() => import('../components/Illustrations/KovaDiagram.vue'))
const LucrumChartDiagram = defineAsyncComponent(() => import('../components/Illustrations/LucrumChartDiagram.vue'))
const MemxGraphDiagram  = defineAsyncComponent(() => import('../components/Illustrations/MemxGraphDiagram.vue'))
const CreatorDiagram    = defineAsyncComponent(() => import('../components/Illustrations/CreatorDiagram.vue'))
const SwitchDiagram     = defineAsyncComponent(() => import('../components/Illustrations/SwitchDiagram.vue'))
const LumenDiagram      = defineAsyncComponent(() => import('../components/Illustrations/LumenDiagram.vue'))
const EcosystemMapIllustration = defineAsyncComponent(() => import('../components/Illustrations/EcosystemMap.vue'))

const pageRef = ref<HTMLElement | null>(null)
const heroRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
useMouseGlow(heroRef)
const { login } = useAuth()
const { track } = useTracking()

// Hero product tags — derived from centralized product data
const heroTags = allProducts
  .filter(p => !['forge', 'identity'].includes(p.id))
  .map(p => ({ name: p.name, color: p.neonColor!, href: p.url }))

// Hero trust signal count-up refs
const heroTrustStats = [
  { value: '1,000,000+', label: '次稳定调用' },
  { value: '50+', label: '主流模型' },
  { value: '99.9%', label: 'SLA 保障' },
]
const heroStatRef0 = ref<HTMLElement | null>(null)
const heroStatRef1 = ref<HTMLElement | null>(null)
const heroStatRef2 = ref<HTMLElement | null>(null)
const { displayValue: heroStatVal0 } = useCountUp(heroStatRef0, heroTrustStats[0].value)
const { displayValue: heroStatVal1 } = useCountUp(heroStatRef1, heroTrustStats[1].value)
const { displayValue: heroStatVal2 } = useCountUp(heroStatRef2, heroTrustStats[2].value)
const heroStatValues = [heroStatVal0, heroStatVal1, heroStatVal2]
const heroStatRefs = [heroStatRef0, heroStatRef1, heroStatRef2]

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

// API section tab switching
const activeApiTab = ref<'quickstart' | 'architecture' | 'scenarios'>('quickstart')

// Product expand/collapse
const expandedProducts = ref<Set<string>>(new Set())
function toggleExpand(id: string) {
  if (expandedProducts.value.has(id)) expandedProducts.value.delete(id)
  else expandedProducts.value.add(id)
}

// Pain point bridge cards
const painPoints = [
  {
    audience: '个人用户',
    pain: '每天切换 5 个 AI 工具，配置散落各处',
    solution: 'Switch 统一管理，MemX 跨工具记忆，Creator 一键发布',
    href: '/for-explorers',
    color: '#FF8C69',
  },
  {
    audience: '创业团队',
    pain: '接入 AI 模型要自建网关、做计费、处理限流',
    solution: '一个 API Key 接入 50+ 模型，按量计费，故障自动转移',
    href: '/for-entrepreneurs',
    color: '#4A9EFF',
  },
  {
    audience: '技术团队',
    pain: 'Agent 跑到一半崩溃，状态全丢，只能从头再来',
    solution: 'Kova WAL 级持久化，断电自动恢复，Lumen 实时调试',
    href: '/for-builders',
    color: '#B08EFF',
  },
]

// API scenario cards
const apiScenarios = [
  { title: '初创团队', desc: '3 分钟上线 AI 功能，按量付费，零前期成本', icon: 'rocket' },
  { title: '企业客户', desc: '多租户隔离、配额管理、合规审计，企业级保障', icon: 'building' },
  { title: '服务商', desc: '白标部署，自定义品牌和定价，转售 AI 能力', icon: 'handshake' },
]

// Expanded features for multi-level display
const kovaExpandedFeatures = [
  'Plan → Execute → Review 执行循环',
  '编译时类型安全，错误在部署前拦截',
  'Async 多线程调度，高并发从容应对',
]
const lucrumExpandedFeatures = [
  '30+ 金融指标，覆盖主流技术分析方法',
  '11 个投资流派 AI 顾问，多维度决策支持',
  '多策略同时运行，智能组合管理',
]
const memxExpandedFeatures = [
  '本地优先存储，数据不出你的设备',
  '端到端加密，隐私安全有保障',
  '无限记忆容量，知识积累越用越智能',
]

// Product feature lists
const apiFeatures = [
  'OpenAI SDK 完全兼容，改一行代码即可迁移',
  '智能负载均衡，故障自动转移，服务永不中断',
  '统一账单与用量分析，成本一目了然',
]

const kovaFeatures = [
  'WAL 预写日志，每一步状态持久保存',
  'Rust 原生性能，零 GC 停顿，确定性延迟',
  '崩溃后精准恢复，不重复已完成的工作',
]

const lucrumFeatures = [
  '自然语言到可执行代码，零编程门槛',
  '实时行情接入，毫秒级数据推送',
  '专业级回测引擎，历史验证一键完成',
]

const memxFeatures = [
  '跨会话持久记忆，告别反复交代背景',
  '语义向量检索，精准找回关键上下文',
  'SDK / REST API 接入，3 行代码集成',
]

// API code example — from centralized product data
const apiCode = curlExample

// Switch & Lumen features
const switchFeatures = [
  'Claude Code / Codex / Gemini CLI 集中管控',
  'API Key 统一管理，安全轮换',
  'MCP 预设一键同步到所有工具',
  '环境快照，配置随时回滚',
]
const lumenFeatures = [
  '实时调用链追踪，执行过程透明',
  '断点注入，精准定位问题',
  '状态树可视化，一眼看懂 Agent 状态',
  '结构化日志导出，排查高效从容',
]

// Path cards
const paths = [
  {
    audience: '个人用户',
    action: '用 AI 武装每一天',
    description: '视频创作、量化交易、AI 记忆、工具管理 — 免费下载桌面工具，效率提升肉眼可见',
    href: '/for-explorers',
    color: '#FF8C69',
    badge: '免费使用',
  },
  {
    audience: '创业团队',
    action: '3 分钟接入 AI 能力',
    description: '一个 API Key 接入 50+ 模型，按量计费，智能路由。让你的产品立刻拥有 AI 能力',
    href: '/for-entrepreneurs',
    color: '#4A9EFF',
    badge: '按量计费',
  },
  {
    audience: '技术团队',
    action: '构建生产级 AI 系统',
    description: 'Kova Agent 引擎 + Lumen 调试器 + MemX 记忆 + Identity 认证 — 完整的 AI 基础设施栈',
    href: '/for-builders',
    color: '#B08EFF',
    badge: '开发者',
  },
]
</script>

<template>
  <div ref="pageRef">

    <!-- S1: Hero -->
    <section ref="heroRef" class="home-hero" aria-label="Hero">
      <div class="hero-grid" aria-hidden="true"></div>
      <ParticleField :count="14" />
      <!-- Mouse glow overlay -->
      <div class="hero-mouse-glow" aria-hidden="true"></div>
      <!-- Multi-color neon aura spots with drift animation -->
      <div class="hero-aura" aria-hidden="true">
        <div class="hero-aura-spot hero-aura-spot--animated" style="background:#4A9EFF;top:5%;left:8%;width:420px;height:320px;animation-delay:0s;"></div>
        <div class="hero-aura-spot hero-aura-spot--animated" style="background:#B08EFF;top:20%;right:10%;width:360px;height:280px;animation-delay:3s;"></div>
        <div class="hero-aura-spot hero-aura-spot--animated" style="background:#7AFF89;bottom:10%;left:20%;width:300px;height:260px;animation-delay:6s;"></div>
        <div class="hero-aura-spot hero-aura-spot--animated" style="background:#4AFFCB;bottom:5%;right:25%;width:280px;height:220px;animation-delay:9s;"></div>
      </div>

      <div class="relative max-w-5xl mx-auto px-6 sm:px-8 lg:px-12 py-32 sm:py-44 text-center">
        <div class="hero-eyebrow reveal-fade-up">
          <span class="hero-eyebrow-dot"></span>
          值得信赖的 AI 基础设施
        </div>

        <h1 class="hero-title reveal-fade-up">
          不再拼凑碎片化工具，<br>
          <span class="text-gradient-gold">一个平台，完整交付</span>
        </h1>

        <p class="hero-subtitle reveal-fade-up">
          从模型接入到 Agent 持久运行，从量化交易到内容创作 — 7 款产品无缝协作，让你专注创造价值。
        </p>

        <div class="hero-cta-row reveal-fade-up">
          <button
            class="btn-primary btn-primary--lg"
            @click="track('cta_click', { label: 'hero_register' }); login({ prompt: 'create' })"
          >
            免费体验 →
          </button>
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-outline btn-outline--lg"
            @click="track('cta_click', { label: 'hero_docs' })"
          >
            阅读文档
          </a>
        </div>

        <!-- Hero trust signals -->
        <div class="hero-trust-numbers reveal-fade-up" aria-label="平台数据概览">
          <div class="hero-trust-item">
            <span
              :ref="(el) => { heroStatRefs[0].value = el as HTMLElement | null }"
              class="hero-trust-value"
            >{{ heroStatValues[0].value }}</span>
            <span class="hero-trust-label">次稳定调用</span>
          </div>
          <span class="hero-trust-sep" aria-hidden="true">&middot;</span>
          <div class="hero-trust-item">
            <span
              :ref="(el) => { heroStatRefs[1].value = el as HTMLElement | null }"
              class="hero-trust-value"
            >{{ heroStatValues[1].value }}</span>
            <span class="hero-trust-label">主流模型</span>
          </div>
          <span class="hero-trust-sep" aria-hidden="true">&middot;</span>
          <div class="hero-trust-item">
            <span
              :ref="(el) => { heroStatRefs[2].value = el as HTMLElement | null }"
              class="hero-trust-value"
            >{{ heroStatValues[2].value }}</span>
            <span class="hero-trust-label">SLA 保障</span>
          </div>
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

    <SectionDividerDark variant="down" />

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

    <!-- S3: Model Provider Logos -->
    <section class="section-dark py-10" aria-label="支持的模型提供商">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <p class="text-center text-xs uppercase tracking-wider mb-6" style="color:var(--color-text-muted);letter-spacing:0.12em;font-weight:600">
          支持的 AI 模型提供商
        </p>
        <div class="partner-marquee-wrapper">
          <div class="partner-marquee animate-marquee">
            <span
              v-for="(p, i) in [...partners, ...partners]"
              :key="'partner-' + i"
              class="partner-badge"
              :style="{ borderColor: p.color + '40', color: p.color }"
            >
              {{ p.name }}
            </span>
          </div>
        </div>
      </div>
    </section>

    <!-- S4: Pain Point Bridge -->
    <section class="section-dark py-20" aria-label="痛点桥接">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <h2 class="home-section-title">你是否也面临这些挑战？</h2>
        </div>
        <div class="pain-grid reveal-fade-up">
          <router-link
            v-for="point in painPoints"
            :key="point.audience"
            :to="point.href"
            class="pain-card"
            :style="{ '--pain-color': point.color }"
          >
            <div class="pain-card-top-line" aria-hidden="true"></div>
            <p class="pain-card-audience">{{ point.audience }}</p>
            <p class="pain-card-pain">{{ point.pain }}</p>
            <p class="pain-card-solution">{{ point.solution }}</p>
            <span class="pain-card-arrow" aria-hidden="true">→</span>
          </router-link>
        </div>
      </div>
    </section>

    <!-- S5: Lurus API deep dive -->
    <section class="section-dark-raised py-24" aria-label="Lurus API">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="product-section-grid reveal-fade-up">
          <!-- Copy -->
          <div class="product-copy">
            <span class="neon-badge" style="color:#4A9EFF">
              <span class="neon-dot" style="color:#4A9EFF"></span>
              开发者首选
            </span>
            <h2 class="product-headline">
              告别多平台账号管理，<br><span style="color:#4A9EFF">一个端点，全部搞定</span>
            </h2>
            <p class="product-desc">
              你已经用 OpenAI SDK？改一行 base_url，即刻接入 DeepSeek、Claude、Gemini 等 50+ 模型。负载均衡与故障转移自动完成，统一账单清晰可查。
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
              class="btn-primary product-cta-start"
              @click="track('cta_click', { label: 'api_section' })"
            >
              免费获取 API Key →
            </a>
          </div>

          <!-- Right column: tabs -->
          <div class="api-right-col">
            <div class="product-tabs">
              <button
                :class="{ active: activeApiTab === 'quickstart' }"
                @click="activeApiTab = 'quickstart'"
              >快速接入</button>
              <button
                :class="{ active: activeApiTab === 'architecture' }"
                @click="activeApiTab = 'architecture'"
              >架构总览</button>
              <button
                :class="{ active: activeApiTab === 'scenarios' }"
                @click="activeApiTab = 'scenarios'"
              >适用场景</button>
            </div>

            <!-- Tab 1: Quick start code -->
            <div v-show="activeApiTab === 'quickstart'">
              <div class="api-code-block">
                <div class="api-code-bar">
                  <span class="api-code-lang">bash</span>
                </div>
                <pre class="api-code-pre">{{ apiCode }}</pre>
              </div>
            </div>

            <!-- Tab 2: Architecture diagram -->
            <div v-show="activeApiTab === 'architecture'">
              <div class="diagram-wrapper">
                <ApiFlowDiagram />
              </div>
            </div>

            <!-- Tab 3: Scenarios -->
            <div v-show="activeApiTab === 'scenarios'">
              <div class="scenario-grid">
                <div
                  v-for="scenario in apiScenarios"
                  :key="scenario.title"
                  class="scenario-card"
                >
                  <div class="scenario-card-icon">
                    <svg v-if="scenario.icon === 'rocket'" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="#4A9EFF" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13 10V3L4 14h7v7l9-11h-7z" />
                    </svg>
                    <svg v-else-if="scenario.icon === 'building'" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="#4A9EFF" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                    <svg v-else width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="#4A9EFF" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                  </div>
                  <h4 class="scenario-card-title">{{ scenario.title }}</h4>
                  <p class="scenario-card-desc">{{ scenario.desc }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- S6: Kova + Lucrum Bento Grid -->
    <section class="section-dark py-24" aria-label="Kova 和 Lucrum">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <h2 class="home-section-title">两大旗舰，解决最难的问题</h2>
          <p class="home-section-subtitle">一个让 Agent 永不中断，一个让交易策略触手可及</p>
        </div>
        <div class="bento-grid reveal-fade-up">
          <!-- Kova card (taller) -->
          <div class="bento-card bento-card--tall card-glow" :style="{ '--glow-color': '#B08EFF' }">
            <span class="neon-badge" style="color:#B08EFF">
              <span class="neon-dot" style="color:#B08EFF"></span>
              生产级 Agent 引擎
            </span>
            <h3 class="bento-card-title">
              Agent 永不中断，<span style="color:#B08EFF">状态可靠持久</span>
            </h3>
            <p class="bento-card-desc">
              Kova 将 WAL 预写日志引入 Agent 执行引擎。掉电重启后从断点继续，Rust 零 GC 保障确定性响应，让你的 Agent 在生产环境从容运行。
            </p>
            <div class="bento-diagram-wrapper">
              <KovaDiagram />
            </div>
            <ul class="product-feature-list" role="list">
              <li v-for="feat in kovaFeatures" :key="feat">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#B08EFF" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>

            <!-- Expand toggle -->
            <button class="expand-toggle" @click="toggleExpand('kova')">
              <svg
                width="14" height="14" viewBox="0 0 24 24" fill="none"
                stroke="#B08EFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                :class="{ rotated: expandedProducts.has('kova') }"
              ><path d="M6 9l6 6 6-6" /></svg>
              {{ expandedProducts.has('kova') ? '收起技术细节' : '展开技术细节' }}
            </button>
            <ul v-show="expandedProducts.has('kova')" class="expanded-details" role="list">
              <li v-for="feat in kovaExpandedFeatures" :key="feat">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#B08EFF" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>

            <a
              href="/for-builders"
              class="btn-outline product-cta-start"
              :style="{ borderColor: '#B08EFF', color: '#B08EFF' }"
              @click="track('cta_click', { label: 'kova_section' })"
            >
              了解 Kova →
            </a>
          </div>

          <!-- Lucrum card (shorter) -->
          <div class="bento-card card-glow" :style="{ '--glow-color': '#7AFF89' }">
            <span class="neon-badge" style="color:#7AFF89">
              <span class="neon-dot" style="color:#7AFF89"></span>
              AI 量化交易平台
            </span>
            <h3 class="bento-card-title">
              用中文描述策略，<span style="color:#7AFF89">AI 精准生成代码</span>
            </h3>
            <p class="bento-card-desc">
              用一句话描述交易逻辑，AI 自动生成可执行策略代码。专业级回测引擎即时验证，从想法到策略只需一步。
            </p>
            <div class="bento-diagram-wrapper">
              <LucrumChartDiagram />
            </div>
            <ul class="product-feature-list" role="list">
              <li v-for="feat in lucrumFeatures" :key="feat">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#7AFF89" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>

            <!-- Expand toggle -->
            <button class="expand-toggle" @click="toggleExpand('lucrum')">
              <svg
                width="14" height="14" viewBox="0 0 24 24" fill="none"
                stroke="#7AFF89" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                :class="{ rotated: expandedProducts.has('lucrum') }"
              ><path d="M6 9l6 6 6-6" /></svg>
              {{ expandedProducts.has('lucrum') ? '收起详情' : '展开详情' }}
            </button>
            <ul v-show="expandedProducts.has('lucrum')" class="expanded-details" role="list">
              <li v-for="feat in lucrumExpandedFeatures" :key="feat">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#7AFF89" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feat }}
              </li>
            </ul>

            <a
              href="https://lucrum.lurus.cn"
              target="_blank"
              rel="noopener noreferrer"
              class="btn-primary product-cta-start"
              :style="{ background: '#7AFF89', color: '#0D0B09' }"
              @click="track('cta_click', { label: 'lucrum_section' })"
            >
              进入 Lucrum →
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- S7: MemX (centered full-width) -->
    <section class="section-dark-raised py-24" aria-label="MemX AI记忆引擎">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <span class="neon-badge" style="color:#4AFFCB">
            <span class="neon-dot" style="color:#4AFFCB"></span>
            AI 记忆引擎
          </span>
          <h2 class="product-headline" style="margin-top:16px">
            不再重复解释，<br>
            <span style="color:#4AFFCB">AI 真正理解你</span>
          </h2>
          <p class="product-desc" style="margin:0 auto 32px;text-align:center">
            每次开新对话都要重新交代背景？MemX 为你的 AI 建立持久记忆层。你的偏好、历史上下文跨工具跨会话保存，下次对话直接延续 — 不再从零开始。
          </p>
        </div>

        <div class="memx-diagram-wrapper reveal-fade-up">
          <MemxGraphDiagram />
        </div>

        <ul class="memx-feature-list reveal-fade-up" role="list">
          <li v-for="feat in memxFeatures" :key="feat">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#4AFFCB" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
            </svg>
            {{ feat }}
          </li>
        </ul>

        <!-- MemX expand toggle -->
        <div class="text-center mt-6 reveal-fade-up">
          <button class="expand-toggle expand-toggle--centered" @click="toggleExpand('memx')">
            <svg
              width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="#4AFFCB" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
              :class="{ rotated: expandedProducts.has('memx') }"
            ><path d="M6 9l6 6 6-6" /></svg>
            {{ expandedProducts.has('memx') ? '收起' : '展开更多' }}
          </button>
        </div>
        <ul v-show="expandedProducts.has('memx')" class="memx-feature-list reveal-fade-up" style="margin-top:12px" role="list">
          <li v-for="feat in memxExpandedFeatures" :key="feat">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#4AFFCB" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
            </svg>
            {{ feat }}
          </li>
        </ul>

        <div class="text-center mt-10 reveal-fade-up">
          <a
            href="/download#memx"
            class="btn-outline btn-outline--lg"
            :style="{ borderColor: '#4AFFCB', color: '#4AFFCB' }"
            @click="track('cta_click', { label: 'memx_section' })"
          >
            下载 MemX →
          </a>
        </div>
      </div>
    </section>

    <!-- S8: Lurus Creator -->
    <section class="section-dark-raised py-24" aria-label="Lurus Creator内容工厂">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <span class="neon-badge" style="color:#FFB86C">
            <span class="neon-dot" style="color:#FFB86C"></span>
            桌面内容工厂
          </span>
          <h2 class="product-headline" style="margin-top:16px">
            一条视频，<br>
            <span style="color:#FFB86C">全平台同步发布</span>
          </h2>
          <p class="product-desc" style="margin:0 auto 32px;text-align:center">
            手动转录视频、逐平台发布内容？Creator 自动完成一切。yt-dlp 抓取任意视频，Whisper 高精度转录，LLM 优化文案，一键同步到微信视频号、抖音、YouTube — 全程无需手动操作。
          </p>
        </div>

        <!-- Full-width pipeline diagram -->
        <div class="creator-diagram-wrapper reveal-fade-up">
          <CreatorDiagram />
        </div>

        <div class="text-center mt-10 reveal-fade-up">
          <a
            href="/download"
            class="btn-primary btn-primary--lg"
            :style="{ background: '#FFB86C', color: '#0D0B09' }"
            @click="track('cta_click', { label: 'creator_section' })"
          >
            下载 Lurus Creator →
          </a>
        </div>
      </div>
    </section>

    <!-- S9: Switch + Lumen dual cards -->
    <section class="section-dark py-24" aria-label="Lurus Switch 和 Lumen">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <h2 class="home-section-title">
            让工具听你指挥
          </h2>
          <p class="home-section-subtitle">
            配置不再散落各处，执行过程不再是黑箱
          </p>
        </div>

        <div class="dual-product-grid reveal-fade-up">
          <!-- Lurus Switch card -->
          <div class="dual-card card-glow" :style="{ '--card-accent': '#FF8C69', '--glow-color': '#FF8C69' }">
            <span class="neon-badge" style="color:#FF8C69;margin-bottom:16px;display:inline-flex">
              <span class="neon-dot" style="color:#FF8C69"></span>
              AI 工具管理器
            </span>
            <h3 class="dual-card-title">Lurus Switch</h3>
            <p class="dual-card-desc">AI 命令行工具越来越多，配置散落各处，密钥管理混乱？Switch 一个面板统一管控所有 AI CLI 工具的配置、密钥和 MCP 预设。</p>
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
              class="btn-outline btn-outline--sm"
              :style="{ borderColor: '#FF8C69', color: '#FF8C69' }"
              @click="track('cta_click', { label: 'switch_card' })"
            >
              下载 Switch →
            </a>
          </div>

          <!-- Lumen card -->
          <div class="dual-card card-glow" :style="{ '--card-accent': '#FFE566', '--glow-color': '#FFE566' }">
            <span class="neon-badge" style="color:#FFE566;margin-bottom:16px;display:inline-flex">
              <span class="neon-dot" style="color:#FFE566"></span>
              Agent 调试器
            </span>
            <h3 class="dual-card-title">Lumen</h3>
            <p class="dual-card-desc">Agent 执行过程是黑箱？Lumen 让每一步调用链清晰可见，断点注入精准定位问题，状态树可视化一眼看懂 Agent 运行状态。</p>
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
              class="btn-outline btn-outline--sm"
              :style="{ borderColor: '#FFE566', color: '#FFE566' }"
              @click="track('cta_click', { label: 'lumen_card' })"
            >
              了解 Lumen →
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- S10: Ecosystem Map -->
    <section class="section-dark py-20" aria-label="产品生态">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-14 reveal-fade-up">
          <h2 class="home-section-title">不是 7 个独立工具，是一个完整平台</h2>
          <p class="home-section-subtitle">基础设施层与应用层无缝协作，数据在产品间自由流转</p>
        </div>
        <div class="reveal-fade-up">
          <EcosystemMapIllustration />
        </div>
      </div>
    </section>

    <!-- S11: Path Cards -->
    <section class="section-dark-raised py-24" aria-label="选择你的方案">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-16 reveal-fade-up">
          <h2 class="home-section-title">找到最适合你的方案</h2>
          <p class="home-section-subtitle">三种身份，三条路径，同一个可靠平台</p>
        </div>

        <div class="paths-grid reveal-fade-up">
          <router-link
            v-for="path in paths"
            :key="path.audience"
            :to="path.href"
            class="path-card group card-glow"
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

    <!-- S12: Final CTA -->
    <section class="section-dark py-36 text-center has-light-sweep" aria-label="立即开始">
      <div class="max-w-3xl mx-auto px-6 reveal-fade-up" style="position:relative;z-index:1">
        <h2 class="home-section-title" style="font-size:clamp(2.25rem,5vw,3.25rem)">
          从今天开始，告别碎片化
        </h2>
        <p class="home-section-subtitle mt-4 mb-10">
          一个平台，完整的 AI 基础设施。免费开始，按需扩展。
        </p>
        <div class="flex flex-wrap items-center justify-center gap-4">
          <button
            class="btn-primary btn-primary--lg"
            @click="track('cta_click', { label: 'final_cta' }); login({ prompt: 'create' })"
          >
            免费体验 →
          </button>
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-outline btn-outline--lg"
          >
            阅读文档
          </a>
        </div>
        <div class="cta-trust-row">
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            端到端加密
          </span>
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            免费起步，无需信用卡
          </span>
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            即时开通，秒级就绪
          </span>
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" />
            </svg>
            符合 PIPL 合规要求
          </span>
          <span class="cta-trust-item">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            99.9% SLA 服务保障
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

.hero-aura-spot--animated {
  animation: aura-drift 12s ease-in-out infinite;
}

/* Mouse glow overlay */
.hero-mouse-glow {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background: radial-gradient(
    circle var(--glow-size, 600px) at var(--glow-x, 50%) var(--glow-y, 50%),
    var(--glow-color, rgba(212, 168, 39, 0.06)),
    transparent
  );
  opacity: var(--glow-opacity, 0);
  transition: opacity 0.3s ease;
  z-index: 0;
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
  margin-bottom: 32px;
}

/* Hero trust signal numbers */
.hero-trust-numbers {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin-bottom: 40px;
}

.hero-trust-item {
  display: flex;
  align-items: baseline;
  gap: 6px;
}

.hero-trust-value {
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--color-text-secondary);
  font-variant-numeric: tabular-nums;
}

.hero-trust-label {
  font-size: 0.82rem;
  color: var(--color-text-muted);
}

.hero-trust-sep {
  color: var(--color-text-muted);
  font-size: 1.2rem;
  line-height: 1;
  user-select: none;
}

@media (max-width: 639px) {
  .hero-trust-numbers {
    flex-direction: column;
    gap: 10px;
  }

  .hero-trust-sep {
    display: none;
  }
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

/* ── Pain Point Bridge ────────────────────────── */
.pain-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

@media (max-width: 767px) {
  .pain-grid { grid-template-columns: 1fr; }
}

.pain-card {
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

.pain-card:hover {
  border-color: var(--pain-color, var(--color-ochre));
  transform: translateY(-2px);
}

.pain-card-top-line {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: var(--pain-color, var(--color-ochre));
  opacity: 0.8;
}

.pain-card-audience {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--pain-color, var(--color-text-muted));
  margin-bottom: 12px;
}

.pain-card-pain {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text-primary);
  line-height: 1.4;
  margin-bottom: 12px;
}

.pain-card-solution {
  font-size: 0.88rem;
  color: var(--color-text-secondary);
  line-height: 1.55;
}

.pain-card-arrow {
  display: block;
  margin-top: 16px;
  color: var(--color-text-muted);
  font-size: 1rem;
  transition: color 0.2s, transform 0.2s;
}

.pain-card:hover .pain-card-arrow {
  color: var(--pain-color, var(--color-ochre));
  transform: translateX(5px);
}

/* ── API section right column ─────────────────── */
.api-right-col {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ── Product Tabs (pill style) ────────────────── */
.product-tabs {
  display: flex;
  gap: 4px;
  padding: 4px;
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 10px;
}

.product-tabs button {
  flex: 1;
  padding: 8px 16px;
  border: none;
  border-radius: 8px;
  background: transparent;
  color: var(--color-text-muted);
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s, color 0.2s;
}

.product-tabs button:hover {
  color: var(--color-text-secondary);
}

.product-tabs button.active {
  background-color: var(--color-surface-raised);
  color: #4A9EFF;
  box-shadow: 0 1px 3px rgba(0,0,0,0.3);
}

/* ── Scenario Cards ───────────────────────────── */
.scenario-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}

.scenario-card {
  padding: 20px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  border-radius: 12px;
  transition: border-color 0.2s;
}

.scenario-card:hover {
  border-color: rgba(74, 158, 255, 0.3);
}

.scenario-card-icon {
  margin-bottom: 10px;
}

.scenario-card-title {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.scenario-card-desc {
  font-size: 0.82rem;
  color: var(--color-text-secondary);
  line-height: 1.5;
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

/* ── Expand Toggle ────────────────────────────── */
.expand-toggle {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 0;
  border: none;
  background: transparent;
  color: var(--color-text-muted);
  font-size: 0.82rem;
  font-weight: 500;
  cursor: pointer;
  transition: color 0.2s;
}

.expand-toggle:hover {
  color: var(--color-text-secondary);
}

.expand-toggle--centered {
  justify-content: center;
}

.expand-toggle svg {
  transition: transform 0.25s ease;
}

.expand-toggle svg.rotated {
  transform: rotate(180deg);
}

/* ── Expanded Details ─────────────────────────── */
.expanded-details {
  list-style: none;
  padding: 12px 0 0;
  margin: 0;
  border-top: 1px solid var(--color-surface-border);
}

.expanded-details li {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  padding: 4px 0;
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

/* ── Partner Marquee ──────────────────────────── */
.partner-marquee-wrapper {
  overflow: hidden;
  mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent);
  -webkit-mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent);
}

.partner-marquee {
  display: flex;
  gap: 12px;
  width: max-content;
}

.partner-badge {
  display: inline-flex;
  align-items: center;
  padding: 6px 16px;
  border-radius: 999px;
  border: 1px solid;
  font-size: 0.78rem;
  font-weight: 600;
  white-space: nowrap;
  background: color-mix(in srgb, currentColor 5%, transparent);
}

/* ── Bento Grid ──────────────────────────────── */
.bento-grid {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 20px;
  align-items: start;
}

@media (max-width: 767px) {
  .bento-grid { grid-template-columns: 1fr; }
}

.bento-card {
  padding: 32px 28px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.bento-card-title {
  font-size: 1.35rem;
  font-weight: 800;
  color: var(--color-text-primary);
  letter-spacing: -0.02em;
  line-height: 1.25;
}

.bento-card-desc {
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  line-height: 1.6;
}

.bento-diagram-wrapper {
  aspect-ratio: 16 / 9;
  width: 100%;
  margin: 4px 0;
}

.bento-diagram-wrapper svg {
  width: 100%;
  height: 100%;
}

/* ── MemX centered ───────────────────────────── */
.memx-diagram-wrapper {
  width: 100%;
  max-width: 480px;
  aspect-ratio: 4 / 3;
  margin: 0 auto;
}

.memx-diagram-wrapper svg {
  width: 100%;
  height: 100%;
}

.memx-feature-list {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 16px 32px;
  list-style: none;
  padding: 0;
  margin: 24px 0 0;
}

.memx-feature-list li {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: var(--color-text-secondary);
}

/* ── Product CTA alignment ───────────────────────── */
.product-cta-start {
  align-self: flex-start;
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
