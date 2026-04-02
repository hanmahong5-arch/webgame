defmodule LurusWwwWeb.Plugs.SeoMetaTest do
  use LurusWwwWeb.ConnCase

  alias LurusWwwWeb.Plugs.SeoMeta

  @routes %{
    "/" => {"Lurus — AI 基础设施生态", "一套完整的 AI 基础设施 — API 网关、Agent SDK、量化交易、桌面工具，7 款产品覆盖全场景，开箱即用。"},
    "/pricing" => {"定价方案 — Lurus", "Lurus 按量付费，无订阅陷阱。查看 API 调用、桌面工具和开发者套餐的完整定价。"},
    "/download" => {"下载中心 — Lurus", "下载 Lurus Creator、Switch、MemX 等桌面工具。Windows / macOS 全平台支持，免费开始。"},
    "/about" => {"关于我们 — Lurus", "Lurus 是专注于 AI 基础设施的团队，致力于让每个开发者都能轻松构建和部署 AI 产品。"},
    "/solutions" => {"解决方案 — Lurus", "面向金融、医疗、法律、工程等行业的 AI 解决方案，由 Lurus 基础设施驱动。"},
    "/for-explorers" => {"个人探索者 — Lurus", "免费下载 Lurus 桌面工具套件，让 AI 融入你的每日工作流 — Creator、Switch、MemX 全部免费。"},
    "/for-entrepreneurs" => {"创业者方案 — Lurus", "3 分钟接入 50+ AI 模型，按量付费，无最低消费。快速上线 AI 产品，从 Lurus API 开始。"},
    "/for-builders" => {"开发者工具 — Lurus", "Kova SDK、Lumen、MemX SDK、Lurus Identity — 一站式 AI 开发者基础设施，构建下一代应用。"},
    "/releases" => {"Release History — Lurus", "Track updates across all Lurus products — changelogs, downloads, and version history."},
    "/terms" => {"服务条款 — Lurus", "Lurus 平台服务条款，使用前请仔细阅读。"},
    "/privacy" => {"隐私政策 — Lurus", "Lurus 隐私政策：我们如何收集、使用和保护你的数据。"}
  }

  for {path, {expected_title, expected_description}} <- @routes do
    test "sets correct SEO meta for #{path}", %{conn: conn} do
      conn =
        %{conn | request_path: unquote(path)}
        |> SeoMeta.call(SeoMeta.init([]))

      assert conn.assigns[:page_title] == unquote(expected_title)
      assert conn.assigns[:page_description] == unquote(expected_description)
      assert conn.assigns[:current_path] == unquote(path)
    end
  end

  test "sets default SEO meta for unknown path", %{conn: conn} do
    conn =
      %{conn | request_path: "/some/unknown/page"}
      |> SeoMeta.call(SeoMeta.init([]))

    assert conn.assigns[:page_title] == "Lurus — AI 基础设施生态"
    assert conn.assigns[:page_description] =~ "一套完整的 AI 基础设施"
    assert conn.assigns[:current_path] == "/some/unknown/page"
  end

  test "always sets :current_path to the actual request path", %{conn: conn} do
    conn =
      %{conn | request_path: "/pricing"}
      |> SeoMeta.call(SeoMeta.init([]))

    assert conn.assigns[:current_path] == "/pricing"
  end
end
