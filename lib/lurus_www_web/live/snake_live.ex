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
        my_alive: true
      )

    if connected?(socket) do
      Phoenix.PubSub.subscribe(LurusWww.PubSub, "game:#{room_id}")
      case GameServer.get_state(room_id) do
        {:ok, state} -> {:ok, assign(socket, game_state: state)}
        {:error, :not_found} -> {:ok, push_navigate(socket, to: ~p"/play")}
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
        {:noreply, assign(socket, joined: true, player_name: name, game_state: state, my_alive: true)}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Cannot join: #{reason}")}
    end
  end

  def handle_event("respawn", _params, socket) do
    GameServer.respawn(socket.assigns.room_id, socket.assigns.player_id)
    {:noreply, assign(socket, my_alive: true)}
  end

  def handle_event("steer", %{"angle" => angle}, socket) when is_number(angle) do
    GameServer.set_target(socket.assigns.room_id, socket.assigns.player_id, angle / 1)
    {:noreply, socket}
  end

  def handle_event("boost", %{"active" => active}, socket) when is_boolean(active) do
    GameServer.set_boost(socket.assigns.room_id, socket.assigns.player_id, active)
    {:noreply, socket}
  end

  def handle_event("leave", _params, socket) do
    GameServer.leave(socket.assigns.room_id, socket.assigns.player_id)
    {:noreply, push_navigate(socket, to: ~p"/play")}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:game_state, state}, socket) do
    my_alive =
      case Map.get(state.players, socket.assigns.player_id) do
        %{alive: alive} -> alive
        nil -> false
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
      <%= if not @joined do %>
        <div class="join-overlay">
          <div class="join-card">
            <h2 class="join-title">Join Arena</h2>
            <p class="room-label">Room <span class="room-code-big">{@room_id}</span></p>

            <%= if @game_state do %>
              <div class="player-preview">
                <%= for {_id, p} <- @game_state.players do %>
                  <div class="player-tag">
                    <span class="player-dot-sm" style={"background:#{p.color}; opacity:#{if p.alive, do: 1, else: 0.4}"}></span>
                    {p.name}
                  </div>
                <% end %>
                <%= if map_size(@game_state.players) == 0 do %>
                  <p class="text-muted text-sm">Empty arena. Be the first!</p>
                <% end %>
              </div>
            <% end %>

            <form phx-submit="join" class="join-game-form">
              <input type="text" name="name" value={@player_name} placeholder="Your name"
                maxlength="16" autocomplete="off" class="name-input" autofocus phx-change="set_name" />
              <button type="submit" class="btn-accent btn-accent--lg w-full">Play Now</button>
            </form>

            <p class="controls-hint" style="margin-top:12px;">
              Desktop: mouse to steer, click to boost<br/>
              Mobile: drag to steer, two-finger tap to boost
            </p>

            <.link navigate={~p"/play"} class="back-link">Back to Lobby</.link>
          </div>
        </div>
      <% else %>
        <div class="game-area">
          <div class="canvas-container">
            <canvas id="game-canvas" phx-hook="SnakeCanvas" phx-update="ignore"
              data-player-id={@player_id}></canvas>
          </div>

          <div class="game-hud">
            <div class="hud-left">
              <span class="room-badge">{@room_id}</span>
              <%= if @game_state do %>
                <% me = @game_state.players[@player_id] %>
                <%= if me && me.alive do %>
                  <span class="hud-score">{me.score}</span>
                <% end %>
              <% end %>
            </div>
            <div class="hud-right">
              <button phx-click="leave" class="hud-btn">Leave</button>
            </div>
          </div>

          <div class="scoreboard">
            <%= if @game_state do %>
              <%= for {_id, p} <- Enum.sort_by(@game_state.players, fn {_, p} -> -p.score end) do %>
                <div class={"score-row #{if not p.alive, do: "dead"}"}>
                  <span class="score-color" style={"background:#{p.color}"}></span>
                  <span class="score-name">{p.name}</span>
                  <span class="score-pts">{p.score}</span>
                </div>
              <% end %>
            <% end %>
          </div>

          <%= if not @my_alive do %>
            <div class="respawn-overlay">
              <div class="respawn-card">
                <h3 class="respawn-title">You Died!</h3>
                <%= if @game_state do %>
                  <% me = @game_state.players[@player_id] %>
                  <%= if me do %>
                    <p class="respawn-stats">
                      Score: <strong>{me.score}</strong> &middot; Kills: <strong>{me.kills}</strong>
                    </p>
                  <% end %>
                <% end %>
                <button phx-click="respawn" class="btn-accent btn-accent--lg">Respawn</button>
                <p class="controls-hint">or click anywhere</p>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp generate_id, do: Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
end
