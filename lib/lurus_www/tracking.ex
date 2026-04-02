defmodule LurusWww.Tracking do
  @moduledoc """
  Server-side event tracking. Batches events and forwards to API.
  Replaces client-side sendBeacon approach.
  """

  require Logger

  @doc "Track a page view event"
  def page_view(conn_or_socket, path) do
    if analytics_enabled?() do
      track_event(%{type: "page_view", path: path, timestamp: DateTime.utc_now()})
    end

    conn_or_socket
  end

  @doc "Track a custom event"
  def track(event_type, metadata \\ %{}) do
    if analytics_enabled?() do
      track_event(Map.merge(%{type: event_type, timestamp: DateTime.utc_now()}, metadata))
    end
  end

  defp track_event(event) do
    api_url = Application.get_env(:lurus_www, :api_url, "https://api.lurus.cn")
    url = "#{api_url}/v1/tracking/events"
    body = Jason.encode!(%{events: [event]})
    headers = [{"content-type", "application/json"}]

    # Fire and forget
    Task.start(fn ->
      case Finch.build(:post, url, headers, body) |> Finch.request(LurusWww.Finch, receive_timeout: 5_000) do
        {:ok, _} -> :ok
        {:error, reason} -> Logger.debug("Tracking event failed: #{inspect(reason)}")
      end
    end)
  end

  defp analytics_enabled? do
    Application.get_env(:lurus_www, :analytics_enabled, false)
  end
end
