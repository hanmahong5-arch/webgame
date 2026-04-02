defmodule LurusWww.Data.Products do
  @moduledoc false

  @products [
    %{
      id: "api",
      name: "Lurus API",
      tagline: "LLM 统一网关",
      description: "一站式接入 Claude、GPT、Gemini 等主流 AI 模型，提供稳定、低延迟的企业级 API 服务",
      use_case: "3 行代码接入 50+ AI 模型",
      url: "https://api.lurus.cn",
      docs_url: "https://docs.lurus.cn/guide/quickstart",
      icon: "api",
      color: "product-api",
      neon_color: "#4A9EFF",
      bg_color: "#6B8BA4",
      features: ["统一 API 接口", "智能负载均衡", "用量监控分析", "多租户支持"],
      stats: %{value: "99.9%", label: "可用性"},
      layer: :infra,
      nav_group: :infra,
      nav_desc: "LLM 统一网关，50+ 模型一端点",
      external: true,
      icon_path: "M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z",
      showcase: %{
        type: :code,
        code: "curl https://api.lurus.cn/v1/chat/completions \\\n  -H \"Authorization: Bearer $LURUS_API_KEY\" \\\n  -H \"Content-Type: application/json\" \\\n  -d '{\"model\":\"deepseek-chat\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'",
        language: "bash"
      },
      audiences: %{
        entrepreneur: %{
          description: "一个端点接入 50+ AI 模型。OpenAI 兼容接口，零迁移成本。多租户隔离、用量配额、智能路由 — 企业级 AI 接入从第一天开始。",
          features: ["50+ AI 模型统一接入", "OpenAI 兼容 — 零迁移", "多租户隔离与配额管理", "智能路由与自动故障转移", "99.9% 可用性 SLA"],
          cta: %{text: "注册试用", href: "https://api.lurus.cn", external: true}
        },
        builder: %{
          tagline: "白标 LLM 网关",
          description: "在你的品牌下提供 AI 模型访问服务。私有化部署、自定义定价、完全白标 — 你的客户看到的是你的品牌。",
          features: ["完全白标 — 你的品牌", "自定义定价与配额", "私有化部署选项", "多租户管理后台", "50+ 模型即时可用", "请求日志与分析"],
          cta: %{text: "联系我们", href: "mailto:support@lurus.cn", external: true}
        }
      }
    },
    %{
      id: "switch",
      name: "Lurus Switch",
      tagline: "AI 工具管理器",
      description: "统一管理所有 AI CLI 工具的配置、密钥和代理 — Claude Code、Codex、Gemini CLI，一个面板搞定",
      use_case: "一个面板管理所有 AI 命令行工具",
      url: "/download",
      icon: "desktop",
      color: "product-switch",
      neon_color: "#FF8C69",
      bg_color: "#FF8C69",
      features: ["多工具统一配置", "API Key 集中管理", "MCP 预设分发", "代理与快照管理"],
      stats: %{value: "10+", label: "CLI 工具支持"},
      layer: :infra,
      nav_group: :infra,
      nav_desc: "统一管理所有 AI CLI 工具",
      external: false,
      icon_path: "M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z",
      audiences: %{
        explorer: %{
          tagline: "AI 工具管家",
          description: "一站式管理 Claude Code、Codex CLI、Gemini CLI 等 AI 工具 — 配置、密钥、代理、MCP 预设，一个面板全搞定。",
          features: ["5+ AI CLI 工具管理", "配置自动生成", "MCP 预设库", "配置快照与差异对比", "计费仪表盘"],
          cta: %{text: "下载 Switch", href: "/download"}
        },
        entrepreneur: %{
          tagline: "团队 AI 工具管理",
          description: "统一管理团队的 AI CLI 工具配置。密钥集中管理、代理统一配置、MCP 预设分发 — 从 \"每人自己配\" 到 \"一键同步\"。",
          features: ["团队配置统一管理", "密钥集中分发", "代理与 MCP 预设", "使用量统计", "合规审计"],
          cta: %{text: "下载 Switch", href: "/download"}
        }
      }
    },
    %{
      id: "lucrum",
      name: "Lucrum",
      tagline: "AI 量化交易",
      description: "基于 AI 的智能量化交易平台，自然语言描述策略需求，AI 自动生成可执行代码",
      use_case: "自然语言描述 → AI 生成量化策略",
      url: "https://lucrum.lurus.cn",
      icon: "chart",
      color: "product-lucrum",
      neon_color: "#7AFF89",
      bg_color: "#7D8B6A",
      features: ["AI 策略引擎", "实时行情", "风险控制", "回测模拟"],
      stats: %{value: "50+", label: "量化策略"},
      layer: :app,
      nav_group: :consumer,
      nav_desc: "自然语言驱动 AI 量化交易",
      external: true,
      icon_path: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z",
      audiences: %{
        explorer: %{
          description: "用自然语言描述你的交易策略，AI 自动生成可执行的量化代码。30+ 金融指标，专业级回测引擎，从想法到策略只需一句话。",
          features: ["自然语言策略生成", "30+ 金融指标", "专业级回测引擎", "多策略同时验证", "11 个投资流派 AI 顾问"],
          cta: %{text: "访问 Lucrum", href: "https://lucrum.lurus.cn", external: true}
        },
        entrepreneur: %{
          tagline: "机构量化服务",
          description: "面向金融机构的量化交易解决方案。专业级策略引擎、风控系统、合规报告 — 从研究到实盘的完整闭环。",
          features: ["专业级策略引擎", "风险控制系统", "合规报告生成", "多策略组合管理", "机构级数据安全"],
          cta: %{text: "联系我们", href: "mailto:support@lurus.cn", external: true}
        }
      }
    },
    %{
      id: "memx",
      name: "MemX",
      tagline: "AI 记忆扩展",
      description: "个人知识库与 AI 记忆层，让 AI 记住你的偏好、文档和工作上下文，跨会话持久化",
      use_case: "跨会话持久 AI 记忆",
      url: "/download#memx",
      icon: "database",
      color: "product-memx",
      neon_color: "#4AFFCB",
      bg_color: "#8B7A5C",
      features: ["持久记忆", "语义检索", "本地优先", "隐私加密"],
      stats: %{value: "∞", label: "记忆容量"},
      layer: :app,
      nav_group: :consumer,
      nav_desc: "跨会话持久 AI 记忆引擎",
      external: false,
      icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4",
      audiences: %{
        explorer: %{
          description: "让 AI 永远记住你 — 你的偏好、你的文档、你的工作上下文。跨会话、跨工具的持久记忆，语义检索即用即得。",
          features: ["跨会话持久记忆", "语义检索", "本地优先存储", "端到端加密", "一行命令安装 (pip)"],
          cta: %{text: "安装 MemX", href: "/download#memx"}
        },
        builder: %{
          tagline: "AI 记忆基础设施",
          description: "为你的产品添加跨会话持久记忆。语义检索、本地优先、端到端加密 — 让你的 AI 应用拥有\"记住用户\"的能力，3 行代码接入。",
          features: ["跨会话持久化存储", "语义向量检索", "本地优先 + 端到端加密", "Python SDK (pip install)", "REST API 接口", "无限记忆容量"],
          cta: %{text: "安装 SDK", href: "/download#memx"}
        }
      }
    },
    %{
      id: "kova",
      name: "Kova",
      tagline: "Rust Agent SDK",
      description: "Rust 构建的 AI Agent 持久执行引擎，WAL 级别的状态持久化，掉电不丢失，Agent Loop 自动恢复",
      use_case: "Rust 原生 Agent 持久化执行框架",
      url: "/for-builders#kova",
      icon: "cpu",
      color: "product-kova",
      neon_color: "#B08EFF",
      bg_color: "#B08EFF",
      features: ["WAL 持久化状态", "Rust 零 GC 延迟", "Agent Loop 断点恢复", "编译时类型安全"],
      stats: %{value: "0ms", label: "GC 停顿"},
      layer: :infra,
      nav_group: :dev,
      nav_desc: "Rust Agent 持久化执行框架",
      external: false,
      icon_path: "M9 3H7a2 2 0 00-2 2v2M9 3h6M9 3v2m6-2h2a2 2 0 012 2v2m0 0V7m0 0h2M3 9v6m0 0v2a2 2 0 002 2h2m-4-4h2M21 9v6m0 0v2a2 2 0 01-2 2h-2m4-4h-2M9 21h6M9 21v-2m6 2v-2M9 19H7a2 2 0 01-2-2v-2m14 4h-2a2 2 0 01-2-2v-2",
      audiences: %{
        builder: %{
          description: "将 WAL 预写日志引入 Agent 执行引擎。崩溃重启后自动从断点恢复，Rust 零 GC 保障 μs 级确定性延迟。构建生产级、永不中断的 AI Agent。",
          features: ["WAL 持久化，掉电不丢状态", "Rust 零 GC，μs 级响应", "Agent Loop 断点自动恢复", "Plan → Execute → Review 循环", "编译时类型安全", "Async + 多线程调度"],
          cta: %{text: "查看文档", href: "https://docs.lurus.cn", external: true}
        }
      }
    },
    %{
      id: "creator",
      name: "Lurus Creator",
      tagline: "桌面内容工厂",
      description: "一站式 AI 内容创作桌面应用：视频抓取 → Whisper 转录 → LLM 编辑 → 多平台一键发布",
      use_case: "视频→文稿→多平台，一键完成",
      url: "/download",
      icon: "video",
      color: "product-creator",
      neon_color: "#FFB86C",
      bg_color: "#FFB86C",
      features: ["yt-dlp 视频抓取", "Whisper AI 转录", "LLM 内容优化", "多平台一键发布"],
      stats: %{value: "3", label: "步完成发布"},
      layer: :app,
      nav_group: :consumer,
      nav_desc: "视频→AI 转录→多平台发布",
      external: false,
      icon_path: "M15 10l4.553-2.069A1 1 0 0121 8.845v6.31a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z",
      audiences: %{
        explorer: %{
          description: "输入视频链接，yt-dlp 自动下载，Whisper 高精度转录，LLM 优化文案，一键同步到微信视频号、抖音、YouTube — 全流程无需手动操作。",
          features: ["yt-dlp 视频抓取", "Whisper 语音转录", "LLM 文案优化", "多平台一键发布", "本地运行 · 零云依赖"],
          cta: %{text: "下载 Creator", href: "/download"}
        }
      }
    },
    %{
      id: "lumen",
      name: "Lumen",
      tagline: "Agent 调试工具",
      description: "Agent 开发者专用调试 CLI，实时可视化 Agent 执行轨迹，断点注入与状态树检查",
      use_case: "Agent 执行可视化与断点调试",
      url: "/for-builders#lumen",
      icon: "bug",
      color: "product-lumen",
      neon_color: "#FFE566",
      bg_color: "#FFE566",
      features: ["实时 Agent 追踪", "断点调试注入", "状态树可视化", "日志导出"],
      stats: %{value: "<5ms", label: "追踪延迟"},
      layer: :infra,
      nav_group: :dev,
      nav_desc: "Agent 执行可视化调试 CLI",
      external: false,
      icon_path: "M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4",
      audiences: %{
        builder: %{
          tagline: "Agent 执行可视化与调试 CLI",
          description: "让 Agent 执行过程透明可见。实时追踪调用链与每步耗时，支持断点注入和状态树检查 — 开发阶段必备，生产排查利器。",
          features: ["实时执行 flamechart", "断点注入与暂停", "状态树可视化", "CLI 日志导出", "与 Kova SDK 无缝集成", "零侵入式接入"],
          cta: %{text: "查看文档", href: "https://docs.lurus.cn", external: true}
        }
      }
    },
    %{
      id: "forge",
      name: "Forge",
      tagline: "AI 产品开发工作台",
      description: "对话即需求 — 用自然语言描述产品想法，AI PM Agent 自动生成结构化需求树",
      use_case: "对话 → 需求树 → 可执行 Story",
      url: "https://docs.lurus.cn",
      icon: "building",
      color: "product-creator",
      neon_color: "#FF6B35",
      bg_color: "#FF6B35",
      features: ["对话→需求树自动生成", "AI PM / Architect / Code Agent", "产品本体论（7 级知识图谱）", "Kova WAL 保障任务不丢失"],
      stats: %{value: "7", label: "级知识图谱"},
      layer: :app,
      nav_group: :dev,
      nav_desc: "AI 产品开发工作台",
      external: true,
      icon_path: "M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4",
      audiences: %{
        builder: %{
          description: "对话即需求 — 用自然语言描述产品想法，AI PM Agent 自动生成结构化需求树。从模糊构想到可执行 Story，一场对话搞定。运行在 Kova 之上，Agent 任务永不丢失。",
          features: ["对话 → 需求树自动生成", "AI PM / Architect / Code Agent", "产品本体论（7 级知识图谱）", "Kova WAL 保障任务不丢失", "依赖守护者（自动升级分析）", "实时协作 (WebSocket)"],
          cta: %{text: "了解 Forge", href: "https://docs.lurus.cn", external: true}
        }
      }
    },
    %{
      id: "identity",
      name: "Lurus Identity",
      tagline: "身份认证 + 订阅计费",
      description: "不再重复造认证和计费系统。OIDC 标准认证、订阅管理、钱包系统 — 3 天集成",
      use_case: "OIDC 认证 + 订阅计费一站式",
      url: "https://identity.lurus.cn",
      icon: "shield",
      color: "product-deaigc",
      neon_color: "#C77DBA",
      bg_color: "#8B6B7D",
      features: ["OIDC + gRPC 双协议", "订阅管理 + 钱包", "多支付网关", "角色权限 + 审计"],
      stats: %{value: "3", label: "天完成集成"},
      layer: :infra,
      nav_group: :dev,
      nav_desc: "认证 + 订阅 + 计费平台",
      external: true,
      icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z",
      audiences: %{
        builder: %{
          description: "不再重复造认证和计费系统。OIDC 标准认证、订阅管理、钱包系统、角色权限 — 3 天集成而不是 3 个月。适用于任何需要用户体系的 SaaS 产品。",
          features: ["OIDC + gRPC 双协议支持", "订阅管理 + 钱包系统", "多支付网关 (Stripe / WeChat / Alipay)", "角色权限 + 权限缓存", "审计日志 + 邮件通知", "服务间 API (Bearer Key)"],
          cta: %{text: "查看文档", href: "https://docs.lurus.cn", external: true}
        }
      }
    }
  ]

  def all, do: @products

  def by_id(id), do: Enum.find(@products, &(&1.id == id))

  def for_audience(audience) when audience in [:explorer, :entrepreneur, :builder] do
    @products
    |> Enum.filter(&Map.has_key?(&1.audiences, audience))
    |> Enum.map(fn p ->
      override = p.audiences[audience]

      %{
        id: p.id,
        name: p.name,
        tagline: Map.get(override, :tagline, p.tagline),
        description: Map.get(override, :description, p.description),
        features: Map.get(override, :features, p.features),
        cta: Map.get(override, :cta, %{text: "了解更多", href: p.url, external: p[:external] || false}),
        color: p.bg_color,
        icon_path: p.icon_path,
        icon: p.icon,
        neon_color: p.neon_color,
        showcase: p[:showcase]
      }
    end)
  end

  def nav_products do
    groups = Enum.group_by(@products, & &1.nav_group)

    to_nav = fn list ->
      Enum.map(list || [], fn p ->
        %{name: p.name, desc: p.nav_desc || p.tagline, icon: p.icon, href: p.url, external: p[:external] || false}
      end)
    end

    %{consumer: to_nav.(groups[:consumer]), infra: to_nav.(groups[:infra]), dev: to_nav.(groups[:dev])}
  end

  def footer_products do
    explorers = for p <- @products, Map.has_key?(p.audiences, :explorer), do: %{name: p.name, href: p.url}
    entrepreneurs = for p <- @products, Map.has_key?(p.audiences, :entrepreneur), do: %{name: p.name, href: p.url}
    builders = for p <- @products, Map.has_key?(p.audiences, :builder), do: %{name: p.name, href: p.url}

    %{explorers: explorers, entrepreneurs: entrepreneurs, builders: builders}
  end
end
