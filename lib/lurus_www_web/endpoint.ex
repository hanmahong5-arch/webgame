defmodule LurusWwwWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :lurus_www

  @session_options [
    store: :cookie,
    key: "_lurus_www_key",
    signing_salt: "lurus_www_sign",
    encryption_salt: "lurus_www_enc",
    same_site: "Lax",
    max_age: 86_400
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve static files from priv/static.
  # gzip only in production (after mix phx.digest generates .gz files).
  plug Plug.Static,
    at: "/",
    from: :lurus_www,
    gzip: true,
    only: LurusWwwWeb.static_paths()

  # Serve release downloads from host path
  plug Plug.Static,
    at: "/releases",
    from: "/opt/releases",
    gzip: false,
    headers: %{"content-disposition" => "attachment"}

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug LurusWwwWeb.Router
end
