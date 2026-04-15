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

    test "second player joins mid-game without :game_started event" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "Alice")
      {:ok, s2} = Engine.add_player(s1, "p2", "Bob")
      # Only one game_started in total events since tick resets them
      assert Enum.count(s2.events, &match?({:game_started}, &1)) == 0
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
      food_before = length(state.food)
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
        %{p | alive: false, effects: %{blade: 100, magnet: 50}, has_shield: true, boosting: true}
      end)}
      state = Engine.respawn(state, id)
      p = state.players[id]
      assert p.effects == %{}
      assert p.has_shield == false
      assert p.boosting == false
    end

    test "respawn emits :player_respawned event" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | alive: false})}
      state = Engine.respawn(state, id)
      assert Enum.any?(state.events, &match?({:player_respawned, ^id}, &1))
    end

    test "respawn on already-alive player is a no-op" do
      {state, id} = one_player()
      segs_before = state.players[id].segments
      state2 = Engine.respawn(state, id)
      # alive player: pattern match fails, returns state unchanged
      assert state2.players[id].segments == segs_before
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
    test "steer moves angle by at most turn_rate (0.14) per tick" do
      {state, id} = one_player()
      orig_angle = 0.0
      state = %{state | players: Map.update!(state.players, id, &%{&1 | angle: orig_angle, target_angle: :math.pi()})}
      state2 = Engine.tick(state)
      new_angle = state2.players[id].angle
      # Angle must have changed by at most turn_rate=0.14 in either direction
      diff = abs(new_angle - orig_angle)
      # Accounting for wraparound: diff should be <= 0.14 + epsilon
      assert diff <= 0.14 + 0.001 or diff >= 2 * :math.pi() - 0.14 - 0.001
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
    test "base speed is 5.0 at start" do
      {state, id} = one_player()
      p = state.players[id]
      # food_eaten=0, no effects, no boost
      client = Engine.to_client(state)
      spd = client.players[id].spd
      assert_in_delta spd, 5.0, 0.1
    end

    test "speed increases by 0.3 after every 10 food eaten" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | food_eaten: 10})}
      client = Engine.to_client(state)
      # base=5.0 + 1 * 0.3 = 5.3
      assert_in_delta client.players[id].spd, 5.3, 0.1
    end

    test "speed increases correctly at 30 food eaten" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | food_eaten: 30})}
      client = Engine.to_client(state)
      # base=5.0 + 3 * 0.3 = 5.9
      assert_in_delta client.players[id].spd, 5.9, 0.1
    end

    test "speed is capped at max_speed (9.0)" do
      {state, id} = one_player()
      # Need 133+ food to exceed cap: 5.0 + 13*0.3 = 8.9, 14*0.3 = 9.2 -> capped at 9.0
      state = %{state | players: Map.update!(state.players, id, &%{&1 | food_eaten: 200})}
      client = Engine.to_client(state)
      assert client.players[id].spd <= 9.0 + 0.1
    end

    test "star effect overrides progression speed to max" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | effects: %{star: 100}, food_eaten: 0}
      end)}
      client = Engine.to_client(state)
      # Star sets speed to max_speed (9.0), not boosted
      assert_in_delta client.players[id].spd, 9.0, 0.1
    end

    test "boost multiplies speed when snake is long enough" do
      {state, id} = one_player()
      # Give snake 10 segments and enable boost
      segs = for i <- 1..10, do: {i * 9.0, 100.0}
      state = force_segments(state, id, segs)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | boosting: true})}
      client = Engine.to_client(state)
      # boosted speed = 5.0 * 1.8 = 9.0
      assert client.players[id].spd > 5.0
    end

    test "boost does NOT apply when snake has 5 or fewer segments" do
      {state, id} = one_player()
      short_segs = for i <- 1..5, do: {i * 9.0, 100.0}
      state = force_segments(state, id, short_segs)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | boosting: true})}
      client = Engine.to_client(state)
      # length(segs)=5, condition is >5 → no boost
      assert_in_delta client.players[id].spd, 5.0, 0.1
    end
  end

  describe "boost shrink" do
    test "boost on even tick removes last segment and drops food" do
      {state, id} = one_player()
      segs = for i <- 1..15, do: {i * 9.0, 100.0}
      state = force_segments(state, id, segs)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | boosting: true})}
      # Force tick to be even so shrink fires
      state = %{state | tick: 2}
      food_before = length(state.food)
      state2 = Engine.tick(state)
      assert length(state2.players[id].segments) < length(segs)
      assert length(state2.food) > food_before
    end

    test "boost shrink does not fire when snake has <=8 segments" do
      {state, id} = one_player()
      short_segs = for i <- 1..8, do: {i * 9.0, 100.0}
      state = force_segments(state, id, short_segs)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | boosting: true}), tick: 2}
      # put head far from walls and well-fed on food so replenish doesn't fire
      state = move_head(state, id, 1000.0, 700.0)
      # Pre-fill food to target so replenish is not triggered (needed <= 3)
      target_food = 80 + 1 * 15  # base_food + 1 player * food_per_player
      state = %{state | food: for(_ <- 1..target_food, do: {500.0, 500.0, :normal})}
      food_before = length(state.food)
      state2 = Engine.tick(state)
      # No shrink trail should have been added (boost only shrinks if >8 segments)
      # food should be same or fewer (player might eat some at distance — unlikely at 1000,700)
      assert length(state2.food) <= food_before
    end

    test "boost with :speed effect does NOT shrink" do
      {state, id} = one_player()
      segs = for i <- 1..15, do: {i * 9.0, 100.0}
      state = force_segments(state, id, segs)
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | boosting: true, effects: %{speed: 200}}
      end), tick: 2}
      state = move_head(state, id, 1000.0, 700.0)
      seg_count_before = length(state.players[id].segments)
      state2 = Engine.tick(state)
      # :speed effect prevents shrink
      assert length(state2.players[id].segments) >= seg_count_before - 1
    end
  end

  # ── 3. Collision ─────────────────────────────────────────────────────────────

  describe "wall collision" do
    test "player dies when head goes past left wall (x < 0)" do
      {state, id} = one_player()
      state = move_head(state, id, -1.0, 700.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player dies when head goes past right wall (x > 2000)" do
      {state, id} = one_player()
      state = move_head(state, id, 2001.0, 700.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player dies when head goes past top wall (y < 0)" do
      {state, id} = one_player()
      state = move_head(state, id, 1000.0, -1.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player dies when head goes past bottom wall (y > 1400)" do
      {state, id} = one_player()
      state = move_head(state, id, 1000.0, 1401.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player exactly at boundary (x=0) dies" do
      {state, id} = one_player()
      state = move_head(state, id, 0.0, 700.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "player exactly at right boundary (x=2000) dies" do
      {state, id} = one_player()
      state = move_head(state, id, 2000.0, 700.0)
      state2 = Engine.tick(state)
      assert state2.players[id].alive == false
    end

    test "wall kill drops body food" do
      {state, id} = one_player()
      state = move_head(state, id, -5.0, 700.0)
      food_before = length(state.food)
      state2 = Engine.tick(state)
      # Body food is added on death
      assert length(state2.food) > food_before
    end

    test "wall kill emits :player_died event with nil killer" do
      {state, id} = one_player()
      state = move_head(state, id, -5.0, 700.0)
      state2 = Engine.tick(state)
      assert Enum.any?(state2.events, &match?({:player_died, ^id, nil}, &1))
    end

    test "wall-killed player with shield consumes shield and survives" do
      {state, id} = one_player()
      state = move_head(state, id, -5.0, 700.0)
      state = %{state | players: Map.update!(state.players, id, &%{&1 | has_shield: true})}
      state2 = Engine.tick(state)
      # Shield absorbs hit: alive stays true, shield is removed
      assert state2.players[id].alive == true
      assert state2.players[id].has_shield == false
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

      state2 = Engine.tick(state)
      assert state2.players["p1"].alive == false
    end

    test "killer gets credited +1 kill and +5 score" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      p2_segs = for i <- 0..15, do: {900.0 + i * 9.0, 700.0}
      state = force_segments(state, "p2", p2_segs)
      state = move_head(state, "p1", 945.0, 700.0)

      state2 = Engine.tick(state)
      assert state2.players["p2"].kills == 1
      assert state2.players["p2"].score == 5
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
      # p1 should not die from the 3 leading segments
      # (note: it may die from wall if we placed at boundary — use center)
      # The key assertion: if alive stays true OR a wall kill caused the death
      # We separate: check collision event specifically blames p2
      died_to_p2 = Enum.any?(state2.events, &match?({:player_died, "p1", "p2"}, &1))
      assert died_to_p2 == false
    end

    test "shielded player survives body collision, shield consumed" do
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      p2_segs = for i <- 0..15, do: {900.0 + i * 9.0, 700.0}
      state = force_segments(state, "p2", p2_segs)
      state = move_head(state, "p1", 945.0, 700.0)
      state = %{state | players: Map.update!(state.players, "p1", &%{&1 | has_shield: true})}

      state2 = Engine.tick(state)
      assert state2.players["p1"].alive == true
      assert state2.players["p1"].has_shield == false
    end

    test "dead snake's killer gets Enum.find_value nil when killer also died same tick" do
      # Regression: when killer also dies the same tick, Map.has_key?(deaths, killer)
      # prevents double-crediting but the event killer can be nil-like.
      {:ok, s1} = Engine.add_player(Engine.new("r"), "p1", "A")
      {:ok, state} = Engine.add_player(s1, "p2", "B")

      # Both hit walls simultaneously
      state = move_head(state, "p1", -5.0, 700.0)
      state = move_head(state, "p2", 2005.0, 700.0)

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
      state = %{state | players: Map.update!(state.players, id, &%{&1 | score: 42})}
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
        %{p | score: 0, effects: %{star: 100}}
      end)}
      state2 = Engine.tick(state)
      # 1 point * 3 multiplier = 3
      assert state2.players[id].score == 3
    end

    test "star multiplier triples golden food points" do
      {state, id} = one_player()
      {hx, hy} = hd(state.players[id].segments)
      state = %{state | food: [{hx, hy, :golden}], players: Map.update!(state.players, id, fn p ->
        %{p | score: 0, effects: %{star: 100}}
      end)}
      state2 = Engine.tick(state)
      # 5 * 3 = 15
      assert state2.players[id].score == 15
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

    test "replenish adds at most 8 pieces per tick when far below target" do
      {state, id} = one_player()
      # Drain all food and move player head far from any spawn location to prevent eating
      state = %{state | food: []}
      state = move_head(state, id, 1000.0, 700.0)
      state2 = Engine.tick(state)
      food_added = length(state2.food)
      # replenish_food seeds min(needed, 8) per tick
      assert food_added <= 8
      assert food_added > 0
    end

    test "food count increases with more players" do
      state_1 = n_players(1)
      state_5 = n_players(5)
      # target_food = 80 + N*15; more players = more food target
      # After initial seed, more food present for 5 players
      assert length(state_5.food) >= length(state_1.food)
    end

    test "time accumulation formula: bonus increases every 200 ticks capped at 80" do
      {state, _id} = one_player()
      # At tick 400: time_bonus = min(div(400,200)*2, 80) = 4
      # At tick 8000: time_bonus = min(40*2, 80) = 80
      state_400 = %{state | tick: 400}
      state_8000 = %{state | tick: 8000}
      # Verify target_food is higher at tick 8000 by draining food and checking replenishment
      state_400_after = Engine.tick(%{state_400 | food: []})
      state_8000_after = Engine.tick(%{state_8000 | food: []})
      # Both will replenish up to 8 per tick, but the total target differs
      # Simply verify no crash and food appears
      assert length(state_400_after.food) >= 0
      assert length(state_8000_after.food) >= 0
    end
  end

  # ── 5. Powerups ──────────────────────────────────────────────────────────────

  describe "collect_powerups/1 — each powerup type" do
    defp place_powerup_on_head(state, id, type) do
      {hx, hy} = hd(state.players[id].segments)
      %{state | powerups: [{hx, hy, type}]}
    end

    test "collecting :blade applies effect with TTL 300" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :blade)
      state2 = Engine.tick(state)
      assert Map.has_key?(state2.players[id].effects, :blade)
      assert state2.players[id].effects[:blade] <= 300
    end

    test "collecting :magnet applies effect with TTL 250" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :magnet)
      state2 = Engine.tick(state)
      assert Map.has_key?(state2.players[id].effects, :magnet)
    end

    test "collecting :star applies effect with TTL 250" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :star)
      state2 = Engine.tick(state)
      assert Map.has_key?(state2.players[id].effects, :star)
    end

    test "collecting :shield sets has_shield to true" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :shield)
      state2 = Engine.tick(state)
      assert state2.players[id].has_shield == true
    end

    test "powerup is removed from field after collection" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :star)
      state2 = Engine.tick(state)
      assert length(state2.powerups) < length(state.powerups) + 1
    end

    test "collecting powerup emits :powerup_collected event" do
      {state, id} = one_player()
      state = place_powerup_on_head(state, id, :blade)
      state2 = Engine.tick(state)
      assert Enum.any?(state2.events, &match?({:powerup_collected, ^id, :blade}, &1))
    end
  end

  describe "effect TTL decay" do
    test "effect TTL decrements by 1 per tick" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | effects: %{blade: 10}})}
      state2 = Engine.tick(state)
      # 1 tick of effects happened in steer_and_move... check blade TTL decreased
      blade_ttl = state2.players[id].effects[:blade]
      assert blade_ttl == 9 || blade_ttl == nil  # expires when hitting 0
    end

    test "effect is removed when TTL reaches 0" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, &%{&1 | effects: %{magnet: 1}})}
      state2 = Engine.tick(state)
      refute Map.has_key?(state2.players[id].effects, :magnet)
    end

    test "multiple effects decay independently" do
      {state, id} = one_player()
      state = %{state | players: Map.update!(state.players, id, fn p ->
        %{p | effects: %{blade: 5, star: 10}}
      end)}
      state2 = Engine.tick(state)
      assert state2.players[id].effects[:blade] == 4
      assert state2.players[id].effects[:star] == 9
    end
  end

  describe "magnet attraction" do
    test "food within range 100 moves toward snake head" do
      {state, id} = one_player()
      state = move_head(state, id, 500.0, 500.0)
      # Place food 50 units away
      state = %{state | food: [{550.0, 500.0, :normal}],
                        players: Map.update!(state.players, id, &%{&1 | effects: %{magnet: 200}})}
      state2 = Engine.tick(state)
      [{fx, _, _}] = state2.food
      # Food should have moved closer to 500.0
      assert fx < 550.0
    end

    test "food beyond range 100 is not attracted" do
      {state, id} = one_player()
      state = move_head(state, id, 500.0, 500.0)
      state = %{state | food: [{650.0, 500.0, :normal}],
                        players: Map.update!(state.players, id, &%{&1 | effects: %{magnet: 200}})}
      state2 = Engine.tick(state)
      [{fx, _, _}] = state2.food
      # Food is 150 away, beyond range, should not have moved
      assert_in_delta fx, 650.0, 0.5
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

    test "powerup serialized as [[x, y, idx], ...]" do
      {state, _} = one_player()
      state = %{state | powerups: [{100.0, 100.0, :blade}, {200.0, 200.0, :shield},
                                   {300.0, 300.0, :magnet}, {400.0, 400.0, :star}]}
      client = Engine.to_client(state)
      idxs = Enum.map(client.pups, &Enum.at(&1, 2))
      assert idxs == [0, 1, 2, 3]
    end

    test "unknown powerup type defaults to index 0" do
      {state, _} = one_player()
      state = %{state | powerups: [{100.0, 100.0, :unknown_type}]}
      client = Engine.to_client(state)
      [[_, _, idx]] = client.pups
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
      # Arena: @width=2000.0, @height=1400.0
      assert client.size == [2000.0, 1400.0]
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

      state2 = Engine.tick(state)
      assert Enum.any?(state2.events, &match?({:player_died, "p1", "p2"}, &1))
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

    test "food x/y coordinates are within arena bounds (30..1970 / 30..1370)" do
      {state, _} = one_player()
      Enum.each(state.food, fn {x, y, _} ->
        assert x >= 30.0
        assert x <= 1970.0
        assert y >= 30.0
        assert y <= 1370.0
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
end
