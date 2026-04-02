defmodule LurusWww.Data.Downloads do
  @moduledoc false

  @products [
    %{id: "acest", release_product_id: "acest-desktop", name: "ACEST Desktop", tagline: "AI Desktop Assistant", description: "自适应上下文智能任务引擎 — 桌面 AI 助手，55+ 技能覆盖十大领域", icon: "brain", platforms: [:windows], install_method: :binary, is_released: true, color: "#D4A827"},
    %{id: "switch", release_product_id: "lurus-switch", name: "Lurus Switch", tagline: "Local AI Gateway", description: "本地 AI 网关 — 充一次钱用所有工具，统一计费、智能路由、透明用量追踪", icon: "desktop", platforms: [:windows, :darwin], install_method: :binary, is_released: true, color: "#FF8C69"},
    %{id: "creator", release_product_id: "lurus-creator", name: "Lurus Creator", tagline: "Content Factory", description: "视频抓取 → Whisper 转录 → LLM 编辑 → 多平台一键发布", icon: "video", platforms: [:windows, :darwin], install_method: :binary, is_released: true, color: "#FFB86C"},
    %{id: "memx", release_product_id: "memx", name: "MemX", tagline: "AI Memory Engine", description: "零 LLM 成本的自适应 AI 记忆框架，让智能体学会记忆与遗忘", icon: "database", platforms: [:windows, :darwin, :linux], install_method: :pip, install_command: "pip install memx", is_released: true, color: "#8B7A5C"},
    %{id: "lumen", release_product_id: "lumen", name: "Lumen", tagline: "Agent Debugger CLI", description: "Agent 开发者专用调试 CLI，实时可视化执行轨迹", icon: "bug", platforms: [:windows, :darwin, :linux], install_method: :cargo, install_command: "cargo install lumen-cli", is_released: false, color: "#FFE566"},
    %{id: "lutu", release_product_id: "lutu", name: "Lutu", tagline: "Mobile AI Client", description: "Lurus 移动端，随时随地使用 AI 工具", icon: "mobile", platforms: [:android, :ios], install_method: :app_store, is_released: false, color: "#6B8BA4"}
  ]

  def all, do: @products

  def by_id(id), do: Enum.find(@products, &(&1.id == id))

  def for_platform(platform) do
    Enum.filter(@products, fn p -> p.is_released and platform in p.platforms end)
  end

  def released_binaries do
    Enum.filter(@products, fn p -> p.is_released and p.install_method == :binary end)
  end
end
