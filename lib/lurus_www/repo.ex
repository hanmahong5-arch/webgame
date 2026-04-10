defmodule LurusWww.Repo do
  use Ecto.Repo,
    otp_app: :lurus_www,
    adapter: Ecto.Adapters.Postgres
end
