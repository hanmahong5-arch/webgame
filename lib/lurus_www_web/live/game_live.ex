defmodule LurusWwwWeb.Live.GameLive do
  @moduledoc "Fullscreen game page at /play. Zero friction — instant join."
  use LurusWwwWeb, :live_view

  alias LurusWww.Games.{GameServer, AutoRoom}

  @impl true
  def mount(params, _session, socket) do
    socket = assign(socket,
      page_title: "Play - WebGame",
      room_id: nil,
      player_id: nil,
      player_name: nil,
      joined: false,
      game_state: nil,
      my_alive: false,
      last_killer: nil,
      # Tracks the per-player PubSub topic we're currently subscribed to so
      # we can unsub/resub idempotently on room overflow or reconnect. Game
      # state arrives only on this topic; the room-wide topic carries only
      # server_shutdown / lobby messages.
      player_topic: nil
    )

    if connected?(socket) do
      room_id = case params do
        %{"room_id" => id} ->
          if GameServer.room_exists?(id), do: id, else: AutoRoom.find_or_create()
        _ ->
          AutoRoom.find_or_create()
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

  @impl true
  def handle_event("init_player", %{"id" => id, "name" => name}, socket) do
    socket = assign(socket, player_id: id, player_name: name)
    trimmed = String.trim(name || "")

    if trimmed != "" && !socket.assigns.joined && socket.assigns.room_id &&
         rate_limit_ok?(:init_player, 3, 10_000) do
      case do_join(socket.assigns.room_id, id, String.slice(trimmed, 0..15)) do
        {:ok, room_id, final_pid, state} ->
          socket = if room_id != socket.assigns.room_id do
            Phoenix.PubSub.unsubscribe(LurusWww.PubSub, "game:#{socket.assigns.room_id}")
            Phoenix.PubSub.subscribe(LurusWww.PubSub, "game:#{room_id}")
            assign(socket, room_id: room_id)
          else
            socket
          end

          socket = resub_player(socket, room_id, final_pid)

          # Resume: player may already be dead (rejoined after dying); derive from state.
          my_alive = derive_alive(state, final_pid)

          {:noreply,
            socket
            |> push_event("joined", %{player_id: final_pid})
            |> assign(joined: true, player_id: final_pid, game_state: state, my_alive: my_alive)}

        {:error, _} ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("join", params, socket) do
    if not rate_limit_ok?(:join, 5, 30_000) do
      {:noreply, put_flash(socket, :error, "Too many attempts — slow down")}
    else
      do_handle_join(params, socket)
    end
  end

  defp do_handle_join(params, socket) do
    name = String.trim(params["name"] || "")
    name = if name == "", do: "Snake#{:rand.uniform(999)}", else: String.slice(name, 0..15)

    # Priority: assigns (from init_player) > form hidden field > generate new
    player_id = socket.assigns.player_id ||
      (params["pid"] |> to_string() |> String.trim() |> case do
        "" -> nil
        id -> id
      end) ||
      gen_id()

    case do_join(socket.assigns.room_id, player_id, name) do
      {:ok, room_id, final_pid, state} ->
        # If room changed (overflow), resubscribe
        socket = if room_id != socket.assigns.room_id do
          Phoenix.PubSub.unsubscribe(LurusWww.PubSub, "game:#{socket.assigns.room_id}")
          Phoenix.PubSub.subscribe(LurusWww.PubSub, "game:#{room_id}")
          assign(socket, room_id: room_id)
        else
          socket
        end

        socket = resub_player(socket, room_id, final_pid)

        my_alive = derive_alive(state, final_pid)
        {:noreply,
          socket
          |> push_event("joined", %{player_id: final_pid})
          |> push_event("save_name", %{name: name})
          |> assign(joined: true, player_id: final_pid, player_name: name,
                    game_state: state, my_alive: my_alive)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "#{reason}")}
    end
  end

  def handle_event("respawn", _, socket) do
    if rate_limit_ok?(:respawn, 8, 5_000) &&
         socket.assigns.player_id && socket.assigns.room_id do
      GameServer.respawn(socket.assigns.room_id, socket.assigns.player_id)
    end
    {:noreply, assign(socket, my_alive: true, last_killer: nil)}
  end

  def handle_event("set_killer", %{"name" => name, "color" => color}, socket) do
    {:noreply, assign(socket, last_killer: %{name: to_string(name), color: to_string(color)})}
  end

  def handle_event("steer", %{"angle" => a}, socket) when is_number(a) do
    if socket.assigns.joined && socket.assigns.room_id do
      GameServer.set_target(socket.assigns.room_id, socket.assigns.player_id, a * 1.0)
    end
    {:noreply, socket}
  end

  def handle_event("boost", %{"active" => a}, socket) when is_boolean(a) do
    if socket.assigns.joined && socket.assigns.room_id do
      GameServer.set_boost(socket.assigns.room_id, socket.assigns.player_id, a)
    end
    {:noreply, socket}
  end

  def handle_event("laser", _params, socket) do
    # Server enforces cooldown + length cost; this rate limit is just to throttle
    # event spam from the client (UI button mashing).
    if rate_limit_ok?(:laser, 4, 8_000) &&
         socket.assigns.joined && socket.assigns.room_id do
      GameServer.fire_laser(socket.assigns.room_id, socket.assigns.player_id)
    end
    {:noreply, socket}
  end

  def handle_event("gacha", _params, socket) do
    # Server validates length + score cost; this just throttles spam clicks.
    if rate_limit_ok?(:gacha, 4, 8_000) &&
         socket.assigns.joined && socket.assigns.room_id do
      GameServer.gacha(socket.assigns.room_id, socket.assigns.player_id)
    end
    {:noreply, socket}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:game_state, state}, socket) do
    my_alive = if pid = socket.assigns.player_id do
      case Map.get(state.players || %{}, pid) do
        %{al: a} -> a
        %{alive: a} -> a
        _ -> false
      end
    else
      false
    end

    # Always tell client who they are, every tick
    payload = if socket.assigns.player_id do
      Map.put(state, :my_id, socket.assigns.player_id)
    else
      state
    end

    {:noreply,
      socket
      |> push_event("game_state", payload)
      |> assign(game_state: state, my_alive: my_alive)}
  end

  def handle_info({:server_shutdown}, socket) do
    {:noreply, push_event(socket, "server_shutdown", %{})}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="snake-page">
      <div class="game-area">
        <div class="canvas-container">
          <canvas id="game-canvas" phx-hook="SnakeCanvas" phx-update="ignore"></canvas>
        </div>

        <%!-- Mobile-only on-screen control buttons. Hidden on hover-capable devices via CSS. --%>
        <button id="touch-boost-btn" class="touch-boost-btn" aria-label="boost"
                phx-update="ignore" tabindex="-1">⚡</button>
        <button id="touch-laser-btn" class="touch-laser-btn" aria-label="laser eye"
                phx-update="ignore" tabindex="-1">👁</button>
        <%!-- Gacha button — visible on all viewports; spends tail + score for a roll. --%>
        <button id="gacha-btn" class="gacha-btn" aria-label="gacha"
                phx-update="ignore" tabindex="-1">🎰</button>

        <%!-- Top HUD --%>
        <div class="game-hud">
          <div class="hud-left">
            <a href="/" class="game-brand">WebGame</a>
            <%= if @joined && @game_state do %>
              <% me_hud = (@game_state.players || %{})[@player_id] %>
              <%= if me_hud do %>
                <span class="hud-buffs">
                  <%= for [type, tier, _ttl] <- (me_hud[:ef] || []) do %>
                    <span class={"buff-pill buff-#{type} buff-tier-#{tier}"} title={"#{type} (T#{tier})"}>
                      {effect_icon(type)}
                    </span>
                  <% end %>
                  <%= if me_hud[:sh] && me_hud[:sh] > 0 do %>
                    <span class="buff-pill buff-shield" title={"shield x#{me_hud[:sh]}"}>🛡 {me_hud[:sh]}</span>
                  <% end %>
                </span>
              <% end %>
            <% end %>
          </div>
          <div class="hud-right">
            <%= if @joined && @game_state do %>
              <% me = (@game_state.players || %{})[@player_id] %>
              <%= if me do %>
                <span class="hud-level">Lv {me[:lv] || 1}</span>
                <%= if (me[:st] || 0) >= 3 do %>
                  <span class="hud-streak">🔥 {me[:st]}</span>
                <% end %>
                <span class="hud-score">{me[:sc] || me[:score] || 0}</span>
              <% end %>
            <% end %>
          </div>
        </div>

        <%!-- Scoreboard --%>
        <div class="scoreboard">
          <%= if @game_state do %>
            <%= for {_id, p} <- (@game_state.players || %{}) |> Enum.sort_by(fn {_, p} -> -(p[:sc] || p[:score] || 0) end) |> Enum.take(6) do %>
              <div class={"score-row #{if not (p[:al] || p[:alive] || false), do: "dead"}"}>
                <span class="score-color" style={"background:#{p[:c] || p[:color]}"}></span>
                <span class="score-name">{p[:n] || p[:name]}</span>
                <span class="score-pts">{p[:sc] || p[:score] || 0}</span>
              </div>
            <% end %>
          <% end %>
        </div>

        <%!-- Join --%>
        <%= if not @joined do %>
          <div class="join-floating">
            <div class="join-panel">
              <h1 class="join-brand">WebGame</h1>
              <p class="join-sub">Slither. Eat. Dominate.</p>
              <form phx-submit="join" class="join-form-inline" id="join-form">
                <input type="hidden" name="pid" value={@player_id || ""} id="join-pid" />
                <input type="text" name="name" value={@player_name || ""}
                  placeholder="Your name" maxlength="16"
                  autocomplete="off" class="name-input-big" autofocus
                  id="player-name-input" />
                <button type="submit" class="btn-play">PLAY</button>
              </form>
              <p class="join-controls">
                Mouse = steer &middot; Click / Space / Shift = boost &middot;
                <strong style="color:#FF66AA">V / right-click = laser eye 👁</strong>
                <br/>
                <strong style="color:#FFD700">G = gacha 🎰 — spend tail + score for buffs / equipment</strong>
                <br/>mobile: hold ⚡ to boost &middot; tap 👁 laser &middot; tap 🎰 gacha
              </p>
            </div>
          </div>
        <% end %>

        <%!-- Death --%>
        <%= if @joined and not @my_alive do %>
          <div class="respawn-overlay" phx-click="respawn">
            <div class="respawn-card">
              <h3 class="respawn-title">Game Over</h3>
              <%= if @last_killer do %>
                <p class="killed-by">
                  Killed by <span class="killer-name" style={"color:#{@last_killer.color}"}>{@last_killer.name}</span>
                </p>
              <% end %>
              <%= if @game_state do %>
                <% me = (@game_state.players || %{})[@player_id] %>
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
                    <div class="stat-item">
                      <span class="stat-value">{me[:lv] || 1}</span>
                      <span class="stat-label">Level</span>
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

  # Join with auto-overflow. `:already_joined` is now handled server-side as a resume,
  # so we treat it as success here (server returned :ok in that branch).
  defp do_join(room_id, player_id, name) do
    case GameServer.join(room_id, player_id, name) do
      {:ok, state} ->
        {:ok, room_id, player_id, state}

      {:error, :room_full} ->
        new_room = AutoRoom.find_or_create()
        case GameServer.join(new_room, player_id, name) do
          {:ok, state} -> {:ok, new_room, player_id, state}
          error -> error
        end

      error -> error
    end
  end

  defp gen_id, do: Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)

  # Idempotent resubscribe to the per-player game-state topic. Game state
  # broadcasts are observer-specific, so each LV must listen on a topic keyed
  # by its own player id. Safe to call repeatedly; unsubscribes the old topic
  # first if any.
  defp resub_player(socket, room_id, player_id) do
    new_topic = "game:#{room_id}:#{player_id}"
    case socket.assigns[:player_topic] do
      nil -> Phoenix.PubSub.subscribe(LurusWww.PubSub, new_topic)
      ^new_topic -> :noop
      old ->
        Phoenix.PubSub.unsubscribe(LurusWww.PubSub, old)
        Phoenix.PubSub.subscribe(LurusWww.PubSub, new_topic)
    end
    assign(socket, player_topic: new_topic)
  end

  # Per-LV-pid sliding-window rate limit using process dictionary.
  # Rejects events when the user has exceeded `max` calls within `window_ms`.
  # Each LV is a single Erlang process so this is race-free.
  #
  # KNOWN LIMITATION: scope is per-LV process, not per-player. A user with
  # multiple browser tabs (same player_id) gets independent windows. Server
  # gates (gacha score+length, laser cooldown) prevent actual exploits, but
  # the click-rate limit is effectively N×tabs. A proper fix lives in an ETS
  # table keyed by player_id and is tracked as a separate story.
  defp rate_limit_ok?(key, max, window_ms) do
    now = System.monotonic_time(:millisecond)
    history = Process.get({:rl, key}, [])
    fresh = Enum.filter(history, fn t -> now - t < window_ms end)

    if length(fresh) >= max do
      :telemetry.execute([:webgame, :game, :rate_limited], %{count: 1}, %{event: key})
      false
    else
      Process.put({:rl, key}, [now | fresh])
      true
    end
  end

  defp derive_alive(state, pid) do
    case Map.get(state.players || %{}, pid) do
      %{al: a} -> a
      %{alive: a} -> a
      _ -> false
    end
  end

  defp effect_icon("blade"), do: "⚔"
  defp effect_icon("shield"), do: "🛡"
  defp effect_icon("magnet"), do: "🧲"
  defp effect_icon("star"), do: "⭐"
  defp effect_icon("ghost"), do: "👻"
  defp effect_icon("mega"), do: "💥"
  defp effect_icon("freeze"), do: "❄"
  defp effect_icon("slowmo"), do: "⏳"
  defp effect_icon("slowmo_target"), do: "🐌"
  defp effect_icon(_), do: "✦"
end
