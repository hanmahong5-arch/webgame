defmodule LurusWwwWeb.Live.ForBuildersLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Data.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "开发者 — Lurus")
     |> assign(:page_description, "为开发者打造的 AI 基础设施 — Agent SDK、调试工具、身份认证、产品工作台。")
     |> assign(:products, Products.for_audience(:builder))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Hero --%>
    <.section>
      <div class="text-center max-w-3xl mx-auto">
        <.neon_badge color="#B08EFF">For Builders</.neon_badge>
        <h1 class="text-4xl md:text-5xl font-bold mt-6 mb-4">
          <span class="text-gradient-gold">构建</span>下一代 AI 产品
        </h1>
        <p class="text-lg" style="color:var(--color-text-secondary); line-height:1.75;">
          Agent 执行引擎、调试工具、身份认证与计费平台、AI 产品工作台 — 从底层到上层的完整开发者工具链。
        </p>
      </div>
    </.section>

    <%!-- Product Cards --%>
    <.section raised>
      <div class="grid gap-10">
        <div
          :for={product <- @products}
          class="card-dark p-8 reveal-fade-up"
          phx-hook="ScrollReveal"
          id={"builder-product-#{product.id}"}
        >
          <div class="md:flex gap-8">
            <%!-- Left: Product info --%>
            <div class="md:w-1/2">
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

            <%!-- Right: Code showcase (if available) --%>
            <div :if={product.showcase} class="md:w-1/2 mt-6 md:mt-0">
              <div class="code-block p-5 h-full flex flex-col justify-center" role="img" aria-label={"#{product.name} code example"}>
                <div class="flex items-center gap-2 mb-3">
                  <div class="flex gap-1.5">
                    <span class="w-3 h-3 rounded-full" style="background:#ff5f57;"></span>
                    <span class="w-3 h-3 rounded-full" style="background:#febc2e;"></span>
                    <span class="w-3 h-3 rounded-full" style="background:#28c840;"></span>
                  </div>
                  <span class="text-xs font-mono" style="color:var(--color-text-muted);">
                    <%= product.showcase.language %>
                  </span>
                </div>
                <pre class="whitespace-pre-wrap text-sm" style="color:var(--color-text-secondary);"><code><%= product.showcase.code %></code></pre>
              </div>
            </div>
          </div>
        </div>
      </div>
    </.section>

    <%!-- CTA --%>
    <.section>
      <div class="text-center">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--color-text-primary);">
          准备好构建了吗？
        </h2>
        <p class="mb-8 max-w-lg mx-auto" style="color:var(--color-text-secondary);">
          查看文档，5 分钟内开始集成。
        </p>
        <div class="flex justify-center gap-4">
          <.btn_primary href="https://docs.lurus.cn" external>阅读文档</.btn_primary>
          <.btn_outline href="/pricing">查看定价</.btn_outline>
        </div>
      </div>
    </.section>
    """
  end
end
