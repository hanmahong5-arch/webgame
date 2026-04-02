import Config

config :lurus_www,
  generators: [timestamp_type: :utc_datetime]

config :lurus_www, LurusWwwWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LurusWwwWeb.ErrorHTML, json: LurusWwwWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LurusWww.PubSub,
  live_view: [signing_salt: "lurus_www_lv"]

# esbuild: JS bundling
config :esbuild,
  version: "0.25.4",
  lurus_www: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Tailwind CSS 4
config :tailwind,
  version: "4.0.0",
  lurus_www: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
