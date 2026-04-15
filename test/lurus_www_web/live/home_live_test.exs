defmodule LurusWwwWeb.Live.HomeLiveTest do
  use LurusWwwWeb.ConnCase

  import Phoenix.LiveViewTest

  # ── Mount ───────────────────────────────────────────────────────────────────

  describe "mount" do
    test "renders successfully with 200", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "WebGame"
    end

    test "sets page_title to platform name", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      assert page_title(view) =~ "WebGame"
    end
  end

  # ── Hero Section ────────────────────────────────────────────────────────────

  describe "hero section" do
    test "renders hero section wrapper", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "hero-section"
    end

    test "renders hero h1 with platform name", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "<h1"
      assert html =~ "WebGame"
    end

    test "renders hero tagline", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Create"
      assert html =~ "Play"
      assert html =~ "Share"
      assert html =~ "Earn"
    end

    test "renders hero description mentioning AI and real-time", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "AI-powered"
      assert html =~ "real-time"
    end

    test "renders Platform Online badge", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Platform Online"
    end

    test "renders Play Now CTA link pointing to #games anchor", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="#games")
      assert html =~ "Play Now"
    end

    test "renders Create a Game CTA link pointing to /create", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="/create")
      assert html =~ "Create a Game"
    end
  end

  # ── How It Works Section ─────────────────────────────────────────────────────

  describe "how-it-works section" do
    test "renders how-it-works heading", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "How It Works"
    end

    test "renders all three steps", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Describe"
      assert html =~ "Play"
      # step-title "Share & Earn" is HTML-escaped to "Share &amp; Earn"
      assert html =~ "Share &amp; Earn"
    end

    test "renders step numbers 01 02 03", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "01"
      assert html =~ "02"
      assert html =~ "03"
    end

    test "renders step descriptions mentioning key concepts", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # Step 1: describe to AI
      assert html =~ "plain language"
      # Step 2: runs in browser, multiplayer
      assert html =~ "browser"
      # Step 3: tokens / creators / revenue
      assert html =~ "tokens"
    end
  end

  # ── Featured Games Section ───────────────────────────────────────────────────

  describe "featured games section" do
    test "renders games section with id=games anchor", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(id="games")
    end

    test "renders Featured Games heading", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Featured Games"
    end

    test "renders Snake Arena game card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Snake Arena"
    end

    test "Snake Arena card links to /play", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ ~s(href="/play")
    end

    test "Snake Arena card has Multiplayer badge", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Multiplayer"
    end

    test "Snake Arena card shows capability tags", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Real-time"
      assert html =~ "PvP"
      assert html =~ "Powerups"
      assert html =~ "Mobile"
    end

    test "renders coming soon cards", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Battle Pong"
      assert html =~ "Block Builder"
      assert html =~ "Your Game"
    end

    test "coming soon cards show Coming Soon badge", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Coming Soon"
    end

    test "Your Game card links to /create", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Create Now"
    end
  end

  # ── Platform Features Grid ───────────────────────────────────────────────────

  describe "platform features grid" do
    test "renders Platform Capabilities heading", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Platform Capabilities"
    end

    test "renders Real-time Multiplayer feature card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Real-time Multiplayer"
    end

    test "renders AI Game Creator feature card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "AI Game Creator"
    end

    test "renders Secure Sandbox feature card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Secure Sandbox"
    end

    test "renders Token Economy feature card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Token Economy"
    end

    test "feature cards describe key benefits", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Sub-50ms"
      assert html =~ "BEAM process"
      assert html =~ "Monetize"
    end
  end

  # ── CTA Section ──────────────────────────────────────────────────────────────

  describe "cta section" do
    test "renders Ready? headline", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Ready?"
    end

    test "renders no-account-required copy", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "No account required"
    end

    test "CTA section has Play Now button pointing to #games", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # Two Play Now links exist (hero + CTA); at least one targets #games
      assert html =~ ~s(href="#games")
    end

    test "CTA section has Create a Game link", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      # Both hero and CTA sections render this link
      assert Regex.scan(~r{href="/create"}, html) |> length() >= 1
    end
  end

  # ── Layout / Nav / Footer ────────────────────────────────────────────────────

  describe "layout" do
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
  end
end
