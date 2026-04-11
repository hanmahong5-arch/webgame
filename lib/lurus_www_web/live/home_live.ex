defmodule LurusWwwWeb.Live.HomeLive do
  @moduledoc "Platform landing page with embedded game showcase."
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "WebGame — AI Game Creation Platform")}
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
          Platform Online
        </div>
        <h1 class="hero-h1"><span class="text-gradient-cyan">WebGame</span></h1>
        <p class="hero-tagline">Create &middot; Play &middot; Share &middot; Earn</p>
        <p class="hero-desc">
          AI-powered game creation platform. Describe your game in natural language,
          play with friends in real-time, publish and monetize your creations.
        </p>
        <div class="hero-cta">
          <a href="#games" class="btn-play">Play Now</a>
          <.link navigate={~p"/create"} class="btn-outline-game btn-outline--lg">Create a Game</.link>
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
            <p class="step-desc">Tell AI what game you want. Rules, mechanics, visuals — in plain language.</p>
          </div>
          <div class="step-card">
            <div class="step-number">02</div>
            <h3 class="step-title">Play</h3>
            <p class="step-desc">Your game runs instantly in the browser. Multiplayer, real-time, no install.</p>
          </div>
          <div class="step-card">
            <div class="step-number">03</div>
            <h3 class="step-title">Share & Earn</h3>
            <p class="step-desc">Publish to the platform. Players earn tokens, creators earn revenue.</p>
          </div>
        </div>
      </div>
    </section>

    <%!-- Featured Games --%>
    <section id="games" class="games-section">
      <div class="section-inner">
        <div class="games-header">
          <h2 class="section-title" style="text-align:left; margin-bottom:8px;">Featured Games</h2>
          <p style="color:var(--color-text-muted); font-size:0.9rem; margin-bottom:32px;">
            Official showcases — jump in and play instantly
          </p>
        </div>

        <%!-- Snake Game Card --%>
        <.link navigate={~p"/play"} class="game-showcase-card">
          <div class="showcase-preview">
            <div class="showcase-grid-bg"></div>
            <div class="showcase-snake showcase-snake--1"></div>
            <div class="showcase-snake showcase-snake--2"></div>
            <div class="showcase-snake showcase-snake--3"></div>
            <div class="showcase-food showcase-food--1"></div>
            <div class="showcase-food showcase-food--2"></div>
            <div class="showcase-food showcase-food--3"></div>
            <div class="showcase-food showcase-food--4"></div>
            <div class="showcase-food showcase-food--5"></div>
            <div class="showcase-play-btn">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="currentColor"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            </div>
          </div>
          <div class="showcase-info">
            <div class="showcase-badge">Multiplayer</div>
            <h3 class="showcase-title">Snake Arena</h3>
            <p class="showcase-desc">
              Classic snake reimagined. Free-form movement, mouse steering, powerups,
              boost mechanics. Up to 20 players per arena.
            </p>
            <div class="showcase-tags">
              <span class="showcase-tag">Real-time</span>
              <span class="showcase-tag">PvP</span>
              <span class="showcase-tag">Powerups</span>
              <span class="showcase-tag">Mobile</span>
            </div>
          </div>
        </.link>

        <%!-- Coming Soon Cards --%>
        <div class="coming-soon-grid">
          <div class="coming-soon-card">
            <div class="coming-soon-icon">&#x1F3AE;</div>
            <h4>Battle Pong</h4>
            <p>4-player competitive pong with powerups</p>
            <span class="coming-soon-badge">Coming Soon</span>
          </div>
          <div class="coming-soon-card">
            <div class="coming-soon-icon">&#x1F9F1;</div>
            <h4>Block Builder</h4>
            <p>Collaborative block-building sandbox</p>
            <span class="coming-soon-badge">Coming Soon</span>
          </div>
          <div class="coming-soon-card">
            <div class="coming-soon-icon">&#x1F680;</div>
            <h4>Your Game</h4>
            <p>Create with AI and publish here</p>
            <.link navigate={~p"/create"} class="coming-soon-badge" style="color:var(--color-accent);">Create Now</.link>
          </div>
        </div>
      </div>
    </section>

    <%!-- Platform Features --%>
    <section class="features-section">
      <div class="section-inner">
        <h2 class="section-title">Platform Capabilities</h2>
        <div class="features-grid">
          <div class="feature-card" style="--feature-color:#00F0FF">
            <div class="feature-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#00F0FF" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
            </div>
            <h3 class="feature-title">Real-time Multiplayer</h3>
            <p class="feature-desc">WebSocket-driven. Sub-50ms server ticks. Up to 20 players per room with auto-scaling.</p>
          </div>
          <div class="feature-card" style="--feature-color:#FFB800">
            <div class="feature-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FFB800" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
            </div>
            <h3 class="feature-title">AI Game Creator</h3>
            <p class="feature-desc">Describe your game idea. AI generates code, graphics, and game logic in seconds.</p>
          </div>
          <div class="feature-card" style="--feature-color:#00FF87">
            <div class="feature-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#00FF87" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <h3 class="feature-title">Secure Sandbox</h3>
            <p class="feature-desc">Every game runs in an isolated BEAM process. Crash-proof, memory-safe.</p>
          </div>
          <div class="feature-card" style="--feature-color:#8B5CF6">
            <div class="feature-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#8B5CF6" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M16 8h-6a2 2 0 100 4h4a2 2 0 110 4H8"/><path d="M12 18V6"/></svg>
            </div>
            <h3 class="feature-title">Token Economy</h3>
            <p class="feature-desc">Publish games, earn tokens. Monetize with subscriptions or per-play pricing.</p>
          </div>
        </div>
      </div>
    </section>

    <%!-- CTA --%>
    <section class="cta-section">
      <div class="section-inner text-center">
        <h2 class="cta-title">Ready?</h2>
        <p class="cta-desc">Jump into a game or create your own. No account required.</p>
        <div class="cta-buttons">
          <a href="#games" class="btn-play" style="padding:14px 36px; font-size:17px;">Play Now</a>
          <.link navigate={~p"/create"} class="btn-outline-game btn-outline--lg">Create a Game</.link>
        </div>
      </div>
    </section>
    """
  end
end
