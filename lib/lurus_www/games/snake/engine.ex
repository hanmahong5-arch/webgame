defmodule LurusWww.Games.Snake.Engine do
  @moduledoc """
  Pure functional multiplayer snake game engine.
  Open arena design: join anytime, respawn instantly, no waiting.
  """

  @cols 60
  @rows 40
  @initial_length 4
  @food_count 5
  @golden_chance 0.15
  @max_players 20
  @colors ~w(#FF6B6B #4ECDC4 #45B7D1 #96CEB4 #FFEAA7 #DDA0DD #98D8C8 #F7DC6F #FF8C69 #B08EFF #7AFF89 #FFB800 #FF6BCC #00F0FF #66D9EF #F92672 #A6E22E #FD971F #AE81FF #E6DB74)

  @spawn_positions [
    {10, 10, :right}, {50, 10, :left}, {10, 30, :right}, {50, 30, :left},
    {30, 5, :down}, {30, 35, :up}, {5, 20, :right}, {55, 20, :left},
    {20, 15, :down}, {40, 25, :up}, {15, 35, :right}, {45, 5, :left},
    {25, 20, :right}, {35, 20, :left}, {20, 8, :down}, {40, 32, :up},
    {8, 28, :right}, {52, 12, :left}, {30, 20, :right}, {28, 20, :left}
  ]

  defstruct [
    :id,
    cols: @cols,
    rows: @rows,
    players: %{},
    food: [],
    tick: 0,
    status: :waiting,
    events: [],
    player_order: []
  ]

  # ── Public API ──────────────────────────────────────────

  def new(room_id), do: %__MODULE__{id: room_id}

  @doc "Add player. Always allowed unless room full or duplicate ID."
  def add_player(state, id, name) do
    cond do
      map_size(state.players) >= @max_players ->
        {:error, :room_full}

      Map.has_key?(state.players, id) ->
        {:error, :already_joined}

      true ->
        idx = length(state.player_order)
        color = Enum.at(@colors, rem(idx, length(@colors)))

        player = %{
          id: id, name: name, color: color,
          segments: [], direction: :right, next_direction: :right,
          score: 0, alive: false, kills: 0
        }

        state = %{state |
          players: Map.put(state.players, id, player),
          player_order: state.player_order ++ [id]
        }

        # Auto-start the arena if not already playing
        state = if state.status == :waiting do
          state
          |> ensure_food()
          |> Map.put(:status, :playing)
          |> Map.put(:tick, 0)
          |> Map.put(:events, [{:game_started}])
        else
          state
        end

        # Spawn this player immediately
        state = spawn_single_player(state, id)

        {:ok, state}
    end
  end

  def remove_player(state, id) do
    state = %{state |
      players: Map.delete(state.players, id),
      player_order: List.delete(state.player_order, id)
    }

    # If no players left, go back to waiting
    if map_size(state.players) == 0 do
      %{state | status: :waiting, food: [], tick: 0}
    else
      state
    end
  end

  def set_direction(state, id, direction)
      when direction in [:up, :down, :left, :right] do
    case Map.fetch(state.players, id) do
      {:ok, player} ->
        %{state | players: Map.put(state.players, id, %{player | next_direction: direction})}
      :error ->
        state
    end
  end

  def set_direction(state, _id, _dir), do: state

  @doc "Respawn a dead player instantly."
  def respawn(state, player_id) do
    case Map.fetch(state.players, player_id) do
      {:ok, %{alive: false}} ->
        state
        |> Map.update!(:players, fn ps ->
          Map.update!(ps, player_id, &%{&1 | alive: true, score: 0, kills: 0})
        end)
        |> spawn_single_player(player_id)
        |> Map.update!(:events, &[{:player_respawned, player_id} | &1])

      _ ->
        state
    end
  end

  def tick(%{status: :playing} = state) do
    # Skip tick if no alive players
    alive_count = Enum.count(state.players, fn {_, p} -> p.alive end)
    if alive_count == 0 do
      state
    else
      state
      |> Map.put(:events, [])
      |> Map.update!(:tick, &(&1 + 1))
      |> apply_directions()
      |> move_snakes()
      |> detect_collisions()
      |> consume_food()
      |> trim_tails()
      |> replenish_food()
    end
  end

  def tick(state), do: state

  def to_client(state) do
    %{
      id: state.id,
      grid: [state.cols, state.rows],
      tick: state.tick,
      status: state.status,
      events: Enum.map(state.events, &encode_event/1),
      players:
        Map.new(state.players, fn {id, p} ->
          {id, %{
            name: p.name, color: p.color,
            segments: Enum.map(p.segments, &Tuple.to_list/1),
            direction: p.direction,
            score: p.score, alive: p.alive, kills: p.kills
          }}
        end),
      food: Enum.map(state.food, fn {x, y, t} -> [x, y, Atom.to_string(t)] end)
    }
  end

  # ── Internal: spawning ──────────────────────────────────

  defp spawn_single_player(state, id) do
    alive_segments =
      state.players
      |> Enum.filter(fn {pid, p} -> p.alive and pid != id end)
      |> Enum.flat_map(fn {_, p} -> p.segments end)

    occupied = MapSet.new(alive_segments)

    # Pick spawn position with most clearance from other snakes
    {sx, sy, dir} =
      @spawn_positions
      |> Enum.shuffle()
      |> Enum.max_by(fn {px, py, _} ->
        if alive_segments == [] do
          :rand.uniform(100)
        else
          alive_segments
          |> Enum.map(fn {ax, ay} -> abs(px - ax) + abs(py - ay) end)
          |> Enum.min()
        end
      end)

    segments =
      for i <- 0..(@initial_length - 1) do
        case dir do
          :right -> {sx - i, sy}
          :left -> {sx + i, sy}
          :down -> {sx, sy - i}
          :up -> {sx, sy + i}
        end
      end

    # Verify segments are in bounds and not occupied; fall back to simple position
    segments =
      if Enum.all?(segments, fn {x, y} ->
           x >= 0 and x < @cols and y >= 0 and y < @rows and
             not MapSet.member?(occupied, {x, y})
         end) do
        segments
      else
        [{sx, sy}]
      end

    %{state |
      players: Map.update!(state.players, id, fn p ->
        %{p | segments: segments, direction: dir, next_direction: dir, alive: true}
      end)
    }
  end

  defp ensure_food(state) do
    needed = @food_count - length(state.food)
    if needed > 0, do: place_food(state, needed), else: state
  end

  defp place_food(state, count) do
    occupied = occupied_set(state)

    {food, _} =
      Enum.reduce(1..count, {[], occupied}, fn _i, {foods, occ} ->
        case find_empty_cell(state.cols, state.rows, occ) do
          nil -> {foods, occ}
          {x, y} ->
            type = if :rand.uniform() < @golden_chance, do: :golden, else: :normal
            {[{x, y, type} | foods], MapSet.put(occ, {x, y})}
        end
      end)

    %{state | food: state.food ++ food}
  end

  # ── Internal: tick pipeline ─────────────────────────────

  defp apply_directions(state) do
    players =
      Map.new(state.players, fn {id, p} ->
        if p.alive do
          dir = validate_direction(p.next_direction, p.direction)
          {id, %{p | direction: dir}}
        else
          {id, p}
        end
      end)

    %{state | players: players}
  end

  defp move_snakes(state) do
    players =
      Map.new(state.players, fn {id, p} ->
        if p.alive and p.segments != [] do
          {hx, hy} = hd(p.segments)
          new_head = advance(hx, hy, p.direction)
          {id, %{p | segments: [new_head | p.segments]}}
        else
          {id, p}
        end
      end)

    %{state | players: players}
  end

  defp detect_collisions(state) do
    alive = state.players |> Enum.filter(fn {_id, p} -> p.alive end) |> Map.new()
    segment_sets = Map.new(alive, fn {id, p} -> {id, MapSet.new(p.segments)} end)

    deaths =
      Enum.reduce(alive, %{}, fn {id, player}, acc ->
        [head | body] = player.segments
        {hx, hy} = head

        wall = hx < 0 or hx >= state.cols or hy < 0 or hy >= state.rows
        self = Enum.member?(body, head)

        other_killer =
          Enum.find_value(alive, fn {oid, _op} ->
            if oid != id and MapSet.member?(segment_sets[oid], head), do: oid
          end)

        if wall or self or other_killer do
          Map.put(acc, id, other_killer)
        else
          acc
        end
      end)

    {players, events} =
      Enum.reduce(deaths, {state.players, state.events}, fn {id, killer}, {ps, evts} ->
        ps = Map.update!(ps, id, &%{&1 | alive: false})

        ps =
          if killer && !Map.has_key?(deaths, killer) do
            Map.update!(ps, killer, &%{&1 | kills: &1.kills + 1})
          else
            ps
          end

        {ps, [{:player_died, id, killer} | evts]}
      end)

    %{state | players: players, events: events}
  end

  defp consume_food(state) do
    alive_players = Enum.filter(state.players, fn {_id, p} -> p.alive end)

    {updated_players, remaining_food, new_events} =
      Enum.reduce(alive_players, {state.players, state.food, []}, fn {id, player}, {ps, food, evts} ->
        {hx, hy} = hd(player.segments)

        case Enum.find_index(food, fn {fx, fy, _} -> fx == hx and fy == hy end) do
          nil ->
            {ps, food, evts}

          idx ->
            {_, _, type} = Enum.at(food, idx)
            pts = if type == :golden, do: 5, else: 1
            updated = Map.update!(ps, id, &%{&1 | score: &1.score + pts})
            {updated, List.delete_at(food, idx), [{:food_eaten, id, type} | evts]}
        end
      end)

    %{state | players: updated_players, food: remaining_food, events: state.events ++ new_events}
  end

  defp trim_tails(state) do
    fed_ids =
      state.events
      |> Enum.flat_map(fn
        {:food_eaten, id, _type} -> [id]
        _ -> []
      end)
      |> MapSet.new()

    players =
      Map.new(state.players, fn {id, p} ->
        if p.alive and not MapSet.member?(fed_ids, id) and length(p.segments) > 1 do
          {id, %{p | segments: List.delete_at(p.segments, -1)}}
        else
          {id, p}
        end
      end)

    %{state | players: players}
  end

  defp replenish_food(state) do
    needed = @food_count - length(state.food)
    if needed > 0, do: place_food(state, needed), else: state
  end

  # ── Helpers ─────────────────────────────────────────────

  defp advance(x, y, :up), do: {x, y - 1}
  defp advance(x, y, :down), do: {x, y + 1}
  defp advance(x, y, :left), do: {x - 1, y}
  defp advance(x, y, :right), do: {x + 1, y}

  defp validate_direction(:up, :down), do: :down
  defp validate_direction(:down, :up), do: :up
  defp validate_direction(:left, :right), do: :right
  defp validate_direction(:right, :left), do: :left
  defp validate_direction(next, _cur), do: next

  defp occupied_set(state) do
    snakes = state.players |> Enum.flat_map(fn {_, p} -> p.segments end)
    foods = Enum.map(state.food, fn {x, y, _} -> {x, y} end)
    MapSet.new(snakes ++ foods)
  end

  defp find_empty_cell(cols, rows, occupied) do
    Enum.find_value(1..200, fn _ ->
      cell = {:rand.uniform(cols) - 1, :rand.uniform(rows) - 1}
      unless MapSet.member?(occupied, cell), do: cell
    end)
  end

  defp encode_event({:food_eaten, id, type}), do: ["food_eaten", id, Atom.to_string(type)]
  defp encode_event({:player_died, id, killer}), do: ["player_died", id, killer]
  defp encode_event({:player_respawned, id}), do: ["player_respawned", id]
  defp encode_event({:game_started}), do: ["game_started"]
end
