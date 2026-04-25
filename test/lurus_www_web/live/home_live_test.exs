defmodule LurusWwwWeb.Live.HomeLiveTest do
  use LurusWwwWeb.ConnCase

  import Phoenix.LiveViewTest

  # The homepage is now a slither.io-style splash inside the default app layout.
  # Tests assert on:
  #   - the splash UI (#sio-home, #sio-name, #sio-play, .sio-logo-text, .sio-tips)
  #   - the surrounding layout (topbar nav, footer)
  # Old marketing copy ("Featured Games", "How It Works", "Ready?", etc.) was
  # removed when 2c-bs-www-phoenix pivoted from corporate site to webgame product.

  # ── Mount ───────────────────────────────────────────────────────────────────

  describe "mount" do
    test "renders successfully with 200", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "WebGame"
    end

    test "sets page_title containing the game name", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      # New title is "Snake Arena — play now"
      assert page_title(view) =~ "Snake Arena" or page_title(view) =~ "WebGame"
    end
  end

  # ── Splash UI (slither.io-style) ────────────────────────────────────────────

  describe "splash UI" do
    test "renders the sio-home container with PlayLauncher hook", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(id="sio-home")
      assert html =~ "sio-home"
      assert html =~ "PlayLauncher"
    end

    test "renders the SNAKE.ARENA logo text", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "sio-logo-text"
      # Logo is split into "SNAKE" + dot + "ARENA"
      assert html =~ "SNAKE"
      assert html =~ "ARENA"
    end

    test "renders the logo subtitle", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # Logo sub mentions multiplayer / real-time / no install
      assert html =~ "multiplayer"
      assert html =~ "real-time"
    end

    test "renders the nickname input with id sio-name", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(id="sio-name")
      assert html =~ ~s(class="sio-name")
      assert html =~ ~s(placeholder="nickname")
    end

    test "nickname input enforces 16-char maxlength", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(maxlength="16")
    end

    test "renders the Play button with id sio-play", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(id="sio-play")
      assert html =~ ~s(class="sio-play")
      assert html =~ ">Play<"
    end

    test "renders Create a game ghost link to /create", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # The splash has a secondary "Create a game" link
      assert html =~ ~s(href="/create")
      assert html =~ "Create a game"
    end

    test "renders control tips for mouse + boost", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "sio-tips"
      assert html =~ "steer"
      assert html =~ "boost"
    end

    test "renders animated background worms and pellets", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # Decorative elements that establish the slither.io vibe.
      assert html =~ "sio-bg"
      assert html =~ "sio-worm"
      assert html =~ "sio-pellet"
    end

    test "renders footer links to terms and privacy in the splash", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # The splash has its own minimalist footer + the layout footer.
      assert html =~ ~s(href="/terms")
      assert html =~ ~s(href="/privacy")
    end

    test "splash form prevents native submission; PlayLauncher drives nav via JS", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # The form has onsubmit="return false;" to suppress native form posts;
      # phx-submit="noop" is a defensive no-op on the LV side. Real navigation
      # is driven client-side by the PlayLauncher hook on click.
      assert html =~ ~s(onsubmit="return false;")
    end
  end

  # ── Layout (app shell: topbar + footer) ──────────────────────────────────────

  describe "app layout shell" do
    test "renders topbar nav with Play link", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="/play")
    end

    test "renders topbar nav with Create link", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="/create")
    end

    test "renders footer with copyright info", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Lurus Technology"
    end

    test "renders footer links to terms and privacy", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="/terms")
      assert html =~ ~s(href="/privacy")
    end

    test "renders login link for unauthenticated users", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="/auth/login")
    end

    test "renders the WebGame brand in the topbar", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "topbar-logo"
      assert html =~ "WebGame"
    end
  end

  # ── No-op event handler ──────────────────────────────────────────────────────

  describe "noop event" do
    test "the splash form has phx-submit='noop' wired to the view", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(phx-submit="noop")
    end
  end
end
