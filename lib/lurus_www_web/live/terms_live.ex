defmodule LurusWwwWeb.Live.TermsLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "服务条款 — Lurus")
     |> assign(:page_description, "Lurus 平台服务条款，使用前请仔细阅读。")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.section>
      <h1 class="text-3xl font-bold mb-8" style="color:var(--color-text-primary);">服务条款</h1>
      <div class="prose-dark" style="color:var(--color-text-secondary); line-height:1.8; max-width:720px;">
        <p class="mb-6">最后更新日期：2026 年 1 月 1 日</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">1. 服务说明</h2>
        <p class="mb-4">Lurus（以下简称"我们"）提供 AI 基础设施服务，包括但不限于 API 网关、桌面工具、量化交易平台等。使用我们的服务即表示您同意本条款。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">2. 账户注册</h2>
        <p class="mb-4">您需要提供真实、准确的信息注册账户。您有责任维护账户安全，对账户下的所有活动负责。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">3. 使用规范</h2>
        <p class="mb-4">您同意不将我们的服务用于任何违法目的，不干扰或破坏服务的正常运行，不尝试未授权访问我们的系统。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">4. 费用与支付</h2>
        <p class="mb-4">部分服务需要付费使用。费用标准以定价页面为准。我们保留调整价格的权利，但会提前通知已付费用户。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">5. 知识产权</h2>
        <p class="mb-4">我们的服务、软件、文档及相关内容受知识产权法保护。未经授权，您不得复制、修改或分发我们的内容。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">6. 免责声明</h2>
        <p class="mb-4">我们的服务按"现状"提供。在法律允许范围内，我们不对因使用服务产生的任何直接或间接损失承担责任。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">7. 条款修改</h2>
        <p class="mb-4">我们保留修改本条款的权利。重大变更将通过邮件或站内通知告知用户。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">8. 联系我们</h2>
        <p>如有疑问，请联系 <a href="mailto:support@lurus.cn" style="color:var(--color-ochre);">support@lurus.cn</a></p>
      </div>
    </.section>
    """
  end
end
