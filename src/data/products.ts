/**
 * Products Data
 * Centralized product information for ProductShowcase component
 *
 * Infra layer: Lurus API, Lurus Switch
 * App layer: GuShen, ACEST Desktop, MemX
 * Each product has a useCase field for one-line value proposition
 * Each product has an optional showcase field for visual demo area
 */

import type { Product, ProductIconPaths } from '../types/products'

export const products = [
  {
    id: 'api',
    name: 'Lurus API',
    tagline: 'LLM 统一网关',
    description: '一站式接入 Claude、GPT、Gemini 等主流 AI 模型，提供稳定、低延迟的企业级 API 服务',
    useCase: '3 行代码接入 50+ AI 模型',
    url: 'https://api.lurus.cn',
    docsUrl: 'https://docs.lurus.cn/guide/quickstart',
    icon: 'api',
    color: 'product-api',
    bgColor: '#6B8BA4',
    features: ['统一 API 接口', '智能负载均衡', '用量监控分析', '多租户支持'],
    stats: { value: '99.9%', label: '可用性' },
    layer: 'infra' as const,
    showcase: {
      type: 'code' as const,
      fallbackCode: `curl https://api.lurus.cn/v1/chat/completions \\
  -H "Authorization: Bearer $LURUS_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hello"}]}'`,
      fallbackLanguage: 'bash',
      fallbackAriaLabel: 'Lurus API curl 请求示例',
    },
  },
  {
    id: 'switch',
    name: 'Lurus Switch',
    tagline: '智能客户端',
    description: '桌面端 AI 模型网关，一键切换模型服务，全平台覆盖',
    useCase: '跨平台桌面应用，一键切换 AI 模型',
    url: '#',
    docsUrl: 'https://docs.lurus.cn/switch/',
    icon: 'desktop',
    color: 'product-switch',
    bgColor: '#C67B5C',
    features: ['桌面端应用', '本地代理', '多平台支持', '离线可用'],
    stats: { value: '3', label: '平台支持' },
    layer: 'infra' as const,
    showcase: {
      type: 'features' as const,
      fallbackFeatures: [
        'Windows / macOS / Linux 全平台',
        '本地代理与模型路由',
        '一键切换 AI 模型服务',
        '离线配置管理',
      ],
    },
  },
  {
    id: 'gushen',
    name: 'GuShen',
    tagline: 'AI 量化交易',
    description: '基于 AI 的智能量化交易平台，自然语言描述策略需求，AI 自动生成可执行代码',
    useCase: '自然语言描述 → AI 生成量化策略',
    url: 'https://gushen.lurus.cn',
    docsUrl: 'https://docs.lurus.cn/gushen/',
    icon: 'chart',
    color: 'product-gushen',
    bgColor: '#7D8B6A',
    features: ['AI 策略引擎', '实时行情', '风险控制', '回测模拟'],
    stats: { value: '50+', label: '量化策略' },
    layer: 'app' as const,
    showcase: {
      type: 'screenshot' as const,
      screenshotSrc: '',
      screenshotAlt: 'GuShen 量化交易平台策略编辑器 — 展示自然语言输入与 AI 生成的量化策略代码',
      fallbackCode: `# Natural language → AI-generated strategy
def strategy(context):
    """Buy when 5-day MA crosses above 20-day MA"""
    ma5 = context.ta.sma(period=5)
    ma20 = context.ta.sma(period=20)

    if ma5[-1] > ma20[-1] and ma5[-2] <= ma20[-2]:
        context.order_percent("BTC/USDT", 0.5)`,
      fallbackLanguage: 'bash',
      fallbackAriaLabel: 'GuShen AI 量化策略代码示例',
    },
  },
  {
    id: 'acest',
    name: 'ACEST Desktop',
    tagline: 'Rust 原生 AI 引擎',
    description: 'Rust 构建的桌面 AI 上下文引擎 — 零 GC 停顿、内存安全、极致性能。实时感知工作区，为任意应用注入 AI 能力。',
    useCase: 'Rust 原生桌面 AI 上下文引擎',
    url: '/download',
    icon: 'brain',
    color: 'product-acest',
    bgColor: '#5C7A8B',
    features: ['Rust 原生性能', '零 GC 停顿', '内存安全保证', '< 8MB 内存占用'],
    stats: { value: '<8MB', label: '内存占用' },
    layer: 'app' as const,
    showcase: {
      type: 'features' as const,
      fallbackFeatures: [
        'Rust 编译 — 零垃圾回收，确定性延迟',
        '常驻内存 < 8MB，比 Electron 方案轻 20 倍',
        '全局快捷键唤醒，< 50ms 响应',
        '所有数据本地处理，网络可选',
      ],
    },
  },
  {
    id: 'memx',
    name: 'MemX',
    tagline: 'AI 记忆扩展',
    description: '个人知识库与 AI 记忆层，让 AI 记住你的偏好、文档和工作上下文，跨会话持久化',
    useCase: '跨会话持久 AI 记忆',
    url: '/download#memx',
    icon: 'database',
    color: 'product-memx',
    bgColor: '#8B7A5C',
    features: ['持久记忆', '语义检索', '本地优先', '隐私加密'],
    stats: { value: '∞', label: '记忆容量' },
    layer: 'app' as const,
  },
  {
    id: 'kova',
    name: 'Kova',
    tagline: 'Rust Agent SDK',
    description: 'Rust 构建的 AI Agent 持久执行引擎，WAL 级别的状态持久化，掉电不丢失，Agent Loop 自动恢复',
    useCase: 'Rust 原生 Agent 持久化执行框架',
    url: '#',
    icon: 'cpu',
    color: 'product-kova',
    bgColor: '#B08EFF',
    features: ['WAL 持久化状态', 'Rust 零 GC 延迟', 'Agent Loop 断点恢复', '编译时类型安全'],
    stats: { value: '0ms', label: 'GC 停顿' },
    layer: 'infra' as const,
    showcase: {
      type: 'code' as const,
      fallbackCode: `// Kova SDK — WAL-backed Agent Loop
use kova::{Agent, WalStore};

#[tokio::main]
async fn main() {
    let store = WalStore::open("./state.wal").await?;
    let agent = Agent::builder().store(store).build();
    agent.run_loop().await?; // auto-resumes on crash
}`,
      fallbackLanguage: 'rust',
      fallbackAriaLabel: 'Kova SDK Rust Agent 持久化执行示例',
    },
  },
  {
    id: 'creator',
    name: 'Lurus Creator',
    tagline: '桌面内容工厂',
    description: '一站式 AI 内容创作桌面应用：视频抓取 → Whisper 转录 → LLM 编辑 → 多平台一键发布',
    useCase: '视频→文稿→多平台，一键完成',
    url: '/download',
    icon: 'video',
    color: 'product-creator',
    bgColor: '#FFB86C',
    features: ['yt-dlp 视频抓取', 'Whisper AI 转录', 'LLM 内容优化', '多平台一键发布'],
    stats: { value: '3', label: '步完成发布' },
    layer: 'app' as const,
  },
  {
    id: 'lumen',
    name: 'Lumen',
    tagline: 'Agent 调试工具',
    description: 'Agent 开发者专用调试 CLI，实时可视化 Agent 执行轨迹，断点注入与状态树检查',
    useCase: 'Agent 执行可视化与断点调试',
    url: '#',
    icon: 'bug',
    color: 'product-lumen',
    bgColor: '#FFE566',
    features: ['实时 Agent 追踪', '断点调试注入', '状态树可视化', '日志导出'],
    stats: { value: '<5ms', label: '追踪延迟' },
    layer: 'infra' as const,
    showcase: {
      type: 'features' as const,
      fallbackFeatures: [
        '实时 Agent 执行 flamechart',
        '断点注入与暂停恢复',
        '状态树可视化检查',
        'CLI 日志结构化导出',
      ],
    },
  },
] satisfies Product[]

/**
 * Icon paths for product icons (SVG path data)
 */
export const productIconPaths: ProductIconPaths = {
  api: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
  chart: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
  desktop: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  brain: 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z',
  database: 'M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4',
  cpu: 'M9 3H7a2 2 0 00-2 2v2M9 3h6M9 3v2m6-2h2a2 2 0 012 2v2m0 0V7m0 0h2M3 9v6m0 0v2a2 2 0 002 2h2m-4-4h2M21 9v6m0 0v2a2 2 0 01-2 2h-2m4-4h-2M9 21h6M9 21v-2m6 2v-2M9 19H7a2 2 0 01-2-2v-2m14 4h-2a2 2 0 01-2-2v-2',
  video: 'M15 10l4.553-2.069A1 1 0 0121 8.845v6.31a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z',
  bug: 'M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4',
}

/**
 * curl example for API showcase (API quick start example)
 */
export const curlExample = `curl https://api.lurus.cn/v1/chat/completions \
  -H "Authorization: Bearer $LURUS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hello"}]}'`
