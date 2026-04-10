defmodule LurusWwwWeb.Router do
  use LurusWwwWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LurusWwwWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LurusWwwWeb.Plugs.SecurityHeaders
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LurusWwwWeb do
    pipe_through :browser

    live_session :default do
      live "/", Live.HomeLive, :index
      live "/play", Live.LobbyLive, :index
      live "/create", Live.CreatorLive, :index
      live "/terms", Live.TermsLive, :index
      live "/privacy", Live.PrivacyLive, :index
    end

    live_session :game, layout: {LurusWwwWeb.Layouts, :game} do
      live "/play/snake/:room_id", Live.SnakeLive, :play
    end
  end

  scope "/auth", LurusWwwWeb do
    pipe_through :browser

    get "/login", AuthController, :login
    get "/callback", AuthController, :callback
    get "/logout", AuthController, :logout
  end

  scope "/", LurusWwwWeb do
    get "/health", HealthController, :index
  end

  if Application.compile_env(:lurus_www, :dev_routes, false) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LurusWwwWeb.Telemetry
    end
  end

  # Catch-all 404
  scope "/", LurusWwwWeb do
    pipe_through :browser
    live "/*path", Live.NotFoundLive, :index
  end
end
