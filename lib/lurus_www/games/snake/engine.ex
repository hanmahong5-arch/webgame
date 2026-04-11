defmodule LurusWww.Games.Snake.Engine do
  @moduledoc """
  Slither.io-style multiplayer snake arena.
  Continuous float coordinates, angular steering, circle collision.
  """

  @width 1800.0
  @height 1200.0
  @seg_radius 6.0
  @seg_spacing 10.0
  @base_speed 3.0
  @boost_speed 6.0
  @boost_shrink_rate 0.4
  @turn_rate 0.12
  @initial_length 12
  @food_count 120
  @golden_chance 0.08
  @max_players 20
  @powerup_types [:speed, :blade, :shield, :magnet, :star]
  @powerup_chance 0.015

  @colors ~w(#FF6B6B #4ECDC4 #45B7D1 #96CEB4 #FFEAA7 #DDA0DD #98D8C8 #F7DC6F #FF8C69 #B08EFF #7AFF89 #FFB800 #FF6BCC #00F0FF #66D9EF #F92672 #A6E22E #FD971F #AE81FF #E6DB74)

  defstruct [
    :id,
    width: @width,
    height: @height,
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
        angle = :rand.uniform() * :math.pi() * 2

        player = %{
          id: id, name: name, color: color,
          segments: [], angle: angle, target_angle: angle,
          speed: @base_speed, boosting: false,
          score: 0, alive: false, kills: 0, total_score: 0,
          effects: %{}, has_shield: false
        }

        state = %{state |
          players: Map.put(state.players, id, player),
          player_order: state.player_order ++ [id]
        }

        state = if state.status == :waiting do
          state
          |> seed_food(@food_count)
          |> Map.put(:status, :playing)
          |> Map.put(:tick, 0)
          |> Map.put(:events, [{:game_started}])
        else
          state
        end

        {:ok, spawn_player(state, id)}
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

  def set_target(state, id, target_angle) when is_float(target_angle) do
    case Map.fetch(state.players, id) do
      {:ok, p} -> %{state | players: Map.put(state.players, id, %{p | target_angle: target_angle})}
      :error -> state
    end
  end

  def set_target(state, _id, _), do: state

  def set_boost(state, id, boosting) when is_boolean(boosting) do
    case Map.fetch(state.players, id) do
      {:ok, p} -> %{state | players: Map.put(state.players, id, %{p | boosting: boosting})}
      :error -> state
    end
  end

  def set_boost(state, _id, _), do: state

  def respawn(state, player_id) do
    case Map.fetch(state.players, player_id) do
      {:ok, %{alive: false} = p} ->
        state
        |> Map.update!(:players, fn ps ->
          Map.put(ps, player_id, %{p | alive: true, score: 0, kills: 0, effects: %{}, has_shield: false, boosting: false})
        end)
        |> spawn_player(player_id)
        |> Map.update!(:events, &[{:player_respawned, player_id} | &1])
      _ -> state
    end
  end

  def tick(%{status: :playing} = state) do
    if Enum.any?(state.players, fn {_, p} -> p.alive end) do
      state
      |> Map.put(:events, [])
      |> Map.update!(:tick, &(&1 + 1))
      |> tick_effects()
      |> steer_and_move()
      |> detect_collisions()
      |> collect_food()
      |> collect_powerups()
      |> apply_magnet()
      |> apply_boost_shrink()
      |> replenish_food()
      |> maybe_spawn_powerup()
      |> update_leaderboard()
    else
      state
    end
  end

  def tick(state), do: state

  def to_client(state) do
    %{
      id: state.id,
      size: [state.width, state.height],
      tick: state.tick,
      status: state.status,
      events: Enum.map(state.events, &encode_event/1),
      leaderboard: Enum.take(state.leaderboard, 8),
      players: Map.new(state.players, fn {id, p} ->
        {id, %{
          name: p.name, color: p.color, angle: p.angle,
          segments: Enum.map(p.segments, fn {x, y} -> [round2(x), round2(y)] end),
          score: p.score, alive: p.alive, kills: p.kills,
          total_score: p.total_score, boosting: p.boosting,
          effects: Map.keys(p.effects), has_shield: p.has_shield
        }}
      end),
      food: Enum.map(state.food, fn {x, y, t} -> [round2(x), round2(y), Atom.to_string(t)] end),
      powerups: Enum.map(state.powerups, fn {x, y, t} -> [round2(x), round2(y), Atom.to_string(t)] end)
    }
  end

  defp round2(f), do: Float.round(f * 1.0, 1)

  # ── Spawning ────────────────────────────────────────────

  defp spawn_player(state, id) do
    margin = 150.0
    x = margin + :rand.uniform() * (state.width - margin * 2)
    y = margin + :rand.uniform() * (state.height - margin * 2)
    angle = :rand.uniform() * :math.pi() * 2

    segments = for i <- 0..(@initial_length - 1) do
      {x - :math.cos(angle) * i * @seg_spacing,
       y - :math.sin(angle) * i * @seg_spacing}
    end

    %{state |
      players: Map.update!(state.players, id, fn p ->
        %{p | segments: segments, angle: angle, target_angle: angle, alive: true,
              speed: @base_speed, boosting: false}
      end)
    }
  end

  # ── Tick Pipeline ───────────────────────────────────────

  defp tick_effects(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive do
        effects = p.effects
          |> Enum.map(fn {t, ttl} -> {t, ttl - 1} end)
          |> Enum.filter(fn {_, ttl} -> ttl > 0 end)
          |> Map.new()
        {id, %{p | effects: effects}}
      else
        {id, p}
      end
    end)
    %{state | players: players}
  end

  defp steer_and_move(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive and p.segments != [] do
        # Smooth steering toward target angle
        angle = steer_toward(p.angle, p.target_angle, @turn_rate)

        # Speed (base or boost)
        speed = if p.boosting and length(p.segments) > 5 do
          @boost_speed
        else
          if Map.has_key?(p.effects, :speed), do: @boost_speed, else: @base_speed
        end

        # Move head
        {hx, hy} = hd(p.segments)
        new_head = {hx + :math.cos(angle) * speed, hy + :math.sin(angle) * speed}

        # Build new segments list: add head, trim to maintain spacing
        new_segments = rebuild_segments([new_head | p.segments], @seg_spacing, length(p.segments))

        {id, %{p | segments: new_segments, angle: angle, speed: speed}}
      else
        {id, p}
      end
    end)
    %{state | players: players}
  end

  defp steer_toward(current, target, rate) do
    diff = normalize_angle(target - current)
    clamped = max(-rate, min(rate, diff))
    normalize_angle(current + clamped)
  end

  defp normalize_angle(a) do
    a = :math.fmod(a, 2 * :math.pi())
    cond do
      a > :math.pi() -> a - 2 * :math.pi()
      a < -:math.pi() -> a + 2 * :math.pi()
      true -> a
    end
  end

  defp rebuild_segments(segments, spacing, target_count) do
    # Walk along the path, placing segments at even intervals
    segments
    |> Enum.take(target_count + 5)
    |> resample(spacing, target_count)
  end

  defp resample([first | _] = points, spacing, count) do
    do_resample(points, spacing, count - 1, [first])
  end

  defp do_resample(_, _, 0, acc), do: Enum.reverse(acc)
  defp do_resample([_single], _, _, acc), do: Enum.reverse(acc)

  defp do_resample([{ax, ay} = _a, {bx, by} = b | rest], spacing, remaining, acc) do
    {lx, ly} = hd(acc)
    dist = distance(lx, ly, bx, by)

    if dist >= spacing do
      # Place next segment at spacing distance from last placed
      ratio = spacing / max(dist, 0.01)
      nx = lx + (bx - lx) * ratio
      ny = ly + (by - ly) * ratio
      do_resample([{nx, ny}, b | rest], spacing, remaining - 1, [{nx, ny} | acc])
    else
      do_resample([{ax, ay} | rest], spacing, remaining, acc)
    end
  end

  defp detect_collisions(state) do
    alive = state.players |> Enum.filter(fn {_, p} -> p.alive end) |> Map.new()

    deaths = Enum.reduce(alive, %{}, fn {id, player}, acc ->
      {hx, hy} = hd(player.segments)

      # Wall collision
      wall = hx < 0 or hx > state.width or hy < 0 or hy > state.height

      # Collision with other snakes' bodies (skip first 3 segments = head area)
      other_killer = Enum.find_value(alive, fn {oid, op} ->
        if oid != id do
          hit = op.segments
            |> Enum.drop(3)
            |> Enum.any?(fn {sx, sy} -> distance(hx, hy, sx, sy) < @seg_radius * 2 end)
          if hit, do: oid
        end
      end)

      # Head-to-head
      head_hit = Enum.any?(alive, fn {oid, op} ->
        oid != id and distance(hx, hy, elem(hd(op.segments), 0), elem(hd(op.segments), 1)) < @seg_radius * 2
      end)

      hit = wall or other_killer != nil or head_hit

      if hit do
        if player.has_shield do
          acc  # Shield absorbs hit
        else
          Map.put(acc, id, other_killer)
        end
      else
        acc
      end
    end)

    # Consume shields
    players = Enum.reduce(alive, state.players, fn {id, player}, ps ->
      {hx, hy} = hd(player.segments)
      wall = hx < 0 or hx > state.width or hy < 0 or hy > state.height
      other_hit = Enum.any?(alive, fn {oid, op} ->
        oid != id and (
          Enum.any?(Enum.drop(op.segments, 3), fn {sx, sy} -> distance(hx, hy, sx, sy) < @seg_radius * 2 end) or
          distance(hx, hy, elem(hd(op.segments), 0), elem(hd(op.segments), 1)) < @seg_radius * 2
        )
      end)
      if (wall or other_hit) and player.has_shield and not Map.has_key?(deaths, id) do
        Map.update!(ps, id, &%{&1 | has_shield: false})
      else
        ps
      end
    end)

    # Apply deaths + drop food
    {players, events, body_food} =
      Enum.reduce(deaths, {players, state.events, []}, fn {id, killer}, {ps, evts, bf} ->
        dead = ps[id]
        food = dead.segments
          |> Enum.take_every(3)
          |> Enum.take(15)
          |> Enum.map(fn {x, y} ->
            t = if :rand.uniform() < 0.2, do: :golden, else: :normal
            {x, y, t}
          end)

        ps = Map.update!(ps, id, &%{&1 | alive: false, total_score: &1.total_score + &1.score})
        ps = if killer && !Map.has_key?(deaths, killer) do
          Map.update!(ps, killer, &%{&1 | kills: &1.kills + 1, score: &1.score + 5})
        else
          ps
        end

        {ps, [{:player_died, id, killer} | evts], bf ++ food}
      end)

    %{state | players: players, events: events, food: state.food ++ body_food}
  end

  defp collect_food(state) do
    alive = Enum.filter(state.players, fn {_, p} -> p.alive end)
    eat_radius = @seg_radius * 2.5

    {players, remaining, events} =
      Enum.reduce(alive, {state.players, state.food, []}, fn {id, player}, {ps, food, evts} ->
        {hx, hy} = hd(player.segments)
        mult = if Map.has_key?(player.effects, :star), do: 3, else: 1

        {eaten, kept} = Enum.split_with(food, fn {fx, fy, _} ->
          distance(hx, hy, fx, fy) < eat_radius
        end)

        if eaten == [] do
          {ps, food, evts}
        else
          pts = Enum.reduce(eaten, 0, fn {_, _, t}, acc ->
            acc + (if t == :golden, do: 5, else: 1) * mult
          end)

          # Grow: add segments
          grow = min(length(eaten), 3)
          updated = Map.update!(ps, id, fn p ->
            tail = List.last(p.segments)
            extra = List.duplicate(tail, grow)
            %{p | score: p.score + pts, segments: p.segments ++ extra}
          end)

          {updated, kept, [{:food_eaten, id, if(pts > 5, do: :golden, else: :normal)} | evts]}
        end
      end)

    %{state | players: players, food: remaining, events: state.events ++ events}
  end

  defp collect_powerups(state) do
    alive = Enum.filter(state.players, fn {_, p} -> p.alive end)
    pickup_r = @seg_radius * 3

    {players, remaining, events} =
      Enum.reduce(alive, {state.players, state.powerups, []}, fn {id, player}, {ps, pups, evts} ->
        {hx, hy} = hd(player.segments)
        case Enum.find_index(pups, fn {px, py, _} -> distance(hx, hy, px, py) < pickup_r end) do
          nil -> {ps, pups, evts}
          idx ->
            {_, _, type} = Enum.at(pups, idx)
            {apply_powerup(ps, id, type), List.delete_at(pups, idx), [{:powerup_collected, id, type} | evts]}
        end
      end)

    %{state | players: players, powerups: remaining, events: state.events ++ events}
  end

  defp apply_powerup(ps, id, :speed), do: Map.update!(ps, id, &%{&1 | effects: Map.put(&1.effects, :speed, 200)})
  defp apply_powerup(ps, id, :blade), do: Map.update!(ps, id, &%{&1 | effects: Map.put(&1.effects, :blade, 300)})
  defp apply_powerup(ps, id, :shield), do: Map.update!(ps, id, &%{&1 | has_shield: true})
  defp apply_powerup(ps, id, :magnet), do: Map.update!(ps, id, &%{&1 | effects: Map.put(&1.effects, :magnet, 250)})
  defp apply_powerup(ps, id, :star), do: Map.update!(ps, id, &%{&1 | effects: Map.put(&1.effects, :star, 250)})

  defp apply_magnet(state) do
    magnets = state.players |> Enum.filter(fn {_, p} -> p.alive and Map.has_key?(p.effects, :magnet) end)
    if magnets == [] do
      state
    else
      food = Enum.map(state.food, fn {fx, fy, type} = f ->
        nearest = Enum.min_by(magnets, fn {_, p} -> {hx, hy} = hd(p.segments); distance(hx, hy, fx, fy) end)
        {_, p} = nearest
        {hx, hy} = hd(p.segments)
        dist = distance(hx, hy, fx, fy)
        if dist < 80 and dist > 1 do
          dx = (hx - fx) / dist * 2.5
          dy = (hy - fy) / dist * 2.5
          {fx + dx, fy + dy, type}
        else
          f
        end
      end)
      %{state | food: food}
    end
  end

  defp apply_boost_shrink(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive and p.boosting and length(p.segments) > 5 and not Map.has_key?(p.effects, :speed) do
        # Shed tail segments while boosting
        drop = if rem(state.tick, 3) == 0, do: 1, else: 0
        if drop > 0 do
          tail = List.last(p.segments)
          {tx, ty} = tail
          # Drop as food
          new_food_event = {:boost_trail, id}
          segs = Enum.drop(p.segments, -drop)
          {id, %{p | segments: segs}}
        else
          {id, p}
        end
      else
        {id, p}
      end
    end)

    # Collect boost trail food
    boost_food = state.players
      |> Enum.filter(fn {_, p} -> p.alive and p.boosting and length(p.segments) > 5 and not Map.has_key?(p.effects, :speed) end)
      |> Enum.flat_map(fn {_, p} ->
        if rem(state.tick, 3) == 0 do
          tail = List.last(p.segments)
          {tx, ty} = tail
          [{tx, ty, :normal}]
        else
          []
        end
      end)

    %{state | players: players, food: state.food ++ boost_food}
  end

  defp replenish_food(state) do
    needed = @food_count - length(state.food)
    if needed > 0, do: seed_food(state, needed), else: state
  end

  defp seed_food(state, count) do
    new_food = for _ <- 1..count do
      x = :rand.uniform() * state.width
      y = :rand.uniform() * state.height
      type = if :rand.uniform() < @golden_chance, do: :golden, else: :normal
      {x, y, type}
    end
    %{state | food: state.food ++ new_food}
  end

  defp maybe_spawn_powerup(state) do
    if :rand.uniform() < @powerup_chance and length(state.powerups) < 5 do
      x = 50 + :rand.uniform() * (state.width - 100)
      y = 50 + :rand.uniform() * (state.height - 100)
      type = Enum.random(@powerup_types)
      %{state | powerups: [{x, y, type} | state.powerups]}
    else
      state
    end
  end

  defp update_leaderboard(state) do
    board = state.players
      |> Enum.map(fn {id, p} ->
        %{id: id, name: p.name, color: p.color,
          score: p.score, kills: p.kills,
          total_score: p.total_score + p.score, alive: p.alive,
          length: length(p.segments)}
      end)
      |> Enum.sort_by(&(-&1.total_score))
      |> Enum.take(10)
    %{state | leaderboard: board}
  end

  # ── Helpers ─────────────────────────────────────────────

  defp distance(x1, y1, x2, y2) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end

  defp encode_event({:food_eaten, id, type}), do: ["food_eaten", id, Atom.to_string(type)]
  defp encode_event({:player_died, id, killer}), do: ["player_died", id, killer]
  defp encode_event({:player_respawned, id}), do: ["player_respawned", id]
  defp encode_event({:game_started}), do: ["game_started"]
  defp encode_event({:powerup_collected, id, type}), do: ["powerup", id, Atom.to_string(type)]
  defp encode_event({:boost_trail, id}), do: ["boost_trail", id]
end
