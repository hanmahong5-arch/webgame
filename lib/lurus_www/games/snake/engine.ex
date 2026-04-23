defmodule LurusWww.Games.Snake.Engine do
  @moduledoc """
  Slither.io-style multiplayer snake arena.
  Progression: levels, luck, powerup tiers, respawn invincibility.
  """

  # ── World ────────────────────────────────────────────────
  @width 2400.0
  @height 1600.0

  # ── Snake ────────────────────────────────────────────────
  @seg_radius 6.0
  @seg_spacing 9.0
  @initial_length 10
  @base_speed 5.5
  @max_speed 10.0
  @boost_multiplier 1.8
  @turn_rate 0.15

  # ── Progression ──────────────────────────────────────────
  @food_per_level 15
  @max_level 50
  # Per-level stat increase
  @level_speed_bonus 0.03
  @level_turn_bonus 0.004
  @level_growth_bonus 0.08
  @level_luck_bonus 1

  # ── Eating ───────────────────────────────────────────────
  @eat_radius_mult 5.5
  @magnet_eat_boost 1.5
  @eat_head_segs 3        # head + 2 body segs can eat
  @base_grow 4
  @golden_grow 8
  @food_cap_grow 18

  # ── Respawn safety ───────────────────────────────────────
  @invincible_ticks 50  # ~2.5s at 50ms tick
  @spawn_candidates 12

  # ── Food ─────────────────────────────────────────────────
  @base_food 100
  @food_per_player 15
  @max_food 600  # raised to accommodate death drops
  @base_golden_chance 0.08
  @food_accum_rate 2

  # ── Powerups ─────────────────────────────────────────────
  @powerup_types [:blade, :shield, :magnet, :star, :ghost, :mega, :freeze, :slowmo]
  @powerup_chance 0.020
  @max_powerups 6
  # Tier durations (ticks at 50ms) and effect strength
  @tier_duration %{1 => 160, 2 => 280, 3 => 450}

  # ── Other ────────────────────────────────────────────────
  @max_players 20
  @magnet_range 180
  @magnet_speed 8.5  # Must exceed snake max speed to actually catch food

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
          boosting: false,
          score: 0, alive: false, kills: 0, total_score: 0,
          food_eaten: 0, level: 1,
          effects: %{}, shield_stacks: 0,
          invincible_until: 0,
          combo: 0, combo_until: 0,
          just_leveled: false
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

  @doc "Respawn dead player. Always succeeds even if just died."
  def respawn(state, pid) do
    case Map.get(state.players, pid) do
      nil -> state
      p ->
        reset = %{p |
          alive: true, score: 0, kills: 0, food_eaten: 0, level: 1,
          effects: %{}, shield_stacks: 0, boosting: false,
          combo: 0, combo_until: 0, just_leveled: false
        }
        state
        |> put_in([Access.key(:players), pid], reset)
        |> spawn_player(pid)
        |> Map.update!(:events, &[{:player_respawned, pid} | &1])
    end
  end

  def tick(%{status: :playing} = state) do
    if Enum.any?(state.players, fn {_, p} -> p.alive end) do
      state
      |> Map.put(:events, [])
      |> reset_transient_flags()
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

  # ── Serialization ───────────────────────────────────────

  def to_client(state) do
    %{
      id: state.id,
      size: [state.width, state.height],
      tick: state.tick,
      status: state.status,
      events: state.events |> Enum.map(&encode_event/1) |> Enum.reject(&is_nil/1),
      leaderboard: Enum.take(state.leaderboard, 8),
      players: Map.new(state.players, fn {id, p} ->
        # LOD for long tails
        segs = if length(p.segments) > 30 do
          {head, tail} = Enum.split(p.segments, 8)
          head ++ Enum.take_every(tail, 2)
        else
          p.segments
        end

        {id, %{
          n: p.name, c: p.color, a: r2(p.angle),
          s: Enum.map(segs, fn {x, y} -> [r2(x), r2(y)] end),
          sc: p.score, al: p.alive, k: p.kills,
          ts: p.total_score, b: p.boosting,
          ef: encode_effects(p.effects), sh: p.shield_stacks,
          spd: r2(current_speed(p)),
          lv: p.level, fe: p.food_eaten,
          inv: p.invincible_until > state.tick,
          cmb: p.combo, ul: p.just_leveled
        }}
      end),
      food: Enum.map(state.food, fn {x, y, t} -> [r2(x), r2(y), if(t == :golden, do: 1, else: 0)] end),
      pups: Enum.map(state.powerups, fn {x, y, t, tier} -> [r2(x), r2(y), pup_idx(t), tier] end)
    }
  end

  defp r2(f), do: Float.round(f * 1.0, 1)

  defp encode_effects(effects) do
    Enum.map(effects, fn {type, {ttl, tier}} -> [Atom.to_string(type), tier, ttl] end)
  end

  defp pup_idx(:blade), do: 0
  defp pup_idx(:shield), do: 1
  defp pup_idx(:magnet), do: 2
  defp pup_idx(:star), do: 3
  defp pup_idx(:ghost), do: 4
  defp pup_idx(:mega), do: 5
  defp pup_idx(:freeze), do: 6
  defp pup_idx(:slowmo), do: 7
  defp pup_idx(_), do: 0

  # ── Spawning (safe — far from others) ───────────────────

  defp spawn_player(state, id) do
    other_segments =
      state.players
      |> Enum.filter(fn {pid, p} -> p.alive && pid != id end)
      |> Enum.flat_map(fn {_, p} -> p.segments end)

    # Generate candidates, pick furthest from any alive snake
    candidates = for _ <- 1..@spawn_candidates do
      {200.0 + :rand.uniform() * (state.width - 400.0),
       200.0 + :rand.uniform() * (state.height - 400.0)}
    end

    {x, y} =
      if other_segments == [] do
        hd(candidates)
      else
        Enum.max_by(candidates, fn {cx, cy} ->
          other_segments
          |> Enum.map(fn {ox, oy} -> dist(cx, cy, ox, oy) end)
          |> Enum.min()
        end)
      end

    angle = :rand.uniform() * :math.pi() * 2

    segments = for i <- 0..(@initial_length - 1) do
      {x - :math.cos(angle) * i * @seg_spacing,
       y - :math.sin(angle) * i * @seg_spacing}
    end

    %{state | players: Map.update!(state.players, id, fn p ->
      %{p |
        segments: segments, angle: angle, target_angle: angle, alive: true,
        invincible_until: state.tick + @invincible_ticks
      }
    end)}
  end

  # ── Level / luck ────────────────────────────────────────

  defp level_of(food_eaten) do
    min(@max_level, 1 + div(food_eaten, @food_per_level))
  end

  defp luck_of(level), do: level * @level_luck_bonus

  defp current_speed(p) do
    level_bonus = (p.level - 1) * @level_speed_bonus
    base = min(@max_speed, @base_speed + level_bonus)
    base = if Map.has_key?(p.effects, :star), do: base * 1.1, else: base
    # Frozen = no move
    cond do
      Map.has_key?(p.effects, :freeze) -> 0.0
      Map.has_key?(p.effects, :slowmo_target) -> base * 0.4
      p.boosting && length(p.segments) > 5 -> base * @boost_multiplier
      true -> base
    end
  end

  defp turn_rate(p) do
    @turn_rate + (p.level - 1) * @level_turn_bonus
  end

  defp grow_amount(p, type) do
    base = if type == :golden, do: @golden_grow, else: @base_grow
    level_bonus = (p.level - 1) * @level_growth_bonus
    min(@food_cap_grow, round(base + level_bonus))
  end

  # ── Tick pipeline ───────────────────────────────────────

  defp reset_transient_flags(state) do
    players = Map.new(state.players, fn {id, p} ->
      {id, %{p | just_leveled: false}}
    end)
    %{state | players: players}
  end

  defp tick_effects(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive do
        # effects: %{type => {ttl, tier}}
        effects =
          p.effects
          |> Enum.map(fn {t, {ttl, tier}} -> {t, {ttl - 1, tier}} end)
          |> Enum.filter(fn {_, {ttl, _}} -> ttl > 0 end)
          |> Map.new()

        # Combo decay
        combo = if p.combo_until > state.tick, do: p.combo, else: 0

        {id, %{p | effects: effects, combo: combo}}
      else
        {id, p}
      end
    end)
    %{state | players: players}
  end

  defp steer_and_move(state) do
    players = Map.new(state.players, fn {id, p} ->
      if p.alive && p.segments != [] do
        rate = turn_rate(p)
        angle = steer(p.angle, p.target_angle, rate)
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

  # Extend tail with real spaced points in the tail's outward direction.
  # Using List.duplicate would place points at d=0, which resample/3 immediately
  # collapses — growth must use proper spacing to persist permanently.
  defp extend_tail([], _, _), do: []
  defp extend_tail([{x, y}], count, spacing) do
    for i <- 1..count, do: {x, y + spacing * i}
  end
  defp extend_tail(segments, count, spacing) do
    [{lx, ly}, {sx, sy} | _] = Enum.reverse(segments)
    dx = lx - sx
    dy = ly - sy
    d = :math.sqrt(dx * dx + dy * dy)
    {ux, uy} = if d > 0.01, do: {dx / d, dy / d}, else: {0.0, 1.0}
    for i <- 1..count, do: {lx + ux * spacing * i, ly + uy * spacing * i}
  end

  defp resample(points, spacing, count) do
    do_resample(points, spacing, count - 1, [hd(points)])
  end
  defp do_resample(_, _, 0, acc), do: Enum.reverse(acc)
  defp do_resample([_], _, _, acc), do: Enum.reverse(acc)
  defp do_resample([_a, b | rest], spacing, rem_count, acc) do
    {lx, ly} = hd(acc)
    {bx, by} = b
    d = dist(lx, ly, bx, by)
    if d >= spacing do
      ratio = spacing / max(d, 0.001)
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
      # Invincibility + ghost effect
      invincible = p.invincible_until > state.tick || Map.has_key?(p.effects, :ghost)
      if invincible do
        acc
      else
        {hx, hy} = hd(p.segments)
        wall = hx < 0 || hx > state.width || hy < 0 || hy > state.height

        other_killer = Enum.find_value(alive, fn {oid, op} ->
          if oid != id && op.invincible_until <= state.tick do
            hit = op.segments |> Enum.drop(3) |> Enum.any?(fn {sx, sy} -> dist(hx, hy, sx, sy) < hit_r end)
            if hit, do: oid
          end
        end)

        if wall || other_killer do
          cond do
            p.shield_stacks > 0 -> acc  # shield consumed below
            true -> Map.put(acc, id, other_killer)
          end
        else
          acc
        end
      end
    end)

    # Consume one shield stack on hit
    players = Enum.reduce(alive, state.players, fn {id, p}, ps ->
      if Map.has_key?(deaths, id) || p.shield_stacks == 0 do
        ps
      else
        {hx, hy} = hd(p.segments)
        wall = hx < 0 || hx > state.width || hy < 0 || hy > state.height
        other = Enum.any?(alive, fn {oid, op} ->
          oid != id && Enum.any?(Enum.drop(op.segments, 3), fn {sx, sy} -> dist(hx, hy, sx, sy) < hit_r end)
        end)
        if wall || other do
          # Consume shield, grant brief invincibility
          Map.update!(ps, id, fn pl ->
            %{pl |
              shield_stacks: pl.shield_stacks - 1,
              invincible_until: state.tick + 20
            }
          end)
        else
          ps
        end
      end
    end)

    # Apply deaths — drop body as food trail (every 2nd segment, scales with level)
    {players, events, food} =
      Enum.reduce(deaths, {players, state.events, state.food}, fn {id, killer}, {ps, evts, fd} ->
        dead = ps[id]
        # Higher level = more golden drops. Cap at 150 items for broadcast sanity.
        golden_chance = 0.20 + dead.level * 0.01
        body_food =
          dead.segments
          |> Enum.take_every(2)
          |> Enum.take(150)
          |> Enum.map(fn {x, y} ->
            {x, y, if(:rand.uniform() < golden_chance, do: :golden, else: :normal)}
          end)

        ps = Map.update!(ps, id, &%{&1 | alive: false, total_score: &1.total_score + &1.score})
        ps = if killer && !Map.has_key?(deaths, killer) do
          # Bonus for big kill: scales with victim length too
          kill_bonus = 10 + dead.level + div(length(dead.segments), 4)
          Map.update!(ps, killer, fn kp ->
            %{kp | kills: kp.kills + 1, score: kp.score + kill_bonus}
          end)
        else ps end
        {ps, [{:player_died, id, killer} | evts], fd ++ body_food}
      end)

    %{state | players: players, events: events, food: food}
  end

  defp collect_food(state) do
    alive = Enum.filter(state.players, fn {_, p} -> p.alive end)

    {players, food, events} =
      Enum.reduce(alive, {state.players, state.food, []}, fn {id, p}, {ps, fd, ev} ->
        # Magnet expands eat radius; head + first N segments all eat
        base_r = @seg_radius * @eat_radius_mult
        eat_r = if Map.has_key?(p.effects, :magnet), do: base_r * @magnet_eat_boost, else: base_r
        star_mult = if Map.has_key?(p.effects, :star), do: 3, else: 1
        check_segs = Enum.take(p.segments, @eat_head_segs)

        {eaten, kept} = Enum.split_with(fd, fn {fx, fy, _} ->
          Enum.any?(check_segs, fn {sx, sy} -> dist(sx, sy, fx, fy) < eat_r end)
        end)

        if eaten == [] do
          {ps, fd, ev}
        else
          # Score with combo multiplier
          raw_pts = Enum.reduce(eaten, 0, fn {_, _, t}, a -> a + if(t == :golden, do: 5, else: 1) end)
          combo_new = p.combo + length(eaten)
          combo_mult = 1.0 + min(combo_new * 0.05, 0.5)  # up to 1.5x
          pts = round(raw_pts * star_mult * combo_mult)

          # Growth
          grow = Enum.reduce(eaten, 0, fn {_, _, t}, a -> a + grow_amount(p, t) end)

          new_food_eaten = p.food_eaten + length(eaten)
          new_level = level_of(new_food_eaten)
          leveled_up = new_level > p.level

          ps = Map.update!(ps, id, fn pl ->
            %{pl |
              score: pl.score + pts,
              food_eaten: new_food_eaten,
              level: new_level,
              segments: pl.segments ++ extend_tail(pl.segments, grow, @seg_spacing),
              combo: combo_new,
              combo_until: state.tick + 50,
              just_leveled: leveled_up
            }
          end)

          ev2 = if leveled_up, do: [{:level_up, id, new_level} | ev], else: ev
          ev3 = [{:food_eaten, id, if(raw_pts > 3, do: :golden, else: :normal)} | ev2]
          {ps, kept, ev3}
        end
      end)

    %{state | players: players, food: food, events: state.events ++ events}
  end

  defp collect_powerups(state) do
    alive = Enum.filter(state.players, fn {_, p} -> p.alive end)
    r = @seg_radius * 5

    {players, pups, events} =
      Enum.reduce(alive, {state.players, state.powerups, []}, fn {id, p}, {ps, pps, ev} ->
        {hx, hy} = hd(p.segments)
        case Enum.find_index(pps, fn {px, py, _, _} -> dist(hx, hy, px, py) < r end) do
          nil -> {ps, pps, ev}
          idx ->
            {_, _, type, tier} = Enum.at(pps, idx)
            {apply_pup(ps, state, id, type, tier), List.delete_at(pps, idx),
             [{:powerup_collected, id, type, tier} | ev]}
        end
      end)

    %{state | players: players, powerups: pups, events: state.events ++ events}
  end

  defp apply_pup(ps, _state, id, :shield, tier) do
    Map.update!(ps, id, fn p -> %{p | shield_stacks: min(3, p.shield_stacks + tier)} end)
  end

  defp apply_pup(ps, _state, id, :freeze, tier) do
    # Freeze all OTHER alive players for the duration
    freezer_id = id
    dur = @tier_duration[tier]
    Map.new(ps, fn {pid, p} ->
      if pid == freezer_id || !p.alive do
        {pid, p}
      else
        {pid, %{p | effects: Map.put(p.effects, :freeze, {dur, tier})}}
      end
    end)
  end

  defp apply_pup(ps, _state, id, :slowmo, tier) do
    slower_id = id
    dur = @tier_duration[tier]
    Map.new(ps, fn {pid, p} ->
      if pid == slower_id || !p.alive do
        {pid, p}
      else
        {pid, %{p | effects: Map.put(p.effects, :slowmo_target, {dur, tier})}}
      end
    end)
  end

  defp apply_pup(ps, _state, id, type, tier) do
    # Generic: add effect with tier-based duration
    dur = @tier_duration[tier]
    Map.update!(ps, id, fn p -> %{p | effects: Map.put(p.effects, type, {dur, tier})} end)
  end

  defp apply_magnet(state) do
    magnets = state.players |> Enum.filter(fn {_, p} -> p.alive && Map.has_key?(p.effects, :magnet) end)
    if magnets == [] do
      state
    else
      food = Enum.map(state.food, fn {fx, fy, t} = f ->
        case Enum.min_by(magnets, fn {_, p} -> {hx, hy} = hd(p.segments); dist(hx, hy, fx, fy) end) do
          {_, p} ->
            {_, {_, tier}} = {:magnet, p.effects[:magnet]}
            range = @magnet_range * (0.7 + tier * 0.3)
            speed = @magnet_speed * (0.7 + tier * 0.3)
            {hx, hy} = hd(p.segments)
            d = dist(hx, hy, fx, fy)
            if d < range && d > 1 do
              {fx + (hx - fx) / d * speed, fy + (hy - fy) / d * speed, t}
            else
              f
            end
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
    player_count = Enum.count(state.players, fn {_, p} -> p.alive end)
    base = @base_food + player_count * @food_per_player
    time_bonus = min(div(state.tick, 200) * @food_accum_rate, 120)
    min(base + time_bonus, @max_food)
  end

  defp replenish_food(state) do
    needed = target_food(state) - length(state.food)
    if needed > 3, do: seed_food(state, min(needed, 10)), else: state
  end

  defp seed_food(state, count) do
    # Higher aggregate luck → more golden
    avg_luck = case Enum.filter(state.players, fn {_, p} -> p.alive end) do
      [] -> 0
      ps -> Enum.sum(Enum.map(ps, fn {_, p} -> luck_of(p.level) end)) / length(ps)
    end
    golden_chance = min(0.25, @base_golden_chance + avg_luck * 0.002)

    new = for _ <- 1..count do
      {30.0 + :rand.uniform() * (state.width - 60.0),
       30.0 + :rand.uniform() * (state.height - 60.0),
       if(:rand.uniform() < golden_chance, do: :golden, else: :normal)}
    end
    %{state | food: state.food ++ new}
  end

  defp maybe_spawn_powerup(state) do
    if :rand.uniform() < @powerup_chance && length(state.powerups) < @max_powerups do
      x = 100 + :rand.uniform() * (state.width - 200)
      y = 100 + :rand.uniform() * (state.height - 200)
      type = Enum.random(@powerup_types)
      # Tier distribution influenced by avg player luck
      avg_luck = case Enum.filter(state.players, fn {_, p} -> p.alive end) do
        [] -> 0
        ps -> Enum.sum(Enum.map(ps, fn {_, p} -> luck_of(p.level) end)) / length(ps)
      end
      tier = roll_tier(avg_luck)
      %{state | powerups: [{x, y, type, tier} | state.powerups]}
    else
      state
    end
  end

  defp roll_tier(luck) do
    r = :rand.uniform()
    # Base: 60% t1, 30% t2, 10% t3. Each luck point shifts ~0.3% t1→t3
    shift = min(0.30, luck * 0.003)
    t3_threshold = 0.10 + shift
    t2_threshold = 0.40 + shift / 2
    cond do
      r < t3_threshold -> 3
      r < t2_threshold -> 2
      true -> 1
    end
  end

  defp update_leaderboard(state) do
    board = state.players
      |> Enum.map(fn {id, p} ->
        %{id: id, n: p.name, c: p.color,
          s: p.score, k: p.kills,
          ts: p.total_score + p.score, al: p.alive,
          l: length(p.segments), lv: p.level}
      end)
      |> Enum.sort_by(&(-&1.ts))
      |> Enum.take(10)
    %{state | leaderboard: board}
  end

  # ── Helpers ─────────────────────────────────────────────

  defp dist(x1, y1, x2, y2) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end

  defp encode_event({:food_eaten, id, type}), do: ["eat", id, if(type == :golden, do: 1, else: 0)]
  defp encode_event({:player_died, id, killer}), do: ["die", id, killer]
  defp encode_event({:player_respawned, id}), do: ["spawn", id]
  defp encode_event({:game_started}), do: ["start"]
  defp encode_event({:powerup_collected, id, type, tier}), do: ["pup", id, pup_idx(type), tier]
  defp encode_event({:level_up, id, lv}), do: ["lv", id, lv]
  defp encode_event(_), do: nil
end
