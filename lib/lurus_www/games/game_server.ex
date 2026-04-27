defmodule LurusWww.Games.GameServer do
  @moduledoc "GenServer managing a single game room. Open arena — join anytime, respawn instantly."

  use GenServer

  alias LurusWww.Games.Snake.Engine

  @tick_interval 50
  @idle_timeout 60_000

  # Bot management — only fill when humans present.
  @bot_target_total 4
  @bot_max 5

  # ── Client API ──────────────────────────────────────────

  def start_link(opts) do
    room_id = Keyword.fetch!(opts, :room_id)
    GenServer.start_link(__MODULE__, opts, name: via(room_id))
  end

  def join(room_id, player_id, player_name),
    do: safe_call(room_id, {:join, player_id, player_name})

  def leave(room_id, player_id),
    do: safe_cast(room_id, {:leave, player_id})

  def set_target(room_id, player_id, angle),
    do: safe_cast(room_id, {:set_target, player_id, angle})

  def set_boost(room_id, player_id, boosting),
    do: safe_cast(room_id, {:set_boost, player_id, boosting})

  def respawn(room_id, player_id),
    do: safe_cast(room_id, {:respawn, player_id})

  def get_state(room_id),
    do: safe_call(room_id, :get_state)

  def get_summary(room_id),
    do: safe_call(room_id, :get_summary)

  def room_exists?(room_id) do
    case Registry.lookup(LurusWww.Games.Registry, room_id) do
      [{_pid, _}] -> true
      [] -> false
    end
  end

  def list_rooms do
    LurusWww.Games.Registry
    |> Registry.select([{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.flat_map(fn room_id ->
      case get_summary(room_id) do
        {:ok, summary} -> [summary]
        _ -> []
      end
    end)
  end

  # ── Helpers ─────────────────────────────────────────────

  defp via(room_id),
    do: {:via, Registry, {LurusWww.Games.Registry, room_id}}

  defp safe_call(room_id, msg) do
    case Registry.lookup(LurusWww.Games.Registry, room_id) do
      [{pid, _}] -> GenServer.call(pid, msg)
      [] -> {:error, :not_found}
    end
  end

  defp safe_cast(room_id, msg) do
    case Registry.lookup(LurusWww.Games.Registry, room_id) do
      [{pid, _}] -> GenServer.cast(pid, msg)
      [] -> :ok
    end
  end

  # ── Server Callbacks ────────────────────────────────────

  @impl true
  def init(opts) do
    room_id = Keyword.fetch!(opts, :room_id)
    engine = Engine.new(room_id)
    idle_ref = Process.send_after(self(), :idle_check, @idle_timeout)

    broadcast_lobby(engine)

    {:ok, %{engine: engine, tick_ref: nil, idle_ref: idle_ref}}
  end

  @impl true
  def handle_call({:join, player_id, player_name}, _from, state) do
    result =
      case Engine.add_player(state.engine, player_id, player_name) do
        {:ok, engine} -> {:ok, engine}
        # Same id rejoining (multi-tab or LV reconnect): resume the slot.
        {:error, :already_joined} -> Engine.resume_player(state.engine, player_id, player_name)
        error -> error
      end

    case result do
      {:ok, engine} ->
        :telemetry.execute([:webgame, :game, :join], %{count: 1}, %{room_id: engine.id})
        engine = maybe_fill_bots(engine)
        state = ensure_ticking(%{state | engine: engine})
        state = reset_idle(state)
        broadcast_game(engine)
        broadcast_lobby(engine)
        {:reply, {:ok, Engine.to_client(engine)}, state}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, Engine.to_client(state.engine)}, state}
  end

  def handle_call(:get_summary, _from, state) do
    {:reply, {:ok, build_summary(state.engine)}, state}
  end

  @impl true
  def handle_cast({:leave, player_id}, state) do
    :telemetry.execute([:webgame, :game, :leave], %{count: 1}, %{room_id: state.engine.id})
    engine = Engine.remove_player(state.engine, player_id)
    # If the last human left, drain bots so the room actually idles.
    engine = if Engine.human_count(engine) == 0, do: drain_bots(engine), else: engine
    state = %{state | engine: engine}

    # Stop ticking if no players
    state =
      if engine.status == :waiting and state.tick_ref do
        Process.cancel_timer(state.tick_ref)
        %{state | tick_ref: nil}
      else
        state
      end

    broadcast_game(engine)
    broadcast_lobby(engine)

    if map_size(engine.players) == 0 && engine.id != "MAIN" do
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:set_target, player_id, angle}, state) do
    engine = Engine.set_target(state.engine, player_id, angle)
    {:noreply, reset_idle(%{state | engine: engine})}
  end

  def handle_cast({:set_boost, player_id, boosting}, state) do
    engine = Engine.set_boost(state.engine, player_id, boosting)
    {:noreply, %{state | engine: engine}}
  end

  def handle_cast({:respawn, player_id}, state) do
    :telemetry.execute([:webgame, :game, :respawn], %{count: 1}, %{room_id: state.engine.id})
    engine = Engine.respawn(state.engine, player_id)
    broadcast_game(engine)
    {:noreply, reset_idle(%{state | engine: engine})}
  end

  @impl true
  def handle_info(:tick, state) do
    # Compensate for processing time so ticks don't drift on heavy frames.
    start_us = System.monotonic_time(:microsecond)

    # Wrap the tick in try/rescue: a single buggy tick (e.g. unexpected
    # nil/empty edge case) must not crash the GenServer and freeze the room.
    # On error, keep the previous engine state and try again next tick.
    {engine, tick_ok?} =
      try do
        {Engine.tick(state.engine), true}
      rescue
        e ->
          require Logger
          Logger.error("engine tick crashed: #{Exception.message(e)}")
          {state.engine, false}
      end

    # Maintain bot population every 60 ticks (~3s) — cheap, idempotent.
    engine = if rem(engine.tick, 60) == 0, do: maybe_fill_bots(engine), else: engine

    if tick_ok? do
      broadcast_game(engine)
    end

    elapsed_us = System.monotonic_time(:microsecond) - start_us
    :telemetry.execute(
      [:webgame, :game, :tick],
      %{duration: elapsed_us},
      %{room_id: engine.id}
    )

    # Emit kill/death counters for events produced this tick.
    for ev <- engine.events do
      case ev do
        {:player_died, victim_id, killer, _kn} ->
          :telemetry.execute([:webgame, :game, :death], %{count: 1}, %{room_id: engine.id})
          if killer && killer != victim_id do
            :telemetry.execute([:webgame, :game, :kill], %{count: 1}, %{room_id: engine.id})
          end
        _ -> :ok
      end
    end

    elapsed = div(elapsed_us, 1000)
    next_delay = max(5, @tick_interval - elapsed)

    # Schedule next tick when the room still has work. If the previous tick
    # crashed, status is unchanged (we kept old engine), so playing rooms
    # keep ticking through hiccups instead of freezing.
    tick_ref =
      if engine.status == :playing do
        Process.send_after(self(), :tick, next_delay)
      else
        nil
      end

    {:noreply, %{state | engine: engine, tick_ref: tick_ref}}
  end

  def handle_info(:idle_check, state) do
    cond do
      state.engine.id == "MAIN" ->
        # MAIN room never dies — keep checking but never stop
        idle_ref = Process.send_after(self(), :idle_check, @idle_timeout)
        {:noreply, %{state | idle_ref: idle_ref}}

      map_size(state.engine.players) == 0 ->
        {:stop, :normal, state}

      true ->
        idle_ref = Process.send_after(self(), :idle_check, @idle_timeout)
        {:noreply, %{state | idle_ref: idle_ref}}
    end
  end

  # ── Internal ────────────────────────────────────────────

  defp ensure_ticking(%{tick_ref: nil, engine: %{status: :playing}} = state) do
    %{state | tick_ref: Process.send_after(self(), :tick, @tick_interval)}
  end

  defp ensure_ticking(state), do: state

  defp broadcast_game(engine) do
    client_state = Engine.to_client(engine)

    # Persist scores for players who just died
    for event <- engine.events do
      case event do
        {:player_died, player_id, _killer, _killer_name} ->
          case Map.get(engine.players, player_id) do
            %{name: name, score: score, kills: kills} when score > 0 ->
              Task.start(fn -> LurusWww.Scores.record_score(name, score, kills) end)
            _ -> :ok
          end
        _ -> :ok
      end
    end

    Phoenix.PubSub.broadcast(LurusWww.PubSub, "game:#{engine.id}", {:game_state, client_state})
  end

  defp broadcast_lobby(engine) do
    Phoenix.PubSub.broadcast(
      LurusWww.PubSub,
      "lobby",
      {:room_update, build_summary(engine)}
    )
  end

  defp build_summary(engine) do
    %{
      room_id: engine.id,
      player_count: map_size(engine.players),
      max_players: 20,
      status: engine.status,
      players:
        Enum.map(engine.players, fn {_id, p} ->
          %{name: p.name, color: p.color, alive: p.alive, is_bot: p.is_bot}
        end)
    }
  end

  defp reset_idle(state) do
    if state.idle_ref, do: Process.cancel_timer(state.idle_ref)
    %{state | idle_ref: Process.send_after(self(), :idle_check, @idle_timeout)}
  end

  # Top up bots so total snakes ≈ @bot_target_total whenever any human is around.
  # Idempotent: caller can invoke after every state change.
  defp maybe_fill_bots(engine) do
    humans = Engine.human_count(engine)
    bots = Engine.bot_count(engine)

    cond do
      humans == 0 -> engine
      bots >= @bot_max -> engine
      humans + bots >= @bot_target_total -> engine
      true ->
        deficit = min(@bot_target_total - (humans + bots), @bot_max - bots)
        Enum.reduce(1..deficit, engine, fn _, acc ->
          case Engine.add_bot(acc) do
            {:ok, new_engine, _id} ->
              :telemetry.execute([:webgame, :game, :bot_spawn], %{count: 1}, %{room_id: acc.id})
              new_engine
            _ -> acc
          end
        end)
    end
  end

  defp drain_bots(engine) do
    bot_ids =
      engine.players
      |> Enum.filter(fn {_, p} -> p.is_bot end)
      |> Enum.map(&elem(&1, 0))

    Enum.reduce(bot_ids, engine, &Engine.remove_player(&2, &1))
  end
end
