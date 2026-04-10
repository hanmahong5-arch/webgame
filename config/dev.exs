import Config

config :lurus_www, LurusWwwWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 3001],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_only_secret_key_base_that_is_at_least_64_bytes_long_for_development_use",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:lurus_www, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:lurus_www, ~w(--watch)]}
  ]

config :lurus_www, LurusWwwWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/lurus_www_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :lurus_www, LurusWww.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "webgame_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 5

config :lurus_www,
  chat_enabled: false,
  api_url: "https://api.lurus.cn",
  zitadel_issuer: "https://auth.lurus.cn",
  zitadel_client_id: ""

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :logger, level: :debug
