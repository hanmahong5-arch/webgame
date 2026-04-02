defmodule LurusWwwWeb.Live.ReleasesLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "更新日志 — Lurus")
     |> assign(:page_description, "Lurus 产品更新日志 — 查看所有版本发布记录。")
     |> assign(:releases, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.section>
      <div class="text-center max-w-2xl mx-auto mb-16">
        <h1 class="text-4xl md:text-5xl font-bold mb-4">
          <span class="text-gradient-gold">更新日志</span>
        </h1>
        <p class="text-lg" style="color:var(--color-text-secondary);">
          所有产品的版本发布记录与变更说明。
        </p>
      </div>

      <%= if @releases == [] do %>
        <div class="text-center py-20">
          <div class="mb-4">
            <svg class="w-12 h-12 mx-auto animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor" style="color:var(--color-text-muted);" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <p style="color:var(--color-text-muted);">正在加载...</p>
          <p class="text-sm mt-2" style="color:var(--color-text-muted);">
            更新日志将从 GitHub Releases 同步。
          </p>
        </div>
      <% else %>
        <div class="max-w-3xl mx-auto">
          <article
            :for={release <- @releases}
            class="card-dark p-6 mb-6"
          >
            <div class="flex items-center gap-3 mb-4">
              <.neon_badge color={release[:color] || "var(--color-ochre)"}>
                <%= release[:product] || "Lurus" %>
              </.neon_badge>
              <span class="text-sm font-mono" style="color:var(--color-text-muted);">
                <%= release[:version] %>
              </span>
              <span class="text-sm" style="color:var(--color-text-muted);">
                <%= release[:date] %>
              </span>
            </div>

            <h2 class="text-xl font-bold mb-3" style="color:var(--color-text-primary);">
              <%= release[:title] %>
            </h2>

            <div
              class="prose-dark text-sm"
              style="color:var(--color-text-secondary); line-height:1.7;"
            >
              <%= if release[:body_html] do %>
                <%= Phoenix.HTML.raw(release[:body_html]) %>
              <% else %>
                <p><%= release[:body] %></p>
              <% end %>
            </div>
          </article>
        </div>
      <% end %>
    </.section>
    """
  end
end
