defmodule LurusWwwWeb.Live.TermsLive do
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Terms — WebGame")
     |> assign(:page_description, "WebGame platform terms of service.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="py-16 px-6 max-w-3xl mx-auto">
      <h1 class="text-3xl font-bold mb-8" style="color:var(--color-text-primary);">Terms of Service</h1>
      <div style="color:var(--color-text-secondary); line-height:1.8;">
        <p class="mb-6">Last updated: January 1, 2026</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">1. Service Description</h2>
        <p class="mb-4">WebGame provides an AI-powered game creation and multiplayer gaming platform. By using our services, you agree to these terms.</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">2. User Conduct</h2>
        <p class="mb-4">You agree not to use our services for illegal purposes, disrupt normal operations, or attempt unauthorized access to our systems.</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">3. Game Content</h2>
        <p class="mb-4">Games created on the platform must not contain harmful, illegal, or offensive content. We reserve the right to remove content that violates these terms.</p>

        <h2 class="text-xl font-semibold mt-8 mb-4" style="color:var(--color-text-primary);">4. Contact</h2>
        <p>Questions? Contact <a href="mailto:support@lurus.cn" style="color:var(--color-accent);">support@lurus.cn</a></p>
      </div>
    </div>
    """
  end
end
