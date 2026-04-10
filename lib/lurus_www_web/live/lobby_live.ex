defmodule LurusWwwWeb.Live.LobbyLive do
  use LurusWwwWeb, :live_view

  alias LurusWww.Games.{GameSupervisor, GameServer}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(LurusWww.PubSub, "lobby")
    end

    rooms = GameServer.list_rooms()

    socket =
      assign(socket,
        page_title: "Play - WebGame",
        rooms: rooms,
        join_code: ""
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("create_room", _params, socket) do
    room_id = GameSupervisor.generate_room_id()

    case GameSupervisor.create_room(room_id) do
      {:ok, _pid} ->
        {:noreply, push_navigate(socket, to: ~p"/play/snake/#{room_id}")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to create room")}
    end
  end

  def handle_event("update_code", %{"code" => code}, socket) do
    {:noreply, assign(socket, join_code: String.upcase(code))}
  end

  def handle_event("join_room", %{"code" => code}, socket) do
    room_id = code |> String.trim() |> String.upcase()

    if String.length(room_id) == 4 and GameServer.room_exists?(room_id) do
      {:noreply, push_navigate(socket, to: ~p"/play/snake/#{room_id}")}
    else
      {:noreply, put_flash(socket, :error, "Room not found")}
    end
  end

  @impl true
  def handle_info({:room_update, room}, socket) do
    rooms =
      socket.assigns.rooms
      |> Enum.reject(&(&1.room_id == room.room_id))
      |> then(fn rooms ->
        if room.player_count > 0, do: [room | rooms], else: rooms
      end)

    {:noreply, assign(socket, rooms: rooms)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="lobby-page">
      <div class="lobby-container">
        <%!-- Header --%>
        <div class="lobby-header">
          <h1 class="lobby-title">Game Lobby</h1>
          <p class="lobby-subtitle">Create a room or join an existing game</p>
        </div>

        <%!-- Actions --%>
        <div class="lobby-actions">
          <button phx-click="create_room" class="btn-accent btn-accent--lg">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Create Arena
          </button>

          <form phx-submit="join_room" class="join-form">
            <input
              type="text"
              name="code"
              value={@join_code}
              placeholder="ABCD"
              maxlength="4"
              class="join-input"
              phx-change="update_code"
              autocomplete="off"
            />
            <button type="submit" class="btn-outline-game">Join</button>
          </form>
        </div>

        <%!-- Room List --%>
        <div class="room-list">
          <h2 class="room-list-title">
            Active Rooms
            <span class="room-count">{length(@rooms)}</span>
          </h2>

          <%= if @rooms == [] do %>
            <div class="empty-state">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#55556A" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1112.63 8 4 4 0 0116 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
              <p>No active games. Create one to get started!</p>
            </div>
          <% else %>
            <div class="room-grid">
              <%= for room <- @rooms do %>
                <.link navigate={~p"/play/snake/#{room.room_id}"} class="room-card">
                  <div class="room-card-top">
                    <span class="room-game-type">Snake</span>
                    <span class="room-code">{room.room_id}</span>
                  </div>
                  <div class="room-card-players">
                    <%= for p <- room.players do %>
                      <span class="player-dot-sm" style={"background:#{p.color}"}></span>
                    <% end %>
                    <span class="player-count-label">{room.player_count}/{room.max_players}</span>
                  </div>
                  <div class="room-card-bottom">
                    <span class={"room-status room-status--#{room.status}"}>{room.status}</span>
                    <span class="room-join-hint">Join &rarr;</span>
                  </div>
                </.link>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
