defmodule LurusWwwWeb.Live.ForEntrepreneursLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Data.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "创业者 — Lurus")
     |> assign(:page_description, "为创业者和团队打造的 AI 基础设施 — API 网关、团队工具管理、量化交易。")
     |> assign(:products, Products.for_audience(:entrepreneur))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Hero --%>
    <.section>
      <div class="text-center max-w-3xl mx-auto">
        <.neon_badge color="#FF8C69">For Entrepreneurs</.neon_badge>
        <h1 class="text-4xl md:text-5xl font-bold mt-6 mb-4">
          <span class="text-gradient-gold">专注产品</span>，基础设施交给我们
        </h1>
        <p class="text-lg" style="color:var(--color-text-secondary); line-height:1.75;">
          你不该把时间花在重复造轮子上。统一 API、团队工具管理、量化交易 — 从第一天起用企业级基础设施。
        </p>
      </div>
    </.section>

    <%!-- Product Cards --%>
    <.section raised>
      <div class="grid md:grid-cols-2 gap-8">
        <div
          :for={product <- @products}
          class="card-dark p-8 reveal-fade-up"
          phx-hook="ScrollReveal"
          id={"entrepreneur-product-#{product.id}"}
        >
          <%!-- Header --%>
          <div class="flex items-center gap-3 mb-4">
            <div
              class="w-10 h-10 rounded-lg flex items-center justify-center"
              style={"background:#{product.neon_color}15;"}
            >
              <.icon path={product.icon_path} class="w-5 h-5" />
            </div>
            <div>
              <h3 class="text-xl font-bold" style="color:var(--color-text-primary);">
                <%= product.name %>
              </h3>
              <p class="text-xs font-mono" style={"color:#{product.neon_color};"}>
                <%= product.tagline %>
              </p>
            </div>
          </div>

          <%!-- Description --%>
          <p class="mb-5" style="color:var(--color-text-secondary); line-height:1.65;">
            <%= product.description %>
          </p>

          <%!-- Features --%>
          <ul class="mb-6" style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:6px;">
            <li
              :for={feature <- product.features}
              class="text-sm flex items-start gap-2"
              style="color:var(--color-text-muted);"
            >
              <span class="mt-0.5 shrink-0" style={"color:#{product.neon_color};"}>&#10003;</span>
              <%= feature %>
            </li>
          </ul>

          <%!-- CTA --%>
          <%= if product.cta[:external] do %>
            <.btn_primary href={product.cta.href} external size="sm">
              <%= product.cta.text %>
            </.btn_primary>
          <% else %>
            <.btn_primary href={product.cta.href} size="sm">
              <%= product.cta.text %>
            </.btn_primary>
          <% end %>
        </div>
      </div>
    </.section>

    <%!-- CTA --%>
    <.section>
      <div class="text-center">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--color-text-primary);">
          需要企业级定制方案？
        </h2>
        <p class="mb-8" style="color:var(--color-text-secondary);">
          私有化部署、白标定制、专属 SLA — 联系我们的商务团队。
        </p>
        <div class="flex justify-center gap-4">
          <.btn_primary href="mailto:enterprise@lurus.cn" external>联系商务</.btn_primary>
          <.btn_outline href="/pricing">查看定价</.btn_outline>
        </div>
      </div>
    </.section>
    """
  end
end
