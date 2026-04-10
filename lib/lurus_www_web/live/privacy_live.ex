defmodule LurusWwwWeb.Live.PrivacyLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Privacy — WebGame")
     |> assign(:page_description, "WebGame privacy policy.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="py-16 px-6 max-w-3xl mx-auto">
      <h1 class="text-3xl font-bold mb-8" style="color:var(--color-text-primary);">Privacy Policy</h1>
      <div style="color:var(--color-text-secondary); line-height:1.8;">
        <p class="mb-6">Last updated: January 1, 2026</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">1. Data Collection</h2>
        <p class="mb-4">We collect minimal data required to provide our services: session cookies for gameplay and optional account information if you sign up.</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">2. Game Data</h2>
        <p class="mb-4">Game sessions are ephemeral and not stored after completion. AI-generated game code is stored only if you choose to publish it.</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">3. Cookies</h2>
        <p class="mb-4">We use encrypted cookies for session management only. No third-party tracking cookies are used.</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">4. Contact</h2>
        <p>Privacy questions: <a href="mailto:privacy@lurus.cn" style="color:var(--color-accent);">privacy@lurus.cn</a></p>
      </div>
    </div>
    """
  end
end
