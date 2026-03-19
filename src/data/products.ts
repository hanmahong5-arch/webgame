/**
 * Products Data — Single Source of Truth
 *
 * All product information centralized here. TopBar, Footer, audience pages,
 * and Home page all derive from this data.
 *
 * Infra layer: Lurus API, Lurus Switch, Kova, Lumen
 * App layer: Lucrum, MemX, Creator
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
    neonColor: '#4A9EFF',
    bgColor: '#6B8BA4',
    features: ['统一 API 接口', '智能负载均衡', '用量监控分析', '多租户支持'],
    stats: { value: '99.9%', label: '可用性' },
    layer: 'infra' as const,
    navGroup: 'infra' as const,
    navDesc: 'LLM 统一网关，50+ 模型一端点',
    external: true,
    iconPath: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
    showcase: {
      type: 'code' as const,
      fallbackCode: `curl https://api.lurus.cn/v1/chat/completions \\
  -H "Authorization: Bearer $LURUS_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hello"}]}'`,
      fallbackLanguage: 'bash',
      fallbackAriaLabel: 'Lurus API curl 请求示例',
    },
    audiences: {
      entrepreneur: {
        description: '一个端点接入 50+ AI 模型。OpenAI 兼容接口，零迁移成本。多租户隔离、用量配额、智能路由 — 企业级 AI 接入从第一天开始。',
        features: ['50+ AI 模型统一接入', 'OpenAI 兼容 — 零迁移', '多租户隔离与配额管理', '智能路由与自动故障转移', '99.9% 可用性 SLA'],
        cta: { text: '注册试用', href: 'https://api.lurus.cn', external: true },
      },
      builder: {
        tagline: '白标 LLM 网关',
        description: '在你的品牌下提供 AI 模型访问服务。私有化部署、自定义定价、完全白标 — 你的客户看到的是你的品牌。',
        features: ['完全白标 — 你的品牌', '自定义定价与配额', '私有化部署选项', '多租户管理后台', '50+ 模型即时可用', '请求日志与分析'],
        cta: { text: '联系我们', href: 'mailto:support@lurus.cn', external: true },
      },
    },
  },
  {
    id: 'switch',
    name: 'Lurus Switch',
    tagline: 'AI 工具管理器',
    description: '统一管理所有 AI CLI 工具的配置、密钥和代理 — Claude Code、Codex、Gemini CLI，一个面板搞定',
    useCase: '一个面板管理所有 AI 命令行工具',
    url: '/download',
    docsUrl: 'https://docs.lurus.cn/switch/',
    icon: 'desktop',
    color: 'product-switch',
    neonColor: '#FF8C69',
    bgColor: '#FF8C69',
    features: ['多工具统一配置', 'API Key 集中管理', 'MCP 预设分发', '代理与快照管理'],
    stats: { value: '10+', label: 'CLI 工具支持' },
    layer: 'infra' as const,
    navGroup: 'infra' as const,
    navDesc: '统一管理所有 AI CLI 工具',
    external: false,
    iconPath: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    showcase: {
      type: 'features' as const,
      fallbackFeatures: [
        'Claude Code / Codex / Gemini CLI 统一管理',
        'API Key 集中分发与轮换',
        'MCP Server 预设一键同步',
        '代理配置与环境快照',
      ],
    },
    audiences: {
      explorer: {
        tagline: 'AI 工具管家',
        description: '一站式管理 Claude Code、Codex CLI、Gemini CLI 等 AI 工具 — 配置、密钥、代理、MCP 预设，一个面板全搞定。',
        features: ['5+ AI CLI 工具管理', '配置自动生成', 'MCP 预设库', '配置快照与差异对比', '计费仪表盘'],
        cta: { text: '下载 Switch', href: '/download' },
      },
      entrepreneur: {
        tagline: '团队 AI 工具管理',
        description: '统一管理团队的 AI CLI 工具配置。密钥集中管理、代理统一配置、MCP 预设分发 — 从 "每人自己配" 到 "一键同步"。',
        features: ['团队配置统一管理', '密钥集中分发', '代理与 MCP 预设', '使用量统计', '合规审计'],
        cta: { text: '下载 Switch', href: '/download' },
      },
    },
  },
  {
    id: 'lucrum',
    name: 'Lucrum',
    tagline: 'AI 量化交易',
    description: '基于 AI 的智能量化交易平台，自然语言描述策略需求，AI 自动生成可执行代码',
    useCase: '自然语言描述 → AI 生成量化策略',
    url: 'https://gushen.lurus.cn',
    docsUrl: 'https://docs.lurus.cn/lucrum/',
    icon: 'chart',
    color: 'product-lucrum',
    neonColor: '#7AFF89',
    bgColor: '#7D8B6A',
    features: ['AI 策略引擎', '实时行情', '风险控制', '回测模拟'],
    stats: { value: '50+', label: '量化策略' },
    layer: 'app' as const,
    navGroup: 'consumer' as const,
    navDesc: '自然语言驱动 AI 量化交易',
    external: true,
    iconPath: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
    showcase: {
      type: 'screenshot' as const,
      screenshotSrc: '',
      screenshotAlt: 'Lucrum 量化交易平台策略编辑器',
      fallbackCode: `# Natural language → AI-generated strategy
def strategy(context):
    """Buy when 5-day MA crosses above 20-day MA"""
    ma5 = context.ta.sma(period=5)
    ma20 = context.ta.sma(period=20)

    if ma5[-1] > ma20[-1] and ma5[-2] <= ma20[-2]:
        context.order_percent("BTC/USDT", 0.5)`,
      fallbackLanguage: 'bash',
      fallbackAriaLabel: 'Lucrum AI 量化策略代码示例',
    },
    audiences: {
      explorer: {
        description: '用自然语言描述你的交易策略，AI 自动生成可执行的量化代码。30+ 金融指标，专业级回测引擎，从想法到策略只需一句话。',
        features: ['自然语言策略生成', '30+ 金融指标', '专业级回测引擎', '多策略同时验证', '11 个投资流派 AI 顾问'],
        cta: { text: '访问 Lucrum', href: 'https://gushen.lurus.cn', external: true },
      },
      entrepreneur: {
        tagline: '机构量化服务',
        description: '面向金融机构的量化交易解决方案。专业级策略引擎、风控系统、合规报告 — 从研究到实盘的完整闭环。',
        features: ['专业级策略引擎', '风险控制系统', '合规报告生成', '多策略组合管理', '机构级数据安全'],
        cta: { text: '联系我们', href: 'mailto:support@lurus.cn', external: true },
      },
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
    neonColor: '#4AFFCB',
    bgColor: '#8B7A5C',
    features: ['持久记忆', '语义检索', '本地优先', '隐私加密'],
    stats: { value: '∞', label: '记忆容量' },
    layer: 'app' as const,
    navGroup: 'consumer' as const,
    navDesc: '跨会话持久 AI 记忆引擎',
    external: false,
    iconPath: 'M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4',
    audiences: {
      explorer: {
        description: '让 AI 永远记住你 — 你的偏好、你的文档、你的工作上下文。跨会话、跨工具的持久记忆，语义检索即用即得。',
        features: ['跨会话持久记忆', '语义检索', '本地优先存储', '端到端加密', '一行命令安装 (pip)'],
        cta: { text: '安装 MemX', href: '/download#memx' },
      },
      builder: {
        tagline: 'AI 记忆基础设施',
        description: '为你的产品添加跨会话持久记忆。语义检索、本地优先、端到端加密 — 让你的 AI 应用拥有"记住用户"的能力，3 行代码接入。',
        features: ['跨会话持久化存储', '语义向量检索', '本地优先 + 端到端加密', 'Python SDK (pip install)', 'REST API 接口', '无限记忆容量'],
        cta: { text: '安装 SDK', href: '/download#memx' },
      },
    },
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
    neonColor: '#B08EFF',
    bgColor: '#B08EFF',
    features: ['WAL 持久化状态', 'Rust 零 GC 延迟', 'Agent Loop 断点恢复', '编译时类型安全'],
    stats: { value: '0ms', label: 'GC 停顿' },
    layer: 'infra' as const,
    navGroup: 'dev' as const,
    navDesc: 'Rust Agent 持久化执行框架',
    external: false,
    iconPath: 'M9 3H7a2 2 0 00-2 2v2M9 3h6M9 3v2m6-2h2a2 2 0 012 2v2m0 0V7m0 0h2M3 9v6m0 0v2a2 2 0 002 2h2m-4-4h2M21 9v6m0 0v2a2 2 0 01-2 2h-2m4-4h-2M9 21h6M9 21v-2m6 2v-2M9 19H7a2 2 0 01-2-2v-2m14 4h-2a2 2 0 01-2-2v-2',
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
    audiences: {
      builder: {
        description: '将 WAL 预写日志引入 Agent 执行引擎。崩溃重启后自动从断点恢复，Rust 零 GC 保障 μs 级确定性延迟。构建生产级、永不中断的 AI Agent。',
        features: ['WAL 持久化，掉电不丢状态', 'Rust 零 GC，μs 级响应', 'Agent Loop 断点自动恢复', 'Plan → Execute → Review 循环', '编译时类型安全', 'Async + 多线程调度'],
        cta: { text: '查看文档', href: 'https://docs.lurus.cn', external: true },
      },
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
    neonColor: '#FFB86C',
    bgColor: '#FFB86C',
    features: ['yt-dlp 视频抓取', 'Whisper AI 转录', 'LLM 内容优化', '多平台一键发布'],
    stats: { value: '3', label: '步完成发布' },
    layer: 'app' as const,
    navGroup: 'consumer' as const,
    navDesc: '视频→AI 转录→多平台发布',
    external: false,
    iconPath: 'M15 10l4.553-2.069A1 1 0 0121 8.845v6.31a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z',
    audiences: {
      explorer: {
        description: '输入视频链接，yt-dlp 自动下载，Whisper 高精度转录，LLM 优化文案，一键同步到微信视频号、抖音、YouTube — 全流程无需手动操作。',
        features: ['yt-dlp 视频抓取', 'Whisper 语音转录', 'LLM 文案优化', '多平台一键发布', '本地运行 · 零云依赖'],
        cta: { text: '下载 Creator', href: '/download' },
      },
    },
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
    neonColor: '#FFE566',
    bgColor: '#FFE566',
    features: ['实时 Agent 追踪', '断点调试注入', '状态树可视化', '日志导出'],
    stats: { value: '<5ms', label: '追踪延迟' },
    layer: 'infra' as const,
    navGroup: 'dev' as const,
    navDesc: 'Agent 执行可视化调试 CLI',
    external: false,
    iconPath: 'M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4',
    showcase: {
      type: 'features' as const,
      fallbackFeatures: [
        '实时 Agent 执行 flamechart',
        '断点注入与暂停恢复',
        '状态树可视化检查',
        'CLI 日志结构化导出',
      ],
    },
    audiences: {
      builder: {
        tagline: 'Agent 执行可视化与调试 CLI',
        description: '让 Agent 执行过程透明可见。实时追踪调用链与每步耗时，支持断点注入和状态树检查 — 开发阶段必备，生产排查利器。',
        features: ['实时执行 flamechart', '断点注入与暂停', '状态树可视化', 'CLI 日志导出', '与 Kova SDK 无缝集成', '零侵入式接入'],
        cta: { text: '查看文档', href: 'https://docs.lurus.cn', external: true },
      },
    },
  },
  {
    id: 'forge',
    name: 'Forge',
    tagline: 'AI 产品开发工作台',
    description: '对话即需求 — 用自然语言描述产品想法，AI PM Agent 自动生成结构化需求树',
    useCase: '对话 → 需求树 → 可执行 Story',
    url: 'https://docs.lurus.cn',
    icon: 'building',
    color: 'product-creator',
    neonColor: '#FF6B35',
    bgColor: '#FF6B35',
    features: ['对话→需求树自动生成', 'AI PM / Architect / Code Agent', '产品本体论（7 级知识图谱）', 'Kova WAL 保障任务不丢失'],
    stats: { value: '7', label: '级知识图谱' },
    layer: 'app' as const,
    navGroup: 'dev' as const,
    navDesc: 'AI 产品开发工作台',
    external: true,
    iconPath: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4',
    audiences: {
      builder: {
        description: '对话即需求 — 用自然语言描述产品想法，AI PM Agent 自动生成结构化需求树。从模糊构想到可执行 Story，一场对话搞定。运行在 Kova 之上，Agent 任务永不丢失。',
        features: ['对话 → 需求树自动生成', 'AI PM / Architect / Code Agent', '产品本体论（7 级知识图谱）', 'Kova WAL 保障任务不丢失', '依赖守护者（自动升级分析）', '实时协作 (WebSocket)'],
        cta: { text: '了解 Forge', href: 'https://docs.lurus.cn', external: true },
      },
    },
  },
  {
    id: 'identity',
    name: 'Lurus Identity',
    tagline: '身份认证 + 订阅计费',
    description: '不再重复造认证和计费系统。OIDC 标准认证、订阅管理、钱包系统 — 3 天集成',
    useCase: 'OIDC 认证 + 订阅计费一站式',
    url: 'https://identity.lurus.cn',
    icon: 'shield',
    color: 'product-deaigc',
    neonColor: '#C77DBA',
    bgColor: '#8B6B7D',
    features: ['OIDC + gRPC 双协议', '订阅管理 + 钱包', '多支付网关', '角色权限 + 审计'],
    stats: { value: '3', label: '天完成集成' },
    layer: 'infra' as const,
    navGroup: 'dev' as const,
    navDesc: '认证 + 订阅 + 计费平台',
    external: true,
    iconPath: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z',
    showcase: {
      type: 'code' as const,
      fallbackCode: `# OIDC token exchange — integrate in minutes\ncurl -X POST https://auth.lurus.cn/oauth/v2/token \\\n  -d grant_type=client_credentials \\\n  -d client_id=$CLIENT_ID \\\n  -d client_secret=$CLIENT_SECRET \\\n  -d scope="openid profile email"\n\n# Subscribe user to a plan\ncurl -X POST https://identity.lurus.cn/v1/subscriptions \\\n  -H "Authorization: Bearer $TOKEN" \\\n  -d '{"plan_id":"pro","user_id":"usr_123"}'`,
      fallbackLanguage: 'bash',
      fallbackAriaLabel: 'Lurus Identity OIDC and subscription API example',
    },
    audiences: {
      builder: {
        description: '不再重复造认证和计费系统。OIDC 标准认证、订阅管理、钱包系统、角色权限 — 3 天集成而不是 3 个月。适用于任何需要用户体系的 SaaS 产品。',
        features: ['OIDC + gRPC 双协议支持', '订阅管理 + 钱包系统', '多支付网关 (Stripe / WeChat / Alipay)', '角色权限 + 权限缓存', '审计日志 + 邮件通知', '服务间 API (Bearer Key)'],
        cta: { text: '查看文档', href: 'https://docs.lurus.cn', external: true },
      },
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
  shield: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z',
  building: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4',
}

/**
 * curl example for API showcase (API quick start example)
 */
export const curlExample = `curl https://api.lurus.cn/v1/chat/completions \
  -H "Authorization: Bearer $LURUS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hello"}]}'`

// ── Helper functions ────────────────────────────────────────────────

type AudienceKey = 'explorer' | 'entrepreneur' | 'builder'

interface AudienceProduct {
  id: string
  name: string
  tagline: string
  description: string
  features: string[]
  cta: { text: string; href: string; external?: boolean }
  color: string
  iconPath: string
  icon: string
  neonColor?: string
  showcase?: Product['showcase']
}

/**
 * Returns products filtered and overridden for a specific audience.
 */
export function getProductsForAudience(audience: AudienceKey): AudienceProduct[] {
  return products
    .filter(p => p.audiences?.[audience])
    .map(p => {
      const override = p.audiences![audience]!
      return {
        id: p.id,
        name: p.name,
        tagline: override.tagline ?? p.tagline,
        description: override.description ?? p.description,
        features: override.features ?? p.features,
        cta: override.cta ?? { text: '了解更多', href: p.url, external: p.external },
        color: p.bgColor,
        iconPath: p.iconPath ?? '',
        icon: p.icon,
        neonColor: p.neonColor,
        showcase: p.showcase,
      }
    })
}

interface NavProduct {
  name: string
  desc: string
  icon: string
  href: string
  external: boolean
}

/**
 * Returns products grouped for the TopBar mega menu.
 */
export function getNavProducts(): { consumer: NavProduct[]; infra: NavProduct[]; dev: NavProduct[] } {
  const consumer: NavProduct[] = []
  const infra: NavProduct[] = []
  const dev: NavProduct[] = []

  for (const p of products) {
    if (!p.navGroup) continue
    const item: NavProduct = {
      name: p.name,
      desc: p.navDesc ?? p.tagline,
      icon: p.icon,
      href: p.url,
      external: p.external ?? false,
    }
    if (p.navGroup === 'consumer') consumer.push(item)
    else if (p.navGroup === 'infra') infra.push(item)
    else dev.push(item)
  }

  return { consumer, infra, dev }
}

interface FooterProduct {
  name: string
  href: string
}

/**
 * Returns product lists for the Footer.
 */
export function getFooterProducts(): { explorers: FooterProduct[]; entrepreneurs: FooterProduct[]; builders: FooterProduct[] } {
  const explorers: FooterProduct[] = []
  const entrepreneurs: FooterProduct[] = []
  const builders: FooterProduct[] = []

  for (const p of products) {
    if (p.audiences?.explorer) {
      explorers.push({ name: p.name, href: p.url })
    }
    if (p.audiences?.entrepreneur) {
      entrepreneurs.push({ name: p.name, href: p.url })
    }
    if (p.audiences?.builder) {
      builders.push({ name: p.name, href: p.url })
    }
  }

  return { explorers, entrepreneurs, builders }
}
