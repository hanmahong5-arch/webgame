defmodule LurusWwwWeb.Live.AboutLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Data.About
  alias LurusWww.Data.Team

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "关于我们 — Lurus")
     |> assign(:page_description, "了解 Lurus 的使命、团队与技术愿景 — 让 AI 基础设施像水电一样可靠。")
     |> assign(:milestones, About.milestones())
     |> assign(:values, About.values())
     |> assign(:stats, About.stats())
     |> assign(:tech_highlights, About.tech_highlights())
     |> assign(:team, Team.members())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Mission / Vision Hero --%>
    <.section>
      <div class="text-center max-w-3xl mx-auto">
        <h1 class="text-4xl md:text-5xl font-bold mb-6">
          <span class="text-gradient-gold">让 AI 基础设施</span>
          <br />像水电一样可靠
        </h1>
        <p class="text-lg mb-4" style="color:var(--color-text-secondary); line-height:1.75;">
          Lurus 致力于构建下一代 AI 基础设施。我们相信，可靠、易用、透明的 AI 服务应该是每个开发者和企业的基本权利，而不是少数人的特权。
        </p>
        <p style="color:var(--color-text-muted);">
          从统一 API 网关到 Agent 持久化引擎，从量化交易到桌面工具 — 我们用技术连接 AI 与真实世界。
        </p>
      </div>
    </.section>

    <%!-- Animated Timeline --%>
    <.section raised id="milestones">
      <div class="text-center mb-16">
        <h2 class="text-3xl font-bold mb-3" style="color:var(--color-text-primary);">发展历程</h2>
        <p style="color:var(--color-text-secondary);">从零到一，每一步都踏实前行</p>
      </div>

      <div class="relative max-w-3xl mx-auto">
        <%!-- Vertical line --%>
        <div
          class="absolute left-1/2 top-0 bottom-0 w-px -translate-x-1/2 hidden md:block"
          style="background:var(--color-border-subtle);"
        >
        </div>

        <div :for={{milestone, idx} <- Enum.with_index(@milestones)} class="reveal-fade-up mb-12 last:mb-0" phx-hook="ScrollReveal" id={"milestone-#{idx}"}>
          <div class={[
            "md:flex items-center gap-8",
            if(rem(idx, 2) == 0, do: "md:flex-row", else: "md:flex-row-reverse")
          ]}>
            <%!-- Content card --%>
            <div class="md:w-5/12">
              <div class="card-dark p-6">
                <span class="text-sm font-mono font-semibold" style="color:var(--color-ochre);">
                  <%= milestone.year %>
                </span>
                <p class="mt-2" style="color:var(--color-text-secondary); line-height:1.65;">
                  <%= milestone.event %>
                </p>
              </div>
            </div>

            <%!-- Center dot --%>
            <div class="hidden md:flex md:w-2/12 justify-center">
              <div
                class="w-4 h-4 rounded-full border-2 z-10"
                style="border-color:var(--color-ochre); background:var(--color-surface-base);"
              >
              </div>
            </div>

            <%!-- Spacer --%>
            <div class="hidden md:block md:w-5/12"></div>
          </div>
        </div>
      </div>
    </.section>

    <%!-- Team --%>
    <.section id="team">
      <div class="text-center mb-16">
        <h2 class="text-3xl font-bold mb-3" style="color:var(--color-text-primary);">团队</h2>
        <p style="color:var(--color-text-secondary);">四个核心小组，专注不同领域</p>
      </div>

      <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div
          :for={member <- @team}
          class="card-dark p-6 text-center reveal-fade-up"
          phx-hook="ScrollReveal"
          id={"team-#{member.initials}"}
        >
          <div
            class="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4 text-xl font-bold"
            style={"background:#{member.color}20; color:#{member.color};"}
          >
            <%= member.initials %>
          </div>
          <h3 class="text-lg font-semibold mb-1" style="color:var(--color-text-primary);">
            <%= member.name %>
          </h3>
          <p class="text-sm font-mono mb-3" style="color:var(--color-ochre);">
            <%= member.role %>
          </p>
          <p class="text-sm" style="color:var(--color-text-muted); line-height:1.6;">
            <%= member.bio %>
          </p>
        </div>
      </div>
    </.section>

    <%!-- Core Values --%>
    <.section raised id="values">
      <div class="text-center mb-16">
        <h2 class="text-3xl font-bold mb-3" style="color:var(--color-text-primary);">核心价值</h2>
        <p style="color:var(--color-text-secondary);">驱动我们每一个决策的四个原则</p>
      </div>

      <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div
          :for={{value, idx} <- Enum.with_index(@values)}
          class="card-dark p-6 reveal-fade-up"
          phx-hook="ScrollReveal"
          id={"value-#{idx}"}
        >
          <div class="mb-4" style="color:var(--color-ochre);">
            <svg class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d={value.icon} />
            </svg>
          </div>
          <h3 class="text-lg font-semibold mb-2" style="color:var(--color-text-primary);">
            <%= value.title %>
          </h3>
          <p class="text-sm" style="color:var(--color-text-secondary); line-height:1.65;">
            <%= value.desc %>
          </p>
        </div>
      </div>
    </.section>

    <%!-- Technology Highlights --%>
    <.section id="tech">
      <div class="text-center mb-16">
        <h2 class="text-3xl font-bold mb-3" style="color:var(--color-text-primary);">技术亮点</h2>
        <p style="color:var(--color-text-secondary);">支撑平台的核心技术能力</p>
      </div>

      <div class="grid md:grid-cols-3 gap-8">
        <div
          :for={{tech, idx} <- Enum.with_index(@tech_highlights)}
          class="bento-card p-8 reveal-fade-up"
          phx-hook="ScrollReveal"
          id={"tech-#{idx}"}
        >
          <div class="mb-5" style="color:var(--color-ochre);">
            <svg class="w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d={tech.icon} />
            </svg>
          </div>
          <h3 class="text-xl font-semibold mb-3" style="color:var(--color-text-primary);">
            <%= tech.title %>
          </h3>
          <p style="color:var(--color-text-secondary); line-height:1.65;">
            <%= tech.desc %>
          </p>
        </div>
      </div>
    </.section>

    <%!-- Stats Row --%>
    <.section raised>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
        <div :for={stat <- @stats} class="reveal-fade-up" phx-hook="ScrollReveal" id={"stat-#{stat.label}"}>
          <p class="text-3xl md:text-4xl font-bold mb-1" style="color:var(--color-ochre);">
            <%= stat.value %>
          </p>
          <p class="text-sm" style="color:var(--color-text-muted);">
            <%= stat.label %>
          </p>
        </div>
      </div>
    </.section>

    <%!-- CTA --%>
    <.section>
      <div class="text-center">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--color-text-primary);">
          加入我们，一起构建 AI 基础设施
        </h2>
        <p class="mb-8 max-w-lg mx-auto" style="color:var(--color-text-secondary);">
          我们正在寻找对 AI 基础设施充满热情的伙伴。
        </p>
        <div class="flex justify-center gap-4">
          <.btn_primary href="mailto:hr@lurus.cn" external>加入团队</.btn_primary>
          <.btn_outline href="/pricing">查看产品</.btn_outline>
        </div>
      </div>
    </.section>
    """
  end
end
