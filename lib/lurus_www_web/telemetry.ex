defmodule LurusWwwWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix
      summary("phoenix.endpoint.start.system_time", unit: {:native, :millisecond}),
      summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.live_view.mount.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.live_view.handle_event.stop.duration", unit: {:native, :millisecond}),

      # Game — counters
      counter("webgame.game.join.count", tags: [:room_id]),
      counter("webgame.game.leave.count", tags: [:room_id]),
      counter("webgame.game.death.count", tags: [:room_id]),
      counter("webgame.game.kill.count", tags: [:room_id]),
      counter("webgame.game.respawn.count", tags: [:room_id]),
      counter("webgame.game.bot_spawn.count", tags: [:room_id]),
      counter("webgame.game.rate_limited.count", tags: [:event]),
      counter("webgame.game.laser.count", tags: [:room_id]),

      # Game — distributions
      distribution("webgame.game.tick.duration",
        unit: {:microsecond, :millisecond},
        reporter_options: [buckets: [1, 5, 10, 25, 50, 100, 250]]
      ),

      # Game — gauges (polled)
      last_value("webgame.game.rooms.total"),
      last_value("webgame.game.players.humans"),
      last_value("webgame.game.players.bots")
    ]
  end

  defp periodic_measurements do
    [
      {__MODULE__, :poll_game_metrics, []}
    ]
  end

  @doc false
  def poll_game_metrics do
    rooms = LurusWww.Games.GameServer.list_rooms()
    total = length(rooms)
    {humans, bots} =
      Enum.reduce(rooms, {0, 0}, fn r, {h, b} ->
        ps = r[:players] || []
        humans = Enum.count(ps, &(!Map.get(&1, :is_bot, false)))
        bots = Enum.count(ps, &Map.get(&1, :is_bot, false))
        {h + humans, b + bots}
      end)

    :telemetry.execute([:webgame, :game, :rooms], %{total: total}, %{})
    :telemetry.execute([:webgame, :game, :players], %{humans: humans, bots: bots}, %{})
  rescue
    _ -> :ok
  end
end
