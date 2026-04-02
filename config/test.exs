import Config

config :lurus_www, LurusWwwWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_only_secret_key_base_that_is_at_least_64_bytes_long_for_testing_purposes",
  server: false

config :lurus_www,
  chat_enabled: false,
  api_url: "http://localhost:4010",
  zitadel_issuer: "http://localhost:4010",
  zitadel_client_id: "test-client-id"

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
