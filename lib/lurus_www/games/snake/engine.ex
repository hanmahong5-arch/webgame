defmodule LurusWww.Games.Snake.Engine do
  @moduledoc """
  Slither.io-style multiplayer snake arena.
  Continuous movement, angular steering, progression system.
  Optimized for minimal broadcast payload.
  """

  @width 2000.0
  @height 1400.0
  @seg_radius 6.0
  @seg_spacing 9.0
  @base_speed 5.0
  @max_speed 9.0
  @speed_per_10_food 0.3
  @boost_multiplier 1.8
  @turn_rate 0.14
  @initial_length 10
  @base_food 80
  @food_per_player 15
  @max_food 300
  @food_accum_rate 2
  @golden_chance 0.08
  @max_players 20
  @powerup_types [:blade, :shield, :magnet, :star]
  @powerup_chance 0.012

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
          base_speed: @base_speed, boosting: false,
          score: 0, alive: false, kills: 0, total_score: 0,
          food_eaten: 0,
          effects: %{}, has_shield: false
        }

        state = %{state |
          players: Map.put(state.players, id, player),
          player_order: state.player_order ++ [id]
        }

        state = if state.status == :waiting do
          state |> seed_food(target_food(state)) |> Map.merge(%{status: :playing, tick: 0, events: [{:game_started}]})
        else
          state
        end

        {:ok, spawn_player(state, id)}
    end
  end

  def remove_player(state, id) do
    # Drop body as food when leaving
    state = case Map.get(state.players, id) do
      %{alive: true, segments: segs} when length(segs) > 3 ->
        food = segs |> Enum.take_every(3) |> Enum.take(12) |> Enum.map(fn {x, y} -> {x, y, :normal} end)
        %{state | food: state.food ++ food}
      _ -> state
    end

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

  def set_target(state, id, angle) when is_number(angle) do
    case Map.get(state.players, id) do
      nil -> state
      p -> %{state | players: Map.put(state.players, id, %{p | target_angle: angle * 1.0})}
    end
  end
  def set_target(state, _, _), do: state

  def set_boost(state, id, boosting) when is_boolean(boosting) do
    case Map.get(state.players, id) do
      nil -> state
      p -> %{state | players: Map.put(state.players, id, %{p | boosting: boosting})}
    end
  end
  def set_boost(state, _, _), do: state

  def respawn(state, pid) do
    case Map.get(state.players, pid) do
      %{alive: false} = p ->
        state
        |> put_in([:players, pid], %{p | alive: true, score: 0, kills: 0, food_eaten: 0,
            effects: %{}, has_shield: false, boosting: false, base_speed: @base_speed})
        |> spawn_player(pid)
        |> Map.update!(:events, &[{:player_respawned, pid} | &1])
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

  def player_count(state), do: map_size(state.players)

  # ── Serialization (optimized payload) ───────────────────

  def to_client(state) do
    %{
      id: state.id,
      size: [state.width, state.height],
      tick: state.tick,
      status: state.status,
      events: state.events |> Enum.map(&encode_event/1) |> Enum.reject(&is_nil/1),
      leaderboard: Enum.take(state.leaderboard, 8),
      players: Map.new(state.players, fn {id, p} ->
        # Only send every 2nd segment for long snakes (visual LOD)
        segs = if length(p.segments) > 30 do
          {head_area, tail_area} = Enum.split(p.segments, 8)
          head_area ++ Enum.take_every(tail_area, 2)
        else
          p.segments
        end

        {id, %{
          n: p.name, c: p.color, a: r2(p.angle),
          s: Enum.map(segs, fn {x, y} -> [r2(x), r2(y)] end),
          sc: p.score, al: p.alive, k: p.kills,
          ts: p.total_score, b: p.boosting,
          ef: Map.keys(p.effects), sh: p.has_shield,
          spd: r2(current_speed(p))
        }}
      end),
      food: Enum.map(state.food, fn {x, y, t} -> [r2(x), r2(y), if(t == :golden, do: 1, else: 0)] end),
      pups: Enum.map(state.powerups, fn {x, y, t} -> [r2(x), r2(y), pup_idx(t)] end)
    }
  end

  defp r2(f), do: Float.round(f * 1.0, 1)
  defp pup_idx(:blade), do: 0
  defp pup_idx(:shield), do: 1
  defp pup_idx(:magnet), do: 2
  defp pup_idx(:star), do: 3
  defp pup_idx(_), do: 0

  # ── Internal ────────────────────────────────────────────

  defp spawn_player(state, id) do
    margin = 200.0
    x = margin + :rand.uniform() * (state.width - margin * 2)
    y = margin + :rand.uniform() * (state.height - margin * 2)
    angle = :rand.uniform() * :math.pi() * 2

    segments = for i <- 0..(@initial_length - 1) do
      {x - :math.cos(angle) * i * @seg_spacing, y - :math.sin(angle) * i * @seg_spacing}
    end

    %{state | players: Map.update!(state.players, id, fn p ->
      %{p | segments: segments, angle: angle, target_angle: angle, alive: true}
    end)}
  end

  defp current_speed(p) do
    # Progression: faster as you eat more
    progression = min(@max_speed, p.base_speed + div(p.food_eaten, 10) * @speed_per_10_food)
    base = if Map.has_key?(p.effects, :speed), do: @max_speed, else: progression
    if p.boosting && length(p.segments) > 5, do: base * @boost_multiplier, else: base
  end

  defp tick_effects(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive do
        effects = p.effects |> Enum.map(fn {t, ttl} -> {t, ttl - 1} end) |> Enum.filter(fn {_, t} -> t > 0 end) |> Map.new()
        {id, %{p | effects: effects}}
      else
        {id, p}
      end
    end)
    %{state | players: players}
  end

  defp steer_and_move(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive && p.segments != [] do
        angle = steer(p.angle, p.target_angle, @turn_rate)
        speed = current_speed(p)
        {hx, hy} = hd(p.segments)
        new_head = {hx + :math.cos(angle) * speed, hy + :math.sin(angle) * speed}
        new_segs = resample([new_head | p.segments], @seg_spacing, length(p.segments))
        {id, %{p | segments: new_segs, angle: angle}}
      else
        {id, p}
      end
    end)
    %{state | players: players}
  end

  defp steer(cur, target, rate) do
    diff = :math.fmod(target - cur + 3 * :math.pi(), 2 * :math.pi()) - :math.pi()
    normalize(cur + max(-rate, min(rate, diff)))
  end

  defp normalize(a) do
    a = :math.fmod(a, 2 * :math.pi())
    cond do
      a > :math.pi() -> a - 2 * :math.pi()
      a < -:math.pi() -> a + 2 * :math.pi()
      true -> a
    end
  end

  defp resample(points, spacing, count) do
    do_resample(points, spacing, count - 1, [hd(points)])
  end

  defp do_resample(_, _, 0, acc), do: Enum.reverse(acc)
  defp do_resample([_], _, _, acc), do: Enum.reverse(acc)
  defp do_resample([_a, b | rest], spacing, rem_count, acc) do
    {lx, ly} = hd(acc)
    {bx, by} = b
    dist = dist(lx, ly, bx, by)
    if dist >= spacing do
      ratio = spacing / max(dist, 0.001)
      next = {lx + (bx - lx) * ratio, ly + (by - ly) * ratio}
      do_resample([next, b | rest], spacing, rem_count - 1, [next | acc])
    else
      do_resample([hd(acc) | rest], spacing, rem_count, acc)
    end
  end

  defp detect_collisions(state) do
    alive = state.players |> Enum.filter(fn {_, p} -> p.alive end) |> Map.new()
    hit_r = @seg_radius * 2.2

    deaths = Enum.reduce(alive, %{}, fn {id, p}, acc ->
      {hx, hy} = hd(p.segments)
      wall = hx < 0 || hx > state.width || hy < 0 || hy > state.height

      other_killer = Enum.find_value(alive, fn {oid, op} ->
        if oid != id do
          hit = op.segments |> Enum.drop(3) |> Enum.any?(fn {sx, sy} -> dist(hx, hy, sx, sy) < hit_r end)
          if hit, do: oid
        end
      end)

      hit = wall || other_killer != nil

      cond do
        hit && !p.has_shield -> Map.put(acc, id, other_killer)
        hit && p.has_shield -> acc  # shield consumed below
        true -> acc
      end
    end)

    # Consume shields
    players = Enum.reduce(alive, state.players, fn {id, p}, ps ->
      {hx, hy} = hd(p.segments)
      wall = hx < 0 || hx > state.width || hy < 0 || hy > state.height
      other = Enum.any?(alive, fn {oid, op} ->
        oid != id && Enum.any?(Enum.drop(op.segments, 3), fn {sx, sy} -> dist(hx, hy, sx, sy) < hit_r end)
      end)
      if (wall || other) && p.has_shield && !Map.has_key?(deaths, id) do
        Map.update!(ps, id, &%{&1 | has_shield: false})
      else
        ps
      end
    end)

    # Deaths: drop body food + credit kills
    {players, events, food} =
      Enum.reduce(deaths, {players, state.events, state.food}, fn {id, killer}, {ps, evts, fd} ->
        dead = ps[id]
        body_food = dead.segments |> Enum.take_every(3) |> Enum.take(12) |> Enum.map(fn {x, y} ->
          {x, y, if(:rand.uniform() < 0.2, do: :golden, else: :normal)}
        end)
        ps = Map.update!(ps, id, &%{&1 | alive: false, total_score: &1.total_score + &1.score})
        ps = if killer && !Map.has_key?(deaths, killer) do
          Map.update!(ps, killer, &%{&1 | kills: &1.kills + 1, score: &1.score + 5})
        else ps end
        {ps, [{:player_died, id, killer} | evts], fd ++ body_food}
      end)

    %{state | players: players, events: events, food: food}
  end

  defp collect_food(state) do
    alive = Enum.filter(state.players, fn {_, p} -> p.alive end)
    eat_r = @seg_radius * 3

    {players, food, events} =
      Enum.reduce(alive, {state.players, state.food, []}, fn {id, p}, {ps, fd, ev} ->
        {hx, hy} = hd(p.segments)
        mult = if Map.has_key?(p.effects, :star), do: 3, else: 1

        {eaten, kept} = Enum.split_with(fd, fn {fx, fy, _} -> dist(hx, hy, fx, fy) < eat_r end)
        if eaten == [] do
          {ps, fd, ev}
        else
          pts = Enum.reduce(eaten, 0, fn {_, _, t}, a -> a + (if t == :golden, do: 5, else: 1) * mult end)
          grow = min(length(eaten) * 2, 6)
          ps = Map.update!(ps, id, fn pl ->
            tail = List.last(pl.segments)
            %{pl | score: pl.score + pts, food_eaten: pl.food_eaten + length(eaten),
                   segments: pl.segments ++ List.duplicate(tail, grow)}
          end)
          {ps, kept, [{:food_eaten, id, if(pts > 5, do: :golden, else: :normal)} | ev]}
        end
      end)

    %{state | players: players, food: food, events: state.events ++ events}
  end

  defp collect_powerups(state) do
    alive = Enum.filter(state.players, fn {_, p} -> p.alive end)
    r = @seg_radius * 4

    {players, pups, events} =
      Enum.reduce(alive, {state.players, state.powerups, []}, fn {id, p}, {ps, pps, ev} ->
        {hx, hy} = hd(p.segments)
        case Enum.find_index(pps, fn {px, py, _} -> dist(hx, hy, px, py) < r end) do
          nil -> {ps, pps, ev}
          idx ->
            {_, _, t} = Enum.at(pps, idx)
            {apply_pup(ps, id, t), List.delete_at(pps, idx), [{:powerup_collected, id, t} | ev]}
        end
      end)

    %{state | players: players, powerups: pups, events: state.events ++ events}
  end

  defp apply_pup(ps, id, :blade), do: Map.update!(ps, id, &%{&1 | effects: Map.put(&1.effects, :blade, 300)})
  defp apply_pup(ps, id, :shield), do: Map.update!(ps, id, &%{&1 | has_shield: true})
  defp apply_pup(ps, id, :magnet), do: Map.update!(ps, id, &%{&1 | effects: Map.put(&1.effects, :magnet, 250)})
  defp apply_pup(ps, id, :star), do: Map.update!(ps, id, &%{&1 | effects: Map.put(&1.effects, :star, 250)})

  defp apply_magnet(state) do
    magnets = state.players |> Enum.filter(fn {_, p} -> p.alive && Map.has_key?(p.effects, :magnet) end)
    if magnets == [] do state else
      food = Enum.map(state.food, fn {fx, fy, t} = f ->
        case Enum.min_by(magnets, fn {_, p} -> {hx, hy} = hd(p.segments); dist(hx, hy, fx, fy) end) do
          {_, p} ->
            {hx, hy} = hd(p.segments)
            d = dist(hx, hy, fx, fy)
            if d < 100 && d > 1 do
              {fx + (hx - fx) / d * 3.0, fy + (hy - fy) / d * 3.0, t}
            else f end
        end
      end)
      %{state | food: food}
    end
  end

  defp apply_boost_shrink(state) do
    {players, trail} = Enum.reduce(state.players, {state.players, []}, fn {id, p}, {ps, tr} ->
      if p.alive && p.boosting && length(p.segments) > 8 && !Map.has_key?(p.effects, :speed) do
        if rem(state.tick, 2) == 0 do
          tail = List.last(p.segments)
          {Map.update!(ps, id, &%{&1 | segments: Enum.drop(&1.segments, -1)}),
           [{elem(tail, 0), elem(tail, 1), :normal} | tr]}
        else
          {ps, tr}
        end
      else
        {ps, tr}
      end
    end)
    %{state | players: players, food: state.food ++ trail}
  end

  defp target_food(state) do
    # More players = more food. Time accumulation when fewer players.
    player_count = Enum.count(state.players, fn {_, p} -> p.alive end)
    base = @base_food + player_count * @food_per_player
    # Accumulate bonus food every 200 ticks (10 sec at 50ms)
    time_bonus = min(div(state.tick, 200) * @food_accum_rate, 80)
    min(base + time_bonus, @max_food)
  end

  defp replenish_food(state) do
    needed = target_food(state) - length(state.food)
    if needed > 3, do: seed_food(state, min(needed, 8)), else: state
  end

  defp seed_food(state, count) do
    new = for _ <- 1..count do
      {_rand_pos(state.width), _rand_pos(state.height),
       if(:rand.uniform() < @golden_chance, do: :golden, else: :normal)}
    end
    %{state | food: state.food ++ new}
  end

  defp _rand_pos(max), do: 30.0 + :rand.uniform() * (max - 60.0)

  defp maybe_spawn_powerup(state) do
    if :rand.uniform() < @powerup_chance && length(state.powerups) < 4 do
      x = 80 + :rand.uniform() * (state.width - 160)
      y = 80 + :rand.uniform() * (state.height - 160)
      %{state | powerups: [{x, y, Enum.random(@powerup_types)} | state.powerups]}
    else state end
  end

  defp update_leaderboard(state) do
    board = state.players
      |> Enum.map(fn {id, p} ->
        %{id: id, n: p.name, c: p.color, s: p.score, k: p.kills,
          ts: p.total_score + p.score, al: p.alive, l: length(p.segments)}
      end)
      |> Enum.sort_by(&(-&1.ts))
      |> Enum.take(10)
    %{state | leaderboard: board}
  end

  defp dist(x1, y1, x2, y2) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end

  defp encode_event({:food_eaten, id, type}), do: ["eat", id, if(type == :golden, do: 1, else: 0)]
  defp encode_event({:player_died, id, killer}), do: ["die", id, killer]
  defp encode_event({:player_respawned, id}), do: ["spawn", id]
  defp encode_event({:game_started}), do: ["start"]
  defp encode_event({:powerup_collected, id, type}), do: ["pup", id, pup_idx(type)]
  defp encode_event(_), do: nil
end
