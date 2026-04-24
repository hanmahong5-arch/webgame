defmodule LurusWwwWeb.Live.HomeLive do
  @moduledoc "Slither.io-style splash: nickname + PLAY, straight into the arena."
  use LurusWwwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Snake Arena — play now")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="sio-home" id="sio-home" phx-hook="PlayLauncher">
      <div class="sio-bg" aria-hidden="true">
        <div class="sio-bg-dots"></div>
        <div class="sio-worm sio-worm--1"></div>
        <div class="sio-worm sio-worm--2"></div>
        <div class="sio-worm sio-worm--3"></div>
        <div class="sio-worm sio-worm--4"></div>
        <div class="sio-pellet sio-pellet--1"></div>
        <div class="sio-pellet sio-pellet--2"></div>
        <div class="sio-pellet sio-pellet--3"></div>
        <div class="sio-pellet sio-pellet--4"></div>
        <div class="sio-pellet sio-pellet--5"></div>
        <div class="sio-pellet sio-pellet--6"></div>
      </div>

      <main class="sio-main">
        <div class="sio-logo">
          <h1 class="sio-logo-text">SNAKE<span class="sio-logo-dot">.</span>ARENA</h1>
          <p class="sio-logo-sub">multiplayer &middot; real-time &middot; no install</p>
        </div>

        <form class="sio-panel" phx-submit="noop" onsubmit="return false;">
          <input
            type="text"
            id="sio-name"
            class="sio-name"
            placeholder="nickname"
            maxlength="16"
            autocomplete="off"
            spellcheck="false"
            autofocus
          />
          <button type="button" id="sio-play" class="sio-play">Play</button>
          <div class="sio-row">
            <.link navigate={~p"/create"} class="sio-ghost">Create a game</.link>
          </div>
        </form>

        <div class="sio-tips">
          <span><kbd>Mouse</kbd> steer</span>
          <span><kbd>Click</kbd>/<kbd>Space</kbd> boost</span>
        </div>
      </main>

      <footer class="sio-footer">
        <.link navigate={~p"/terms"}>Terms</.link>
        <span class="sio-dot">&middot;</span>
        <.link navigate={~p"/privacy"}>Privacy</.link>
      </footer>
    </div>
    """
  end

  @impl true
  def handle_event("noop", _, socket), do: {:noreply, socket}
end
