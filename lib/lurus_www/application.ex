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

  # Called by the BEAM before the supervision tree shuts down (SIGTERM, :init.stop/0).
  # Notifies every active room so clients can show a "reconnecting" banner instead of
  # going blank. Reconnect grace on the new pod will resume players by their localStorage id.
  @impl true
  def prep_stop(state) do
    try do
      LurusWww.Games.Registry
      |> Registry.select([{{:"$1", :_, :_}, [], [:"$1"]}])
      |> Enum.each(fn room_id ->
        Phoenix.PubSub.broadcast(
          LurusWww.PubSub,
          "game:#{room_id}",
          {:server_shutdown}
        )
      end)

      # Give Phoenix Channels / LV a brief moment to flush the broadcast before
      # the endpoint goes down. Anything longer just delays K8s rolling deploys.
      Process.sleep(500)
    rescue
      _ -> :ok
    end

    state
  end

  defp finch_pools do
    %{
      :default => [size: 10],
      "https://api.lurus.cn" => [size: 25, count: 2],
      "https://auth.lurus.cn" => [size: 5]
    }
  end
end
