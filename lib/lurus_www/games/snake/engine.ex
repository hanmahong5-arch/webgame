defmodule LurusWww.Games.Snake.Engine do
  @moduledoc """
  Multiplayer Snake Arena Engine.
  Open arena: join anytime, respawn instantly, powerups, leaderboard.

  Mechanics:
  - Head hits another snake's body → you die, your body becomes collectible food trail
  - Head hits head → both die
  - Powerups spawn randomly: speed boost, blade (cut tails), shield, magnet, score multiplier
  - Blade powerup: cuts 5 segments off any snake you touch from behind
  - Shield: survive one collision
  - Speed: move every other tick (2x speed) for 40 ticks
  - Magnet: food within 3-cell radius auto-attracts
  - Star: 3x score for 50 ticks
  """

  @cols 60
  @rows 40
  @initial_length 4
  @food_count 8
  @golden_chance 0.12
  @max_players 20
  @powerup_chance 0.025
  @powerup_types [:speed, :blade, :shield, :magnet, :star]

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
    powerups: [],
    tick: 0,
    status: :waiting,
    events: [],
    player_order: [],
    leaderboard: []
  ]

  # ── Public API ──────────────────────────────────────────

  def new(room_id), do: %__MODULE__{id: room_id}

  def add_player(state, id, name) do
    cond do
      map_size(state.players) >= @max_players -> {:error, :room_full}
      Map.has_key?(state.players, id) -> {:error, :already_joined}
      true ->
        idx = length(state.player_order)
        color = Enum.at(@colors, rem(idx, length(@colors)))

        player = %{
          id: id, name: name, color: color,
          segments: [], direction: :right, next_direction: :right,
          score: 0, alive: false, kills: 0, total_score: 0,
          # Active effects: %{type => ticks_remaining}
          effects: %{},
          has_shield: false
        }

        state = %{state |
          players: Map.put(state.players, id, player),
          player_order: state.player_order ++ [id]
        }

        state = if state.status == :waiting do
          state
          |> ensure_food()
          |> Map.put(:status, :playing)
          |> Map.put(:tick, 0)
          |> Map.put(:events, [{:game_started}])
        else
          state
        end

        state = spawn_single_player(state, id)
        {:ok, state}
    end
  end

  def remove_player(state, id) do
    state = %{state |
      players: Map.delete(state.players, id),
      player_order: List.delete(state.player_order, id)
    }

    if map_size(state.players) == 0 do
      %{state | status: :waiting, food: [], powerups: [], tick: 0}
    else
      update_leaderboard(state)
    end
  end

  def set_direction(state, id, direction) when direction in [:up, :down, :left, :right] do
    case Map.fetch(state.players, id) do
      {:ok, player} ->
        %{state | players: Map.put(state.players, id, %{player | next_direction: direction})}
      :error -> state
    end
  end

  def set_direction(state, _id, _dir), do: state

  def respawn(state, player_id) do
    case Map.fetch(state.players, player_id) do
      {:ok, %{alive: false} = p} ->
        state
        |> Map.update!(:players, fn ps ->
          Map.put(ps, player_id, %{p | alive: true, score: 0, kills: 0, effects: %{}, has_shield: false})
        end)
        |> spawn_single_player(player_id)
        |> Map.update!(:events, &[{:player_respawned, player_id} | &1])
      _ -> state
    end
  end

  def tick(%{status: :playing} = state) do
    alive_count = Enum.count(state.players, fn {_, p} -> p.alive end)
    if alive_count == 0, do: state, else: do_tick(state)
  end

  def tick(state), do: state

  defp do_tick(state) do
    state
    |> Map.put(:events, [])
    |> Map.update!(:tick, &(&1 + 1))
    |> tick_effects()
    |> apply_directions()
    |> move_snakes()
    |> detect_collisions()
    |> apply_blade_cuts()
    |> consume_food()
    |> collect_powerups()
    |> apply_magnet()
    |> trim_tails()
    |> replenish_food()
    |> maybe_spawn_powerup()
    |> update_leaderboard()
  end

  def to_client(state) do
    %{
      id: state.id,
      grid: [state.cols, state.rows],
      tick: state.tick,
      status: state.status,
      events: Enum.map(state.events, &encode_event/1),
      leaderboard: state.leaderboard,
      players:
        Map.new(state.players, fn {id, p} ->
          {id, %{
            name: p.name, color: p.color,
            segments: Enum.map(p.segments, &Tuple.to_list/1),
            direction: p.direction,
            score: p.score, alive: p.alive, kills: p.kills,
            total_score: p.total_score,
            effects: Map.keys(p.effects),
            has_shield: p.has_shield
          }}
        end),
      food: Enum.map(state.food, fn {x, y, t} -> [x, y, Atom.to_string(t)] end),
      powerups: Enum.map(state.powerups, fn {x, y, t} -> [x, y, Atom.to_string(t)] end)
    }
  end

  # ── Spawning ────────────────────────────────────────────

  defp spawn_single_player(state, id) do
    alive_segments =
      state.players
      |> Enum.filter(fn {pid, p} -> p.alive and pid != id end)
      |> Enum.flat_map(fn {_, p} -> p.segments end)

    occupied = MapSet.new(alive_segments)

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

  # ── Tick Pipeline ───────────────────────────────────────

  defp tick_effects(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive do
        effects = p.effects
          |> Enum.map(fn {type, ttl} -> {type, ttl - 1} end)
          |> Enum.filter(fn {_, ttl} -> ttl > 0 end)
          |> Map.new()
        {id, %{p | effects: effects}}
      else
        {id, p}
      end
    end)
    %{state | players: players}
  end

  defp apply_directions(state) do
    players = Map.new(state.players, fn {id, p} ->
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
    players = Map.new(state.players, fn {id, p} ->
      if p.alive and p.segments != [] do
        # Speed powerup: move twice on even ticks
        moves = if Map.has_key?(p.effects, :speed), do: 2, else: 1
        segments = Enum.reduce(1..moves, p.segments, fn _, segs ->
          {hx, hy} = hd(segs)
          new_head = advance(hx, hy, p.direction)
          [new_head | segs]
        end)
        {id, %{p | segments: segments}}
      else
        {id, p}
      end
    end)
    %{state | players: players}
  end

  defp detect_collisions(state) do
    alive = state.players |> Enum.filter(fn {_id, p} -> p.alive end) |> Map.new()
    segment_sets = Map.new(alive, fn {id, p} -> {id, MapSet.new(tl(p.segments))} end)
    head_map = Map.new(alive, fn {id, p} -> {id, hd(p.segments)} end)

    deaths = Enum.reduce(alive, %{}, fn {id, player}, acc ->
      head = hd(player.segments)
      {hx, hy} = head

      wall = hx < 0 or hx >= state.cols or hy < 0 or hy >= state.rows
      self = Enum.member?(tl(player.segments), head)

      # Hit other snake's body (not head)
      body_killer = Enum.find_value(alive, fn {oid, _} ->
        if oid != id and MapSet.member?(segment_sets[oid], head), do: oid
      end)

      # Head-to-head collision
      head_collision = Enum.any?(alive, fn {oid, _} ->
        oid != id and head_map[oid] == head
      end)

      hit = wall or self or body_killer != nil or head_collision

      if hit do
        # Shield blocks one death
        if player.has_shield do
          :shielded
        else
          killer = body_killer
          Map.put(acc, id, killer)
        end
      else
        acc
      end
    end)

    # Remove :shielded entries and consume shields
    {real_deaths, shielded_ids} =
      Enum.reduce(alive, {%{}, []}, fn {id, player}, {deaths_acc, shielded_acc} ->
        head = hd(player.segments)
        {hx, hy} = head
        wall = hx < 0 or hx >= state.cols or hy < 0 or hy >= state.rows
        self = Enum.member?(tl(player.segments), head)
        body_killer = Enum.find_value(alive, fn {oid, _} ->
          if oid != id and MapSet.member?(segment_sets[oid], head), do: oid
        end)
        head_collision = Enum.any?(alive, fn {oid, _} -> oid != id and head_map[oid] == head end)
        hit = wall or self or body_killer != nil or head_collision

        if hit and player.has_shield do
          {deaths_acc, [id | shielded_acc]}
        else
          if Map.has_key?(deaths, id) do
            {Map.put(deaths_acc, id, deaths[id]), shielded_acc}
          else
            {deaths_acc, shielded_acc}
          end
        end
      end)

    # Apply shield consumption
    players = Enum.reduce(shielded_ids, state.players, fn id, ps ->
      Map.update!(ps, id, &%{&1 | has_shield: false})
    end)

    # Apply deaths — drop body as food trail
    {players, events} =
      Enum.reduce(real_deaths, {players, state.events}, fn {id, killer}, {ps, evts} ->
        dead_player = ps[id]
        body_food = dead_player.segments
          |> Enum.take_every(2)
          |> Enum.map(fn {x, y} ->
            type = if :rand.uniform() < 0.2, do: :golden, else: :normal
            {x, y, type}
          end)

        ps = Map.update!(ps, id, &%{&1 | alive: false, total_score: &1.total_score + &1.score})

        ps = if killer && !Map.has_key?(real_deaths, killer) do
          Map.update!(ps, killer, &%{&1 | kills: &1.kills + 1, score: &1.score + 3})
        else
          ps
        end

        {ps, [{:player_died, id, killer} | evts]}
      end)

    # Add body food to the field
    body_food = Enum.flat_map(real_deaths, fn {id, _} ->
      state.players[id].segments
      |> Enum.take_every(2)
      |> Enum.filter(fn {x, y} -> x >= 0 and x < @cols and y >= 0 and y < @rows end)
      |> Enum.map(fn {x, y} ->
        type = if :rand.uniform() < 0.2, do: :golden, else: :normal
        {x, y, type}
      end)
    end)

    %{state | players: players, events: events, food: state.food ++ body_food}
  end

  defp apply_blade_cuts(state) do
    alive_with_blade = state.players
      |> Enum.filter(fn {_, p} -> p.alive and Map.has_key?(p.effects, :blade) end)

    if alive_with_blade == [] do
      state
    else
      Enum.reduce(alive_with_blade, state, fn {cutter_id, cutter}, state ->
        head = hd(cutter.segments)

        # Check if cutter's head is adjacent to (within 2 cells of) another snake's body
        Enum.reduce(state.players, state, fn {target_id, target}, state ->
          if target_id == cutter_id or not target.alive or length(target.segments) <= 5 do
            state
          else
            # Check if head is near any segment from index 3 onward (not head area)
            cut_idx = Enum.find_index(Enum.drop(target.segments, 3), fn {sx, sy} ->
              {hx, hy} = head
              abs(hx - sx) + abs(hy - sy) <= 1
            end)

            if cut_idx do
              real_idx = cut_idx + 3
              {keep, cut_off} = Enum.split(target.segments, real_idx)
              # Turn cut segments into food
              cut_food = cut_off
                |> Enum.take_every(2)
                |> Enum.filter(fn {x, y} -> x >= 0 and x < @cols and y >= 0 and y < @rows end)
                |> Enum.map(fn {x, y} -> {x, y, :golden} end)

              state
              |> Map.update!(:players, fn ps ->
                ps
                |> Map.update!(target_id, &%{&1 | segments: keep})
                |> Map.update!(cutter_id, &%{&1 | score: &1.score + length(cut_off), effects: Map.delete(&1.effects, :blade)})
              end)
              |> Map.update!(:food, &(&1 ++ cut_food))
              |> Map.update!(:events, &[{:blade_cut, cutter_id, target_id, length(cut_off)} | &1])
            else
              state
            end
          end
        end)
      end)
    end
  end

  defp consume_food(state) do
    alive_players = Enum.filter(state.players, fn {_id, p} -> p.alive end)

    {updated_players, remaining_food, new_events} =
      Enum.reduce(alive_players, {state.players, state.food, []}, fn {id, player}, {ps, food, evts} ->
        {hx, hy} = hd(player.segments)
        multiplier = if Map.has_key?(player.effects, :star), do: 3, else: 1

        case Enum.find_index(food, fn {fx, fy, _} -> fx == hx and fy == hy end) do
          nil -> {ps, food, evts}
          idx ->
            {_, _, type} = Enum.at(food, idx)
            pts = (if type == :golden, do: 5, else: 1) * multiplier
            updated = Map.update!(ps, id, &%{&1 | score: &1.score + pts})
            {updated, List.delete_at(food, idx), [{:food_eaten, id, type} | evts]}
        end
      end)

    %{state | players: updated_players, food: remaining_food, events: state.events ++ new_events}
  end

  defp collect_powerups(state) do
    alive_players = Enum.filter(state.players, fn {_id, p} -> p.alive end)

    {updated_players, remaining_pups, new_events} =
      Enum.reduce(alive_players, {state.players, state.powerups, []}, fn {id, player}, {ps, pups, evts} ->
        {hx, hy} = hd(player.segments)

        case Enum.find_index(pups, fn {px, py, _} -> px == hx and py == hy end) do
          nil -> {ps, pups, evts}
          idx ->
            {_, _, type} = Enum.at(pups, idx)
            ps = apply_powerup(ps, id, type)
            {ps, List.delete_at(pups, idx), [{:powerup_collected, id, type} | evts]}
        end
      end)

    %{state | players: updated_players, powerups: remaining_pups, events: state.events ++ new_events}
  end

  defp apply_powerup(players, id, :speed) do
    Map.update!(players, id, fn p ->
      %{p | effects: Map.put(p.effects, :speed, 40)}
    end)
  end

  defp apply_powerup(players, id, :blade) do
    Map.update!(players, id, fn p ->
      %{p | effects: Map.put(p.effects, :blade, 60)}
    end)
  end

  defp apply_powerup(players, id, :shield) do
    Map.update!(players, id, &%{&1 | has_shield: true})
  end

  defp apply_powerup(players, id, :magnet) do
    Map.update!(players, id, fn p ->
      %{p | effects: Map.put(p.effects, :magnet, 50)}
    end)
  end

  defp apply_powerup(players, id, :star) do
    Map.update!(players, id, fn p ->
      %{p | effects: Map.put(p.effects, :star, 50)}
    end)
  end

  defp apply_magnet(state) do
    magnets = state.players
      |> Enum.filter(fn {_, p} -> p.alive and Map.has_key?(p.effects, :magnet) end)

    if magnets == [] do
      state
    else
      # Move food within radius 3 toward nearest magnet player
      food = Enum.map(state.food, fn {fx, fy, type} = f ->
        nearest = Enum.min_by(magnets, fn {_, p} ->
          {hx, hy} = hd(p.segments)
          abs(hx - fx) + abs(hy - fy)
        end)

        {_, p} = nearest
        {hx, hy} = hd(p.segments)
        dist = abs(hx - fx) + abs(hy - fy)

        if dist <= 4 and dist > 0 do
          dx = if hx > fx, do: 1, else: if(hx < fx, do: -1, else: 0)
          dy = if hy > fy, do: 1, else: if(hy < fy, do: -1, else: 0)
          {fx + dx, fy + dy, type}
        else
          f
        end
      end)

      %{state | food: food}
    end
  end

  defp trim_tails(state) do
    fed_ids =
      state.events
      |> Enum.flat_map(fn
        {:food_eaten, id, _} -> [id]
        _ -> []
      end)
      |> MapSet.new()

    players = Map.new(state.players, fn {id, p} ->
      if p.alive and not MapSet.member?(fed_ids, id) and length(p.segments) > 1 do
        # Speed snakes trim 2 (since they moved 2)
        trim = if Map.has_key?(p.effects, :speed), do: 2, else: 1
        segs = Enum.drop(p.segments, -min(trim, length(p.segments) - 1))
        {id, %{p | segments: segs}}
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

  defp maybe_spawn_powerup(state) do
    if :rand.uniform() < @powerup_chance and length(state.powerups) < 5 do
      type = Enum.random(@powerup_types)
      occupied = occupied_set(state)
      case find_empty_cell(state.cols, state.rows, occupied) do
        nil -> state
        {x, y} -> %{state | powerups: [{x, y, type} | state.powerups]}
      end
    else
      state
    end
  end

  defp update_leaderboard(state) do
    board = state.players
      |> Enum.map(fn {id, p} ->
        %{id: id, name: p.name, color: p.color, score: p.score, kills: p.kills,
          total_score: p.total_score + p.score, alive: p.alive}
      end)
      |> Enum.sort_by(&(-&1.total_score))
      |> Enum.take(10)

    %{state | leaderboard: board}
  end

  # ── Food ────────────────────────────────────────────────

  defp ensure_food(state) do
    needed = @food_count - length(state.food)
    if needed > 0, do: place_food(state, needed), else: state
  end

  defp place_food(state, count) do
    occupied = occupied_set(state)
    {food, _} = Enum.reduce(1..count, {[], occupied}, fn _i, {foods, occ} ->
      case find_empty_cell(state.cols, state.rows, occ) do
        nil -> {foods, occ}
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
    pups = Enum.map(state.powerups, fn {x, y, _} -> {x, y} end)
    MapSet.new(snakes ++ foods ++ pups)
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
  defp encode_event({:powerup_collected, id, type}), do: ["powerup", id, Atom.to_string(type)]
  defp encode_event({:blade_cut, cutter, target, len}), do: ["blade_cut", cutter, target, len]
end
