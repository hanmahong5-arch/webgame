import Config

config :lurus_www, LurusWwwWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  force_ssl: false

config :logger, level: :info
