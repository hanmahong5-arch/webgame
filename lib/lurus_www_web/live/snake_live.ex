defmodule LurusWwwWeb.Live.SnakeLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Games.GameServer

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    player_id = generate_id()

    socket =
      assign(socket,
        page_title: "Snake - #{room_id}",
        room_id: room_id,
        player_id: player_id,
        player_name: "",
        joined: false,
        game_state: nil,
        game_status: nil
      )

    if connected?(socket) do
      Phoenix.PubSub.subscribe(LurusWww.PubSub, "game:#{room_id}")

      case GameServer.get_state(room_id) do
        {:ok, state} ->
          {:ok, assign(socket, game_state: state, game_status: state.status)}

        {:error, :not_found} ->
          {:ok, push_navigate(socket, to: ~p"/play")}
      end
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("set_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, player_name: name)}
  end

  def handle_event("join", %{"name" => name}, socket) do
    name = String.trim(name)
    name = if name == "", do: "Player #{:rand.uniform(999)}", else: name

    case GameServer.join(socket.assigns.room_id, socket.assigns.player_id, name) do
      {:ok, state} ->
        {:noreply,
         assign(socket,
           joined: true,
           player_name: name,
           game_state: state,
           game_status: state.status
         )}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Cannot join: #{reason}")}
    end
  end

  def handle_event("start_game", _params, socket) do
    GameServer.start_game(socket.assigns.room_id)
    {:noreply, socket}
  end

  def handle_event("rematch", _params, socket) do
    GameServer.rematch(socket.assigns.room_id)
    {:noreply, socket}
  end

  def handle_event("input", %{"direction" => dir}, socket)
      when dir in ["up", "down", "left", "right"] do
    GameServer.input(socket.assigns.room_id, socket.assigns.player_id, String.to_existing_atom(dir))
    {:noreply, socket}
  end

  def handle_event("input", _params, socket), do: {:noreply, socket}

  def handle_event("leave", _params, socket) do
    GameServer.leave(socket.assigns.room_id, socket.assigns.player_id)
    {:noreply, push_navigate(socket, to: ~p"/play")}
  end

  @impl true
  def handle_info({:game_state, state}, socket) do
    socket =
      socket
      |> push_event("game_state", state)
      |> assign(game_state: state, game_status: state.status)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="snake-page">
      <%= if not @joined do %>
        <%!-- Join Screen --%>
        <div class="join-overlay">
          <div class="join-card">
            <div class="join-card-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#00F0FF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 12h8"/><path d="M12 8v8"/></svg>
            </div>
            <h2 class="join-title">Join Game</h2>
            <p class="room-label">Room <span class="room-code-big">{@room_id}</span></p>

            <%= if @game_state do %>
              <div class="player-preview">
                <%= for {_id, p} <- @game_state.players do %>
                  <div class="player-tag">
                    <span class="player-dot-sm" style={"background:#{p.color}"}></span>
                    {p.name}
                  </div>
                <% end %>
                <%= if map_size(@game_state.players) == 0 do %>
                  <p class="text-muted text-sm">No players yet. Be the first!</p>
                <% end %>
              </div>
            <% end %>

            <form phx-submit="join" class="join-game-form">
              <input
                type="text"
                name="name"
                value={@player_name}
                placeholder="Your name"
                maxlength="16"
                autocomplete="off"
                class="name-input"
                autofocus
                phx-change="set_name"
              />
              <button type="submit" class="btn-accent btn-accent--lg w-full">Join Game</button>
            </form>

            <.link navigate={~p"/play"} class="back-link">Back to Lobby</.link>
          </div>
        </div>
      <% else %>
        <%!-- Game Area --%>
        <div class="game-area">
          <div class="canvas-container">
            <canvas
              id="game-canvas"
              phx-hook="SnakeCanvas"
              phx-update="ignore"
              data-player-id={@player_id}
            >
            </canvas>
          </div>

          <%!-- HUD --%>
          <div class="game-hud">
            <div class="hud-left">
              <span class="room-badge">{@room_id}</span>
            </div>
            <div class="hud-right">
              <button phx-click="leave" class="hud-btn">Leave</button>
            </div>
          </div>

          <%!-- Scoreboard --%>
          <div class="scoreboard">
            <%= if @game_state do %>
              <%= for {_id, p} <- Enum.sort_by(@game_state.players, fn {_, p} -> -p.score end) do %>
                <div class={"score-row #{if not p.alive, do: "dead"}"}>
                  <span class="score-color" style={"background:#{p.color}"}></span>
                  <span class="score-name">{p.name}</span>
                  <span class="score-pts">{p.score}</span>
                  <%= if p.kills > 0 do %>
                    <span class="score-kills">{p.kills}K</span>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>

          <%!-- Waiting Overlay --%>
          <%= if @game_status == :waiting do %>
            <div class="game-overlay">
              <div class="overlay-card">
                <h3 class="overlay-title">Waiting for Players</h3>
                <p class="player-count-big">
                  {(@game_state && map_size(@game_state.players)) || 0} / 8
                </p>
                <p class="share-hint">Share code: <strong class="text-accent">{@room_id}</strong></p>
                <div class="overlay-players">
                  <%= if @game_state do %>
                    <%= for {_id, p} <- @game_state.players do %>
                      <span class="player-chip" style={"border-color:#{p.color}; color:#{p.color}"}>
                        <span class="player-dot-sm" style={"background:#{p.color}"}></span>
                        {p.name}
                      </span>
                    <% end %>
                  <% end %>
                </div>
                <button phx-click="start_game" class="btn-accent btn-accent--lg">
                  Start Game
                </button>
                <p class="controls-hint">Controls: WASD or Arrow Keys</p>
              </div>
            </div>
          <% end %>

          <%!-- Game Over Overlay --%>
          <%= if @game_status == :finished do %>
            <div class="game-overlay">
              <div class="overlay-card gameover">
                <h2 class="overlay-title">Game Over</h2>
                <%= if @game_state && @game_state.winner do %>
                  <% winner = @game_state.players[@game_state.winner] %>
                  <%= if winner do %>
                    <p class="winner-name" style={"color:#{winner.color}"}>
                      {winner.name} Wins!
                    </p>
                  <% end %>
                <% else %>
                  <p class="winner-name">Draw!</p>
                <% end %>

                <div class="final-scores">
                  <%= if @game_state do %>
                    <%= for {_id, p} <- Enum.sort_by(@game_state.players, fn {_, p} -> -p.score end) do %>
                      <div class="final-row">
                        <span class="score-color" style={"background:#{p.color}"}></span>
                        <span class="final-name">{p.name}</span>
                        <span class="final-pts">{p.score} pts</span>
                        <span class="final-kills">{p.kills} kills</span>
                      </div>
                    <% end %>
                  <% end %>
                </div>

                <div class="gameover-actions">
                  <button phx-click="rematch" class="btn-accent">Rematch</button>
                  <.link navigate={~p"/play"} class="btn-outline-game">Lobby</.link>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp generate_id do
    Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
  end
end
