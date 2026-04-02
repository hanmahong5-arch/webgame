defmodule LurusWww.Data.Pricing do
  @moduledoc false

  @audience_tiers [
    %{code: :personal, name: "个人", tagline: "独立开发者、学生、个人用户", icon: "👤", highlight: false},
    %{code: :team, name: "团队", tagline: "初创团队、工作室、中小企业", icon: "👥", highlight: true},
    %{code: :platform, name: "平台", tagline: "企业、SaaS 平台、OEM 集成", icon: "🏢", highlight: false}
  ]

  @audience_products %{
    personal: [
      %{id: "api-personal", name: "API 接入", description: "一个 Key 调用 50+ AI 模型", monthly_price: 0, yearly_price: 0, unit: "月", features: ["免费额度 5 万 Token/天", "支持 Claude / GPT / Gemini", "标准 API 响应速度", "社区支持"], status: :available, popular: false},
      %{id: "api-pro", name: "API 专业版", description: "更高配额，更快响应", monthly_price: 59.9, yearly_price: 47.9, unit: "月", features: ["每日 100 万 Token 配额", "优先响应通道", "配额降级保护", "工单客服支持"], status: :available, popular: true},
      %{id: "switch-personal", name: "Switch 桌面端", description: "统一管理你的 AI 工具", monthly_price: 0, yearly_price: 0, unit: "月", features: ["免费使用", "管理 3 个 AI 工具", "基础代理配置", "社区支持"], status: :available, popular: false},
      %{id: "memx-personal", name: "MemX 记忆", description: "让 AI 记住你", monthly_price: nil, yearly_price: nil, unit: "月", features: ["跨工具记忆同步", "个人偏好存储", "项目上下文管理"], status: :coming_soon, popular: false}
    ],
    team: [
      %{id: "api-team", name: "API 团队版", description: "团队共享配额与管理", monthly_price: 199, yearly_price: 159, unit: "月", features: ["团队共享 500 万 Token/天", "成员用量管理面板", "多 API Key 管理", "优先客服支持"], status: :available, popular: true},
      %{id: "switch-team", name: "Switch 团队版", description: "团队统一工具配置", monthly_price: 29.9, yearly_price: 23.9, unit: "人/月", features: ["团队配置同步", "管理无限 AI 工具", "共享 MCP 预设", "管理员控制台"], status: :available, popular: false},
      %{id: "lucrum-team", name: "Lucrum 量化", description: "AI 驱动的量化交易", monthly_price: nil, yearly_price: nil, unit: "月", features: ["AI 策略分析", "实时行情数据", "回测与模拟交易"], status: :coming_soon, popular: false}
    ],
    platform: [
      %{id: "api-platform", name: "API 平台版", description: "大规模 AI 接入方案", monthly_price: nil, yearly_price: nil, unit: "月", features: ["定制配额与速率限制", "专属模型路由", "99.9% SLA 保障", "1对1 技术支持", "企业发票"], status: :available, popular: true},
      %{id: "switch-platform", name: "Switch OEM", description: "白标桌面端定制", monthly_price: nil, yearly_price: nil, unit: "月", features: ["品牌定制", "私有化部署", "SSO 集成", "专属技术支持"], status: :available, popular: false},
      %{id: "identity-platform", name: "Identity 平台", description: "统一身份与计费", monthly_price: nil, yearly_price: nil, unit: "月", features: ["统一用户认证", "计费与钱包系统", "SSO / OIDC 集成"], status: :coming_soon, popular: false}
    ]
  }

  @comparison_features [
    %{name: "API 调用配额", personal: "5万/天 (免费)", team: "500万/天", platform: "定制"},
    %{name: "支持模型数", personal: "50+", team: "50+", platform: "50+ (含专属)"},
    %{name: "响应速度", personal: "标准", team: "优先", platform: "专属通道"},
    %{name: "团队管理", personal: false, team: true, platform: true},
    %{name: "多 Key 管理", personal: false, team: true, platform: true},
    %{name: "SLA 保障", personal: false, team: false, platform: true},
    %{name: "SSO 集成", personal: false, team: false, platform: true},
    %{name: "专属客服", personal: false, team: true, platform: true},
    %{name: "企业发票", personal: false, team: false, platform: true},
    %{name: "私有化部署", personal: false, team: false, platform: true}
  ]

  @faq [
    %{question: "什么是 Token 配额？", answer: "Token 是 AI 模型处理文本的基本单位。日配额是每天可使用的 Token 数量，总配额是套餐期内的总可用量。一般来说，1 个汉字约等于 2 个 Token，1 个英文单词约等于 1 个 Token。"},
    %{question: "配额用完了怎么办？", answer: "日配额用完后，系统会自动降级到基础服务（响应速度可能变慢）。你也可以随时充值或升级套餐来增加配额。"},
    %{question: "个人版和团队版有什么区别？", answer: "个人版适合独立使用，提供基础免费额度。团队版支持多人共享配额、成员管理、多 API Key 管理等协作功能。"},
    %{question: "支持哪些支付方式？", answer: "我们支持支付宝、微信支付、银行卡（通过 Stripe）等多种支付方式。企业用户可以申请对公转账。"},
    %{question: "可以退款吗？", answer: "套餐购买后 7 天内，如未使用超过总配额的 10%，可以申请全额退款。超过 7 天或使用超过 10% 后，将按实际使用量计算退款金额。"},
    %{question: "如何获取企业发票？", answer: "平台版用户可以在控制台申请企业增值税发票。请确保填写正确的公司名称和税号。"},
    %{question: "如何切换套餐？", answer: "可以在控制台随时升级套餐，升级后按差价补费。降级需等当前套餐到期后生效，系统会自动切换。"},
    %{question: "企业定制套餐如何申请？", answer: "如需大额配额、专属模型部署或定制 SLA，请发送邮件至 enterprise@lurus.cn，我们的商务团队将在 24 小时内联系你。"}
  ]

  def tiers, do: @audience_tiers
  def products(tier), do: Map.get(@audience_products, tier, [])
  def comparison_features, do: @comparison_features
  def faq, do: @faq
  def support_email, do: "support@lurus.cn"
end
