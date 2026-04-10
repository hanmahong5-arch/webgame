defmodule LurusWww.Games.Snake.Engine do
  @moduledoc "Pure functional multiplayer snake game engine. No side effects."

  @cols 60
  @rows 40
  @initial_length 4
  @food_count 5
  @golden_chance 0.15
  @max_players 8
  @colors ~w(#FF6B6B #4ECDC4 #45B7D1 #96CEB4 #FFEAA7 #DDA0DD #98D8C8 #F7DC6F)

  @spawn_positions [
    {15, 20, :right},
    {45, 20, :left},
    {30, 8, :down},
    {30, 32, :up},
    {10, 8, :right},
    {50, 8, :left},
    {10, 32, :right},
    {50, 32, :left}
  ]

  defstruct [
    :id,
    :winner,
    cols: @cols,
    rows: @rows,
    players: %{},
    food: [],
    tick: 0,
    status: :waiting,
    countdown: 3,
    events: [],
    player_order: []
  ]

  # ── Public API ──────────────────────────────────────────

  def new(room_id), do: %__MODULE__{id: room_id}

  def add_player(%{status: status}, _id, _name)
      when status not in [:waiting, :finished],
      do: {:error, :game_in_progress}

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
          id: id,
          name: name,
          color: color,
          segments: [],
          direction: :right,
          next_direction: :right,
          score: 0,
          alive: true,
          kills: 0
        }

        {:ok,
         %{
           state
           | players: Map.put(state.players, id, player),
             player_order: state.player_order ++ [id]
         }}
    end
  end

  def remove_player(state, id) do
    %{
      state
      | players: Map.delete(state.players, id),
        player_order: List.delete(state.player_order, id)
    }
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

  def start_countdown(%{status: :waiting} = state) do
    if map_size(state.players) >= 1 do
      %{state | status: :countdown, countdown: 3, events: [{:countdown, 3}]}
    else
      state
    end
  end

  def start_countdown(state), do: state

  def countdown_tick(%{status: :countdown} = state) do
    next = state.countdown - 1

    if next <= 0 do
      state
      |> place_players()
      |> place_food(@food_count)
      |> Map.merge(%{status: :playing, countdown: 0, tick: 0, events: [{:game_started}]})
    else
      %{state | countdown: next, events: [{:countdown, next}]}
    end
  end

  def countdown_tick(state), do: state

  def tick(%{status: :playing} = state) do
    state
    |> Map.put(:events, [])
    |> Map.update!(:tick, &(&1 + 1))
    |> apply_directions()
    |> move_snakes()
    |> detect_collisions()
    |> consume_food()
    |> trim_tails()
    |> replenish_food()
    |> check_winner()
  end

  def tick(state), do: state

  def reset(state) do
    players =
      Map.new(state.players, fn {id, p} ->
        {id,
         %{
           p
           | segments: [],
             direction: :right,
             next_direction: :right,
             score: 0,
             alive: true,
             kills: 0
         }}
      end)

    %{
      state
      | players: players,
        food: [],
        tick: 0,
        status: :waiting,
        countdown: 3,
        winner: nil,
        events: []
    }
  end

  def to_client(state) do
    %{
      id: state.id,
      grid: [state.cols, state.rows],
      tick: state.tick,
      status: state.status,
      countdown: state.countdown,
      winner: state.winner,
      events: Enum.map(state.events, &encode_event/1),
      players:
        Map.new(state.players, fn {id, p} ->
          {id,
           %{
             name: p.name,
             color: p.color,
             segments: Enum.map(p.segments, &Tuple.to_list/1),
             direction: p.direction,
             score: p.score,
             alive: p.alive,
             kills: p.kills
           }}
        end),
      food: Enum.map(state.food, fn {x, y, t} -> [x, y, Atom.to_string(t)] end)
    }
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

    segment_sets =
      Map.new(alive, fn {id, p} -> {id, MapSet.new(p.segments)} end)

    # Compute all deaths independently (no order dependency)
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

    # Apply deaths and credit kills
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
      Enum.reduce(alive_players, {state.players, state.food, []}, fn {id, player},
                                                                     {ps, food, evts} ->
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

  defp check_winner(state) do
    alive = Enum.count(state.players, fn {_id, p} -> p.alive end)
    total = map_size(state.players)

    cond do
      total <= 1 and alive == 0 ->
        %{state | status: :finished, events: state.events ++ [{:game_over, nil}]}

      total > 1 and alive <= 1 ->
        winner = Enum.find(state.players, fn {_, p} -> p.alive end)
        winner_id = if winner, do: elem(winner, 0)

        %{
          state
          | status: :finished,
            winner: winner_id,
            events: state.events ++ [{:game_over, winner_id}]
        }

      true ->
        state
    end
  end

  # ── Internal: setup ─────────────────────────────────────

  defp place_players(state) do
    ids = state.player_order |> Enum.filter(&Map.has_key?(state.players, &1))

    players =
      ids
      |> Enum.with_index()
      |> Enum.reduce(state.players, fn {id, idx}, acc ->
        {sx, sy, dir} = Enum.at(@spawn_positions, rem(idx, length(@spawn_positions)))

        segments =
          for i <- 0..(@initial_length - 1) do
            case dir do
              :right -> {sx - i, sy}
              :left -> {sx + i, sy}
              :down -> {sx, sy - i}
              :up -> {sx, sy + i}
            end
          end

        Map.update!(acc, id, fn p ->
          %{p | segments: segments, direction: dir, next_direction: dir, alive: true, score: 0, kills: 0}
        end)
      end)

    %{state | players: players}
  end

  defp place_food(state, count) do
    occupied = occupied_set(state)

    {food, _} =
      Enum.reduce(1..count, {[], occupied}, fn _i, {foods, occ} ->
        case find_empty_cell(state.cols, state.rows, occ) do
          nil ->
            {foods, occ}

          {x, y} ->
            type = if :rand.uniform() < @golden_chance, do: :golden, else: :normal
            {[{x, y, type} | foods], MapSet.put(occ, {x, y})}
        end
      end)

    %{state | food: state.food ++ food}
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
  defp encode_event({:game_started}), do: ["game_started"]
  defp encode_event({:game_over, winner}), do: ["game_over", winner]
  defp encode_event({:countdown, n}), do: ["countdown", n]
end
