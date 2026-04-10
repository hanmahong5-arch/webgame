defmodule LurusWwwWeb.Live.NotFoundLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "404 — WebGame")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center min-h-[60vh] px-6 text-center">
      <p class="text-7xl font-bold mb-4" style="color:var(--color-accent);">404</p>
      <h1 class="text-2xl font-bold mb-3" style="color:var(--color-text-primary);">Page Not Found</h1>
      <p class="mb-8 max-w-md" style="color:var(--color-text-secondary);">
        The page you're looking for doesn't exist or has been moved.
      </p>
      <div class="flex gap-4">
        <a href="/" class="btn-accent">Home</a>
        <a href="/play" class="btn-outline-game">Play</a>
      </div>
    </div>
    """
  end
end
