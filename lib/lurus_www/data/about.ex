defmodule LurusWww.Data.About do
  @moduledoc false

  @milestones [
    %{year: "2024", event: "公司成立，确立 AI 基础设施服务方向"},
    %{year: "2025 Q1", event: "Lurus API 网关上线，支持 OpenAI / Anthropic"},
    %{year: "2025 Q2", event: "Lucrum AI 量化交易平台发布"},
    %{year: "2025 Q3", event: "接入 50+ 模型，日均 API 调用突破百万"},
    %{year: "2026 Q1", event: "Lurus Switch 桌面客户端发布，全平台覆盖"}
  ]

  @values [
    %{title: "可靠稳定", desc: "多节点部署，智能容灾，确保服务 7x24 小时稳定运行", icon: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"},
    %{title: "极致性能", desc: "优化网络路由，就近接入，提供极低延迟的访问体验", icon: "M13 10V3L4 14h7v7l9-11h-7z"},
    %{title: "透明定价", desc: "简单清晰的定价模式，按需付费，没有隐藏费用", icon: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"},
    %{title: "用户至上", desc: "产品决策从用户痛点出发，持续优化体验，让技术服务于人", icon: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"}
  ]

  @stats [
    %{value: "99.9%", label: "服务可用性"},
    %{value: "50+", label: "支持模型"},
    %{value: "<100ms", label: "平均延迟"},
    %{value: "24/7", label: "技术支持"}
  ]

  @tech_highlights [
    %{title: "企业级基础设施", desc: "多区域冗余部署，自动故障转移，持续交付流水线确保每次更新安全上线", icon: "M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"},
    %{title: "全链路安全", desc: "传输加密、密钥隔离、细粒度访问控制，保护每一次 API 调用和数据交换", icon: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"},
    %{title: "智能路由", desc: "根据模型可用性、延迟和成本自动选择最优路径，确保每个请求获得最佳响应", icon: "M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"}
  ]

  def milestones, do: @milestones
  def values, do: @values
  def stats, do: @stats
  def tech_highlights, do: @tech_highlights
end
