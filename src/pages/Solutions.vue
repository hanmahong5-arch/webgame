<script setup lang="ts">
import { ref } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useAuth } from '../composables/useAuth'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { login } = useAuth()

const solutions = [
  {
    id: 'academic',
    icon: '📚',
    title: '学术研究',
    desc: '论文检索、文献综述、数据分析、科研写作辅助',
    useCases: ['论文摘要自动生成', '跨语言文献翻译', '实验数据解读', '科研方法论建议'],
    models: ['DeepSeek (高性价比)', 'GPT-4o (多模态)', 'Claude (长文本)'],
  },
  {
    id: 'finance',
    icon: '💹',
    title: '金融分析',
    desc: '市场研究、风险评估、量化策略、合规审查',
    useCases: ['财报分析与解读', '市场情绪判断', '投资策略回测报告', '监管合规文档审查'],
    models: ['DeepSeek (中文金融)', 'GPT-4o (数据分析)', 'Claude (长报告)'],
  },
  {
    id: 'medical',
    icon: '🏥',
    title: '医疗健康',
    desc: '医学文献检索、临床辅助决策、健康科普内容生成',
    useCases: ['医学文献摘要', '药物相互作用查询', '病历结构化整理', '患者教育材料生成'],
    models: ['GPT-4o (医学知识)', 'Claude (隐私安全)', 'DeepSeek (中文医学)'],
  },
  {
    id: 'legal',
    icon: '⚖️',
    title: '法律服务',
    desc: '法规检索、合同审查、案例分析、法律文书起草',
    useCases: ['法条关联检索', '合同条款风险识别', '判例相似度分析', '法律意见书初稿'],
    models: ['Claude (逻辑推理)', 'DeepSeek (中国法律)', 'GPT-4o (多语言)'],
  },
  {
    id: 'engineering',
    icon: '💻',
    title: '软件工程',
    desc: '代码生成、架构设计、文档撰写、代码审查',
    useCases: ['智能代码补全', '技术方案设计', 'API 文档自动生成', '代码安全审计'],
    models: ['Claude (代码推理)', 'DeepSeek Coder (编程)', 'GPT-4o (全能)'],
  },
]
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section id="hero" class="py-24 section-dark-raised relative overflow-hidden">
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h1 class="text-phi-3xl sm:text-phi-4xl font-bold text-[var(--color-text-primary)] mb-4">
          解决方案
        </h1>
        <p class="text-phi-xl text-[var(--color-text-secondary)] max-w-2xl mx-auto">
          Lurus 为不同行业提供定制化的 AI 模型接入方案，助力业务智能化升级
        </p>
      </div>
    </section>

    <!-- Solutions Grid -->
    <section class="py-20 section-dark">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="space-y-8">
          <div
            v-for="(s, idx) in solutions"
            :id="s.id"
            :key="s.id"
            class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] hover:bg-[var(--color-surface-overlay)] p-8 transition-colors reveal-fade-up"
            :class="idx % 2 === 0 ? '' : 'md:flex-row-reverse'"
          >
            <div class="grid md:grid-cols-3 gap-8">
              <!-- Left: Icon + Title -->
              <div>
                <div class="text-4xl mb-4">{{ s.icon }}</div>
                <h3 class="text-phi-xl font-bold text-[var(--color-text-primary)] mb-4">{{ s.title }}</h3>
                <p class="text-[var(--color-text-secondary)] text-phi-base leading-relaxed">{{ s.desc }}</p>
              </div>

              <!-- Middle: Use Cases -->
              <div>
                <h4 class="text-sm font-semibold text-[var(--color-text-muted)] uppercase tracking-wider mb-4">典型场景</h4>
                <ul class="space-y-2">
                  <li
                    v-for="uc in s.useCases"
                    :key="uc"
                    class="flex items-start gap-2 text-[var(--color-text-secondary)] text-sm"
                  >
                    <svg class="w-4 h-4 text-product-lucrum flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                    </svg>
                    {{ uc }}
                  </li>
                </ul>
              </div>

              <!-- Right: Recommended Models -->
              <div>
                <h4 class="text-sm font-semibold text-[var(--color-text-muted)] uppercase tracking-wider mb-4">推荐模型</h4>
                <ul class="space-y-2">
                  <li
                    v-for="m in s.models"
                    :key="m"
                    class="text-[var(--color-text-secondary)] text-sm flex items-center gap-2"
                  >
                    <span class="w-2 h-2 rounded-full bg-ochre flex-shrink-0"></span>
                    {{ m }}
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Tech Advantages -->
    <section id="tech-advantages" class="py-20 section-dark-raised">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-10 text-center reveal-fade-up">技术优势</h2>
        <div class="grid md:grid-cols-3 gap-6">
          <div class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6 text-center reveal-fade-up">
            <svg class="w-10 h-10 mx-auto text-ochre mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
            </svg>
            <h3 class="font-bold text-[var(--color-text-primary)] mb-2">多供应商路由</h3>
            <p class="text-[var(--color-text-secondary)] text-sm">智能选择最优模型供应商，自动负载均衡</p>
          </div>
          <div class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6 text-center reveal-fade-up">
            <svg class="w-10 h-10 mx-auto text-ochre mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            <h3 class="font-bold text-[var(--color-text-primary)] mb-2">自动容灾</h3>
            <p class="text-[var(--color-text-secondary)] text-sm">单一供应商故障时自动切换备用通道，零感知恢复</p>
          </div>
          <div class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6 text-center reveal-fade-up">
            <svg class="w-10 h-10 mx-auto text-ochre mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            <h3 class="font-bold text-[var(--color-text-primary)] mb-2">智能缓存</h3>
            <p class="text-[var(--color-text-secondary)] text-sm">语义级缓存重复请求，节省 Token 消耗降低成本</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Security -->
    <section id="security" class="py-20 section-dark">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-10 text-center reveal-fade-up">安全保障</h2>
        <div class="grid md:grid-cols-3 gap-6">
          <div class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6 reveal-fade-up">
            <h3 class="font-bold text-[var(--color-text-primary)] mb-2">传输加密</h3>
            <p class="text-[var(--color-text-secondary)] text-sm">全链路 TLS 1.3 加密，API 密钥安全存储，请求数据端到端保护</p>
          </div>
          <div class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6 reveal-fade-up">
            <h3 class="font-bold text-[var(--color-text-primary)] mb-2">合规认证</h3>
            <p class="text-[var(--color-text-secondary)] text-sm">符合中国网络安全法和 PIPL 要求，数据存储于境内服务器</p>
          </div>
          <div class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6 reveal-fade-up">
            <h3 class="font-bold text-[var(--color-text-primary)] mb-2">无日志策略</h3>
            <p class="text-[var(--color-text-secondary)] text-sm">不存储用户对话内容，仅记录匿名化的调用统计用于计费</p>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="py-20 section-dark-raised relative overflow-hidden">
      <div class="relative max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-4">准备好了吗？</h2>
        <p class="text-[var(--color-text-secondary)] mb-6">免费注册，立即体验 Lurus AI 基础设施服务</p>
        <button
          @click="login({ prompt: 'create' })"
          class="btn-primary inline-flex items-center gap-2 text-lg"
        >
          免费注册
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        </button>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
