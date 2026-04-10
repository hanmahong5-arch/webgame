defmodule LurusWww.Games.GameServer do
  @moduledoc "GenServer managing a single game room. One process per room."

  use GenServer

  alias LurusWww.Games.Snake.Engine

  @tick_interval 120
  @idle_timeout 300_000

  # ── Client API ──────────────────────────────────────────

  def start_link(opts) do
    room_id = Keyword.fetch!(opts, :room_id)
    GenServer.start_link(__MODULE__, opts, name: via(room_id))
  end

  def join(room_id, player_id, player_name),
    do: safe_call(room_id, {:join, player_id, player_name})

  def leave(room_id, player_id),
    do: safe_cast(room_id, {:leave, player_id})

  def input(room_id, player_id, direction),
    do: safe_cast(room_id, {:input, player_id, direction})

  def start_game(room_id),
    do: safe_cast(room_id, :start_game)

  def rematch(room_id),
    do: safe_cast(room_id, :rematch)

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
    case Engine.add_player(state.engine, player_id, player_name) do
      {:ok, engine} ->
        state = reset_idle(%{state | engine: engine})
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
    summary = build_summary(state.engine)
    {:reply, {:ok, summary}, state}
  end

  @impl true
  def handle_cast({:leave, player_id}, state) do
    engine = Engine.remove_player(state.engine, player_id)
    broadcast_game(engine)
    broadcast_lobby(engine)

    if map_size(engine.players) == 0 do
      {:stop, :normal, %{state | engine: engine}}
    else
      {:noreply, %{state | engine: engine}}
    end
  end

  def handle_cast({:input, player_id, direction}, state) do
    engine = Engine.set_direction(state.engine, player_id, direction)
    {:noreply, reset_idle(%{state | engine: engine})}
  end

  def handle_cast(:start_game, state) do
    engine = Engine.start_countdown(state.engine)
    broadcast_game(engine)
    broadcast_lobby(engine)
    tick_ref = Process.send_after(self(), :tick, 1000)
    {:noreply, reset_idle(%{state | engine: engine, tick_ref: tick_ref})}
  end

  def handle_cast(:rematch, state) do
    engine = Engine.reset(state.engine)
    broadcast_game(engine)
    broadcast_lobby(engine)
    {:noreply, reset_idle(%{state | engine: engine, tick_ref: nil})}
  end

  @impl true
  def handle_info(:tick, state) do
    engine =
      case state.engine.status do
        :countdown -> Engine.countdown_tick(state.engine)
        :playing -> Engine.tick(state.engine)
        _ -> state.engine
      end

    broadcast_game(engine)

    tick_ref =
      case engine.status do
        :countdown -> Process.send_after(self(), :tick, 1000)
        :playing -> Process.send_after(self(), :tick, @tick_interval)
        :finished -> broadcast_lobby(engine); nil
        _ -> nil
      end

    {:noreply, %{state | engine: engine, tick_ref: tick_ref}}
  end

  def handle_info(:idle_check, state) do
    if map_size(state.engine.players) == 0 do
      {:stop, :normal, state}
    else
      idle_ref = Process.send_after(self(), :idle_check, @idle_timeout)
      {:noreply, %{state | idle_ref: idle_ref}}
    end
  end

  # ── Broadcasting ────────────────────────────────────────

  defp broadcast_game(engine) do
    Phoenix.PubSub.broadcast(
      LurusWww.PubSub,
      "game:#{engine.id}",
      {:game_state, Engine.to_client(engine)}
    )
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
      max_players: 8,
      status: engine.status,
      players:
        Enum.map(engine.players, fn {_id, p} ->
          %{name: p.name, color: p.color}
        end)
    }
  end

  defp reset_idle(state) do
    if state.idle_ref, do: Process.cancel_timer(state.idle_ref)
    %{state | idle_ref: Process.send_after(self(), :idle_check, @idle_timeout)}
  end
end
