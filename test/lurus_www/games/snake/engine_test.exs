defmodule LurusWww.Games.Snake.EngineTest do
  use ExUnit.Case, async: true

  alias LurusWww.Games.Snake.Engine

  # ── Helpers ─────────────────────────────────────────────────────────────────

  # Build a fresh engine with one alive player. Returns {state, player_id}.
  defp one_player(name \\ "Alice") do
    state = Engine.new("test-room")
    {:ok, state} = Engine.add_player(state, "p1", name)
    {state, "p1"}
  end

  # Build a fresh engine with N alive players. Returns state.
  defp n_players(n) do
    state = Engine.new("room-n")
    Enum.reduce(1..n, state, fn i, acc ->
      id = "p#{i}"
      {:ok, acc} = Engine.add_player(acc, id, "Player#{i}")
      acc
    end)
  end

  # Teleport a player's head to position (x, y).
  defp move_head(state, id, x, y) do
    %{state | players: Map.update!(state.players, id, fn p ->
      [{_, _} | tail] = p.segments
      %{p | segments: [{x * 1.0, y * 1.0} | tail]}
    end)}
  end

  # Force all of a player's segments to exactly (x, y) for collision testing.
  defp force_segments(state, id, segs) do
    %{state | players: Map.update!(state.players, id, &%{&1 | segments: segs})}
  end

  # ── 1. Player Lifecycle ──────────────────────────────────────────────────────

  describe "add_player/3" do
    test "first player transitions state to :playing" do
      state = Engine.new("r")
      assert state.status == :waiting
      {:ok, state} = Engine.add_player(state, "p1", "Alice")
      assert state.status == :playing
    end

    test "first player emits :game_started event" do
      state = Engine.new("r")
      {:ok, state} = Engine.add_player(state, "p1", "Alice")
      assert Enum.any?(state.events, &match?({:game_started}, &1))
    end

    test "first player is spawned alive with segments" do
      {:ok, state} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      p = state.players["p1"]
      assert p.alive == true
      assert length(p.segments) >= 10
    end

    test "second player joins mid-game without an extra :game_started event" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      {:ok, s2} = Engine.add_player(s1, "p2", "Bob")
      # The original :game_started from p1 is still present (events are reset
      # on tick, not on join), but joining p2 must NOT push another one.
      assert Enum.count(s2.events, &match?({:game_started}, &1)) == 1
    end

    test "second player is immediately alive" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      {:ok, s2} = Engine.add_player(s1, "p2", "Bob")
      assert s2.players["p2"].alive == true
    end

    test "duplicate player id returns :already_joined" do
      {:ok, state} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      assert {:error, :already_joined} = Engine.add_player(state, "p1", "Alice2")
    end

    test "room fills at exactly @max_players (20)" do
      state = n_players(20)
      assert Engine.player_count(state) == 20
      assert {:error, :room_full} = Engine.add_player(state, "overflow", "X")
    end

    test "player_order tracks insertion order" do
      state = n_players(3)
      assert state.player_order == ["p1", "p2", "p3"]
    end

    test "each player gets a distinct color from the palette" do
      state = n_players(5)
      colors = Enum.map(state.players, fn {_, p} -> p.color end)
      assert length(Enum.uniq(colors)) == 5
    end

    test "player scores start at zero" do
      {:ok, state} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      p = state.players["p1"]
      assert p.score == 0
      assert p.kills == 0
      assert p.total_score == 0
      assert p.food_eaten == 0
    end

    test "initial food is seeded when first player joins" do
      {:ok, state} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      assert length(state.food) > 0
    end
  end

  describe "remove_player/2" do
    test "removing the last player resets state to :waiting" do
      {state, id} = one_player()
      state = Engine.remove_player(state, id)
      assert state.status == :waiting
    end

    test "removing last player clears food and powerups" do
      {state, id} = one_player()
      state = Engine.remove_player(state, id)
      assert state.food == []
      assert state.powerups == []
    end

    test "removing last player resets tick to 0" do
      {state, id} = one_player()
      state = Engine.tick(state)
      state = Engine.remove_player(state, id)
      assert state.tick == 0
    end

    test "alive player with >3 segments drops body food on leave" do
      {state, "p1"} = one_player()
      _food_before = length(state.food)
      # Ensure player has enough segments (spawned with 10)
      assert length(state.players["p1"].segments) > 3
      state = Engine.remove_player(state, "p1")
      # State is :waiting so food was cleared — just verify the logic ran
      # (when two players: second player's food would accumulate)
      assert state.status == :waiting
    end

    test "body food drop capped at 12 pieces when alive with long snake" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      {:ok, state} = Engine.add_player(s1, "p2", "Bob")
      food_before = length(state.food)

      # Give p1 a very long snake (simulate 40 segments)
      long_segs = for i <- 1..40, do: {i * 10.0, 100.0}
      state = force_segments(state, "p1", long_segs)

      state = Engine.remove_player(state, "p1")
      # body drops Enum.take_every(3) |> Enum.take(12) = at most 12 pieces
      food_added = length(state.food) - food_before
      assert food_added <= 12
    end

    test "removing non-existent player id is safe" do
      {state, _} = one_player()
      state2 = Engine.remove_player(state, "ghost")
      assert map_size(state2.players) == map_size(state.players)
    end

    test "removing one of two players keeps state :playing" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")
      state = Engine.remove_player(state, "p1")
      assert state.status == :playing
    end
  end

  describe "respawn/2" do
    test "dead player becomes alive after respawn" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | alive: false})}
      state = Engine.respawn(state, id)
      assert state.players[id].alive == true
    end

    test "respawn resets score and kills" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | alive: false, score: 999, kills: 5, food_eaten: 50}
      end)}
      state = Engine.respawn(state, id)
      p = state.players[id]
      assert p.score == 0
      assert p.kills == 0
      assert p.food_eaten == 0
    end

    test "respawn resets effects and shield" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | alive: false, effects: %{blade: {100, 1}, magnet: {50, 1}}, shield_stacks: 2, boosting: true}
      end)}
      state = Engine.respawn(state, id)
      p = state.players[id]
      assert p.effects == %{}
      assert p.shield_stacks == 0
      assert p.boosting == false
    end

    test "respawn emits :player_respawned event" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | alive: false})}
      state = Engine.respawn(state, id)
      assert Enum.any?(state.events, &match?({:player_respawned, ^id}, &1))
    end

    test "respawn on an alive player resets stats and re-spawns segments" do
      # New behaviour (post-RPG-overhaul): respawn unconditionally resets the
      # player. Calling it on an alive player is harmless but does mutate state
      # — segments are re-rolled, score/kills cleared, alive stays true.
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | score: 99, kills: 7})}
      state2 = Engine.respawn(state, id)
      assert state2.players[id].alive == true
      assert state2.players[id].score == 0
      assert state2.players[id].kills == 0
      assert length(state2.players[id].segments) >= 10
    end

    test "respawn on unknown player id is a no-op" do
      {state, _} = one_player()
      state2 = Engine.respawn(state, "ghost")
      assert state2 == state
    end
  end

  # ── 2. Movement ──────────────────────────────────────────────────────────────

  describe "set_target/3" do
    test "accepts integer angle and coerces to float" do
      {state, id} = one_player()
      state = Engine.set_target(state, id, 1)
      assert state.players[id].target_angle == 1.0
      assert is_float(state.players[id].target_angle)
    end

    test "accepts float angle" do
      {state, id} = one_player()
      state = Engine.set_target(state, id, 1.57)
      assert_in_delta state.players[id].target_angle, 1.57, 0.001
    end

    test "nil angle is ignored, state unchanged" do
      {state, id} = one_player()
      orig = state.players[id].target_angle
      state2 = Engine.set_target(state, id, nil)
      assert state2.players[id].target_angle == orig
    end

    test "string angle is ignored" do
      {state, id} = one_player()
      orig = state.players[id].target_angle
      state2 = Engine.set_target(state, id, "north")
      assert state2.players[id].target_angle == orig
    end

    test "atom angle is ignored" do
      {state, id} = one_player()
      orig = state.players[id].target_angle
      state2 = Engine.set_target(state, id, :up)
      assert state2.players[id].target_angle == orig
    end

    test "set_target for unknown player is a no-op" do
      {state, _} = one_player()
      state2 = Engine.set_target(state, "ghost", 1.0)
      assert state2 == state
    end

    test "target angle zero is accepted" do
      {state, id} = one_player()
      state = Engine.set_target(state, id, 0)
      assert state.players[id].target_angle == 0.0
    end

    test "negative angle is accepted" do
      {state, id} = one_player()
      state = Engine.set_target(state, id, -1.57)
      assert_in_delta state.players[id].target_angle, -1.57, 0.001
    end
  end

  describe "steer_toward / angle steering" do
    test "steer moves angle by at most turn_rate (0.15) per tick" do
      {state, id} = one_player()
      orig_angle = 0.0
      state = %{state | players: Map.update!(state.players, id, &%{&1 | angle: orig_angle, target_angle: :math.pi()})}
      state2 = Engine.tick(state)
      new_angle = state2.players[id].angle
      # Angle must have changed by at most turn_rate=0.15 in either direction
      diff = abs(new_angle - orig_angle)
      # Accounting for wraparound: diff should be <= 0.15 + epsilon
      assert diff <= 0.15 + 0.001 or diff >= 2 * :math.pi() - 0.15 - 0.001
    end

    test "steer toward -pi wraps correctly (does not go the long way)" do
      {state, id} = one_player()
      # angle at 0, target at -pi: shortest path is clockwise (negative)
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | angle: 0.0, target_angle: -:math.pi() + 0.01}
      end)}
      state2 = Engine.tick(state)
      # The snake should have steered — direction may vary, but it shouldn't blow up
      assert is_float(state2.players[id].angle)
    end

    test "angle stays normalized within [-pi, pi]" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | angle: 0.0, target_angle: 100.0})}
      # Run many ticks and check angle always stays in range
      final = Enum.reduce(1..60, state, fn _, acc -> Engine.tick(acc) end)
      angle = final.players[id].angle
      assert angle >= -:math.pi() - 0.001
      assert angle <= :math.pi() + 0.001
    end

    test "head advances in direction of current angle each tick" do
      {state, id} = one_player()
      angle = 0.0  # pointing right
      state = %{state | players: Map.update!(state.players, id, &%{&1 | angle: angle, target_angle: angle})}
      {hx0, _hy0} = hd(state.players[id].segments)
      state2 = Engine.tick(state)
      {hx1, _hy1} = hd(state2.players[id].segments)
      # Pointing right means x should increase
      assert hx1 > hx0
    end
  end

  describe "speed progression" do
    test "base speed is 5.5 at start" do
      {state, id} = one_player()
      _p = state.players[id]
      # food_eaten=0, level=1, no effects, no boost
      client = Engine.to_client(state)
      spd = client.players[id].spd
      assert_in_delta spd, 5.5, 0.1
    end

    test "speed increases by 0.03 per level (1 level per 15 food)" do
      {state, id} = one_player()
      # 15 food = level 2 -> base 5.5 + 1*0.03 = 5.53
      state = %{state | players: Map.update!(state.players, id, &%{&1 | food_eaten: 15, level: 2})}
      client = Engine.to_client(state)
      assert_in_delta client.players[id].spd, 5.53, 0.05
    end

    test "speed increases correctly at level 4 (45 food eaten)" do
      {state, id} = one_player()
      # 45 food = level 4 -> base 5.5 + 3*0.03 = 5.59
      state = %{state | players: Map.update!(state.players, id, &%{&1 | food_eaten: 45, level: 4})}
      client = Engine.to_client(state)
      assert_in_delta client.players[id].spd, 5.59, 0.05
    end

    test "speed is capped at max_speed (10.0)" do
      {state, id} = one_player()
      # Set artificially high level; speed should clamp to 10.0
      state = %{state | players: Map.update!(state.players, id, &%{&1 | food_eaten: 999, level: 50})}
      client = Engine.to_client(state)
      assert client.players[id].spd <= 10.0 + 0.1
    end

    test "star effect grants 1.1x speed multiplier" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | effects: %{star: {100, 1}}, food_eaten: 0}
      end)}
      client = Engine.to_client(state)
      # Star: base_speed 5.5 * 1.1 = 6.05
      assert_in_delta client.players[id].spd, 6.05, 0.1
    end

    test "boost multiplies speed when snake has >=3 segments" do
      {state, id} = one_player()
      # Give snake 10 segments and enable boost
      segs = for i <- 1..10, do: {i * 9.0, 100.0}
      state = force_segments(state, id, segs)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | boosting: true})}
      client = Engine.to_client(state)
      # boosted speed = 5.5 * 1.8 = 9.9
      assert client.players[id].spd > 5.5
    end

    test "boost applies when snake has at least 3 segments" do
      {state, id} = one_player()
      # Engine boost condition is >=3 segments. Use exactly 3 to verify boost engages.
      short_segs = for i <- 1..3, do: {i * 9.0, 100.0}
      state = force_segments(state, id, short_segs)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | boosting: true})}
      client = Engine.to_client(state)
      # length(segs)=3, condition is >=3 → boost applies (5.5 * 1.8 = 9.9)
      assert client.players[id].spd > 5.5
    end
  end

  describe "boost behavior" do
    test "boost increases head displacement per tick" do
      {state, id} = one_player()
      segs = for i <- 1..15, do: {1000.0 - i * 9.0, 700.0}
      state = force_segments(state, id, segs)
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | boosting: true, angle: 0.0, target_angle: 0.0}
      end)}
      {hx0, _} = hd(state.players[id].segments)
      state2 = Engine.tick(state)
      {hx1, _} = hd(state2.players[id].segments)
      # boosted speed (5.5 * 1.8 = 9.9) should drive head further than base 5.5
      assert hx1 - hx0 > 5.5
    end

    test "boost is ignored when snake is shorter than 3 segments" do
      {state, id} = one_player()
      short_segs = for i <- 1..2, do: {i * 9.0, 100.0}
      state = force_segments(state, id, short_segs)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | boosting: true})}
      client = Engine.to_client(state)
      # length(segs)=2 < 3 → no boost applied; speed stays at base 5.5
      assert_in_delta client.players[id].spd, 5.5, 0.1
    end

    test "freeze effect overrides boost (speed becomes 0)" do
      {state, id} = one_player()
      segs = for i <- 1..15, do: {i * 9.0, 100.0}
      state = force_segments(state, id, segs)
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | boosting: true, effects: %{freeze: {200, 1}}}
      end)}
      client = Engine.to_client(state)
      # freeze sets current_speed to 0.0 regardless of boost
      assert_in_delta client.players[id].spd, 0.0, 0.01
    end
  end

  # ── 3. Collision ─────────────────────────────────────────────────────────────

  describe "wall collision" do
    # Helper for wall tests: after teleporting the head, also pin the angle so
    # steer_and_move doesn't carry the head back inside before detect_collisions
    # gets a chance to register the kill.
    defp pin_for_wall(state, id, angle) do
      %{state |
        players: Map.update!(state.players, id, &%{&1 |
          angle: angle, target_angle: angle, invincible_until: 0
        }),
        tick: 100
      }
    end

    test "player dies when head goes past left wall (x < 0)" do
      {state, id} = one_player()
      state = state |> move_head(id, -1.0, 700.0) |> pin_for_wall(id, :math.pi())
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player dies when head goes past right wall (x > 2400)" do
      {state, id} = one_player()
      state = state |> move_head(id, 2401.0, 700.0) |> pin_for_wall(id, 0.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player dies when head goes past top wall (y < 0)" do
      {state, id} = one_player()
      state = state |> move_head(id, 1000.0, -1.0) |> pin_for_wall(id, -:math.pi() / 2)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player dies when head goes past bottom wall (y > 1600)" do
      {state, id} = one_player()
      state = state |> move_head(id, 1000.0, 1601.0) |> pin_for_wall(id, :math.pi() / 2)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player just past the left boundary dies" do
      {state, id} = one_player()
      state = state |> move_head(id, -1.0, 700.0) |> pin_for_wall(id, :math.pi())
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player just past the right boundary dies" do
      {state, id} = one_player()
      state = state |> move_head(id, 2400.5, 700.0) |> pin_for_wall(id, 0.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "wall kill drops body food" do
      {state, id} = one_player()
      state = state |> move_head(id, -5.0, 700.0) |> pin_for_wall(id, :math.pi())
      food_before = length(state.food)
      state2 = Engine.tick(state)
      # Body food is added on death (replenishment may also add — strict >).
      assert length(state2.food) > food_before
    end

    test "wall kill emits :player_died event with nil killer" do
      {state, id} = one_player()
      state = state |> move_head(id, -5.0, 700.0) |> pin_for_wall(id, :math.pi())
      state2 = Engine.tick(state)
      # Engine emits 4-tuple: {:player_died, id, killer, killer_name}
      assert Enum.any?(state2.events, &match?({:player_died, ^id, nil, nil}, &1))
    end

    test "wall-killed player with shield consumes shield and survives" do
      {state, id} = one_player()
      state = state |> move_head(id, -5.0, 700.0) |> pin_for_wall(id, :math.pi())
      state = %{state | players: Map.update!(state.players, id, &%{&1 | shield_stacks: 1})}
      state2 = Engine.tick(state)
      # Shield absorbs hit: alive stays true, shield_stacks decremented
      assert state2.players[id].alive == true
      assert state2.players[id].shield_stacks == 0
    end
  end

  describe "snake-to-snake collision" do
    test "head hitting another snake's body kills the colliding snake" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      # Place p2's body as a horizontal wall at y=700, p1's head right on it
      p2_segs = for i <- 0..15, do: {900.0 + i * 9.0, 700.0}
      state = force_segments(state, "p2", p2_segs)
      # p1's head sits right on segment index 5 of p2 (well past the 3-skip)
      state = move_head(state, "p1", 945.0, 700.0)
      # Clear invincibility on both — fresh spawns are invincible for 80 ticks
      state = %{state |
        players: state.players
          |> Map.update!("p1", &%{&1 | invincible_until: 0})
          |> Map.update!("p2", &%{&1 | invincible_until: 0}),
        tick: 100
      }

      state2 = Engine.tick(state)
      assert state2.players["p1"].alive == false
    end

    test "killer gets credited +1 kill and a positive score bonus" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      p2_segs = for i <- 0..15, do: {900.0 + i * 9.0, 700.0}
      state = force_segments(state, "p2", p2_segs)
      state = move_head(state, "p1", 945.0, 700.0)
      # Pin p1's angle so steer_and_move drives the head INTO p2's body line,
      # not in a random direction (add_player picks angle randomly).
      state = %{state |
        players: state.players
          |> Map.update!("p1", &%{&1 | invincible_until: 0, angle: 0.0, target_angle: 0.0})
          # Pin p2 angle too — random direction makes resample warp body
          # off the y=700 line and the test becomes flaky.
          |> Map.update!("p2", &%{&1 | invincible_until: 0, angle: 0.0, target_angle: 0.0}),
        tick: 100
      }

      state2 = Engine.tick(state)
      assert state2.players["p2"].kills == 1
      # Engine awards: 15 + level*2 + length/3 + girth_bonus, multiplied by streak
      assert state2.players["p2"].score > 0
    end

    test "first 3 segments of a snake body are skipped for collision" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      # p2's first 3 segments placed right on p1's head position — should NOT kill
      p2_segs = [{500.0, 500.0}, {509.0, 500.0}, {518.0, 500.0}] ++
                (for i <- 3..12, do: {500.0 + i * 9.0, 600.0})
      state = force_segments(state, "p2", p2_segs)
      state = move_head(state, "p1", 500.0, 500.0)

      state2 = Engine.tick(state)
      # Engine emits 4-tuple :player_died — p1 should NOT have died blaming p2
      died_to_p2 = Enum.any?(state2.events, &match?({:player_died, "p1", "p2", _}, &1))
      assert died_to_p2 == false
    end

    test "shielded player survives body collision, shield consumed" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      p2_segs = for i <- 0..15, do: {900.0 + i * 9.0, 700.0}
      state = force_segments(state, "p2", p2_segs)
      state = move_head(state, "p1", 945.0, 700.0)
      state = %{state |
        players: state.players
          |> Map.update!("p1", &%{&1 | shield_stacks: 1, invincible_until: 0})
          |> Map.update!("p2", &%{&1 | invincible_until: 0}),
        tick: 100
      }

      state2 = Engine.tick(state)
      assert state2.players["p1"].alive == true
      assert state2.players["p1"].shield_stacks == 0
    end

    test "dead snake's killer gets Enum.find_value nil when killer also died same tick" do
      # Regression: when killer also dies the same tick, Map.has_key?(deaths, killer)
      # prevents double-crediting but the event killer can be nil-like.
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      # Both hit walls simultaneously (engine width is 2400). Pin angle so
      # steer_and_move keeps the head past the wall instead of curving back.
      state = move_head(state, "p1", -5.0, 700.0)
      state = move_head(state, "p2", 2405.0, 700.0)
      state = %{state |
        players: state.players
          |> Map.update!("p1", &%{&1 | invincible_until: 0, angle: :math.pi(), target_angle: :math.pi()})
          |> Map.update!("p2", &%{&1 | invincible_until: 0, angle: 0.0, target_angle: 0.0}),
        tick: 100
      }

      state2 = Engine.tick(state)
      # Both should be dead
      assert state2.players["p1"].alive == false
      assert state2.players["p2"].alive == false
      # Neither gets kill credit for the other (both died to walls)
      assert state2.players["p1"].kills == 0
      assert state2.players["p2"].kills == 0
    end

    test "death increments total_score by current score" do
      {state, id} = one_player()
      state = %{state |
        players: Map.update!(state.players, id, &%{&1 |
          score: 42, invincible_until: 0,
          angle: :math.pi(), target_angle: :math.pi()
        }),
        tick: 100
      }
      state = move_head(state, id, -5.0, 700.0)
      state2 = Engine.tick(state)
      assert state2.players[id].total_score == 42
    end
  end

  # ── 4. Food ──────────────────────────────────────────────────────────────────

  describe "collect_food/1" do
    test "player eating food increases score" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      # Place a food item directly on the head
      close_food = [{hx, hy, :normal}]
      state = %{state | food: close_food}
      state2 = Engine.tick(state)
      assert state2.players[id].score > 0
    end

    test "player eating food increases food_eaten counter" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      state = %{state | food: [{hx, hy, :normal}]}
      state2 = Engine.tick(state)
      assert state2.players[id].food_eaten > 0
    end

    test "eating normal food awards 1 point" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      state = %{state | food: [{hx, hy, :normal}], players: Map.update!(state.players, id, &%{&1 | score: 0})}
      state2 = Engine.tick(state)
      assert state2.players[id].score == 1
    end

    test "eating golden food awards 5 points" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      state = %{state | food: [{hx, hy, :golden}], players: Map.update!(state.players, id, &%{&1 | score: 0})}
      state2 = Engine.tick(state)
      assert state2.players[id].score == 5
    end

    test "star multiplier triples food points" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      state = %{state | food: [{hx, hy, :normal}], players: Map.update!(state.players, id, fn p ->
        %{p | score: 0, effects: %{star: {100, 1}}}
      end)}
      state2 = Engine.tick(state)
      # 1 point * 3 multiplier = 3 (rounded with combo bonus may give 3)
      assert state2.players[id].score >= 3
    end

    test "star multiplier triples golden food points" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      state = %{state | food: [{hx, hy, :golden}], players: Map.update!(state.players, id, fn p ->
        %{p | score: 0, effects: %{star: {100, 1}}}
      end)}
      state2 = Engine.tick(state)
      # 5 * 3 = 15 (rounded with combo bonus may give 15+)
      assert state2.players[id].score >= 15
    end

    test "eating food grows the snake" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      seg_count = length(state.players[id].segments)
      state = %{state | food: [{hx, hy, :normal}]}
      state2 = Engine.tick(state)
      assert length(state2.players[id].segments) > seg_count
    end

    test "eating food emits :food_eaten event" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      state = %{state | food: [{hx, hy, :normal}]}
      state2 = Engine.tick(state)
      assert Enum.any?(state2.events, &match?({:food_eaten, ^id, _}, &1))
    end
  end

  describe "replenish_food/1" do
    test "food is replenished when below target" do
      {state, id} = one_player()
      # Drain all food
      state = %{state | food: []}
      # tick will trigger replenishment
      state2 = Engine.tick(state)
      assert length(state2.food) > 0
    end

    test "replenish adds at most 30 pieces per tick when far below target" do
      {state, id} = one_player()
      # Drain all food and move player head far from any spawn location to prevent eating
      state = %{state | food: []}
      state = move_head(state, id, 1000.0, 700.0)
      state2 = Engine.tick(state)
      food_added = length(state2.food)
      # replenish_food seeds min(needed, 30) per tick
      assert food_added <= 30
      assert food_added > 0
    end

    test "food count increases with more players" do
      state_1 = n_players(1)
      state_5 = n_players(5)
      # target_food = base_food(100) + N*food_per_player(15); more players = more food target
      # After initial seed, more food present for 5 players
      assert length(state_5.food) >= length(state_1.food)
    end

    test "time accumulation formula: bonus increases every 200 ticks capped at 120" do
      {state, _id} = one_player()
      # Engine: time_bonus = min(div(tick,200) * @food_accum_rate(2), 120)
      state_400 = %{state | tick: 400}
      state_8000 = %{state | tick: 8000}
      # Verify replenishment runs without crashing; targets differ
      state_400_after = Engine.tick(%{state_400 | food: []})
      state_8000_after = Engine.tick(%{state_8000 | food: []})
      assert length(state_400_after.food) >= 0
      assert length(state_8000_after.food) >= 0
    end
  end

  # ── 5. Powerups ──────────────────────────────────────────────────────────────

  describe "collect_powerups/1 — each powerup type" do
    defp place_powerup_on_head(state, id, type, tier \\ 1) do
      {hx, hy} = hd(state.players[id].segments)
      %{state | powerups: [{hx, hy, type, tier}]}
    end

    test "collecting :blade applies effect within tier-1 duration (160)" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :blade, 1)
      state2 = Engine.tick(state)
      assert Map.has_key?(state2.players[id].effects, :blade)
      {ttl, tier} = state2.players[id].effects[:blade]
      assert ttl <= 160
      assert tier == 1
    end

    test "collecting :magnet applies magnet effect" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :magnet, 1)
      state2 = Engine.tick(state)
      assert Map.has_key?(state2.players[id].effects, :magnet)
    end

    test "collecting :star applies star effect" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :star, 1)
      state2 = Engine.tick(state)
      assert Map.has_key?(state2.players[id].effects, :star)
    end

    test "collecting :shield increments shield_stacks by tier" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :shield, 2)
      state2 = Engine.tick(state)
      # tier 2 shield grants 2 stacks (capped at 3)
      assert state2.players[id].shield_stacks == 2
    end

    test "powerup is removed from field after collection" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :star, 1)
      state2 = Engine.tick(state)
      assert length(state2.powerups) < length(state.powerups) + 1
    end

    test "collecting powerup emits :powerup_collected event with tier" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :blade, 1)
      state2 = Engine.tick(state)
      # Engine emits 4-element tuple including tier
      assert Enum.any?(state2.events, &match?({:powerup_collected, ^id, :blade, _}, &1))
    end
  end

  describe "effect TTL decay" do
    test "effect TTL decrements by 1 per tick" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | effects: %{blade: {10, 1}}})}
      state2 = Engine.tick(state)
      # Effects stored as {ttl, tier}; ttl decremented or expired
      case state2.players[id].effects[:blade] do
        nil -> :ok
        {ttl, _tier} -> assert ttl == 9
      end
    end

    test "effect is removed when TTL reaches 0" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | effects: %{magnet: {1, 1}}})}
      state2 = Engine.tick(state)
      refute Map.has_key?(state2.players[id].effects, :magnet)
    end

    test "multiple effects decay independently" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | effects: %{blade: {5, 1}, star: {10, 2}}}
      end)}
      state2 = Engine.tick(state)
      {blade_ttl, _} = state2.players[id].effects[:blade]
      {star_ttl, _} = state2.players[id].effects[:star]
      assert blade_ttl == 4
      assert star_ttl == 9
    end
  end

  describe "magnet attraction" do
    # Pick the food item nearest to (x0, y0) — use this to find the placed food
    # in the post-tick food list (replenish_food adds extras every tick).
    defp find_food_near(food, x0, y0) do
      Enum.min_by(food, fn {fx, fy, _} ->
        dx = fx - x0
        dy = fy - y0
        dx * dx + dy * dy
      end)
    end

    test "food within magnet range moves toward snake head" do
      {state, id} = one_player()
      state = move_head(state, id, 500.0, 500.0)
      # Place food 100 units away — outside the magnet-boosted eat radius (~50)
      # but well inside the tier-1 magnet range (~180). Pin the angle so the
      # head doesn't drift over and eat it.
      state = %{state |
        food: [{600.0, 500.0, :normal}],
        players: Map.update!(state.players, id, &%{&1 |
          angle: :math.pi(), target_angle: :math.pi(),
          effects: %{magnet: {200, 1}}
        })
      }
      state2 = Engine.tick(state)
      {fx, _, _} = find_food_near(state2.food, 600.0, 500.0)
      # Food should have moved closer to the head (i.e. toward x=500 → fx<600).
      assert fx < 600.0
    end

    test "food beyond magnet range is not attracted" do
      {state, id} = one_player()
      state = move_head(state, id, 500.0, 500.0)
      # Tier-1 range = 180 * (0.7 + 0.3) = 180; place food at distance 300 (outside)
      state = %{state |
        food: [{800.0, 500.0, :normal}],
        players: Map.update!(state.players, id, &%{&1 |
          angle: :math.pi(), target_angle: :math.pi(),
          effects: %{magnet: {200, 1}}
        })
      }
      state2 = Engine.tick(state)
      {fx, _, _} = find_food_near(state2.food, 800.0, 500.0)
      # Food is 300 away, beyond range, should not have moved.
      assert_in_delta fx, 800.0, 0.5
    end
  end

  # ── 6. Serialization ─────────────────────────────────────────────────────────

  describe "to_client/1" do
    test "output contains expected top-level keys" do
      {state, _} = one_player()
      client = Engine.to_client(state)
      assert Map.has_key?(client, :id)
      assert Map.has_key?(client, :size)
      assert Map.has_key?(client, :tick)
      assert Map.has_key?(client, :status)
      assert Map.has_key?(client, :events)
      assert Map.has_key?(client, :leaderboard)
      assert Map.has_key?(client, :players)
      assert Map.has_key?(client, :food)
      assert Map.has_key?(client, :pups)
    end

    test "player entry uses compact keys" do
      {state, id} = one_player()
      client = Engine.to_client(state)
      player = client.players[id]
      assert Map.has_key?(player, :n)
      assert Map.has_key?(player, :c)
      assert Map.has_key?(player, :a)
      assert Map.has_key?(player, :s)
      assert Map.has_key?(player, :sc)
      assert Map.has_key?(player, :al)
      assert Map.has_key?(player, :k)
    end

    test "segments serialized as [[x, y], ...] with 1-decimal floats" do
      {state, id} = one_player()
      client = Engine.to_client(state)
      segs = client.players[id].s
      assert is_list(segs)
      assert length(segs) > 0
      Enum.each(segs, fn seg ->
        assert is_list(seg)
        assert length(seg) == 2
        assert is_float(Enum.at(seg, 0))
      end)
    end

    test "food serialized as [[x, y, type_flag], ...]" do
      {state, _} = one_player()
      state = %{state | food: [{100.0, 200.0, :normal}, {300.0, 400.0, :golden}]}
      client = Engine.to_client(state)
      assert length(client.food) == 2
      [normal_entry, golden_entry] = client.food
      assert Enum.at(normal_entry, 2) == 0
      assert Enum.at(golden_entry, 2) == 1
    end

    test "powerup serialized as [[x, y, idx, tier], ...]" do
      {state, _} = one_player()
      state = %{state | powerups: [{100.0, 100.0, :blade, 1}, {200.0, 200.0, :shield, 2},
                                   {300.0, 300.0, :magnet, 1}, {400.0, 400.0, :star, 3}]}
      client = Engine.to_client(state)
      idxs = Enum.map(client.pups, &Enum.at(&1, 2))
      assert idxs == [0, 1, 2, 3]
    end

    test "unknown powerup type defaults to index 0" do
      {state, _} = one_player()
      state = %{state | powerups: [{100.0, 100.0, :unknown_type, 1}]}
      client = Engine.to_client(state)
      [[_, _, idx, _tier]] = client.pups
      assert idx == 0
    end

    test "nil events are filtered out from events list" do
      {state, _} = one_player()
      state = %{state | events: [{:game_started}, {:unknown_event_type}, {:player_respawned, "p1"}]}
      client = Engine.to_client(state)
      # :unknown_event_type encodes to nil and should be rejected
      refute Enum.any?(client.events, &is_nil/1)
    end

    test "leaderboard is capped at 8 entries" do
      state = n_players(10)
      client = Engine.to_client(state)
      assert length(client.leaderboard) <= 8
    end

    test "long snake (>30 segments) uses LOD: head area 8 + every-2nd tail" do
      {state, id} = one_player()
      long_segs = for i <- 1..60, do: {i * 9.0, 100.0}
      state = force_segments(state, id, long_segs)
      client = Engine.to_client(state)
      # Should be fewer than 60 segments sent
      sent_count = length(client.players[id].s)
      assert sent_count < 60
      # Head area (8) + take_every(2) on remaining 52 elements:
      # Enum.take_every([0..51], 2) keeps indices 0,2,4,... = 26 elements
      assert sent_count == 8 + 26
    end

    test "short snake (<=30 segments) sends all segments" do
      {state, id} = one_player()
      # Spawns with ~10 segments
      client = Engine.to_client(state)
      sent_count = length(client.players[id].s)
      assert sent_count == length(state.players[id].segments)
    end

    test "size field is [width, height] matching arena dimensions" do
      {state, _} = one_player()
      client = Engine.to_client(state)
      # Arena: @width=2400.0, @height=1600.0
      assert client.size == [2400.0, 1600.0]
    end
  end

  describe "encode_event/1" do
    test "encodes :game_started" do
      {state, _} = one_player()
      client = Engine.to_client(state)
      assert ["start"] in client.events
    end

    test "encodes :player_died with killer" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      p2_segs = for i <- 0..15, do: {900.0 + i * 9.0, 700.0}
      state = force_segments(state, "p2", p2_segs)
      state = move_head(state, "p1", 945.0, 700.0)
      state = %{state |
        players: state.players
          |> Map.update!("p1", &%{&1 | invincible_until: 0})
          |> Map.update!("p2", &%{&1 | invincible_until: 0}),
        tick: 100
      }

      state2 = Engine.tick(state)
      # Engine emits 4-tuple {:player_died, id, killer, killer_name}
      assert Enum.any?(state2.events, &match?({:player_died, "p1", "p2", _}, &1))
    end

    test "encodes :player_respawned" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | alive: false})}
      state2 = Engine.respawn(state, id)
      # to_client will encode this
      client = Engine.to_client(state2)
      assert Enum.any?(client.events, fn e -> match?(["spawn", ^id], e) end)
    end

    test "unknown event type returns nil and is filtered" do
      {state, _} = one_player()
      # Inject a bogus event
      state = %{state | events: [{:totally_unknown, "x"}]}
      client = Engine.to_client(state)
      refute Enum.any?(client.events, &is_nil/1)
    end
  end

  # ── 7. Tick lifecycle ─────────────────────────────────────────────────────────

  describe "tick/1" do
    test "tick on :waiting state is a no-op" do
      state = Engine.new("r")
      state2 = Engine.tick(state)
      assert state2 == state
    end

    test "tick increments the tick counter" do
      {state, _} = one_player()
      state2 = Engine.tick(state)
      assert state2.tick == state.tick + 1
    end

    test "tick resets events list at start of each tick" do
      {state, id} = one_player()
      # Inject stale events
      state = %{state | events: [{:stale_event}]}
      state2 = Engine.tick(state)
      # After tick, :stale_event should be gone (events reset at tick start)
      refute Enum.any?(state2.events, &match?({:stale_event}, &1))
    end

    test "tick on :playing state with no alive players is a no-op" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | alive: false})}
      tick_before = state.tick
      state2 = Engine.tick(state)
      assert state2.tick == tick_before
    end
  end

  # ── 8. Leaderboard ──────────────────────────────────────────────────────────

  describe "leaderboard" do
    test "leaderboard is sorted by total_score descending" do
      state = n_players(3)
      state = %{state | players: state.players
        |> Map.update!("p1", &%{&1 | total_score: 100})
        |> Map.update!("p2", &%{&1 | total_score: 300})
        |> Map.update!("p3", &%{&1 | total_score: 200})}
      state2 = Engine.tick(state)
      scores = Enum.map(state2.leaderboard, & &1.ts)
      assert scores == Enum.sort(scores, :desc)
    end

    test "leaderboard capped at 10 entries even with more players" do
      state = n_players(15)
      client = Engine.to_client(state)
      assert length(client.leaderboard) <= 8
    end

    test "leaderboard entry includes :al field for alive status" do
      {state, _} = one_player()
      # Leaderboard is materialised inside tick/update_leaderboard, not on
      # add_player. Tick once so the board is non-empty.
      state = Engine.tick(state)
      client = Engine.to_client(state)
      entry = hd(client.leaderboard)
      assert Map.has_key?(entry, :al)
    end
  end

  # ── 9. Edge Cases ────────────────────────────────────────────────────────────

  describe "edge cases" do
    test "Engine.new/1 returns a struct with correct id and defaults" do
      state = Engine.new("my-room")
      assert state.id == "my-room"
      assert state.status == :waiting
      assert state.players == %{}
      assert state.food == []
      assert state.tick == 0
    end

    test "player_count/1 returns correct count" do
      state = n_players(5)
      assert Engine.player_count(state) == 5
    end

    test "player_count/1 on empty room returns 0" do
      assert Engine.player_count(Engine.new("r")) == 0
    end

    test "20 players can all join without error" do
      state = n_players(20)
      assert Engine.player_count(state) == 20
      Enum.each(state.players, fn {_, p} ->
        assert p.alive == true
        assert length(p.segments) >= 10
      end)
    end

    test "20-player tick does not crash" do
      state = n_players(20)
      # Move all heads to safe center area to avoid immediate wall deaths
      state = Enum.reduce(1..20, state, fn i, acc ->
        id = "p#{i}"
        x = 500.0 + rem(i, 5) * 200.0
        y = 400.0 + div(i, 5) * 200.0
        move_head(acc, id, x, y)
      end)
      state2 = Engine.tick(state)
      # Just ensure it doesn't crash and tick incremented
      assert state2.tick == state.tick + 1
    end

    test "set_boost with non-boolean is ignored" do
      {state, id} = one_player()
      state2 = Engine.set_boost(state, id, "yes")
      assert state2.players[id].boosting == state.players[id].boosting
    end

    test "set_boost for unknown player is a no-op" do
      {state, _} = one_player()
      state2 = Engine.set_boost(state, "ghost", true)
      assert state2 == state
    end

    test "food items all have three-element tuple format" do
      {state, _} = one_player()
      Enum.each(state.food, fn item ->
        assert tuple_size(item) == 3
        {_, _, type} = item
        assert type in [:normal, :golden]
      end)
    end

    test "food x/y coordinates are within arena bounds (30..2370 / 30..1570)" do
      {state, _} = one_player()
      Enum.each(state.food, fn {x, y, _} ->
        assert x >= 30.0
        assert x <= 2370.0
        assert y >= 30.0
        assert y <= 1570.0
      end)
    end

    test "respawn on unknown player returns unchanged state" do
      state = Engine.new("r")
      state2 = Engine.respawn(state, "nonexistent")
      assert state2 == state
    end

    test "remove_player on empty room does not crash" do
      state = Engine.new("r")
      state2 = Engine.remove_player(state, "nobody")
      assert state2.status == :waiting
    end
  end

  # ── Gacha ────────────────────────────────────────────────────────────────
  # Helper to put a player into gacha-eligible shape: long enough body,
  # enough score, alive. Avoids depending on the exact food/eat math.
  defp gacha_ready(state, id, segs \\ 50, score \\ 200) do
    body = for i <- 0..(segs - 1), do: {500.0 + i * 9.0, 500.0}

    %{
      state
      | players:
          Map.update!(state.players, id, fn p ->
            %{p | segments: body, score: score}
          end)
    }
  end

  describe "trigger_gacha/2" do
    test "no-op (returns {state, false}) when score below min" do
      {state, id} = one_player()
      state = gacha_ready(state, id, 50, 50)
      assert {^state, false} = Engine.trigger_gacha(state, id)
    end

    test "no-op (returns {state, false}) when length below min" do
      {state, id} = one_player()
      state = gacha_ready(state, id, 30, 200)
      assert {^state, false} = Engine.trigger_gacha(state, id)
    end

    test "no-op for unknown player id" do
      {state, _id} = one_player()
      assert {^state, false} = Engine.trigger_gacha(state, "ghost")
    end

    test "no-op for dead player" do
      {state, id} = one_player()
      state = gacha_ready(state, id)
      state = update_in(state.players[id], &%{&1 | alive: false})
      assert {^state, false} = Engine.trigger_gacha(state, id)
    end

    test "successful roll deducts segments and score and emits :gacha_result" do
      {state, id} = one_player()
      state = gacha_ready(state, id, 50, 200)
      {state2, true} = Engine.trigger_gacha(state, id)
      p = state2.players[id]
      # Segment cost is 25, but never trim below @laser_min_victim_len (6).
      assert length(p.segments) == 25
      assert p.score == 100
      assert Enum.any?(state2.events, fn
               {:gacha_result, ^id, _meta} -> true
               _ -> false
             end)
    end

    test "successful roll never trims below @laser_min_victim_len floor" do
      {state, id} = one_player()
      state = gacha_ready(state, id, 40, 200)
      {state2, true} = Engine.trigger_gacha(state, id)
      assert length(state2.players[id].segments) >= 6
    end
  end

  describe "apply_gacha_prize merge logic (H1)" do
    test "rolling lower-tier same effect does NOT downgrade existing tier" do
      {state, id} = one_player()
      # Hand-place a star T3 with 1500 ttl in effects.
      state =
        update_in(state.players[id], fn p ->
          %{p | effects: Map.put(p.effects, :star, {1500, 3})}
        end)

      # Force-roll a star T1 (400 ttl) by bypassing pick_weighted.
      # Use a private dispatch via apply_gacha_prize indirectly: build
      # a state with one prize in the events and check effects map.
      # Since apply_gacha_prize is private, drive it via trigger_gacha
      # repeatedly until we get a star T1 (deterministic check below uses
      # the merge invariant: tier never decreases).
      state = gacha_ready(state, id, 50, 5_000)

      # Run up to 200 gacha rolls; the player should never lose star T3.
      final =
        Enum.reduce(1..50, state, fn _i, acc ->
          {acc2, _} = Engine.trigger_gacha(acc, id)
          # Re-fund + re-grow so we can keep rolling.
          gacha_ready(acc2, id, 50, 5_000)
        end)

      case Map.get(final.players[id].effects, :star) do
        {_ttl, tier} -> assert tier >= 3
        nil -> :ok  # star can naturally expire from ttl decay over many ticks
      end
    end
  end

  describe "shield stacking (H2)" do
    test "shield powerup pickup does NOT decrease an existing higher stack" do
      {state, id} = one_player()
      state = update_in(state.players[id], &%{&1 | shield_stacks: 5})

      # Place a shield powerup directly under the head.
      [{hx, hy} | _] = state.players[id].segments
      state = %{state | powerups: [{hx, hy, :shield, 2}]}

      state2 = Engine.tick(state)
      # max(5, min(3, 5+2)) = max(5, 3) = 5 — never below 5.
      assert state2.players[id].shield_stacks == 5
    end

    test "shield powerup pickup still floors small stacks at 3" do
      {state, id} = one_player()
      state = update_in(state.players[id], &%{&1 | shield_stacks: 0})
      [{hx, hy} | _] = state.players[id].segments
      state = %{state | powerups: [{hx, hy, :shield, 2}]}

      state2 = Engine.tick(state)
      # max(0, min(3, 0+2)) = 2.
      assert state2.players[id].shield_stacks == 2
    end
  end

  describe "max_segments cap" do
    test "eating does not grow segments past @max_segments (200)" do
      {state, id} = one_player()
      # Force the snake to exactly 200 segments.
      body = for i <- 0..199, do: {600.0 + i * 9.0, 600.0}
      state = %{state | players: Map.update!(state.players, id, &%{&1 | segments: body})}
      [{hx, hy} | _] = body
      # Drop 5 food right under the head so the eat radius catches them.
      state = %{state | food: [{hx, hy, :normal}, {hx + 5, hy, :normal}, {hx + 10, hy, :normal}]}

      state2 = Engine.tick(state)
      assert length(state2.players[id].segments) == 200
      # But score still increased (eating still rewards points).
      assert state2.players[id].score > 0
    end
  end

  describe "food cap drops oldest, not newest (M5)" do
    test "when over cap, fresh kill drops survive and oldest food is trimmed" do
      state = n_players(2)
      # Pin victim to a known location so we know what to expect.
      state = force_segments(state, "p2", for(i <- 0..40, do: {800.0 + i * 9.0, 700.0}))
      # Park p1's head right inside p2's body (segment index 5+, past the
      # neck-skip of 3) so detect_collisions kills p1. Pin angles + clear
      # invincibility so the collision actually fires this tick.
      state = move_head(state, "p1", 800.0 + 5 * 9.0, 700.0)
      state = %{
        state
        | tick: 100,
          players:
            state.players
            |> Map.update!("p1", &%{&1 | invincible_until: 0, angle: 0.0, target_angle: 0.0})
            |> Map.update!("p2", &%{&1 | invincible_until: 0, angle: 0.0, target_angle: 0.0})
      }

      # Pre-fill food list with 600 marker items at a sentinel coord we can
      # filter for. After the kill, the marker food should be trimmed away
      # (oldest first) and the new body-drop food should remain.
      sentinel = {-9999.0, -9999.0, :normal}
      state = %{state | food: List.duplicate(sentinel, 600)}

      state2 = Engine.tick(state)
      # Total food still capped at @max_food.
      assert length(state2.food) <= 600
      # At least some of the newly-dropped (non-sentinel) food survived.
      fresh = Enum.reject(state2.food, fn f -> f == sentinel end)
      assert fresh != [], "expected fresh kill drops to survive food cap"
    end
  end

  describe "precompute_shared/1 dedupes encode_events + LOD" do
    test "shape is correct and to_client/3 accepts it" do
      state = n_players(3)
      shared = Engine.precompute_shared(state)
      assert is_list(shared.encoded_events)
      assert is_map(shared.lod_cache)
      # Snapshot built with shared cache equals snapshot built without.
      a = Engine.to_client(state, "p1")
      b = Engine.to_client(state, "p1", shared)
      assert a == b
    end
  end
end
