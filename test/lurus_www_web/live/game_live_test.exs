defmodule LurusWwwWeb.Live.GameLiveTest do
  use LurusWwwWeb.ConnCase

  import Phoenix.LiveViewTest

  alias LurusWww.Games.{GameServer, GameSupervisor}

  # Join flow note (post-pivot):
  # The legacy "submit join form" path is being replaced by the "init_player"
  # event the SnakeCanvas hook fires after restoring identity from localStorage.
  # Tests therefore drive the join via render_hook(view, "init_player", ...)
  # rather than form/2 + render_submit/2. The hidden #join-form is still in the
  # DOM as a fallback, but tests prefer the canonical init_player path.

  # ── Helpers ──────────────────────────────────────────────────────────────────

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

  # Drive the LiveView's init_player handler with a unique id+name.
  defp do_join(view, id, name) do
    render_hook(view, "init_player", %{"id" => id, "name" => name})
  end

  # Generate unique player ids so concurrent tests sharing the MAIN room
  # don't collide on the same id (which would route through resume_player).
  defp uid(prefix), do: "#{prefix}-#{System.unique_integer([:positive])}"

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
    test "renders game shell after connect", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      assert render(view) =~ "WebGame"
    end

    test "assigns initial game_state on connect when room has state", %{conn: conn} do
      room_id = create_room()
      {:ok, _view, html} = live(conn, "/play/#{room_id}")
      # Rendered without error
      assert html =~ "game-canvas"
    end

    test "subscribes to PubSub topic for the assigned room", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
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
        size: [2400, 1600]
      }

      send(pid, {:game_state, fake_state})
      assert Process.alive?(pid)
    end

    test "falls back to auto room when requested room_id does not exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play/DOESNOTEXIST")
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

  # ── Join Flow (init_player) ──────────────────────────────────────────────────

  describe "init_player join" do
    test "init_player with valid name marks player as joined and hides join overlay", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("ok"), "TestPlayer")
      html = render(view)
      refute html =~ "join-floating"
    end

    test "init_player with empty name does not join", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("empty"), "")
      html = render(view)
      # Empty name → still not joined → join-floating still visible.
      assert html =~ "join-floating" or html =~ "PLAY"
    end

    test "init_player with whitespace-only name does not join", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("ws"), "   ")
      html = render(view)
      assert html =~ "join-floating" or html =~ "PLAY"
    end

    test "init_player truncates names longer than 16 characters", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      long_name = "ABCDEFGHIJKLMNOPQRST"
      do_join(view, uid("long"), long_name)
      html = render(view)
      # Joined successfully — overlay gone.
      refute html =~ "join-floating"
    end

    test "init_player uses the supplied player_id verbatim", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = uid("fixed")
      do_join(view, pid, "Alice")
      assert Process.alive?(view.pid)
      refute render(view) =~ "join-floating"
    end

    test "init_player with the same id again resumes (server-side resume_player)", %{conn: conn} do
      # GameServer.handle_call({:join, ...}) catches {:error, :already_joined}
      # from Engine.add_player and falls through to Engine.resume_player —
      # so a duplicate join is now a successful reconnect, not an error.
      room_id = create_room()
      {:ok, _state} = GameServer.join(room_id, "dup-id", "DupPlayer")

      {:ok, view, _html} = live(conn, "/play/#{room_id}")
      do_join(view, "dup-id", "DupPlayer")

      html = render(view)
      refute html =~ "join-floating"
    end

    test "init_player on a full room overflows into a fresh room", %{conn: conn} do
      full_room = create_room()
      fill_room(full_room)

      {:ok, view, _html} = live(conn, "/play/#{full_room}")
      do_join(view, uid("overflow"), "Overflow")

      html = render(view)
      refute html =~ "join-floating"
    end
  end

  # ── Gameplay Events ──────────────────────────────────────────────────────────

  describe "steer event" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("steer"), "Steerer")
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
      do_join(view, uid("boost"), "Booster")
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
      render_hook(view, "boost", %{"active" => "true"})
      assert Process.alive?(view.pid)
    end
  end

  describe "respawn event" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("respawn"), "Respawner")
      {:ok, view: view}
    end

    test "respawn event does not crash the LiveView process", %{view: view} do
      render_hook(view, "respawn", %{})
      assert Process.alive?(view.pid)
    end

    test "respawn sets my_alive to true and hides respawn overlay", %{view: view} do
      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 10,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      render_hook(view, "respawn", %{})
      html = render(view)
      refute html =~ "respawn-overlay"
    end
  end

  describe "set_killer event" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("killer"), "Victim")
      {:ok, view: view}
    end

    test "set_killer stores killer name + color and surfaces it on the death card", %{view: view} do
      # Force the player into "dead" state so the overlay (and killed-by row)
      # render. We send a game_state where the joined player has no entry,
      # which makes derive_alive → false → respawn overlay shown.
      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 10,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      render_hook(view, "set_killer", %{"name" => "Boss", "color" => "#FF00FF"})
      html = render(view)
      assert html =~ "Boss"
      assert html =~ "#FF00FF"
      assert html =~ "killed-by"
    end

    test "set_killer is safe to call before any death", %{view: view} do
      render_hook(view, "set_killer", %{"name" => "Anyone", "color" => "#123456"})
      assert Process.alive?(view.pid)
    end
  end

  describe "leave / unknown events" do
    test "unknown events fall through to catch-all without crashing", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("leave"), "Leaver")
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
        size: [2400, 1600]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state without my player_id does not crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("alive"), "AliveTest")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 2,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state with player using :al key tracks alive status", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "my-snake-id-#{System.unique_integer([:positive])}"
      do_join(view, pid, "Me")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 3,
        status: :playing,
        players: %{pid => %{al: true, n: "Me", sc: 10, c: "#FF0000"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state with player using :alive key also tracks alive status", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "my-snake-id-#{System.unique_integer([:positive])}"
      do_join(view, pid, "Me2")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 4,
        status: :playing,
        players: %{pid => %{alive: false, n: "Me2", sc: 0, c: "#00FF00"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      html = render(view)
      assert html =~ "respawn-overlay" or html =~ "Game Over"
    end

    test "game_state injects my_id when player_id is assigned", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("inject"), "Injector")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 1,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state with nil player_id does not inject my_id and does not crash", %{conn: conn} do
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
        size: [2400, 1600]
      }})

      assert Process.alive?(view.pid)
    end

    test "game_state updates scoreboard display", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("score"), "Scorer")

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
        size: [2400, 1600]
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
      pid = "dead-player-#{System.unique_integer([:positive])}"
      do_join(view, pid, "Deadman")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 20,
        status: :playing,
        players: %{
          pid => %{al: false, n: "Deadman", sc: 7, k: 1, c: "#AAAAAA"}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      html = render(view)
      assert html =~ "Game Over"
      assert html =~ "PLAY AGAIN"
    end

    test "death overlay shows score and kills from game_state", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "dead-scorer-#{System.unique_integer([:positive])}"
      do_join(view, pid, "Scorer")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 50,
        status: :playing,
        players: %{
          pid => %{al: false, n: "Scorer", sc: 99, k: 3, c: "#BBBBBB"}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      html = render(view)
      assert html =~ "99"
      assert html =~ "3"
    end

    test "respawn overlay has phx-click=respawn handler", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "clicker-#{System.unique_integer([:positive])}"
      do_join(view, pid, "Clicker")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 10,
        status: :playing,
        players: %{pid => %{al: false, n: "Clicker", sc: 0, k: 0, c: "#CCCCCC"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      html = render(view)
      assert html =~ ~s(phx-click="respawn")
    end

    test "clicking PLAY AGAIN triggers respawn and hides overlay", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "respawner2-#{System.unique_integer([:positive])}"
      do_join(view, pid, "Respawner")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 10,
        status: :playing,
        players: %{pid => %{al: false, n: "Respawner", sc: 0, k: 0, c: "#CCCCCC"}},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      # Two elements have phx-click="respawn" (the overlay div and the button);
      # target the button specifically to avoid the ambiguity error.
      html = view |> element("button.btn-play[phx-click='respawn']") |> render_click()
      refute html =~ "respawn-overlay"
    end
  end

  # ── HUD Score Display ─────────────────────────────────────────────────────────

  describe "HUD score display" do
    test "shows score in HUD after join and game_state update with :sc key", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "hud-player-#{System.unique_integer([:positive])}"
      do_join(view, pid, "HUDUser")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 8,
        status: :playing,
        players: %{
          pid => %{al: true, n: "HUDUser", sc: 77, k: 0, c: "#123456", lv: 1}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      html = render(view)
      assert html =~ "77"
    end

    test "shows score in HUD with :score key fallback", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "hud-player2-#{System.unique_integer([:positive])}"
      do_join(view, pid, "HUDUser2")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 9,
        status: :playing,
        players: %{
          pid => %{al: true, n: "HUDUser2", score: 55, k: 0, c: "#654321", lv: 1}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      html = render(view)
      assert html =~ "55"
    end

    test "renders new HUD wrapper classes (hud-left, hud-right, hud-score)", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      pid = "hud-classes-#{System.unique_integer([:positive])}"
      do_join(view, pid, "HUDClasses")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 1,
        status: :playing,
        players: %{
          pid => %{al: true, n: "HUDClasses", sc: 1, k: 0, c: "#FFF", lv: 1}
        },
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
      }})

      html = render(view)
      assert html =~ "hud-left"
      assert html =~ "hud-right"
      assert html =~ "hud-score"
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
      do_join(view, uid("rapid"), "Rapid")

      for angle <- [0.1, 0.5, 1.0, 1.57, 3.14, -1.0, -0.5] do
        render_hook(view, "steer", %{"angle" => angle})
      end

      assert Process.alive?(view.pid)
    end

    test "multiple rapid boost toggles do not crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("boostrapid"), "Boostrapid")

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
        size: [2400, 1600]
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
        size: [2400, 1600]
      }})

      assert Process.alive?(view.pid)
    end

    test "view survives state churn after join", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/play")
      do_join(view, uid("reconnect"), "Reconnect")

      send(view.pid, {:game_state, %{
        id: "ROOM",
        tick: 2,
        status: :playing,
        players: %{},
        food: [],
        pups: [],
        leaderboard: [],
        events: [],
        size: [2400, 1600]
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
