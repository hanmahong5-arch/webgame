defmodule LurusWwwWeb.NavComponents do
  use Phoenix.Component

  attr :current_path, :string, default: "/"
  attr :current_user, :map, default: nil

  def topbar(assigns) do
    ~H"""
    <header
      class="game-topbar"
      id="topbar"
      phx-hook="TopBarScroll"
      aria-label="Main navigation"
    >
      <div class="topbar-inner">
        <a href="/" class="topbar-logo">
          <div class="logo-icon">W</div>
          <span class="logo-text">WebGame</span>
        </a>

        <nav class="topbar-nav hidden md:flex" aria-label="Primary">
          <a href="/play" class={"nav-link #{if @current_path =~ ~r"^/play", do: "active"}"}>Play</a>
          <a href="/create" class={"nav-link #{if @current_path == "/create", do: "active"}"}>Create</a>
        </nav>

        <div class="topbar-right hidden md:flex">
          <%= if @current_user do %>
            <div class="user-badge">
              <div class="user-avatar">
                {String.first(@current_user.name || "U") |> String.upcase()}
              </div>
              <span class="user-name">{@current_user.name}</span>
            </div>
            <a href="/auth/logout" class="nav-link text-muted">Logout</a>
          <% else %>
            <a href="/auth/login" class="nav-link">Login</a>
            <a href="/auth/login?prompt=create" class="btn-accent btn-accent--sm">Sign Up</a>
          <% end %>
        </div>

        <button
          class="mobile-menu-btn flex md:hidden"
          phx-click={Phoenix.LiveView.JS.toggle(to: "#mobile-menu")}
          aria-label="Toggle navigation"
        >
          <svg width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>

      <div id="mobile-menu" class="mobile-menu hidden" role="dialog" aria-modal="true">
        <div class="mobile-menu-inner">
          <a href="/play" class="mobile-nav-link">Play</a>
          <a href="/create" class="mobile-nav-link">Create</a>
          <div class="mobile-divider"></div>
          <%= if @current_user do %>
            <span class="mobile-nav-link">{@current_user.name}</span>
            <a href="/auth/logout" class="mobile-nav-link">Logout</a>
          <% else %>
            <a href="/auth/login" class="mobile-nav-link">Login</a>
            <a href="/auth/login?prompt=create" class="btn-accent mobile-cta">Sign Up</a>
          <% end %>
        </div>
      </div>
    </header>
    """
  end
end
