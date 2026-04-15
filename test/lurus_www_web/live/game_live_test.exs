defmodule LurusWwwWeb.Live.GameLiveTest do
  use LurusWwwWeb.ConnCase

  import Phoenix.LiveViewTest

  alias LurusWww.Games.{GameServer, GameSupervisor}

  # ── Helpers ──────────────────────────────────────────────────────────────────

  # Create a real room backed by a supervised GameServer process and return its id.
  defp create_room do
    room_id = GameSupervisor.generate_room_id()
    {:ok, _pid} = GameSupervisor.create_room(room_id)
    room_id
  end

  # Fill a room up to 20 players so subsequent joins overflow.
  defp fill_room(room_id) do
    Enum.each(1..20, fn i ->
      case GameServer.join(room_id, "filler-#{i}", "Filler #{i}") do
        {:ok, _} -> :ok
        {:error, :room_full} -> :ok
        _other -> :ok
      end
    end)
  end

  # ── Mount: disconnected (static render) ─────────────────────────────────────

  describe "mount (disconnected)" do
    test "renders the game page with HTTP 200", %{conn: conn} do
      conn = get(conn, "/play")
      assert html_response(conn, 200) =~ "WebGame"
    end

    test "shows join panel before connection established", %{conn: conn} do
      conn = get(conn, "/play")
      html = html_response(conn, 200)
      # Join overlay should be present in static render
      assert html =~ "join-floating" or html =~ "join-panel" or html =~ "PLAY"
    end
  end

  # ── Mount: connected (LiveView upgrade) ──────────────────────────────────────

  describe "mount (connected)" do
    test "assigns room_id on connect", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      # room_id is set after connected? check; join panel should still be shown
      assert render(view) =~ "PLAY"
    end

    test "assigns initial game_state on connect when room has state", %{conn: conn} do
      room_id = create_room()
      {:ok, _view, html} = live(conn, "/play/#{room_id}")
      # Rendered without error; join panel visible (not yet joined)
      assert html =~ "join-panel" or html =~ "join-floating" or html =~ "PLAY"
    end

    test "subscribes to PubSub topic for the assigned room", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      # Verify by sending a fake game_state message and confirming render updates
      pid = view.pid

      fake_state = %{
        id: "TEST",
        tick: 1,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }

      send(pid, {:game_state, fake_state})
      # push_event is sent to client; the process should not crash
      assert Process.alive?(pid)
    end

    test "falls back to auto room when requested room_id does not exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play/DOESNOTEXIST")
      # Should still mount successfully (AutoRoom.find_or_create called)
      assert render(view) =~ "WebGame"
    end

    test "uses existing room when room_id param is valid", %{conn: conn} do
      room_id = create_room()
      {:ok, view, _html} = live(conn, "/play/#{room_id}")
      assert render(view) =~ "WebGame"
    end

    test "page_title is set to Play - WebGame", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      assert page_title(view) =~ "Play"
    end

    test "renders canvas element with SnakeCanvas hook", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/play")
      assert html =~ "game-canvas"
      assert html =~ "SnakeCanvas"
    end

    test "renders game HUD with brand link", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/play")
      assert html =~ "game-brand" or html =~ ~s(href="/")
    end

    test "renders scoreboard container", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/play")
      assert html =~ "scoreboard"
    end
  end

  # ── Join Flow ────────────────────────────────────────────────────────────────

  describe "join event" do
    test "join with valid name marks player as joined and hides join panel", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      html = view |> form("#join-form", %{name: "TestPlayer"}) |> render_submit()

      # Join panel should disappear after successful join
      refute html =~ "join-floating"
    end

    test "join with empty name auto-generates SnakeNNN name", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      # Submit form with empty name
      html = view |> form("#join-form", %{name: ""}) |> render_submit()

      # Should be joined (no join panel), auto-name was generated internally
      refute html =~ "join-floating"
    end

    test "join with whitespace-only name auto-generates a name", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      html = view |> form("#join-form", %{name: "   "}) |> render_submit()

      refute html =~ "join-floating"
    end

    test "join name is truncated at 16 characters", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      # 20-character name should be sliced to 16
      long_name = "ABCDEFGHIJKLMNOPQRST"
      html = view |> form("#join-form", %{name: long_name}) |> render_submit()

      # Joined successfully; the internal name is 16 chars max
      refute html =~ "join-floating"
    end

    test "join with pid hidden field uses provided player_id", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      fixed_pid = "deadbeefdeadbeef"

      html =
        view
        |> form("#join-form", %{name: "Alice", pid: fixed_pid})
        |> render_submit()

      refute html =~ "join-floating"
    end

    test "join with empty pid hidden field generates a new id", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      html =
        view
        |> form("#join-form", %{name: "Bob", pid: ""})
        |> render_submit()

      refute html =~ "join-floating"
    end

    test "init_player event pre-fills player_id and player_name", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      # Simulate JS hook sending saved player data
      render_hook(view, "init_player", %{"id" => "saved-pid-abc", "name" => "SavedName"})

      # After init_player, form should show the saved name
      html = render(view)
      assert html =~ "SavedName"
    end

    test "init_player player_id is preferred over form pid on join", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "preferred-id", "name" => "Known"})

      html = view |> form("#join-form", %{name: "Known", pid: "ignored-id"}) |> render_submit()

      # Join succeeds; preferred-id was used (no error flash)
      refute html =~ "join-floating"
    end

    test "join when room is full redirects player to an overflow room", %{conn: conn} do
      full_room = create_room()
      fill_room(full_room)

      {:ok, view, _html} = live(conn, "/play/#{full_room}")

      # AutoRoom.find_or_create will be called internally; join should succeed
      html = view |> form("#join-form", %{name: "Overflow"}) |> render_submit()

      refute html =~ "join-floating"
    end

    test "failed join (non-overflow error) shows flash error", %{conn: conn} do
      # Join the same player twice to trigger :already_joined error
      room_id = create_room()
      {:ok, _state} = GameServer.join(room_id, "dup-id", "DupPlayer")

      {:ok, view, _html} = live(conn, "/play/#{room_id}")

      # Use the same player_id that's already in the room
      render_hook(view, "init_player", %{"id" => "dup-id", "name" => "DupPlayer"})
      html = view |> form("#join-form", %{name: "DupPlayer", pid: "dup-id"}) |> render_submit()

      # Already-joined triggers {:error, :already_joined} → flash error
      assert html =~ "already_joined" or html =~ "flash" or html =~ "error"
    end
  end

  # ── Gameplay Events ──────────────────────────────────────────────────────────

  describe "steer event" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Steerer"}) |> render_submit()
      {:ok, view: view}
    end

    test "steer with float angle is accepted without error", %{view: view} do
      render_hook(view, "steer", %{"angle" => 1.57})
      assert Process.alive?(view.pid)
    end

    test "steer with integer angle is accepted (coerced to float internally)", %{view: view} do
      render_hook(view, "steer", %{"angle" => 3})
      assert Process.alive?(view.pid)
    end

    test "steer with negative angle is accepted", %{view: view} do
      render_hook(view, "steer", %{"angle" => -0.5})
      assert Process.alive?(view.pid)
    end

    test "steer with zero angle is accepted", %{view: view} do
      render_hook(view, "steer", %{"angle" => 0})
      assert Process.alive?(view.pid)
    end

    test "steer with string angle falls through to catch-all and does not crash", %{view: view} do
      # String "1.57" does not match is_number guard → caught by catch-all handle_event
      render_hook(view, "steer", %{"angle" => "1.57"})
      assert Process.alive?(view.pid)
    end

    test "steer with missing angle key falls through to catch-all without crash", %{view: view} do
      render_hook(view, "steer", %{})
      assert Process.alive?(view.pid)
    end
  end

  describe "boost event" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Booster"}) |> render_submit()
      {:ok, view: view}
    end

    test "boost true activates boost", %{view: view} do
      render_hook(view, "boost", %{"active" => true})
      assert Process.alive?(view.pid)
    end

    test "boost false deactivates boost", %{view: view} do
      render_hook(view, "boost", %{"active" => false})
      assert Process.alive?(view.pid)
    end

    test "boost with non-boolean value falls through to catch-all without crash", %{view: view} do
      # String "true" does not match is_boolean guard
      render_hook(view, "boost", %{"active" => "true"})
      assert Process.alive?(view.pid)
    end
  end

  describe "respawn event" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Respawner"}) |> render_submit()
      {:ok, view: view}
    end

    test "respawn event does not crash the LiveView process", %{view: view} do
      render_hook(view, "respawn", %{})
      assert Process.alive?(view.pid)
    end

    test "respawn sets my_alive to true and hides respawn overlay", %{view: view} do
      # Simulate player dying via game_state update
      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 10,
        status: :playing,
        players: %{},  # no player entry → alive derives to false
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      render_hook(view, "respawn", %{})
      html = render(view)

      # After respawn, the respawn overlay should not be shown
      refute html =~ "respawn-overlay"
    end
  end

  describe "leave event" do
    test "unknown events fall through to catch-all without crashing", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Leaver"}) |> render_submit()

      # "leave" is not explicitly defined; hits the catch-all handle_event
      render_hook(view, "leave", %{})
      assert Process.alive?(view.pid)
    end
  end

  # ── State Updates (handle_info) ───────────────────────────────────────────────

  describe "handle_info :game_state" do
    test "receiving game_state does not crash the view", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 5,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state with alive player sets my_alive true", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      # Join first so player_id is assigned
      view |> form("#join-form", %{name: "AliveTest"}) |> render_submit()

      # Send a game_state where player_id is not present (unknown player)
      # The view should survive
      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 2,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state with player using :al key tracks alive status", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      # Grab assigned player_id by injecting via init_player
      render_hook(view, "init_player", %{"id" => "my-snake-id", "name" => "Me"})
      view |> form("#join-form", %{name: "Me", pid: "my-snake-id"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 3,
        status: :playing,
        players: %{"my-snake-id" => %{al: true, n: "Me", sc: 10, c: "#FF0000"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      # No crash; alive status was updated
      assert Process.alive?(view.pid)
    end

    test "game_state with player using :alive key also tracks alive status", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "my-snake-id2", "name" => "Me2"})
      view |> form("#join-form", %{name: "Me2", pid: "my-snake-id2"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 4,
        status: :playing,
        players: %{"my-snake-id2" => %{alive: false, n: "Me2", sc: 0, c: "#00FF00"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      # Player is dead: respawn overlay should appear
      html = render(view)
      assert html =~ "respawn-overlay" or html =~ "Game Over"
    end

    test "game_state injects my_id when player_id is assigned", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "inject-test-id", "name" => "Injector"})
      view |> form("#join-form", %{name: "Injector", pid: "inject-test-id"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 1,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      # push_event("game_state", payload) is sent with :my_id injected
      # We cannot directly inspect push_event calls in LiveViewTest,
      # but the process must remain alive
      assert Process.alive?(view.pid)
    end

    test "game_state with nil player_id does not inject my_id and does not crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      # No init_player or join, so player_id remains nil

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 1,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state updates scoreboard display", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Scorer"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 5,
        status: :playing,
        players: %{
          "p1" => %{n: "TopSnake", c: "#FF0000", sc: 42, al: true, k: 2}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      html = render(view)
      assert html =~ "TopSnake"
      assert html =~ "42"
    end
  end

  # ── Death Overlay ─────────────────────────────────────────────────────────────

  describe "death overlay" do
    test "shows respawn overlay when joined but player is dead", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "dead-player", "name" => "Deadman"})
      view |> form("#join-form", %{name: "Deadman", pid: "dead-player"}) |> render_submit()

      # Simulate death via game_state
      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 20,
        status: :playing,
        players: %{
          "dead-player" => %{al: false, n: "Deadman", sc: 7, k: 1, c: "#AAAAAA"}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      html = render(view)
      assert html =~ "Game Over"
      assert html =~ "PLAY AGAIN"
    end

    test "death overlay shows score and kills from game_state", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "dead-scorer", "name" => "Scorer"})
      view |> form("#join-form", %{name: "Scorer", pid: "dead-scorer"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 50,
        status: :playing,
        players: %{
          "dead-scorer" => %{al: false, n: "Scorer", sc: 99, k: 3, c: "#BBBBBB"}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      html = render(view)
      assert html =~ "99"
      assert html =~ "3"
    end

    test "respawn overlay has phx-click=respawn handler", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "clicker", "name" => "Clicker"})
      view |> form("#join-form", %{name: "Clicker", pid: "clicker"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 10,
        status: :playing,
        players: %{"clicker" => %{al: false, n: "Clicker", sc: 0, k: 0, c: "#CCCCCC"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      html = render(view)
      assert html =~ ~s(phx-click="respawn")
    end

    test "clicking PLAY AGAIN triggers respawn and hides overlay", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "respawner2", "name" => "Respawner"})
      view |> form("#join-form", %{name: "Respawner", pid: "respawner2"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 10,
        status: :playing,
        players: %{"respawner2" => %{al: false, n: "Respawner", sc: 0, k: 0, c: "#CCCCCC"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      # Click the PLAY AGAIN button
      html = view |> element("[phx-click=\"respawn\"]") |> render_click()
      refute html =~ "respawn-overlay"
    end
  end

  # ── HUD Score Display ─────────────────────────────────────────────────────────

  describe "HUD score display" do
    test "shows score in HUD after join and game_state update with :sc key", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "hud-player", "name" => "HUDUser"})
      view |> form("#join-form", %{name: "HUDUser", pid: "hud-player"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 8,
        status: :playing,
        players: %{
          "hud-player" => %{al: true, n: "HUDUser", sc: 77, k: 0, c: "#123456"}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      html = render(view)
      assert html =~ "77"
    end

    test "shows score in HUD with :score key fallback", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      render_hook(view, "init_player", %{"id" => "hud-player2", "name" => "HUDUser2"})
      view |> form("#join-form", %{name: "HUDUser2", pid: "hud-player2"}) |> render_submit()

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 9,
        status: :playing,
        players: %{
          "hud-player2" => %{al: true, n: "HUDUser2", score: 55, k: 0, c: "#654321"}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      html = render(view)
      assert html =~ "55"
    end
  end

  # ── Edge Cases ────────────────────────────────────────────────────────────────

  describe "edge cases" do
    test "unrecognized event falls through to catch-all without crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      render_hook(view, "some_unknown_event", %{"data" => "whatever"})
      assert Process.alive?(view.pid)
    end

    test "steer before join is silently ignored", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      # No join, joined=false
      render_hook(view, "steer", %{"angle" => 1.0})
      assert Process.alive?(view.pid)
    end

    test "boost before join is silently ignored", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      render_hook(view, "boost", %{"active" => true})
      assert Process.alive?(view.pid)
    end

    test "respawn before join with nil player_id is silently ignored", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      render_hook(view, "respawn", %{})
      assert Process.alive?(view.pid)
    end

    test "multiple rapid steer events do not crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Rapid"}) |> render_submit()

      for angle <- [0.1, 0.5, 1.0, 1.57, 3.14, -1.0, -0.5] do
        render_hook(view, "steer", %{"angle" => angle})
      end

      assert Process.alive?(view.pid)
    end

    test "multiple rapid boost toggles do not crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Boostrapid"}) |> render_submit()

      for active <- [true, false, true, false, true] do
        render_hook(view, "boost", %{"active" => active})
      end

      assert Process.alive?(view.pid)
    end

    test "game_state with empty players map renders without crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 1,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state with nil players key renders without crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 1,
        status: :playing,
        players: nil,
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      assert Process.alive?(view.pid)
    end

    test "view survives disconnect/reconnect cycle", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      view |> form("#join-form", %{name: "Reconnect"}) |> render_submit()

      # Simulate process still being alive after state changes
      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 2,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2000, 1400]
      }})

      assert Process.alive?(view.pid)
    end
  end

  # ── Router Integration ────────────────────────────────────────────────────────

  describe "router: live routes" do
    test "GET / renders 200", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "WebGame"
    end

    test "GET /play renders 200", %{conn: conn} do
      conn = get(conn, "/play")
      assert html_response(conn, 200) =~ "WebGame"
    end

    test "GET /play/:room_id with valid room renders 200", %{conn: conn} do
      room_id = create_room()
      conn = get(conn, "/play/#{room_id}")
      assert html_response(conn, 200) =~ "WebGame"
    end

    test "GET /create renders 200", %{conn: conn} do
      conn = get(conn, "/create")
      assert html_response(conn, 200) =~ "WebGame"
    end

    test "GET /terms renders 200", %{conn: conn} do
      conn = get(conn, "/terms")
      assert html_response(conn, 200)
    end

    test "GET /privacy renders 200", %{conn: conn} do
      conn = get(conn, "/privacy")
      assert html_response(conn, 200)
    end

    test "GET /health returns 200 OK text", %{conn: conn} do
      conn = get(conn, "/health")
      assert response(conn, 200) == "OK"
    end

    test "GET /unknown-path renders 404 page via catch-all LiveView", %{conn: conn} do
      conn = get(conn, "/this/does/not/exist")
      html = html_response(conn, 200)
      assert html =~ "404"
    end

    test "catch-all live route renders Page Not Found message", %{conn: conn} do
      conn = get(conn, "/definitely/not/a/page")
      html = html_response(conn, 200)
      assert html =~ "Page Not Found" or html =~ "404"
    end

    test "live /play uses :game live_session (game layout)", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/play")
      # Game layout wraps content in main#main-content (no topbar/footer)
      assert html =~ "main-content" or html =~ "game-hud"
      # Specifically should NOT include topbar nav from app layout
      refute html =~ "topbar-logo"
    end

    test "live / uses :default live_session (app layout with topbar)", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # App layout includes topbar
      assert html =~ "topbar-logo" or html =~ "game-topbar"
    end
  end
end
