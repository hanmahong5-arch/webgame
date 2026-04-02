defmodule LurusWww.Data.Navigation do
  @moduledoc false

  @icon_paths %{
    "api" => "M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z",
    "chart" => "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z",
    "desktop" => "M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z",
    "database" => "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4",
    "cpu" => "M9 3H7a2 2 0 00-2 2v2M9 3h6M9 3v2m6-2h2a2 2 0 012 2v2m0 0V7m0 0h2M3 9v6m0 0v2a2 2 0 002 2h2m-4-4h2M21 9v6m0 0v2a2 2 0 01-2 2h-2m4-4h-2M9 21h6M9 21v-2m6 2v-2M9 19H7a2 2 0 01-2-2v-2m14 4h-2a2 2 0 01-2-2v-2",
    "video" => "M15 10l4.553-2.069A1 1 0 0121 8.845v6.31a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z",
    "bug" => "M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4",
    "shield" => "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z",
    "building" => "M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4",
    "brain" => "M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z",
    "mail" => "M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
  }

  def icon_paths, do: @icon_paths

  def icon_path(key), do: Map.get(@icon_paths, key, "")

  @nav_items [
    %{
      name: "探索者",
      path: "/for-explorers",
      children: [
        %{name: "Lucrum", desc: "自然语言驱动的 AI 量化交易", path: "https://lucrum.lurus.cn", external: true, icon: "chart"},
        %{name: "Lurus Creator", desc: "视频→AI 转录→多平台发布一键完成", path: "/download", icon: "video"},
        %{name: "Lurus Switch", desc: "一键管理 AI CLI 工具", path: "/download", icon: "desktop"},
        %{name: "MemX", desc: "跨会话持久 AI 记忆", path: "/download#memx", icon: "database"}
      ]
    },
    %{
      name: "创业者",
      path: "/for-entrepreneurs",
      children: [
        %{name: "Lurus API", desc: "LLM 统一网关，50+ 模型一个端点", path: "https://api.lurus.cn", external: true, icon: "api"},
        %{name: "Lurus Switch", desc: "团队 AI 工具统一管理", path: "/download", icon: "desktop"},
        %{name: "Lucrum Pro", desc: "机构级量化交易服务", path: "https://lucrum.lurus.cn", external: true, icon: "chart"}
      ]
    },
    %{
      name: "构建者",
      path: "/for-builders",
      children: [
        %{name: "Kova SDK", desc: "Rust Agent 持久化执行框架", path: "/for-builders", icon: "cpu"},
        %{name: "Lumen", desc: "Agent 执行可视化与断点调试 CLI", path: "/for-builders", icon: "bug"},
        %{name: "Lurus Identity", desc: "即插即用的认证 + 订阅 + 计费", path: "https://identity.lurus.cn", external: true, icon: "shield"},
        %{name: "MemX SDK", desc: "为你的产品添加跨会话持久记忆", path: "/download#memx", icon: "database"}
      ]
    },
    %{name: "定价", path: "/pricing"},
    %{name: "关于", path: "/about"}
  ]

  def items, do: @nav_items

  def audience_groups do
    @nav_items
    |> Enum.filter(&Map.has_key?(&1, :children))
    |> Enum.map(&%{name: &1.name, path: &1.path, children: &1.children})
  end
end
