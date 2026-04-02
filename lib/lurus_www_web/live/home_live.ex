defmodule LurusWwwWeb.Live.HomeLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Data.Products
  alias LurusWww.Data.Stats
  alias LurusWww.Data.Partners

  @pain_points [
    %{
      audience: "个人用户",
      pain: "每天切换 5 个 AI 工具，配置散落各处",
      solution: "Switch 统一管理，MemX 跨工具记忆，Creator 一键发布",
      href: "/for-explorers",
      color: "#FF8C69"
    },
    %{
      audience: "创业团队",
      pain: "接入 AI 模型要自建网关、做计费、处理限流",
      solution: "一个 API Key 接入 50+ 模型，按量计费，故障自动转移",
      href: "/for-entrepreneurs",
      color: "#4A9EFF"
    },
    %{
      audience: "技术团队",
      pain: "Agent 跑到一半崩溃，状态全丢，只能从头再来",
      solution: "Kova WAL 级持久化，断电自动恢复，Lumen 实时调试",
      href: "/for-builders",
      color: "#B08EFF"
    }
  ]

  @paths [
    %{
      audience: "个人用户",
      action: "用 AI 武装每一天",
      description: "视频创作、量化交易、AI 记忆、工具管理 — 免费下载桌面工具，效率提升肉眼可见",
      href: "/for-explorers",
      color: "#FF8C69",
      badge: "免费使用"
    },
    %{
      audience: "创业团队",
      action: "3 分钟接入 AI 能力",
      description: "一个 API Key 接入 50+ 模型，按量计费，智能路由。让你的产品立刻拥有 AI 能力",
      href: "/for-entrepreneurs",
      color: "#4A9EFF",
      badge: "按量计费"
    },
    %{
      audience: "技术团队",
      action: "构建生产级 AI 系统",
      description: "Kova Agent 引擎 + Lumen 调试器 + MemX 记忆 + Identity 认证 — 完整的 AI 基础设施栈",
      href: "/for-builders",
      color: "#B08EFF",
      badge: "开发者"
    }
  ]

  @api_features [
    "OpenAI SDK 完全兼容，改一行代码即可迁移",
    "智能负载均衡，故障自动转移，服务永不中断",
    "统一账单与用量分析，成本一目了然"
  ]

  @kova_features [
    "WAL 预写日志，每一步状态持久保存",
    "Rust 原生性能，零 GC 停顿，确定性延迟",
    "崩溃后精准恢复，不重复已完成的工作"
  ]

  @lucrum_features [
    "自然语言到可执行代码，零编程门槛",
    "实时行情接入，毫秒级数据推送",
    "专业级回测引擎，历史验证一键完成"
  ]

  @memx_features [
    "跨会话持久记忆，告别反复交代背景",
    "语义向量检索，精准找回关键上下文",
    "SDK / REST API 接入，3 行代码集成"
  ]

  @switch_features [
    "Claude Code / Codex / Gemini CLI 集中管控",
    "API Key 统一管理，安全轮换",
    "MCP 预设一键同步到所有工具",
    "环境快照，配置随时回滚"
  ]

  @lumen_features [
    "实时调用链追踪，执行过程透明",
    "断点注入，精准定位问题",
    "状态树可视化，一眼看懂 Agent 状态",
    "结构化日志导出，排查高效从容"
  ]

  @impl true
  def mount(_params, _session, socket) do
    products = Products.all()

    hero_tags =
      products
      |> Enum.reject(&(&1.id in ["forge", "identity"]))
      |> Enum.map(&%{name: &1.name, color: &1.neon_color, href: &1.url})

    api_product = Products.by_id("api")

    api_code =
      case api_product[:showcase] do
        %{code: code} -> code
        _ -> ""
      end

    {:ok,
     socket
     |> assign(:page_title, "Lurus — 构建下一代 AI 基础设施")
     |> assign(:page_description, "完整的 AI 基础设施生态。API 网关接入 50+ 模型、Kova Agent SDK、Lucrum AI 量化交易、Creator 内容工厂、MemX 持久记忆，7 款产品覆盖全场景。")
     |> assign(:products, products)
     |> assign(:stats, Stats.all())
     |> assign(:trust_badges, Stats.trust_badges())
     |> assign(:partners, Partners.all())
     |> assign(:hero_tags, hero_tags)
     |> assign(:api_code, api_code)
     |> assign(:pain_points, @pain_points)
     |> assign(:paths, @paths)
     |> assign(:api_features, @api_features)
     |> assign(:kova_features, @kova_features)
     |> assign(:lucrum_features, @lucrum_features)
     |> assign(:memx_features, @memx_features)
     |> assign(:switch_features, @switch_features)
     |> assign(:lumen_features, @lumen_features)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- S1: Hero --%>
    <section
      id="hero"
      class="relative overflow-hidden"
      style="background-color:var(--color-surface-base)"
      phx-hook="ParticleField"
      aria-label="Hero"
    >
      <%!-- Grid background --%>
      <div
        class="absolute inset-0 pointer-events-none"
        aria-hidden="true"
        style="background-image:linear-gradient(rgba(255,255,255,0.018) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,0.018) 1px,transparent 1px);background-size:52px 52px"
      ></div>

      <%!-- Mouse glow overlay --%>
      <div
        id="hero-glow"
        class="absolute inset-0 pointer-events-none"
        phx-hook="MouseGlow"
        aria-hidden="true"
        style="background:radial-gradient(circle 600px at 50% 50%,rgba(212,168,39,0.06),transparent);opacity:0;transition:opacity 0.3s ease;z-index:0"
      ></div>

      <%!-- Neon aura spots --%>
      <div class="absolute inset-0 pointer-events-none overflow-hidden" aria-hidden="true">
        <div class="absolute rounded-full" style="background:#4A9EFF;top:5%;left:8%;width:420px;height:320px;filter:blur(100px);opacity:0.07;animation:aura-drift 12s ease-in-out infinite"></div>
        <div class="absolute rounded-full" style="background:#B08EFF;top:20%;right:10%;width:360px;height:280px;filter:blur(100px);opacity:0.07;animation:aura-drift 12s ease-in-out infinite;animation-delay:3s"></div>
        <div class="absolute rounded-full" style="background:#7AFF89;bottom:10%;left:20%;width:300px;height:260px;filter:blur(100px);opacity:0.07;animation:aura-drift 12s ease-in-out infinite;animation-delay:6s"></div>
        <div class="absolute rounded-full" style="background:#4AFFCB;bottom:5%;right:25%;width:280px;height:220px;filter:blur(100px);opacity:0.07;animation:aura-drift 12s ease-in-out infinite;animation-delay:9s"></div>
      </div>

      <div class="relative max-w-5xl mx-auto px-6 sm:px-8 lg:px-12 py-32 sm:py-44 text-center">
        <%!-- Eyebrow --%>
        <div
          class="reveal-fade-up inline-flex items-center gap-2 px-4 py-1.5 rounded-full mb-7"
          phx-hook="ScrollReveal"
          id="hero-eyebrow"
          style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border);color:var(--color-text-secondary);font-size:0.78rem"
        >
          <span
            class="w-1.5 h-1.5 rounded-full flex-shrink-0"
            style="background-color:var(--color-ochre);animation:neon-dot-pulse 2s ease-in-out infinite"
          ></span>
          值得信赖的 AI 基础设施
        </div>

        <%!-- Title --%>
        <h1
          class="reveal-fade-up font-extrabold mb-5"
          phx-hook="ScrollReveal"
          id="hero-title"
          style="font-size:clamp(2.5rem,5vw,4.5rem);color:var(--color-text-primary);line-height:1.08;letter-spacing:-0.03em"
        >
          不再拼凑碎片化工具，<br>
          <span class="text-gradient-gold">一个平台，完整交付</span>
        </h1>

        <%!-- Subtitle --%>
        <p
          class="reveal-fade-up mx-auto mb-9"
          phx-hook="ScrollReveal"
          id="hero-subtitle"
          style="color:var(--color-text-secondary);font-size:1.15rem;max-width:520px;line-height:1.65"
        >
          从模型接入到 Agent 持久运行，从量化交易到内容创作 — 7 款产品无缝协作，让你专注创造价值。
        </p>

        <%!-- CTA buttons --%>
        <div
          class="reveal-fade-up flex flex-wrap items-center justify-center gap-4 mb-8"
          phx-hook="ScrollReveal"
          id="hero-cta"
        >
          <.btn_primary href="https://api.lurus.cn" external size="lg">免费体验 →</.btn_primary>
          <.btn_outline href="https://docs.lurus.cn" external size="lg">阅读文档</.btn_outline>
        </div>

        <%!-- Hero trust numbers --%>
        <div
          class="reveal-fade-up flex flex-wrap items-center justify-center gap-4 mb-10"
          phx-hook="ScrollReveal"
          id="hero-trust"
          aria-label="平台数据概览"
        >
          <div class="flex items-baseline gap-1.5">
            <span
              class="font-bold"
              phx-hook="CountUp"
              id="hero-stat-0"
              data-target="1,000,000+"
              style="font-size:1.05rem;color:var(--color-text-secondary);font-variant-numeric:tabular-nums"
            >0</span>
            <span style="font-size:0.82rem;color:var(--color-text-muted)">次稳定调用</span>
          </div>
          <span style="color:var(--color-text-muted);font-size:1.2rem;user-select:none" aria-hidden="true">&middot;</span>
          <div class="flex items-baseline gap-1.5">
            <span
              class="font-bold"
              phx-hook="CountUp"
              id="hero-stat-1"
              data-target="50+"
              style="font-size:1.05rem;color:var(--color-text-secondary);font-variant-numeric:tabular-nums"
            >0</span>
            <span style="font-size:0.82rem;color:var(--color-text-muted)">主流模型</span>
          </div>
          <span style="color:var(--color-text-muted);font-size:1.2rem;user-select:none" aria-hidden="true">&middot;</span>
          <div class="flex items-baseline gap-1.5">
            <span
              class="font-bold"
              phx-hook="CountUp"
              id="hero-stat-2"
              data-target="99.9%"
              style="font-size:1.05rem;color:var(--color-text-secondary);font-variant-numeric:tabular-nums"
            >0</span>
            <span style="font-size:0.82rem;color:var(--color-text-muted)">SLA 保障</span>
          </div>
        </div>

        <%!-- Product tag cloud --%>
        <div
          class="reveal-fade-up flex flex-wrap items-center justify-center gap-2.5"
          phx-hook="ScrollReveal"
          id="hero-tags"
          role="list"
          aria-label="产品线"
        >
          <%= for tag <- @hero_tags do %>
            <a
              href={tag.href}
              target={if String.starts_with?(tag.href, "http"), do: "_blank"}
              rel={if String.starts_with?(tag.href, "http"), do: "noopener noreferrer"}
              class="inline-flex items-center gap-1.5 py-1.5 px-4 rounded-full text-sm"
              role="listitem"
              style={"border:1px solid #{tag.color};background:color-mix(in srgb, #{tag.color} 8%, transparent);color:var(--color-text-secondary);font-weight:500;text-decoration:none;transition:background-color 0.2s,color 0.2s,transform 0.15s;font-size:0.85rem"}
            >
              <span
                class="w-1.5 h-1.5 rounded-full flex-shrink-0"
                style={"background:#{tag.color};animation:neon-dot-pulse 2.5s ease-in-out infinite"}
              ></span>
              <%= tag.name %>
            </a>
          <% end %>
        </div>
      </div>
    </section>

    <%!-- Divider --%>
    <hr class="divider-dark" />

    <%!-- S2: Stats bar --%>
    <section
      style="background-color:var(--color-surface-raised);border-top:1px solid var(--color-surface-border);border-bottom:1px solid var(--color-surface-border)"
      aria-label="平台数据"
    >
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <div
          class="grid grid-cols-2 sm:grid-cols-4"
          style="background-color:var(--color-surface-border);gap:1px"
        >
          <%= for {stat, idx} <- Enum.with_index(@stats) do %>
            <div
              class="flex flex-col items-center gap-1.5 py-7 px-4"
              style="background-color:var(--color-surface-raised)"
            >
              <span
                class={"font-extrabold #{stat.color}"}
                phx-hook="CountUp"
                id={"stat-#{idx}"}
                data-target={stat.value}
                style="font-size:2rem;letter-spacing:-0.03em;line-height:1;font-variant-numeric:tabular-nums"
              ><%= stat.value %></span>
              <span style="font-size:0.8rem;color:var(--color-text-muted)"><%= stat.label %></span>
            </div>
          <% end %>
        </div>
      </div>
    </section>

    <%!-- S3: Partner logos marquee --%>
    <section class="section-dark py-10" aria-label="支持的模型提供商">
      <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
        <p
          class="text-center text-xs uppercase tracking-wider mb-6"
          style="color:var(--color-text-muted);letter-spacing:0.12em;font-weight:600"
        >
          支持的 AI 模型提供商
        </p>
        <div
          class="overflow-hidden"
          style="mask-image:linear-gradient(90deg,transparent,#000 10%,#000 90%,transparent);-webkit-mask-image:linear-gradient(90deg,transparent,#000 10%,#000 90%,transparent)"
        >
          <div
            class="flex gap-3 w-max animate-marquee"
            phx-hook="Marquee"
            id="partner-marquee"
          >
            <%!-- Duplicate list for seamless loop --%>
            <%= for p <- @partners ++ @partners do %>
              <span
                class="inline-flex items-center py-1.5 px-4 rounded-full whitespace-nowrap"
                style={"border:1px solid #{p.color}40;color:#{p.color};font-size:0.78rem;font-weight:600;background:color-mix(in srgb, #{p.color} 5%, transparent)"}
              >
                <%= p.name %>
              </span>
            <% end %>
          </div>
        </div>
      </div>
    </section>

    <%!-- S4: Pain Point Bridge --%>
    <.section id="pain-points">
      <div
        class="text-center mb-14 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="pain-heading"
      >
        <h2
          class="font-extrabold"
          style="font-size:clamp(2rem,4.5vw,3rem);color:var(--color-text-primary);letter-spacing:-0.03em;line-height:1.1"
        >你是否也面临这些挑战？</h2>
      </div>
      <div
        class="grid md:grid-cols-3 gap-5 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="pain-grid"
      >
        <%= for point <- @pain_points do %>
          <a
            href={point.href}
            class="relative block p-7 rounded-2xl overflow-hidden no-underline"
            style={"--pain-color:#{point.color};background-color:var(--color-surface-raised);border:1px solid var(--color-surface-border);transition:border-color 0.2s,transform 0.2s"}
          >
            <div
              class="absolute top-0 left-0 right-0 h-0.5"
              style={"background:#{point.color};opacity:0.8"}
              aria-hidden="true"
            ></div>
            <p
              class="text-xs font-semibold uppercase mb-3"
              style={"letter-spacing:0.08em;color:#{point.color}"}
            ><%= point.audience %></p>
            <p
              class="font-bold mb-3"
              style="font-size:1rem;color:var(--color-text-primary);line-height:1.4"
            ><%= point.pain %></p>
            <p style="font-size:0.88rem;color:var(--color-text-secondary);line-height:1.55"><%= point.solution %></p>
            <span class="block mt-4" style="color:var(--color-text-muted);font-size:1rem" aria-hidden="true">→</span>
          </a>
        <% end %>
      </div>
    </.section>

    <%!-- S5: Lurus API deep dive --%>
    <.section id="api-section" raised>
      <div
        class="product-section-grid reveal-fade-up"
        phx-hook="ScrollReveal"
        id="api-grid"
      >
        <%!-- Copy --%>
        <div class="product-copy">
          <.neon_badge color="#4A9EFF">开发者首选</.neon_badge>
          <h2 class="product-headline">
            告别多平台账号管理，<br><span style="color:#4A9EFF">一个端点，全部搞定</span>
          </h2>
          <p class="product-desc">
            你已经用 OpenAI SDK？改一行 base_url，即刻接入 DeepSeek、Claude、Gemini 等 50+ 模型。负载均衡与故障转移自动完成，统一账单清晰可查。
          </p>
          <ul class="product-feature-list" role="list">
            <%= for feat <- @api_features do %>
              <li>
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#4A9EFF" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                <%= feat %>
              </li>
            <% end %>
          </ul>
          <.btn_primary href="https://api.lurus.cn" external>免费获取 API Key →</.btn_primary>
        </div>

        <%!-- Right column: code block --%>
        <div class="flex flex-col gap-4 min-w-0">
          <.code_block code={@api_code} language="bash" label="API quick start" />
          <div class="diagram-wrapper" aria-label="API architecture">
            <div
              class="w-full h-full rounded-xl flex items-center justify-center"
              style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border)"
            >
              <span style="color:var(--color-text-muted);font-size:0.82rem">Architecture Diagram</span>
            </div>
          </div>
        </div>
      </div>
    </.section>

    <%!-- S6: Kova + Lucrum Bento Grid --%>
    <.section id="kova-lucrum">
      <div
        class="text-center mb-14 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="bento-heading"
      >
        <h2
          class="font-extrabold"
          style="font-size:clamp(2rem,4.5vw,3rem);color:var(--color-text-primary);letter-spacing:-0.03em;line-height:1.1"
        >两大旗舰，解决最难的问题</h2>
        <p
          class="mt-3 mx-auto"
          style="font-size:1.1rem;color:var(--color-text-secondary);max-width:520px;line-height:1.65"
        >一个让 Agent 永不中断，一个让交易策略触手可及</p>
      </div>

      <div
        class="grid md:grid-cols-2 gap-5 items-start reveal-fade-up"
        style="grid-template-columns:1.2fr 1fr"
        phx-hook="ScrollReveal"
        id="bento-grid"
      >
        <%!-- Kova card --%>
        <div
          class="bento-card card-glow flex flex-col gap-3 p-8"
          style="--glow-color:#B08EFF"
        >
          <.neon_badge color="#B08EFF">生产级 Agent 引擎</.neon_badge>
          <h3
            class="font-extrabold"
            style="font-size:1.35rem;color:var(--color-text-primary);letter-spacing:-0.02em;line-height:1.25"
          >
            Agent 永不中断，<span style="color:#B08EFF">状态可靠持久</span>
          </h3>
          <p style="font-size:0.9rem;color:var(--color-text-secondary);line-height:1.6">
            Kova 将 WAL 预写日志引入 Agent 执行引擎。掉电重启后从断点继续，Rust 零 GC 保障确定性响应，让你的 Agent 在生产环境从容运行。
          </p>
          <div class="diagram-wrapper my-1" aria-label="Kova architecture">
            <div
              class="w-full h-full rounded-xl flex items-center justify-center"
              style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border)"
            >
              <span style="color:var(--color-text-muted);font-size:0.82rem">Kova Diagram</span>
            </div>
          </div>
          <ul class="product-feature-list" role="list">
            <%= for feat <- @kova_features do %>
              <li>
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#B08EFF" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                <%= feat %>
              </li>
            <% end %>
          </ul>
          <.btn_outline href="/for-builders">了解 Kova →</.btn_outline>
        </div>

        <%!-- Lucrum card --%>
        <div
          class="bento-card card-glow flex flex-col gap-3 p-8"
          style="--glow-color:#7AFF89"
        >
          <.neon_badge color="#7AFF89">AI 量化交易平台</.neon_badge>
          <h3
            class="font-extrabold"
            style="font-size:1.35rem;color:var(--color-text-primary);letter-spacing:-0.02em;line-height:1.25"
          >
            用中文描述策略，<span style="color:#7AFF89">AI 精准生成代码</span>
          </h3>
          <p style="font-size:0.9rem;color:var(--color-text-secondary);line-height:1.6">
            用一句话描述交易逻辑，AI 自动生成可执行策略代码。专业级回测引擎即时验证，从想法到策略只需一步。
          </p>
          <div class="diagram-wrapper my-1" aria-label="Lucrum chart">
            <div
              class="w-full h-full rounded-xl flex items-center justify-center"
              style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border)"
            >
              <span style="color:var(--color-text-muted);font-size:0.82rem">Lucrum Chart Diagram</span>
            </div>
          </div>
          <ul class="product-feature-list" role="list">
            <%= for feat <- @lucrum_features do %>
              <li>
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#7AFF89" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                <%= feat %>
              </li>
            <% end %>
          </ul>
          <.btn_primary href="https://lucrum.lurus.cn" external>进入 Lucrum →</.btn_primary>
        </div>
      </div>
    </.section>

    <%!-- S7: MemX (centered full-width) --%>
    <.section id="memx" raised>
      <div
        class="text-center mb-14 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="memx-heading"
      >
        <.neon_badge color="#4AFFCB">AI 记忆引擎</.neon_badge>
        <h2 class="product-headline" style="margin-top:16px">
          不再重复解释，<br>
          <span style="color:#4AFFCB">AI 真正理解你</span>
        </h2>
        <p class="product-desc" style="margin:0 auto 32px;text-align:center">
          每次开新对话都要重新交代背景？MemX 为你的 AI 建立持久记忆层。你的偏好、历史上下文跨工具跨会话保存，下次对话直接延续 — 不再从零开始。
        </p>
      </div>

      <div
        class="mx-auto reveal-fade-up"
        phx-hook="ScrollReveal"
        id="memx-diagram"
        style="max-width:480px;aspect-ratio:4/3"
        aria-label="MemX graph"
      >
        <div
          class="w-full h-full rounded-xl flex items-center justify-center"
          style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border)"
        >
          <span style="color:var(--color-text-muted);font-size:0.82rem">MemX Graph Diagram</span>
        </div>
      </div>

      <ul
        class="flex flex-wrap justify-center gap-x-8 gap-y-4 list-none p-0 mt-6 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="memx-features"
        role="list"
      >
        <%= for feat <- @memx_features do %>
          <li class="flex items-center gap-2" style="font-size:0.9rem;color:var(--color-text-secondary)">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#4AFFCB" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
            </svg>
            <%= feat %>
          </li>
        <% end %>
      </ul>

      <div
        class="text-center mt-10 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="memx-cta"
      >
        <a
          href="/download#memx"
          class="btn-outline btn-outline--lg"
          style="border-color:#4AFFCB;color:#4AFFCB"
        >下载 MemX →</a>
      </div>
    </.section>

    <%!-- S8: Lurus Creator --%>
    <.section id="creator" raised>
      <div
        class="text-center mb-14 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="creator-heading"
      >
        <.neon_badge color="#FFB86C">桌面内容工厂</.neon_badge>
        <h2 class="product-headline" style="margin-top:16px">
          一条视频，<br>
          <span style="color:#FFB86C">全平台同步发布</span>
        </h2>
        <p class="product-desc" style="margin:0 auto 32px;text-align:center">
          手动转录视频、逐平台发布内容？Creator 自动完成一切。yt-dlp 抓取任意视频，Whisper 高精度转录，LLM 优化文案，一键同步到微信视频号、抖音、YouTube — 全程无需手动操作。
        </p>
      </div>

      <div
        class="reveal-fade-up"
        phx-hook="ScrollReveal"
        id="creator-diagram"
        style="width:100%;aspect-ratio:16/5;max-height:200px"
        aria-label="Creator pipeline"
      >
        <div
          class="w-full h-full rounded-xl flex items-center justify-center"
          style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border)"
        >
          <span style="color:var(--color-text-muted);font-size:0.82rem">Creator Pipeline Diagram</span>
        </div>
      </div>

      <div
        class="text-center mt-10 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="creator-cta"
      >
        <a
          href="/download"
          class="btn-primary btn-primary--lg"
          style="background:#FFB86C;color:#0D0B09"
        >下载 Lurus Creator →</a>
      </div>
    </.section>

    <%!-- S9: Switch + Lumen dual cards --%>
    <.section id="switch-lumen">
      <div
        class="text-center mb-14 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="dual-heading"
      >
        <h2
          class="font-extrabold"
          style="font-size:clamp(2rem,4.5vw,3rem);color:var(--color-text-primary);letter-spacing:-0.03em;line-height:1.1"
        >让工具听你指挥</h2>
        <p
          class="mt-3 mx-auto"
          style="font-size:1.1rem;color:var(--color-text-secondary);max-width:520px;line-height:1.65"
        >配置不再散落各处，执行过程不再是黑箱</p>
      </div>

      <div
        class="dual-product-grid reveal-fade-up"
        phx-hook="ScrollReveal"
        id="dual-grid"
      >
        <%!-- Switch card --%>
        <div class="dual-card card-glow" style="--card-accent:#FF8C69;--glow-color:#FF8C69">
          <.neon_badge color="#FF8C69">AI 工具管理器</.neon_badge>
          <h3
            class="font-extrabold mt-4 mb-2"
            style="font-size:1.4rem;color:var(--color-text-primary);letter-spacing:-0.02em"
          >Lurus Switch</h3>
          <p class="mb-5" style="font-size:0.9rem;color:var(--color-text-secondary);line-height:1.6">
            AI 命令行工具越来越多，配置散落各处，密钥管理混乱？Switch 一个面板统一管控所有 AI CLI 工具的配置、密钥和 MCP 预设。
          </p>
          <div class="diagram-wrapper mb-5" aria-label="Switch diagram">
            <div
              class="w-full h-full rounded-xl flex items-center justify-center"
              style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border)"
            >
              <span style="color:var(--color-text-muted);font-size:0.82rem">Switch Diagram</span>
            </div>
          </div>
          <ul class="product-feature-list mb-5" role="list">
            <%= for feat <- @switch_features do %>
              <li>
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#FF8C69" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                <%= feat %>
              </li>
            <% end %>
          </ul>
          <a
            href="/download"
            class="btn-outline btn-outline--sm"
            style="border-color:#FF8C69;color:#FF8C69"
          >下载 Switch →</a>
        </div>

        <%!-- Lumen card --%>
        <div class="dual-card card-glow" style="--card-accent:#FFE566;--glow-color:#FFE566">
          <.neon_badge color="#FFE566">Agent 调试器</.neon_badge>
          <h3
            class="font-extrabold mt-4 mb-2"
            style="font-size:1.4rem;color:var(--color-text-primary);letter-spacing:-0.02em"
          >Lumen</h3>
          <p class="mb-5" style="font-size:0.9rem;color:var(--color-text-secondary);line-height:1.6">
            Agent 执行过程是黑箱？Lumen 让每一步调用链清晰可见，断点注入精准定位问题，状态树可视化一眼看懂 Agent 运行状态。
          </p>
          <div class="diagram-wrapper mb-5" aria-label="Lumen diagram">
            <div
              class="w-full h-full rounded-xl flex items-center justify-center"
              style="background-color:var(--color-surface-overlay);border:1px solid var(--color-surface-border)"
            >
              <span style="color:var(--color-text-muted);font-size:0.82rem">Lumen Diagram</span>
            </div>
          </div>
          <ul class="product-feature-list mb-5" role="list">
            <%= for feat <- @lumen_features do %>
              <li>
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="#FFE566" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                <%= feat %>
              </li>
            <% end %>
          </ul>
          <a
            href="/for-builders"
            class="btn-outline btn-outline--sm"
            style="border-color:#FFE566;color:#FFE566"
          >了解 Lumen →</a>
        </div>
      </div>
    </.section>

    <%!-- S10: Ecosystem Map / Bento overview --%>
    <.section id="ecosystem">
      <div
        class="text-center mb-14 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="ecosystem-heading"
      >
        <h2
          class="font-extrabold"
          style="font-size:clamp(2rem,4.5vw,3rem);color:var(--color-text-primary);letter-spacing:-0.03em;line-height:1.1"
        >不是 7 个独立工具，是一个完整平台</h2>
        <p
          class="mt-3 mx-auto"
          style="font-size:1.1rem;color:var(--color-text-secondary);max-width:520px;line-height:1.65"
        >基础设施层与应用层无缝协作，数据在产品间自由流转</p>
      </div>

      <div
        class="reveal-fade-up"
        phx-hook="ScrollReveal"
        id="ecosystem-map"
      >
        <%!-- Bento grid showing the product ecosystem --%>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
          <%= for product <- Enum.take(@products, 8) do %>
            <a
              href={product.url}
              target={if product[:external], do: "_blank"}
              rel={if product[:external], do: "noopener noreferrer"}
              class="bento-card card-glow p-5 no-underline"
              style={"--glow-color:#{product.neon_color}"}
            >
              <div class="flex items-center gap-2 mb-3">
                <.icon path={product.icon_path} class="w-5 h-5" />
                <span class="font-semibold text-sm" style="color:var(--color-text-primary)"><%= product.name %></span>
              </div>
              <p style="font-size:0.78rem;color:var(--color-text-muted);line-height:1.5"><%= product.tagline %></p>
              <div class="mt-3 flex items-center gap-1">
                <span
                  class="w-1.5 h-1.5 rounded-full"
                  style={"background:#{product.neon_color};animation:neon-dot-pulse 2.4s ease-in-out infinite"}
                ></span>
                <span style={"font-size:0.7rem;color:#{product.neon_color};font-weight:600"}><%= product.stats.value %> <%= product.stats.label %></span>
              </div>
            </a>
          <% end %>
        </div>
      </div>
    </.section>

    <%!-- S11: Path Cards --%>
    <.section id="choose-path" raised>
      <div
        class="text-center mb-16 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="paths-heading"
      >
        <h2
          class="font-extrabold"
          style="font-size:clamp(2rem,4.5vw,3rem);color:var(--color-text-primary);letter-spacing:-0.03em;line-height:1.1"
        >找到最适合你的方案</h2>
        <p
          class="mt-3 mx-auto"
          style="font-size:1.1rem;color:var(--color-text-secondary);max-width:520px;line-height:1.65"
        >三种身份，三条路径，同一个可靠平台</p>
      </div>

      <div
        class="grid md:grid-cols-3 gap-4 reveal-fade-up"
        phx-hook="ScrollReveal"
        id="paths-grid"
      >
        <%= for path <- @paths do %>
          <a
            href={path.href}
            class="relative block p-7 rounded-2xl overflow-hidden no-underline card-glow"
            style={"--path-color:#{path.color};--glow-color:#{path.color};background-color:var(--color-surface-raised);border:1px solid var(--color-surface-border);transition:border-color 0.2s,transform 0.2s;text-decoration:none"}
          >
            <%!-- Top line on hover via CSS --%>
            <div
              class="absolute top-0 left-0 right-0 h-0.5 opacity-0"
              style={"background:linear-gradient(90deg,transparent,#{path.color},transparent);transition:opacity 0.2s"}
              aria-hidden="true"
            ></div>
            <span
              class="inline-block py-0.5 px-2.5 rounded-full mb-4"
              style={"font-size:0.68rem;font-weight:600;letter-spacing:0.08em;color:#{path.color};border:1px solid #{path.color};opacity:0.75"}
            ><%= path.badge %></span>
            <p style="font-size:0.78rem;color:var(--color-text-muted);margin-bottom:6px"><%= path.audience %></p>
            <p
              class="font-bold mb-2"
              style="font-size:1.05rem;color:var(--color-text-primary);line-height:1.3"
            ><%= path.action %></p>
            <p style="font-size:0.85rem;color:var(--color-text-secondary);line-height:1.55"><%= path.description %></p>
            <span class="block mt-5" style="color:var(--color-text-muted);font-size:1rem" aria-hidden="true">→</span>
          </a>
        <% end %>
      </div>
    </.section>

    <%!-- S12: Final CTA --%>
    <section
      class="section-dark py-36 text-center has-light-sweep"
      aria-label="立即开始"
    >
      <div
        class="max-w-3xl mx-auto px-6 reveal-fade-up relative z-10"
        phx-hook="ScrollReveal"
        id="final-cta"
      >
        <h2
          class="font-extrabold"
          style="font-size:clamp(2.25rem,5vw,3.25rem);color:var(--color-text-primary);letter-spacing:-0.03em;line-height:1.1"
        >从今天开始，告别碎片化</h2>
        <p
          class="mt-4 mb-10 mx-auto"
          style="font-size:1.1rem;color:var(--color-text-secondary);max-width:520px;line-height:1.65"
        >一个平台，完整的 AI 基础设施。免费开始，按需扩展。</p>

        <div class="flex flex-wrap items-center justify-center gap-4">
          <.btn_primary href="https://api.lurus.cn" external size="lg">免费体验 →</.btn_primary>
          <.btn_outline href="https://docs.lurus.cn" external size="lg">阅读文档</.btn_outline>
        </div>

        <%!-- Trust badges --%>
        <div class="flex flex-wrap items-center justify-center gap-6 mt-7">
          <%= for badge <- @trust_badges do %>
            <span class="flex items-center gap-1.5" style="font-size:0.85rem;color:var(--color-text-muted)">
              <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={badge.path} />
              </svg>
              <%= badge.label %>
            </span>
          <% end %>
          <span class="flex items-center gap-1.5" style="font-size:0.85rem;color:var(--color-text-muted)">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" />
            </svg>
            符合 PIPL 合规要求
          </span>
          <span class="flex items-center gap-1.5" style="font-size:0.85rem;color:var(--color-text-muted)">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="var(--color-ochre)" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            99.9% SLA 服务保障
          </span>
        </div>
      </div>
    </section>
    """
  end
end
