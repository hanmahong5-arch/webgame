defmodule LurusWwwWeb.Live.DownloadLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Data.Downloads

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "下载 — Lurus")
     |> assign(:page_description, "下载 Lurus 桌面工具与 SDK — Switch、Creator、MemX、Lumen 等。")
     |> assign(:products, Downloads.all())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Header --%>
    <.section>
      <div class="text-center max-w-2xl mx-auto">
        <h1 class="text-4xl md:text-5xl font-bold mb-4">
          <span class="text-gradient-gold">下载</span> Lurus 工具
        </h1>
        <p class="text-lg" style="color:var(--color-text-secondary);">
          桌面客户端、CLI 工具与 SDK — 选择适合你的工具开始使用。
        </p>
      </div>

      <%!-- Platform detection hint --%>
      <div
        class="text-center mt-6"
        id="platform-detect"
        phx-hook="PlatformDetect"
        style="color:var(--color-text-muted); font-size:0.875rem;"
      >
        正在检测您的操作系统...
      </div>
    </.section>

    <%!-- Product Download Cards --%>
    <.section raised>
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          :for={product <- @products}
          class="card-dark p-6 flex flex-col"
          id={"download-#{product.id}"}
        >
          <%!-- Icon + Name --%>
          <div class="flex items-center gap-3 mb-3">
            <div
              class="w-10 h-10 rounded-lg flex items-center justify-center text-lg"
              style={"background:#{product.color}20; color:#{product.color};"}
            >
              <%= product_icon(product.icon) %>
            </div>
            <div>
              <h3 class="text-lg font-bold" style="color:var(--color-text-primary);">
                <%= product.name %>
              </h3>
              <p class="text-xs font-mono" style="color:var(--color-ochre);">
                <%= product.tagline %>
              </p>
            </div>
          </div>

          <%!-- Description --%>
          <p class="text-sm mb-4 flex-1" style="color:var(--color-text-secondary); line-height:1.65;">
            <%= product.description %>
          </p>

          <%!-- Platforms --%>
          <div class="flex flex-wrap gap-2 mb-4">
            <span
              :for={platform <- product.platforms}
              class="text-xs px-2 py-1 rounded"
              style="background:var(--color-surface-overlay); color:var(--color-text-muted);"
            >
              <%= platform_label(platform) %>
            </span>
          </div>

          <%!-- Release status --%>
          <div :if={!product.is_released} class="mb-4">
            <span
              class="text-xs font-mono px-2 py-1 rounded"
              style="background:var(--color-surface-overlay); color:var(--color-text-muted);"
            >
              开发中
            </span>
          </div>

          <%!-- Install action --%>
          <%= case product.install_method do %>
            <% :binary -> %>
              <%= if product.is_released do %>
                <.btn_primary href={"/releases/#{product.release_product_id}"} size="sm">
                  下载
                </.btn_primary>
              <% else %>
                <.btn_outline size="sm" disabled>即将推出</.btn_outline>
              <% end %>
            <% :pip -> %>
              <.code_block code={product.install_command} language="bash" label="pip install command" />
            <% :cargo -> %>
              <.code_block code={product.install_command} language="bash" label="cargo install command" />
            <% :app_store -> %>
              <.btn_outline size="sm" disabled>即将上线</.btn_outline>
            <% _ -> %>
              <.btn_outline size="sm" disabled>即将推出</.btn_outline>
          <% end %>
        </div>
      </div>
    </.section>
    """
  end

  defp product_icon("brain"), do: "🧠"
  defp product_icon("desktop"), do: "🖥"
  defp product_icon("video"), do: "🎬"
  defp product_icon("database"), do: "💾"
  defp product_icon("bug"), do: "🔍"
  defp product_icon("mobile"), do: "📱"
  defp product_icon(_), do: "📦"

  defp platform_label(:windows), do: "Windows"
  defp platform_label(:darwin), do: "macOS"
  defp platform_label(:linux), do: "Linux"
  defp platform_label(:android), do: "Android"
  defp platform_label(:ios), do: "iOS"
  defp platform_label(other), do: to_string(other)
end
