import Config

# PHX_SERVER=true enables the HTTP server in releases
if System.get_env("PHX_SERVER") do
  config :lurus_www, LurusWwwWeb.Endpoint, server: true
end

# Port binding — applies to all envs so dev/test can override too
config :lurus_www, LurusWwwWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

db_url = System.get_env("DATABASE_URL", "ecto://webgame:webgame_2026@lurus-pg-rw.database.svc:5432/webgame")

config :lurus_www, LurusWww.Repo,
  url: db_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "5")),
  queue_target: 10_000,
  queue_interval: 30_000

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "webgame.lurus.cn"

  config :lurus_www, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :lurus_www, LurusWwwWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base

  config :lurus_www,
    chat_enabled: System.get_env("CHAT_ENABLED", "true") == "true",
    api_url: System.get_env("API_URL", "https://api.lurus.cn"),
    demo_api_key: System.get_env("DEMO_API_KEY"),
    zitadel_issuer: System.get_env("ZITADEL_ISSUER", "https://auth.lurus.cn"),
    zitadel_client_id:
      (case System.get_env("ZITADEL_CLIENT_ID", "") do
         "" ->
           raise """
           environment variable ZITADEL_CLIENT_ID is missing or empty.
           Set it to the Zitadel OIDC public client ID (numeric, e.g. "364461324094146384").
           """

         id ->
           id
       end),
    identity_url: System.get_env("IDENTITY_URL", "https://identity.lurus.cn"),
    icp_number: System.get_env("ICP_NUMBER", "鲁ICP备2026000242号"),
    analytics_enabled: System.get_env("ANALYTICS_ENABLED", "false") == "true"
end
