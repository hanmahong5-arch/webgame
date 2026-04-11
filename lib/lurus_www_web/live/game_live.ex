defmodule LurusWwwWeb.Live.GameLive do
  @moduledoc """
  The game IS the homepage. Zero friction — open page, see game, click to play.
  Player identity persisted via JS localStorage (pushed on mount).
  """
  use LurusWwwWeb, :live_view

  alias LurusWww.Games.{GameServer, AutoRoom}

  @impl true
  def mount(params, _session, socket) do
    socket = assign(socket,
      page_title: "WebGame",
      room_id: nil,
      player_id: nil,
      player_name: nil,
      joined: false,
      game_state: nil,
      my_alive: false,
      spectating: true
    )

    if connected?(socket) do
      # Determine room: from URL or auto-assign
      room_id = case params do
        %{"room_id" => id} -> ensure_room(id)
        _ -> AutoRoom.find_or_create()
      end

      Phoenix.PubSub.subscribe(LurusWww.PubSub, "game:#{room_id}")

      game_state = case GameServer.get_state(room_id) do
        {:ok, s} -> s
        _ -> nil
      end

      {:ok, assign(socket, room_id: room_id, game_state: game_state)}
    else
      {:ok, socket}
    end
  end

  defp ensure_room(id) do
    if GameServer.room_exists?(id), do: id, else: AutoRoom.find_or_create()
  end

  # Player connects with their localStorage identity
  @impl true
  def handle_event("init_player", %{"id" => id, "name" => name}, socket) do
    {:noreply, assign(socket, player_id: id, player_name: name)}
  end

  def handle_event("join", %{"name" => name}, socket) do
    name = String.trim(name)
    name = if name == "", do: "Snake#{:rand.uniform(999)}", else: String.slice(name, 0..15)
    player_id = socket.assigns.player_id || generate_id()

    case GameServer.join(socket.assigns.room_id, player_id, name) do
      {:ok, state} ->
        {:noreply,
          socket
          |> push_event("save_name", %{name: name})
          |> assign(joined: true, player_id: player_id, player_name: name,
                    game_state: state, my_alive: true, spectating: false)
        }
      {:error, :room_full} ->
        # Auto-overflow to new room
        new_room = AutoRoom.find_or_create()
        Phoenix.PubSub.unsubscribe(LurusWww.PubSub, "game:#{socket.assigns.room_id}")
        Phoenix.PubSub.subscribe(LurusWww.PubSub, "game:#{new_room}")
        case GameServer.join(new_room, player_id, name) do
          {:ok, state} ->
            {:noreply, assign(socket,
              room_id: new_room, joined: true, player_id: player_id,
              player_name: name, game_state: state, my_alive: true, spectating: false
            )}
          _ ->
            {:noreply, put_flash(socket, :error, "Server busy, try again")}
        end
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Error: #{reason}")}
    end
  end

  def handle_event("respawn", _params, socket) do
    if socket.assigns.player_id && socket.assigns.room_id do
      GameServer.respawn(socket.assigns.room_id, socket.assigns.player_id)
    end
    {:noreply, assign(socket, my_alive: true)}
  end

  def handle_event("steer", %{"angle" => angle}, socket) when is_number(angle) do
    if socket.assigns.joined do
      GameServer.set_target(socket.assigns.room_id, socket.assigns.player_id, angle / 1)
    end
    {:noreply, socket}
  end

  def handle_event("boost", %{"active" => active}, socket) when is_boolean(active) do
    if socket.assigns.joined do
      GameServer.set_boost(socket.assigns.room_id, socket.assigns.player_id, active)
    end
    {:noreply, socket}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:game_state, state}, socket) do
    my_alive = if socket.assigns.player_id do
      case Map.get(state.players, socket.assigns.player_id) do
        %{al: alive} -> alive
        %{alive: alive} -> alive
        _ -> false
      end
    else
      false
    end

    socket =
      socket
      |> push_event("game_state", state)
      |> assign(game_state: state, my_alive: my_alive)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="snake-page">
      <%!-- Game canvas always visible (spectate mode until join) --%>
      <div class="game-area">
        <div class="canvas-container">
          <canvas id="game-canvas" phx-hook="SnakeCanvas" phx-update="ignore"
            data-player-id={@player_id || "spectator"}></canvas>
        </div>

        <%!-- Top HUD --%>
        <div class="game-hud">
          <div class="hud-left">
            <span class="game-brand">WebGame</span>
          </div>
          <div class="hud-right">
            <%= if @joined do %>
              <span class="hud-score">
                <%= if @game_state do %>
                  <% me = @game_state.players[@player_id] %>
                  {(me && (me[:sc] || me[:score])) || 0}
                <% end %>
              </span>
            <% end %>
          </div>
        </div>

        <%!-- Scoreboard (right side) --%>
        <div class="scoreboard">
          <%= if @game_state do %>
            <%= for {_id, p} <- Enum.sort_by(@game_state.players || %{}, fn {_, p} -> -(p[:sc] || p[:score] || 0) end) |> Enum.take(6) do %>
              <div class={"score-row #{if not (p[:al] || p[:alive] || false), do: "dead"}"}>
                <span class="score-color" style={"background:#{p[:c] || p[:color]}"}></span>
                <span class="score-name">{p[:n] || p[:name]}</span>
                <span class="score-pts">{p[:sc] || p[:score] || 0}</span>
              </div>
            <% end %>
          <% end %>
        </div>

        <%!-- Join Overlay (shown when not yet playing) --%>
        <%= if not @joined do %>
          <div class="join-floating">
            <div class="join-panel">
              <h1 class="join-brand">WebGame</h1>
              <p class="join-sub">Slither. Eat. Dominate.</p>
              <form phx-submit="join" class="join-form-inline">
                <input type="text" name="name" value={@player_name || ""}
                  placeholder="Enter your name" maxlength="16"
                  autocomplete="off" class="name-input-big" autofocus
                  id="player-name-input" />
                <button type="submit" class="btn-play">PLAY</button>
              </form>
              <p class="join-controls">Mouse to steer &middot; Click to boost &middot; Space to sprint</p>
            </div>
          </div>
        <% end %>

        <%!-- Death overlay --%>
        <%= if @joined and not @my_alive do %>
          <div class="respawn-overlay" phx-click="respawn">
            <div class="respawn-card">
              <h3 class="respawn-title">Game Over</h3>
              <%= if @game_state do %>
                <% me = @game_state.players[@player_id] %>
                <%= if me do %>
                  <div class="death-stats">
                    <div class="stat-item">
                      <span class="stat-value">{me[:sc] || me[:score] || 0}</span>
                      <span class="stat-label">Score</span>
                    </div>
                    <div class="stat-item">
                      <span class="stat-value">{me[:k] || me[:kills] || 0}</span>
                      <span class="stat-label">Kills</span>
                    </div>
                  </div>
                <% end %>
              <% end %>
              <button phx-click="respawn" class="btn-play">PLAY AGAIN</button>
              <p class="controls-hint">Click anywhere or press any key</p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp generate_id, do: Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
end
