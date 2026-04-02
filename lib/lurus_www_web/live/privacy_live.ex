defmodule LurusWwwWeb.Live.PrivacyLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "隐私政策 — Lurus")
     |> assign(:page_description, "Lurus 隐私政策：我们如何收集、使用和保护你的数据。")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.section>
      <h1 class="text-3xl font-bold mb-8" style="color:var(--color-text-primary);">隐私政策</h1>
      <div class="prose-dark" style="color:var(--color-text-secondary); line-height:1.8; max-width:720px;">
        <p class="mb-6">最后更新日期：2026 年 1 月 1 日</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">1. 信息收集</h2>
        <p class="mb-4">我们收集您在注册和使用服务时提供的信息，包括邮箱地址、用户名、API 使用数据等。我们不收集不必要的个人信息。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">2. 信息使用</h2>
        <p class="mb-4">收集的信息用于提供和改进服务、处理支付、发送服务通知。我们不会将您的数据出售给第三方。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">3. 数据安全</h2>
        <p class="mb-4">我们采用行业标准的安全措施保护您的数据，包括传输加密（TLS）、存储加密、访问控制。但互联网传输无法保证绝对安全。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">4. API 数据</h2>
        <p class="mb-4">通过 API 传输的数据在处理完成后不会被存储。我们不使用您的 API 调用数据来训练模型。日志仅保留必要的请求元数据用于计费和故障排查。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">5. Cookie 使用</h2>
        <p class="mb-4">我们使用加密 Cookie 维护登录会话。不使用第三方追踪 Cookie。您可以在浏览器设置中管理 Cookie 偏好。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">6. 您的权利</h2>
        <p class="mb-4">您有权访问、更正或删除您的个人数据。如需行使这些权利，请联系我们的隐私团队。</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">7. 联系方式</h2>
        <p>隐私相关问题请联系 <a href="mailto:privacy@lurus.cn" style="color:var(--color-ochre);">privacy@lurus.cn</a></p>
      </div>
    </.section>
    """
  end
end
