defmodule LurusWww.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LurusWwwWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:lurus_www, :dns_cluster_query) || :ignore},
      {Finch, name: LurusWww.Finch, pools: finch_pools()},
      # LurusWww.Repo starts only when DATABASE_URL is reachable
      {Phoenix.PubSub, name: LurusWww.PubSub},
      {Registry, keys: :unique, name: LurusWww.Games.Registry},
      LurusWww.Games.GameSupervisor,
      LurusWwwWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: LurusWww.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    LurusWwwWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp finch_pools do
    %{
      :default => [size: 10],
      "https://api.lurus.cn" => [size: 25, count: 2],
      "https://auth.lurus.cn" => [size: 5]
    }
  end
end
