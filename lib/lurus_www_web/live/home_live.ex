defmodule LurusWwwWeb.Live.HomeLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Games.GameServer

  @features [
    %{
      title: "Real-time Multiplayer",
      desc: "WebSocket-driven game rooms with sub-100ms latency. Up to 8 players per room.",
      icon: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z",
      color: "#00F0FF"
    },
    %{
      title: "AI Game Creator",
      desc: "Describe your game in natural language. AI generates the code, graphics, and logic.",
      icon: "M13 10V3L4 14h7v7l9-11h-7z",
      color: "#FFB800"
    },
    %{
      title: "Secure Sandbox",
      desc: "Every game runs in an isolated BEAM process. Crash-proof, memory-safe, zero-downtime.",
      icon: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z",
      color: "#00FF87"
    },
    %{
      title: "Token Economy",
      desc: "Publish games, earn tokens from plays. Monetize with subscriptions or per-play pricing.",
      icon: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
      color: "#8B5CF6"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    room_count =
      if connected?(socket) do
        length(GameServer.list_rooms())
      else
        0
      end

    socket =
      assign(socket,
        page_title: "WebGame - AI Game Platform",
        features: @features,
        room_count: room_count
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Hero --%>
    <section class="hero-section">
      <div class="hero-bg" aria-hidden="true">
        <div class="hero-grid-lines"></div>
        <div class="hero-glow hero-glow--1"></div>
        <div class="hero-glow hero-glow--2"></div>
      </div>

      <div class="hero-inner">
        <div class="hero-badge">
          <span class="hero-badge-dot"></span>
          {if @room_count > 0, do: "#{@room_count} active games", else: "Platform Online"}
        </div>

        <h1 class="hero-h1">
          <span class="text-gradient-cyan">WebGame</span>
        </h1>
        <p class="hero-tagline">AI-Powered Game Creation Platform</p>
        <p class="hero-desc">
          Create games with natural language. Play with friends in real-time.
          <br />Publish and monetize your creations.
        </p>

        <div class="hero-cta">
          <.link navigate={~p"/play"} class="btn-accent btn-accent--lg">
            Start Playing
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
          </.link>
          <.link navigate={~p"/create"} class="btn-outline-game btn-outline--lg">
            Create a Game
          </.link>
        </div>
      </div>
    </section>

    <%!-- Featured Game --%>
    <section class="featured-section">
      <div class="section-inner">
        <div class="featured-card">
          <div class="featured-left">
            <span class="featured-badge">Featured Game</span>
            <h2 class="featured-title">Multiplayer Snake</h2>
            <p class="featured-desc">
              Classic snake with a twist: compete against up to 8 players in real-time.
              Eat food, grow your snake, eliminate opponents. Last one standing wins.
            </p>
            <ul class="featured-features">
              <li>Real-time multiplayer via WebSocket</li>
              <li>Up to 8 players per room</li>
              <li>Synthesized sound effects</li>
              <li>Mobile touch controls</li>
            </ul>
            <.link navigate={~p"/play"} class="btn-accent">
              Play Now &rarr;
            </.link>
          </div>
          <div class="featured-right">
            <div class="featured-preview">
              <div class="preview-grid">
                <div class="preview-snake preview-snake--1"></div>
                <div class="preview-snake preview-snake--2"></div>
                <div class="preview-snake preview-snake--3"></div>
                <div class="preview-food preview-food--1"></div>
                <div class="preview-food preview-food--2"></div>
                <div class="preview-food preview-food--3"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <%!-- How It Works --%>
    <section class="steps-section">
      <div class="section-inner">
        <h2 class="section-title">How It Works</h2>
        <div class="steps-grid">
          <div class="step-card">
            <div class="step-number">01</div>
            <h3 class="step-title">Describe</h3>
            <p class="step-desc">Tell AI what game you want. Use plain language to describe rules, mechanics, and visuals.</p>
          </div>
          <div class="step-card">
            <div class="step-number">02</div>
            <h3 class="step-title">Create</h3>
            <p class="step-desc">AI generates game code with graphics, sound, and multiplayer logic in a secure sandbox.</p>
          </div>
          <div class="step-card">
            <div class="step-number">03</div>
            <h3 class="step-title">Play & Earn</h3>
            <p class="step-desc">Share your game, invite friends, and earn tokens from every play session.</p>
          </div>
        </div>
      </div>
    </section>

    <%!-- Platform Features --%>
    <section class="features-section">
      <div class="section-inner">
        <h2 class="section-title">Platform Capabilities</h2>
        <div class="features-grid">
          <%= for f <- @features do %>
            <div class="feature-card" style={"--feature-color:#{f.color}"}>
              <div class="feature-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={f.color} stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
                  <path d={f.icon} />
                </svg>
              </div>
              <h3 class="feature-title">{f.title}</h3>
              <p class="feature-desc">{f.desc}</p>
            </div>
          <% end %>
        </div>
      </div>
    </section>

    <%!-- CTA --%>
    <section class="cta-section">
      <div class="section-inner text-center">
        <h2 class="cta-title">Ready to Play?</h2>
        <p class="cta-desc">Jump into a game or create your own. No account required.</p>
        <div class="cta-buttons">
          <.link navigate={~p"/play"} class="btn-accent btn-accent--lg">Start Playing</.link>
          <.link navigate={~p"/create"} class="btn-outline-game btn-outline--lg">Create a Game</.link>
        </div>
      </div>
    </section>
    """
  end
end
