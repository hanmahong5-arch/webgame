defmodule LurusWww.Data.Team do
  @moduledoc false

  @members [
    %{name: "核心工程", role: "Platform Engineering", bio: "负责 Lurus 平台核心基础设施：API 网关、身份认证、计费系统、可观测性。", initials: "PE", color: "#4A9EFF"},
    %{name: "Agent 研发", role: "Agent R&D", bio: "专注于 Kova 执行引擎、Lumen 调试器、Forge 工作台 — 构建下一代 AI Agent 基础设施。", initials: "AR", color: "#B08EFF"},
    %{name: "产品与设计", role: "Product & Design", bio: "从用户视角出发，打磨 Creator、Switch、MemX 等桌面产品的交互体验。", initials: "PD", color: "#FFB86C"},
    %{name: "量化金融", role: "Quantitative Finance", bio: "Lucrum 量化交易引擎的策略研发、回测系统、风控模型构建。", initials: "QF", color: "#7AFF89"}
  ]

  def members, do: @members
end
