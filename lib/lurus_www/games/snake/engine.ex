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
  @base_grow 1
  @golden_grow 2
  @food_cap_grow 4

  # ── Girth ────────────────────────────────────────────────
  # Snakes get visually thicker as they level up (smooth, monotonic).
  # No length truncation — the old fatten-and-truncate mechanic caused
  # a freeze-feeling jolt that broke gameplay flow.
  @max_girth 3.0

  # Self-collision is intentionally disabled — see detect_collisions/1.
  # Slither-style snakes overlap themselves constantly through tight turns
  # and magnet-pull, so killing on self-overlap is too punishing.

  # ── Respawn safety ───────────────────────────────────────
  @invincible_ticks 80  # ~4s at 50ms tick
  @spawn_candidates 12

  # ── Food ─────────────────────────────────────────────────
  @base_food 100
  @food_per_player 15
  @max_food 600  # raised to accommodate death drops
  @base_golden_chance 0.08
  @food_accum_rate 2

  # ── Killstreak ───────────────────────────────────────────
  # Every kill within @streak_window ticks of the last extends the streak.
  # Score multiplier scales up to 2x at streak=5.
  @streak_window 240  # ~12s
  @streak_cap 10

  # ── Food Rain (chaos event) ─────────────────────────────
  # Every @rain_interval ticks (±25%), spawn a burst of food across arena.
  @rain_interval 700
  @rain_burst 80

  # ── Powerups ─────────────────────────────────────────────
  # Pool is 6 self-buffs only. Freeze/slowmo were removed because they
  # disrupted other players' flow ("snake suddenly stops moving") with no
  # warning, which felt like a bug rather than a counter-play opportunity.
  @powerup_types [:blade, :shield, :magnet, :star, :ghost, :mega]
  @powerup_chance 0.020
  @max_powerups 6
  # Tier durations (ticks at 50ms) and effect strength
  @tier_duration %{1 => 160, 2 => 280, 3 => 450}

  # ── Other ────────────────────────────────────────────────
  @max_players 20
  @magnet_range 180
  @magnet_speed 8.5  # Must exceed snake max speed to actually catch food

  # ── Reconnect / idle ─────────────────────────────────────
  # Player slot kept this many ticks after last action; abandoned then.
  @idle_player_ticks 1200  # ~60s

  # ── Bots ─────────────────────────────────────────────────
  @bot_names ~w(Cobra Viper Mamba Anaconda Python Boa Asp Krait Sidewinder Adder)
  @bot_min_humans 1     # only fill bots when at least 1 human is around
  @bot_target_total 3   # bots top up the room to this total (humans + bots)
  @bot_max 4            # never more than this many bots in a room
  @bot_wall_margin 160
  @bot_avoid_radius 90
  @bot_respawn_delay 60  # ticks dead before respawn (~3s)

  # ── Length cap ──────────────────────────────────────────
  # Hard segment limit. Past this, eating awards score only — no further growth.
  # Caps the O(N) cost of resample/extend/serialize that drove 4000+ score lag,
  # and pushes long snakes to spend tail in the gacha (below) for prizes.
  @max_segments 200

  # ── Gacha ───────────────────────────────────────────────
  # Spend a chunk of tail + score to roll a randomized buff or equipment.
  # The seg cost doubles as a player-driven length cap. Smaller snakes can
  # also play once they cross @gacha_min_length, so it's not just a long-snake
  # mechanic.
  @gacha_min_length 40
  @gacha_min_score 100
  @gacha_seg_cost 25
  @gacha_score_cost 100

  # Prize pool: {kind, sub, tier, ttl_ticks, weight}. `:effect` adds a buff to
  # player.effects; `:shield_inc` bumps shield_stacks directly. Long-ttl effects
  # (99999 ≈ 83 minutes of game time) are effectively permanent equipment.
  @gacha_prizes [
    # Common (50%)
    {:effect, :magnet, 2, 600, 18},
    {:shield_inc, nil, 1, 0, 13},
    {:effect, :star, 1, 400, 10},
    {:effect, :ghost, 1, 400, 9},

    # Rare (35%) — combat tilt; armor_pierce is the small-snake counter to
    # heavily-armored long snakes (lasers ignore armor for 10s).
    {:effect, :armor_pierce, 1, 200, 12},
    {:effect, :blade, 3, 800, 8},
    {:effect, :mega, 3, 600, 7},

    # Epic (12%) — round-permanent equipment
    {:effect, :thorn_tail, 1, 99_999, 7},
    {:effect, :laser_charged, 1, 99_999, 5},

    # Legendary (3%)
    {:effect, :star, 3, 1500, 3}
  ]
  @gacha_weight_total 92

  # Thorn-tail revenge: if a thorn-equipped player dies to a killer, the
  # killer also loses this many tail segments. Lets small snakes punish
  # head-bash deaths without needing big bodies of their own.
  @thorn_revenge_segs 30

  # ── Armored / severable body zones ──────────────────────
  # Snakes have two body regions:
  #   * Armored (head-side): immune to laser sever — counter-play requires
  #     hitting the tail.
  #   * Severable (tail-side): lasers cut everything from hit point onward
  #     into food.
  # Armored count grows with level so progression has an evolutionary axis:
  # higher level = harder to cut down. New players are vulnerable; veterans
  # become long but with diminishing severable tails.
  @armor_base 6
  @armor_per_level 3

  # ── Laser Eye / Tail-Sever ───────────────────────────────
  # Press V / right-click / mobile laser button to fire a short forward beam.
  # Hits the closest other-snake segment in front and severs everything past it.
  # Severed segments scatter as food. Killer doesn't kill victim — just trims them.
  @laser_range 180.0      # px straight ahead of head
  @laser_radius 12.0      # collision tolerance perpendicular to beam
  @laser_charge_ticks 4    # ~200ms warning so victim can dodge
  @laser_cooldown 160      # ~8s between fires
  @laser_self_cost 6       # segments lost from attacker's own tail per fire
  @laser_min_segs 12       # cannot fire if length < this
  @laser_min_victim_len 6  # cannot sever if victim shorter than this

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
    leaderboard: [],
    rain_until: 0,
    next_rain_at: 0
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
          just_leveled: false,
          girth: 1.0,
          streak: 0, streak_until: 0,
          last_seen: state.tick,
          is_bot: false,
          dead_at: 0,
          laser_charge_until: 0,
          laser_fire_at: 0,
          laser_cd_until: 0
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

  @doc "Reconnect: same id rejoins. Updates name + refreshes last_seen, keeps everything else."
  def resume_player(state, id, name) do
    case Map.get(state.players, id) do
      nil -> {:error, :not_found}
      _p ->
        state = update_in(state.players[id], fn p ->
          %{p | name: name, last_seen: state.tick}
        end)
        {:ok, state}
    end
  end

  @doc "Refresh last_seen so player isn't culled. Safe no-op if player gone."
  def touch_player(state, id) do
    case Map.get(state.players, id) do
      nil -> state
      _p -> update_in(state.players[id], fn p -> %{p | last_seen: state.tick} end)
    end
  end

  @doc "Spawn a bot with auto-generated id/name. Always succeeds unless room full."
  def add_bot(state) do
    if map_size(state.players) >= @max_players do
      {:error, :room_full}
    else
      id = "bot_" <> Base.encode16(:crypto.strong_rand_bytes(4), case: :lower)
      taken_names = state.players |> Map.values() |> Enum.map(& &1.name) |> MapSet.new()
      name_base = Enum.random(@bot_names)
      name = if MapSet.member?(taken_names, name_base), do: "#{name_base}#{:rand.uniform(99)}", else: name_base
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
        just_leveled: false,
        girth: 1.0,
        streak: 0, streak_until: 0,
        last_seen: state.tick,
        is_bot: true,
        dead_at: 0,
        laser_charge_until: 0,
        laser_fire_at: 0,
        laser_cd_until: 0
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

      {:ok, spawn_player(state, id), id}
    end
  end

  def bot_count(state),
    do: state.players |> Map.values() |> Enum.count(& &1.is_bot)

  def human_count(state),
    do: state.players |> Map.values() |> Enum.count(&(!&1.is_bot))

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
      %{alive: true} = p ->
        %{state | players: Map.put(state.players, id, %{p | target_angle: angle * 1.0, last_seen: state.tick})}
      _ -> state
    end
  end
  def set_target(state, _, _), do: state

  def set_boost(state, id, boosting) when is_boolean(boosting) do
    case Map.get(state.players, id) do
      nil -> state
      p -> %{state | players: Map.put(state.players, id, %{p | boosting: boosting, last_seen: state.tick})}
    end
  end
  def set_boost(state, _, _), do: state

  @doc """
  Begin a laser charge. After @laser_charge_ticks the beam fires automatically
  in `process_lasers/1`. No-op if on cooldown, dead, too short, or already
  charging.
  """
  def trigger_laser(state, id) do
    case Map.get(state.players, id) do
      %{alive: true} = p ->
        cond do
          p.laser_cd_until > state.tick -> state
          p.laser_charge_until > state.tick -> state
          length(p.segments) < @laser_min_segs -> state
          true ->
            charge_until = state.tick + @laser_charge_ticks
            updated = %{p | laser_charge_until: charge_until, last_seen: state.tick}
            state
            |> put_in([Access.key(:players), id], updated)
            |> Map.update!(:events, &[{:laser_charge, id, p.angle} | &1])
        end
      _ -> state
    end
  end

  @doc """
  Roll the gacha for `id`. Costs @gacha_seg_cost tail segs + @gacha_score_cost
  score. Returns `{state, applied?}` so the caller can skip broadcasts +
  telemetry when the roll was a no-op (length/score gate / dead). Emits a
  :gacha_result event on success so the client plays the wheel animation.
  """
  def trigger_gacha(state, id) do
    case Map.get(state.players, id) do
      %{alive: true} = p ->
        cond do
          p.score < @gacha_min_score -> {state, false}
          length(p.segments) < @gacha_min_length -> {state, false}
          true -> {do_gacha(state, id, p), true}
        end

      _ ->
        {state, false}
    end
  end

  defp do_gacha(state, id, p) do
    seg_count = length(p.segments)
    kept = max(@laser_min_victim_len, seg_count - @gacha_seg_cost)
    new_segs = Enum.take(p.segments, kept)
    prize = roll_gacha_prize()

    state
    |> put_in([Access.key(:players), id, Access.key(:segments)], new_segs)
    |> update_in([Access.key(:players), id, Access.key(:score)], &max(0, &1 - @gacha_score_cost))
    |> apply_gacha_prize(id, prize)
    |> Map.update!(:events, &[{:gacha_result, id, prize_meta(prize)} | &1])
  end

  defp roll_gacha_prize do
    r = :rand.uniform(@gacha_weight_total)
    pick_weighted(@gacha_prizes, r)
  end

  defp pick_weighted([prize], _r), do: prize
  defp pick_weighted([prize | rest], r) do
    {_, _, _, _, w} = prize
    if r <= w, do: prize, else: pick_weighted(rest, r - w)
  end

  defp apply_gacha_prize(state, id, {:shield_inc, _, n, _, _}) do
    update_in(state.players[id], fn p ->
      %{p | shield_stacks: min(5, p.shield_stacks + n)}
    end)
  end
  # Tier-aware merge. Rolling a lower-tier copy of an active effect must not
  # downgrade it (legendary star T3 → common T1 felt punishing). Same-or-higher
  # tier wins, ttl always extends to the longer of the two.
  defp apply_gacha_prize(state, id, {:effect, type, tier, ttl, _}) do
    update_in(state.players[id], fn p ->
      merged =
        case Map.get(p.effects, type) do
          {old_ttl, old_tier} when old_tier > tier ->
            {max(old_ttl, ttl), old_tier}
          {old_ttl, _old_tier} ->
            {max(old_ttl, ttl), tier}
          nil ->
            {ttl, tier}
        end
      %{p | effects: Map.put(p.effects, type, merged)}
    end)
  end

  defp prize_meta({:shield_inc, _, n, _, _}), do: ["shield", n, 0]
  defp prize_meta({:effect, type, tier, ttl, _}), do: [Atom.to_string(type), tier, ttl]

  @doc "Respawn dead player. Always succeeds even if just died."
  def respawn(state, pid) do
    case Map.get(state.players, pid) do
      nil -> state
      p ->
        reset = %{p |
          alive: true, score: 0, kills: 0, food_eaten: 0, level: 1,
          effects: %{}, shield_stacks: 0, boosting: false,
          combo: 0, combo_until: 0, just_leveled: false,
          girth: 1.0,
          streak: 0, streak_until: 0,
          last_seen: state.tick, dead_at: 0,
          laser_charge_until: 0, laser_fire_at: 0, laser_cd_until: 0
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
      |> tick_bots()
      |> steer_and_move()
      |> detect_collisions()
      |> process_lasers()
      |> collect_food()
      |> collect_powerups()
      |> apply_magnet()
      |> replenish_food()
      |> maybe_spawn_powerup()
      |> respawn_dead_bots()
      |> cull_idle_players()
      |> update_leaderboard()
    else
      state
    end
  end
  def tick(state), do: state

  def player_count(state), do: map_size(state.players)

  # ── Serialization ───────────────────────────────────────

  # View radius around the observer's head — anything farther is "off-screen".
  # 900px is ~1.5 screen widths so the player has buffer on snake/food entering
  # the visible area before transition. Larger than viewport reduces pop-in;
  # smaller saves more bandwidth/CPU. Tuned empirically.
  @view_radius 900.0

  @doc """
  Pre-compute the per-broadcast pieces that are identical across all observers
  (encoded event list + per-snake LOD). Caller (game_server.broadcast_game)
  passes the result into each `to_client/3` call to avoid N×rework when a
  busy room has many human observers.
  """
  def precompute_shared(state) do
    %{
      encoded_events: state.events |> Enum.map(&encode_event/1) |> Enum.reject(&is_nil/1),
      lod_cache: Map.new(state.players, fn {id, p} -> {id, lod_segments_and_armor(p)} end)
    }
  end

  @doc """
  Build a client snapshot. When `observer_id` is set, segments + food are
  viewport-culled around the observer's head:
    * own snake: full LOD as always
    * other snakes within view: full LOD
    * other snakes off-view: head segment only (so minimap + name still work)
    * food: only items within (view_radius + 250) of observer
  When `observer_id` is nil (e.g. tests, get_state RPC), no culling — full state.
  Pass `shared` (from `precompute_shared/1`) to skip duplicate event encoding +
  per-snake LOD downsampling across observer iterations.
  """
  def to_client(state, observer_id \\ nil, shared \\ nil) do
    observer = if observer_id, do: Map.get(state.players, observer_id), else: nil
    {ox, oy} = observer_center(observer, state)
    cull? = observer != nil
    view_r2 = @view_radius * @view_radius
    food_r2 = (@view_radius + 250.0) * (@view_radius + 250.0)

    encoded_events =
      case shared do
        %{encoded_events: e} -> e
        _ -> state.events |> Enum.map(&encode_event/1) |> Enum.reject(&is_nil/1)
      end
    lod_cache = shared && shared[:lod_cache]

    %{
      id: state.id,
      size: [state.width, state.height],
      tick: state.tick,
      status: state.status,
      events: encoded_events,
      leaderboard: Enum.take(state.leaderboard, 8),
      rain: state.rain_until > state.tick,
      players: Map.new(state.players, fn {id, p} ->
        in_view = !cull? || id == observer_id || snake_in_view?(p, ox, oy, view_r2)

        # LOD for long tails — keep head precise, sample tail more sparsely.
        # Off-view snakes downgrade to a single head segment so minimap and
        # leaderboard still render but body painting is skipped client-side.
        {segs, armor_lod_idx} =
          if in_view do
            (lod_cache && Map.get(lod_cache, id)) || lod_segments_and_armor(p)
          else
            case p.segments do
              [head | _] -> {[head], 0}
              [] -> {[], 0}
            end
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
          cmb: p.combo, ul: p.just_leveled,
          g: r2(p.girth),
          st: if(p.streak_until > state.tick, do: p.streak, else: 0),
          bot: p.is_bot,
          # Laser state — for charge ring telegraph + cooldown HUD on client.
          # lc: ticks remaining of charge (0 = not charging)
          # lcd: ticks remaining of cooldown (0 = ready)
          lc: max(0, p.laser_charge_until - state.tick),
          lcd: max(0, p.laser_cd_until - state.tick),
          # Armored boundary in the LOD'd `s` array — segments at index < ar
          # render as protected (full alpha + outline), >= ar as severable
          # (dim, narrower stroke).
          ar: armor_lod_idx,
          # Off-view marker — client skips body/head paint to save GPU.
          oof: !in_view
        }}
      end),
      food: encode_food(state.food, ox, oy, food_r2, cull?),
      pups: Enum.map(state.powerups, fn {x, y, t, tier} -> [r2(x), r2(y), pup_idx(t), tier] end)
    }
  end

  defp observer_center(%{segments: [{x, y} | _]}, _state), do: {x, y}
  defp observer_center(_, state), do: {state.width / 2, state.height / 2}

  defp snake_in_view?(%{segments: [{hx, hy} | _]}, ox, oy, r2) do
    dx = hx - ox
    dy = hy - oy
    dx * dx + dy * dy < r2
  end
  defp snake_in_view?(_, _, _, _), do: false

  defp encode_food(food, _ox, _oy, _r2, false) do
    Enum.map(food, fn {x, y, t} -> [r2(x), r2(y), if(t == :golden, do: 1, else: 0)] end)
  end
  defp encode_food(food, ox, oy, radius2, true) do
    Enum.reduce(food, [], fn {x, y, t}, acc ->
      dx = x - ox
      dy = y - oy
      if dx * dx + dy * dy < radius2 do
        [[r2(x), r2(y), if(t == :golden, do: 1, else: 0)] | acc]
      else
        acc
      end
    end)
  end

  defp r2(f), do: Float.round(f * 1.0, 1)

  # LOD downsample + armor index in one pass. The armor index in the LOD'd
  # array can differ from the original (we reduce the count of body segs in
  # the tail, so a fixed boundary count maps to a smaller LOD index).
  defp lod_segments_and_armor(p) do
    full = p.segments
    full_len = length(full)
    armor = armored_count(p)

    cond do
      full_len > 150 -> downsample_with_armor(full, 12, 4, armor)
      full_len > 80  -> downsample_with_armor(full, 10, 3, armor)
      full_len > 30  -> downsample_with_armor(full, 8, 2, armor)
      true           -> {full, armor}
    end
  end

  defp downsample_with_armor(segs, head_size, step, armor_full) do
    {head, tail} = Enum.split(segs, head_size)
    sampled = head ++ Enum.take_every(tail, step)

    armor_lod =
      cond do
        armor_full <= head_size -> armor_full
        true -> head_size + div(armor_full - head_size, step)
      end

    {sampled, min(armor_lod, length(sampled))}
  end

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
    # Kill Cascade Aura: streak >= 3 grants +10% speed (synergy with existing streak system)
    base = if p.streak >= 3, do: base * 1.10, else: base
    # Frozen = no move
    cond do
      Map.has_key?(p.effects, :freeze) -> 0.0
      Map.has_key?(p.effects, :slowmo_target) -> base * 0.4
      p.boosting && length(p.segments) >= 3 -> base * @boost_multiplier
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
        # Streak decay — reset when window expires
        {streak, streak_until} =
          if p.streak_until >= state.tick, do: {p.streak, p.streak_until}, else: {0, 0}

        {id, %{p | effects: effects, combo: combo, streak: streak, streak_until: streak_until}}
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

  # Drop tail segments past @max_segments. Once the cap binds, growth halts
  # and the player must spend tail (gacha) to keep level-scaling effects.
  defp cap_segments(segs) do
    if length(segs) > @max_segments, do: Enum.take(segs, @max_segments), else: segs
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
            hit_r = @seg_radius * 2.2 * op.girth
            hit = op.segments |> Enum.drop(3) |> Enum.any?(fn {sx, sy} -> dist(hx, hy, sx, sy) < hit_r end)
            if hit, do: oid
          end
        end)

        # Self-collision is disabled — bumping into your own tail no longer kills.
        # Friendly UX: with magnet/boost, near-self-overlap is too easy to trigger.
        if wall || other_killer do
          if p.shield_stacks > 0 do
            acc  # shield absorbs, consumed below
          else
            Map.put(acc, id, other_killer)
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
          oid != id && Enum.any?(Enum.drop(op.segments, 3), fn {sx, sy} -> dist(hx, hy, sx, sy) < @seg_radius * 2.2 * op.girth end)
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

    # Apply deaths — drop ALL body segments as food (cap 300 for broadcast sanity).
    # Higher level + higher girth = more golden drops.
    {players, events, food} =
      Enum.reduce(deaths, {players, state.events, state.food}, fn {id, killer}, {ps, evts, fd} ->
        dead = ps[id]
        golden_chance = min(0.45, 0.15 + dead.level * 0.01 + (dead.girth - 1.0) * 0.08)
        body_food =
          dead.segments
          |> Enum.take(300)
          |> Enum.map(fn {x, y} ->
            {x, y, if(:rand.uniform() < golden_chance, do: :golden, else: :normal)}
          end)

        ps = Map.update!(ps, id, &%{&1 |
          alive: false,
          total_score: &1.total_score + &1.score,
          streak: 0,
          streak_until: 0,
          dead_at: state.tick
        })

        {ps, evts} =
          if killer && killer != id && !Map.has_key?(deaths, killer) do
            kp = ps[killer]
            streak_active? = kp.streak_until >= state.tick
            new_streak = if streak_active?, do: min(@streak_cap, kp.streak + 1), else: 1
            # Multiplier: 1.0x at streak=1, scales to 2.0x at streak=5, caps at 2.5x at streak=10
            mult = 1.0 + min(new_streak - 1, 9) * 0.15
            base_bonus = 15 + dead.level * 2 + div(length(dead.segments), 3) + round((dead.girth - 1.0) * 20)
            kill_bonus = round(base_bonus * mult)
            ps2 = Map.update!(ps, killer, fn kp2 ->
              %{kp2 |
                kills: kp2.kills + 1,
                score: kp2.score + kill_bonus,
                streak: new_streak,
                streak_until: state.tick + @streak_window
              }
            end)

            # Thorn-tail revenge: if the victim was thorn-equipped, the killer
            # also loses tail. Doesn't kill them (they'd just lose their score
            # streak too) but heavily discourages careless head-bashing.
            {ps3, evts2} =
              if Map.has_key?(dead.effects, :thorn_tail) do
                kp3 = ps2[killer]
                k_len = length(kp3.segments)
                cut = min(@thorn_revenge_segs, max(0, k_len - @laser_min_victim_len))
                if cut > 0 do
                  ps3 = Map.update!(ps2, killer, fn kp4 ->
                    %{kp4 | segments: Enum.take(kp4.segments, k_len - cut)}
                  end)
                  {ps3, [{:thorn_revenge, id, killer, cut} | evts]}
                else
                  {ps2, evts}
                end
              else
                {ps2, evts}
              end

            evts3 = if new_streak >= 3, do: [{:streak, killer, new_streak} | evts2], else: evts2
            {ps3, evts3}
          else
            {ps, evts}
          end
        killer_name = if killer && killer != id, do: ps[killer][:name], else: nil
        {ps, [{:player_died, id, killer, killer_name} | evts], fd ++ body_food}
      end)

    # When over cap, drop OLDEST food (head of list) so fresh kill drops
    # always reach the killer. Enum.take(_, -n) keeps the trailing n items.
    capped_food = if length(food) > @max_food, do: Enum.take(food, -@max_food), else: food
    %{state | players: players, events: events, food: capped_food}
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

          # Growth — no cap. Long snakes are supposed to be possible; the
          # armored/severable zone system + LOD compression keep them
          # tactically interesting without tanking the room.
          grow = Enum.reduce(eaten, 0, fn {_, _, t}, a -> a + grow_amount(p, t) end)

          new_food_eaten = p.food_eaten + length(eaten)
          new_level = level_of(new_food_eaten)
          leveled_up = new_level > p.level

          ps = Map.update!(ps, id, fn pl ->
            # Hard length cap. Past @max_segments, eating only awards score —
            # players spend tail in the gacha to keep growing usefully.
            new_segments =
              if length(pl.segments) >= @max_segments do
                pl.segments
              else
                cap_segments(pl.segments ++ extend_tail(pl.segments, grow, @seg_spacing))
              end

            grown = %{pl |
              score: pl.score + pts,
              food_eaten: new_food_eaten,
              level: new_level,
              segments: new_segments,
              combo: combo_new,
              combo_until: state.tick + 50,
              just_leveled: leveled_up
            }
            # Girth derived smoothly from level — no length truncation, no visual snap.
            %{grown | girth: girth_for_level(grown.level)}
          end)

          fattened? = ps[id].girth > p.girth
          ev2 = if leveled_up, do: [{:level_up, id, new_level} | ev], else: ev
          ev3 = [{:food_eaten, id, if(raw_pts > 3, do: :golden, else: :normal)} | ev2]
          ev4 = if fattened?, do: [{:fatten, id, ps[id].girth} | ev3], else: ev3
          {ps, kept, ev4}
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
    # Powerup pickup floor cap is 3, but never decrease an already-higher
    # stack (gacha can push to 5). max(stacks, ...) preserves the gacha tier.
    Map.update!(ps, id, fn p ->
      %{p | shield_stacks: max(p.shield_stacks, min(3, p.shield_stacks + tier))}
    end)
  end

  defp apply_pup(ps, _state, id, :freeze, tier) do
    # Freeze all OTHER alive players for the duration
    freezer_id = id
    dur = @tier_duration[tier] || @tier_duration[1]
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
    dur = @tier_duration[tier] || @tier_duration[1]
    Map.new(ps, fn {pid, p} ->
      if pid == slower_id || !p.alive do
        {pid, p}
      else
        {pid, %{p | effects: Map.put(p.effects, :slowmo_target, {dur, tier})}}
      end
    end)
  end

  defp apply_pup(ps, _state, id, type, tier) do
    # Generic: add effect with tier-based duration. Falls back to t1 dur if tier invalid.
    dur = @tier_duration[tier] || @tier_duration[1]
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
            if d < range do
              safe_d = max(d, 0.01)
              {fx + (hx - fx) / safe_d * speed, fy + (hy - fy) / safe_d * speed, t}
            else
              f
            end
        end
      end)
      %{state | food: food}
    end
  end

  # Girth derived smoothly from level. Replaces the old fatten-and-truncate
  # mechanic, which caused a jarring visual freeze every time the snake hit
  # the length threshold and lost ~40% of its body in one tick.
  defp girth_for_level(level) do
    Float.round(1.0 + min((level - 1) * 0.04, @max_girth - 1.0), 2)
  end

  defp target_food(state) do
    player_count = Enum.count(state.players, fn {_, p} -> p.alive end)
    base = @base_food + player_count * @food_per_player
    time_bonus = min(div(state.tick, 200) * @food_accum_rate, 120)
    min(base + time_bonus, @max_food)
  end

  defp replenish_food(state) do
    state = maybe_food_rain(state)
    needed = target_food(state) - length(state.food)
    if needed > 0, do: seed_food(state, min(needed, 30)), else: state
  end

  # Periodic food-rain event. Schedules next rain with jitter on first call or after expiry.
  defp maybe_food_rain(%{next_rain_at: 0} = state) do
    jitter = div(@rain_interval, 4)
    delay = @rain_interval + :rand.uniform(jitter * 2) - jitter
    %{state | next_rain_at: state.tick + delay}
  end
  defp maybe_food_rain(state) do
    cond do
      state.tick < state.next_rain_at ->
        state

      true ->
        burst = Enum.min([@rain_burst, @max_food - length(state.food)])
        if burst > 0 do
          jitter = div(@rain_interval, 4)
          delay = @rain_interval + :rand.uniform(jitter * 2) - jitter
          state
          |> seed_food(burst)
          |> Map.merge(%{
            rain_until: state.tick + 50,
            next_rain_at: state.tick + delay,
            events: [{:food_rain, burst} | state.events]
          })
        else
          %{state | next_rain_at: state.tick + 200}
        end
    end
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
          l: length(p.segments), lv: p.level,
          bot: p.is_bot}
      end)
      |> Enum.sort_by(&(-&1.ts))
      |> Enum.take(10)
    %{state | leaderboard: board}
  end

  # ── Laser Eye / Tail Sever ──────────────────────────────
  # On the tick where charge expires, trace a forward beam. The first other
  # alive snake whose body is hit gets severed at that segment (everything
  # behind it scatters as food). Shield absorbs (consumes a stack, no cut).
  # Attacker pays @laser_self_cost from their own tail, regardless of hit.

  defp process_lasers(state) do
    firing =
      state.players
      |> Enum.filter(fn {_id, p} ->
        p.alive && p.laser_charge_until == state.tick
      end)

    if firing == [] do
      state
    else
      Enum.reduce(firing, state, fn {id, _p}, acc -> fire_laser(acc, id) end)
    end
  end

  defp fire_laser(state, id) do
    p = state.players[id]
    {hx, hy} = hd(p.segments)
    fx = :math.cos(p.angle)
    fy = :math.sin(p.angle)
    bx = hx + fx * @laser_range
    by = hy + fy * @laser_range

    # armor_pierce buff: laser ignores the armored zone for the buff's
    # duration. Small snakes use this to actually cut down well-armored
    # long snakes (whose entire visible body is otherwise armored).
    pierce? = Map.has_key?(p.effects, :armor_pierce)

    # Find closest hit across other alive players. Each candidate is tagged
    # with :armored or :severable based on the target's progression — armored
    # zone protects head-side segments and grows with level.
    candidates =
      state.players
      |> Enum.reject(fn {oid, op} ->
        oid == id || !op.alive ||
          # Ghost is intangible
          Map.has_key?(op.effects, :ghost)
      end)
      |> Enum.flat_map(fn {oid, op} ->
        armor = if pierce?, do: 0, else: armored_count(op)
        op.segments
        |> Enum.with_index()
        # First 3 segs (neck) are skipped entirely — head-on collision
        # already covers that geometry in detect_collisions.
        |> Enum.drop(3)
        |> Enum.map(fn {{sx, sy}, idx} ->
          zone = if idx < armor, do: :armored, else: :severable
          {oid, idx, sx, sy,
           segment_dist_along_beam(hx, hy, fx, fy, sx, sy, @laser_range), zone}
        end)
      end)
      |> Enum.filter(fn {_, _, _, _, d_along, _} -> d_along != nil end)
      |> Enum.sort_by(fn {_, _, _, _, d_along, _} -> d_along end)

    # The first segment whose perpendicular distance is within @laser_radius
    # wins. The candidate ordering means the closest one along the beam is
    # checked first — armored segments still BLOCK the beam (don't pass through).
    hit =
      Enum.find(candidates, fn {_oid, _idx, sx, sy, _d_along, _zone} ->
        perpendicular_dist(hx, hy, fx, fy, sx, sy) <= @laser_radius
      end)

    state = pay_laser_cost(state, id)

    case hit do
      nil ->
        # Whiff. Still on cooldown + cost paid.
        state |> Map.update!(:events, &[{:laser_fire, id, nil, bx, by, 0} | &1])

      {oid, hit_idx, sx, sy, _, :armored} ->
        # Beam hits armored zone — absorbed without effect, but visible feedback.
        state
        |> Map.update!(:events, &[{:laser_armored, id, oid, sx, sy} | &1])

      {oid, hit_idx, sx, sy, _, :severable} ->
        target = state.players[oid]

        if target.shield_stacks > 0 do
          state
          |> update_in([Access.key(:players), oid, Access.key(:shield_stacks)], &(&1 - 1))
          |> Map.update!(:events, &[{:laser_blocked, id, oid, sx, sy} | &1])
        else
          sever_at(state, id, oid, hit_idx, sx, sy)
        end
    end
  end

  # How many head-side segments are immune to lasers. Grows with level so
  # progression has a defensive axis. New players: 6 protected (vulnerable);
  # Lv 50: 153 protected (mostly armored, only the trailing tail can be cut).
  defp armored_count(p) do
    min(length(p.segments), @armor_base + (p.level - 1) * @armor_per_level)
  end

  # Reject if the segment is behind the head (negative beam coordinate) or
  # past the beam endpoint. Returns distance along beam, or nil if rejected.
  defp segment_dist_along_beam(hx, hy, fx, fy, sx, sy, range) do
    along = (sx - hx) * fx + (sy - hy) * fy

    cond do
      along < 0 -> nil
      along > range -> nil
      true -> along
    end
  end

  # Perpendicular distance from segment to infinite beam line.
  defp perpendicular_dist(hx, hy, fx, fy, sx, sy) do
    # Cross product magnitude / |forward| (forward is unit so |forward|=1)
    abs((sx - hx) * (-fy) + (sy - hy) * fx)
  end

  defp pay_laser_cost(state, id) do
    update_in(state.players[id], fn p ->
      kept = max(@laser_min_segs - @laser_self_cost, length(p.segments) - @laser_self_cost)
      # laser_charged equipment halves cooldown — gacha-tier permanent buff.
      cd =
        if Map.has_key?(p.effects, :laser_charged),
          do: div(@laser_cooldown, 2),
          else: @laser_cooldown

      %{p |
        segments: Enum.take(p.segments, kept),
        laser_charge_until: 0,
        laser_fire_at: state.tick,
        laser_cd_until: state.tick + cd
      }
    end)
  end

  defp sever_at(state, attacker_id, victim_id, hit_idx, hit_x, hit_y) do
    target = state.players[victim_id]
    {keep, severed} = Enum.split(target.segments, hit_idx)

    # Don't trim short snakes to nothing — leave at least @laser_min_victim_len.
    keep =
      if length(keep) < @laser_min_victim_len do
        Enum.take(target.segments, @laser_min_victim_len)
      else
        keep
      end

    severed_count = length(target.segments) - length(keep)
    # Convert severed body to food. Sample sparsely (every 2nd) so we don't
    # explode broadcast size when hitting a long snake.
    new_food =
      severed
      |> Enum.take_every(2)
      |> Enum.map(fn {x, y} ->
        {x, y, if(:rand.uniform() < 0.20, do: :golden, else: :normal)}
      end)

    state
    |> put_in([Access.key(:players), victim_id, Access.key(:segments)], keep)
    |> Map.update!(:food, fn fd ->
      capped_food = fd ++ new_food
      # Same as detect_collisions: drop oldest when over cap so the sever
      # drops actually persist long enough for someone to eat them.
      if length(capped_food) > @max_food, do: Enum.take(capped_food, -@max_food), else: capped_food
    end)
    |> Map.update!(:events, &[
      {:laser_fire, attacker_id, victim_id, hit_x, hit_y, severed_count} | &1
    ])
  end

  # ── Bot AI ──────────────────────────────────────────────
  # Tiny rule-based AI: wall-avoid → threat-avoid → food-seek.
  # Decisions are stateless (target_angle recomputed each tick) so bots
  # behave reactively without complex pathfinding.

  defp tick_bots(state) do
    alive_bots =
      state.players
      |> Enum.filter(fn {_, p} -> p.alive && p.is_bot end)

    if alive_bots == [] do
      state
    else
      Enum.reduce(alive_bots, state, fn {id, p}, acc ->
        target = bot_decide(acc, p)
        boost = bot_should_boost?(acc, p)
        update_in(acc.players[id], fn pp ->
          %{pp | target_angle: target, boosting: boost, last_seen: acc.tick}
        end)
      end)
    end
  end

  defp bot_decide(state, p) do
    {hx, hy} = hd(p.segments)
    cur = p.angle

    cond do
      hx < @bot_wall_margin ->
        # Bias toward arena center on x with mild y noise
        :math.atan2(state.height / 2 - hy + (:rand.uniform() - 0.5) * 200, state.width / 2 - hx)

      hx > state.width - @bot_wall_margin ->
        :math.atan2(state.height / 2 - hy + (:rand.uniform() - 0.5) * 200, state.width / 2 - hx)

      hy < @bot_wall_margin ->
        :math.atan2(state.height / 2 - hy, state.width / 2 - hx + (:rand.uniform() - 0.5) * 200)

      hy > state.height - @bot_wall_margin ->
        :math.atan2(state.height / 2 - hy, state.width / 2 - hx + (:rand.uniform() - 0.5) * 200)

      true ->
        case bot_nearest_threat(state, p.id, hx, hy) do
          {tx, ty, d} when d < @bot_avoid_radius ->
            # Turn away from the threat
            :math.atan2(hy - ty, hx - tx)

          _ ->
            # Recompute food target only every few ticks to save CPU
            phase = :erlang.phash2(p.id, 8)
            if rem(state.tick, 8) == phase do
              bot_seek_food(state.food, hx, hy, cur)
            else
              cur
            end
        end
    end
  end

  defp bot_nearest_threat(state, my_id, hx, hy) do
    # Sample one segment per other snake for cheapness; head + body mid-points are good proxies.
    state.players
    |> Enum.reject(fn {oid, op} -> oid == my_id || !op.alive end)
    |> Enum.flat_map(fn {_, op} ->
      segs = op.segments
      n = length(segs)
      if n < 2, do: segs, else: [hd(segs), Enum.at(segs, div(n, 2))]
    end)
    |> Enum.min_by(fn {sx, sy} ->
      dx = sx - hx
      dy = sy - hy
      dx * dx + dy * dy
    end, fn -> nil end)
    |> case do
      nil -> nil
      {sx, sy} -> {sx, sy, dist(hx, hy, sx, sy)}
    end
  end

  defp bot_seek_food([], _hx, _hy, fallback), do: fallback
  defp bot_seek_food(food, hx, hy, _fallback) do
    {fx, fy, _t} =
      Enum.min_by(food, fn {fx, fy, _} ->
        dx = fx - hx
        dy = fy - hy
        dx * dx + dy * dy
      end)

    :math.atan2(fy - hy, fx - hx)
  end

  # Boost when chasing food and the snake is fat enough to spare growth.
  defp bot_should_boost?(_state, p) do
    length(p.segments) > 25 && :rand.uniform() < 0.05
  end

  defp respawn_dead_bots(state) do
    to_respawn =
      state.players
      |> Enum.filter(fn {_, p} ->
        p.is_bot && !p.alive && p.dead_at > 0 && state.tick - p.dead_at >= @bot_respawn_delay
      end)
      |> Enum.map(&elem(&1, 0))

    Enum.reduce(to_respawn, state, &respawn(&2, &1))
  end

  # Cull humans who have been silent for @idle_player_ticks. Bots are exempt.
  defp cull_idle_players(state) do
    cutoff = state.tick - @idle_player_ticks

    stale =
      state.players
      |> Enum.filter(fn {_, p} -> !p.is_bot && p.last_seen < cutoff end)
      |> Enum.map(&elem(&1, 0))

    Enum.reduce(stale, state, &remove_player(&2, &1))
  end

  # ── Helpers ─────────────────────────────────────────────

  defp dist(x1, y1, x2, y2) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end

  defp encode_event({:food_eaten, id, type}), do: ["eat", id, if(type == :golden, do: 1, else: 0)]
  defp encode_event({:player_died, id, killer, killer_name}), do: ["die", id, killer, killer_name]
  defp encode_event({:player_died, id, killer}), do: ["die", id, killer, nil]
  defp encode_event({:player_respawned, id}), do: ["spawn", id]
  defp encode_event({:game_started}), do: ["start"]
  defp encode_event({:powerup_collected, id, type, tier}), do: ["pup", id, pup_idx(type), tier]
  defp encode_event({:level_up, id, lv}), do: ["lv", id, lv]
  defp encode_event({:fatten, id, g}), do: ["fat", id, g]
  defp encode_event({:streak, id, n}), do: ["streak", id, n]
  defp encode_event({:food_rain, n}), do: ["rain", n]
  # Laser events — client uses these for SFX + visual beam line + sever burst.
  defp encode_event({:laser_charge, id, angle}), do: ["lcharge", id, r2(angle)]
  defp encode_event({:laser_fire, attacker, victim, hx, hy, severed}),
    do: ["lfire", attacker, victim, r2(hx), r2(hy), severed]
  defp encode_event({:laser_blocked, attacker, victim, hx, hy}),
    do: ["lblock", attacker, victim, r2(hx), r2(hy)]
  defp encode_event({:laser_armored, attacker, victim, hx, hy}),
    do: ["larmor", attacker, victim, r2(hx), r2(hy)]
  # Gacha — meta is [type_string, tier, ttl] (or ["shield", n, 0]).
  defp encode_event({:gacha_result, id, [type, tier, ttl]}),
    do: ["gacha", id, type, tier, ttl]
  # Thorn-tail revenge — victim, attacker, segments cut from attacker.
  defp encode_event({:thorn_revenge, victim, killer, cut}),
    do: ["thorn", victim, killer, cut]
  defp encode_event(_), do: nil
end
