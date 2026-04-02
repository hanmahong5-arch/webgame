defmodule LurusWwwWeb.Live.SolutionsLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "解决方案 — Lurus")
     |> assign(:page_description, "面向金融、医疗、法律、工程等行业的 AI 解决方案，由 Lurus 基础设施驱动。")
     |> assign(:solutions, solutions())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.section>
      <div class="text-center mb-16">
        <h1 class="text-4xl md:text-5xl font-bold mb-4" style="color:var(--color-text-primary);">行业解决方案</h1>
        <p class="text-lg max-w-2xl mx-auto" style="color:var(--color-text-secondary);">
          Lurus 基础设施驱动的 AI 解决方案，覆盖金融、医疗、法律、学术、工程等领域。
        </p>
      </div>

      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div :for={s <- @solutions} class="card-dark p-8 has-light-sweep">
          <div class="text-3xl mb-4"><%= s.icon %></div>
          <h3 class="text-xl font-bold mb-2" style="color:var(--color-text-primary);"><%= s.name %></h3>
          <p class="mb-4" style="color:var(--color-text-secondary); line-height:1.65;"><%= s.description %></p>
          <ul style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:6px;">
            <li :for={f <- s.features} style="font-size:0.875rem; color:var(--color-text-muted); display:flex; align-items:center; gap:8px;">
              <span style="color:var(--color-ochre);">&#10003;</span> <%= f %>
            </li>
          </ul>
        </div>
      </div>
    </.section>

    <.section raised>
      <div class="text-center">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--color-text-primary);">需要定制方案？</h2>
        <p class="mb-8 max-w-lg mx-auto" style="color:var(--color-text-secondary);">
          我们的技术团队可以根据您的行业需求，设计专属的 AI 集成方案。
        </p>
        <.btn_primary href="mailto:enterprise@lurus.cn" external>联系我们</.btn_primary>
      </div>
    </.section>
    """
  end

  defp solutions do
    [
      %{name: "金融", icon: "💹", description: "量化策略生成、风险评估、智能投研 — AI 赋能金融决策全流程。", features: ["自然语言策略生成", "多策略回测验证", "实时风控监控", "合规报告自动生成"]},
      %{name: "医疗健康", icon: "🏥", description: "病历摘要、文献检索、辅助诊断建议 — AI 提升医疗效率。", features: ["医学文献智能检索", "病历结构化提取", "辅助诊断建议", "药物相互作用检查"]},
      %{name: "法律", icon: "⚖️", description: "法条检索、合同审查、案例分析 — AI 加速法律工作流。", features: ["法规条文智能检索", "合同风险自动审查", "案例相似度匹配", "法律文书辅助起草"]},
      %{name: "学术研究", icon: "📚", description: "文献综述、数据分析、论文润色 — AI 辅助研究全周期。", features: ["文献自动综述", "实验数据分析", "论文结构优化", "多语言翻译润色"]},
      %{name: "软件工程", icon: "💻", description: "代码审查、架构设计、调试分析 — AI 提升开发效率。", features: ["Kova Agent SDK 集成", "Lumen 实时调试", "代码审查自动化", "架构设计建议"]},
      %{name: "内容创作", icon: "🎬", description: "视频转录、文案优化、多平台分发 — AI 驱动内容工厂。", features: ["视频 AI 转录", "文案智能优化", "多平台一键发布", "SEO 内容分析"]}
    ]
  end
end
