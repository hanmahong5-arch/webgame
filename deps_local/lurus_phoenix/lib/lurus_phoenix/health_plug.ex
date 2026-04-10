defmodule LurusPhoenix.HealthPlug do
  @moduledoc """
  Minimal health check plug for K8s liveness/readiness probes.

  ## Usage in Router

      # Simple usage:
      get "/health", LurusPhoenix.HealthPlug, :index

      # Or as a plug in endpoint (before router):
      plug LurusPhoenix.HealthPlug, path: "/health"
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts) do
    path = Keyword.get(opts, :path)
    %{path: path}
  end

  @impl true
  def call(%{path_info: path_info} = conn, %{path: match_path}) when not is_nil(match_path) do
    if Enum.join(path_info, "/") == String.trim_leading(match_path, "/") do
      respond_ok(conn)
    else
      conn
    end
  end

  def call(conn, _opts) do
    respond_ok(conn)
  end

  # Called as a controller action via `get "/health", HealthPlug, :index`
  def index(conn, _params) do
    respond_ok(conn)
  end

  defp respond_ok(conn) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK")
    |> halt()
  end
end
