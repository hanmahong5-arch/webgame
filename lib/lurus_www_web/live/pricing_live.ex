defmodule LurusWwwWeb.Live.PricingLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Data.Pricing

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "定价 — Lurus")
     |> assign(:page_description, "Lurus 产品定价方案 — 从免费个人版到企业级平台版，按需选择。")
     |> assign(:tiers, Pricing.tiers())
     |> assign(:active_tier, :personal)
     |> assign(:products, Pricing.products(:personal))
     |> assign(:comparison_features, Pricing.comparison_features())
     |> assign(:faq, Pricing.faq())
     |> assign(:expanded_faq, nil)}
  end

  @impl true
  def handle_event("select_tier", %{"tier" => tier_str}, socket) do
    tier = String.to_existing_atom(tier_str)

    {:noreply,
     socket
     |> assign(:active_tier, tier)
     |> assign(:products, Pricing.products(tier))}
  end

  @impl true
  def handle_event("toggle_faq", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    current = socket.assigns.expanded_faq
    new_expanded = if current == index, do: nil, else: index

    {:noreply, assign(socket, :expanded_faq, new_expanded)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Header --%>
    <.section>
      <div class="text-center max-w-2xl mx-auto">
        <h1 class="text-4xl md:text-5xl font-bold mb-4">
          <span class="text-gradient-gold">简单透明</span>的定价
        </h1>
        <p class="text-lg" style="color:var(--color-text-secondary);">
          从免费开始，按需升级。没有隐藏费用。
        </p>
      </div>
    </.section>

    <%!-- Audience Tier Tabs --%>
    <.section raised>
      <div class="flex justify-center mb-12">
        <div class="inline-flex rounded-lg p-1" style="background:var(--color-surface-overlay);">
          <button
            :for={tier <- @tiers}
            phx-click="select_tier"
            phx-value-tier={tier.code}
            class={[
              "px-6 py-3 rounded-lg text-sm font-medium transition-all",
              if(@active_tier == tier.code,
                do: "shadow-md",
                else: "hover:opacity-80"
              )
            ]}
            style={
              if @active_tier == tier.code do
                "background:var(--color-ochre); color:var(--color-surface-base);"
              else
                "color:var(--color-text-secondary);"
              end
            }
          >
            <span class="mr-1"><%= tier.icon %></span>
            <%= tier.name %>
          </button>
        </div>
      </div>

      <%!-- Active tier tagline --%>
      <p class="text-center mb-10" style="color:var(--color-text-muted);">
        <%= tier_tagline(@tiers, @active_tier) %>
      </p>

      <%!-- Product Pricing Cards --%>
      <div class="product-section-grid grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          :for={product <- @products}
          class={[
            "card-dark p-6 relative flex flex-col",
            product.popular && "ring-1 ring-[var(--color-ochre)]"
          ]}
        >
          <%!-- Popular badge --%>
          <div :if={product.popular} class="absolute -top-3 left-1/2 -translate-x-1/2">
            <.neon_badge>推荐</.neon_badge>
          </div>

          <%!-- Coming soon badge --%>
          <div :if={product.status == :coming_soon} class="absolute top-4 right-4">
            <span
              class="text-xs font-mono px-2 py-1 rounded"
              style="background:var(--color-surface-overlay); color:var(--color-text-muted);"
            >
              即将推出
            </span>
          </div>

          <h3 class="text-xl font-bold mb-1" style="color:var(--color-text-primary);">
            <%= product.name %>
          </h3>
          <p class="text-sm mb-5" style="color:var(--color-text-muted);">
            <%= product.description %>
          </p>

          <%!-- Price --%>
          <div class="mb-6">
            <%= if product.monthly_price do %>
              <%= if product.monthly_price == 0 do %>
                <span class="text-3xl font-bold" style="color:var(--color-ochre);">免费</span>
              <% else %>
                <span class="text-3xl font-bold" style="color:var(--color-ochre);">
                  &yen;<%= product.monthly_price %>
                </span>
                <span class="text-sm" style="color:var(--color-text-muted);">
                  / <%= product.unit %>
                </span>
              <% end %>
            <% else %>
              <span class="text-lg font-semibold" style="color:var(--color-text-secondary);">
                联系销售
              </span>
            <% end %>
          </div>

          <%!-- Features --%>
          <ul class="flex-1 mb-6" style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:8px;">
            <li
              :for={feature <- product.features}
              class="text-sm flex items-start gap-2"
              style="color:var(--color-text-secondary);"
            >
              <span class="mt-0.5 shrink-0" style="color:var(--color-ochre);">&#10003;</span>
              <%= feature %>
            </li>
          </ul>

          <%!-- CTA --%>
          <%= if product.status == :available do %>
            <.btn_primary href="https://api.lurus.cn" external size="sm">开始使用</.btn_primary>
          <% else %>
            <.btn_outline size="sm" disabled>即将推出</.btn_outline>
          <% end %>
        </div>
      </div>
    </.section>

    <%!-- Feature Comparison Table --%>
    <.section id="compare">
      <div class="text-center mb-12">
        <h2 class="text-3xl font-bold mb-3" style="color:var(--color-text-primary);">功能对比</h2>
        <p style="color:var(--color-text-secondary);">一目了然，选择最适合你的方案</p>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full" style="border-collapse:collapse;">
          <thead>
            <tr style="border-bottom:1px solid var(--color-border-subtle);">
              <th class="text-left py-4 pr-4" style="color:var(--color-text-muted); font-weight:500; min-width:200px;">
                功能
              </th>
              <th class="text-center py-4 px-4" style="color:var(--color-text-primary); font-weight:600;">
                个人
              </th>
              <th class="text-center py-4 px-4" style="color:var(--color-ochre); font-weight:600;">
                团队
              </th>
              <th class="text-center py-4 px-4" style="color:var(--color-text-primary); font-weight:600;">
                平台
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={feature <- @comparison_features}
              style="border-bottom:1px solid var(--color-border-subtle);"
            >
              <td class="py-3 pr-4 text-sm" style="color:var(--color-text-secondary);">
                <%= feature.name %>
              </td>
              <td class="py-3 px-4 text-center text-sm">
                <.comparison_cell value={feature.personal} />
              </td>
              <td class="py-3 px-4 text-center text-sm">
                <.comparison_cell value={feature.team} />
              </td>
              <td class="py-3 px-4 text-center text-sm">
                <.comparison_cell value={feature.platform} />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </.section>

    <%!-- FAQ --%>
    <.section raised id="faq">
      <div class="text-center mb-12">
        <h2 class="text-3xl font-bold mb-3" style="color:var(--color-text-primary);">常见问题</h2>
      </div>

      <div class="max-w-2xl mx-auto">
        <div
          :for={{item, idx} <- Enum.with_index(@faq)}
          class="divider-dark"
          style="border-bottom:1px solid var(--color-border-subtle);"
        >
          <button
            phx-click="toggle_faq"
            phx-value-index={idx}
            class="w-full py-5 flex items-center justify-between text-left"
          >
            <span class="font-medium pr-4" style="color:var(--color-text-primary);">
              <%= item.question %>
            </span>
            <span
              class="shrink-0 text-lg transition-transform"
              style={"color:var(--color-text-muted); #{if @expanded_faq == idx, do: "transform:rotate(45deg);"}"}
            >
              +
            </span>
          </button>
          <div
            :if={@expanded_faq == idx}
            class="pb-5 text-sm"
            style="color:var(--color-text-secondary); line-height:1.7;"
          >
            <%= item.answer %>
          </div>
        </div>
      </div>
    </.section>

    <%!-- CTA --%>
    <.section>
      <div class="text-center">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--color-text-primary);">
          准备好开始了吗？
        </h2>
        <p class="mb-8 max-w-lg mx-auto" style="color:var(--color-text-secondary);">
          注册即可获得免费额度，无需信用卡。
        </p>
        <div class="flex justify-center gap-4">
          <.btn_primary href="https://api.lurus.cn" external>免费开始</.btn_primary>
          <.btn_outline href="mailto:enterprise@lurus.cn" external>企业咨询</.btn_outline>
        </div>
      </div>
    </.section>
    """
  end

  defp tier_tagline(tiers, active) do
    case Enum.find(tiers, &(&1.code == active)) do
      nil -> ""
      tier -> tier.tagline
    end
  end

  defp comparison_cell(%{value: true} = assigns) do
    ~H"""
    <span style="color:var(--color-ochre);">&#10003;</span>
    """
  end

  defp comparison_cell(%{value: false} = assigns) do
    ~H"""
    <span style="color:var(--color-text-muted);">&mdash;</span>
    """
  end

  defp comparison_cell(assigns) do
    ~H"""
    <span style="color:var(--color-text-secondary);"><%= @value %></span>
    """
  end
end
