defmodule LurusWwwWeb.Live.NotFoundLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Page Not Found — Lurus")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center min-h-[60vh] px-6 text-center">
      <p class="text-7xl font-bold mb-4" style="color:var(--color-ochre);">404</p>
      <h1 class="text-2xl font-bold mb-3" style="color:var(--color-text-primary);">页面未找到</h1>
      <p class="mb-8 max-w-md" style="color:var(--color-text-secondary);">
        你访问的页面不存在或已被移动。请检查 URL 是否正确，或返回首页继续浏览。
      </p>
      <div class="flex gap-4">
        <.btn_primary href="/">返回首页</.btn_primary>
        <.btn_outline href="https://docs.lurus.cn" external>查看文档</.btn_outline>
      </div>
    </div>
    """
  end
end
