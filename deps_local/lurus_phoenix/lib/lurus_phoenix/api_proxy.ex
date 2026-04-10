defmodule LurusPhoenix.ApiProxy do
  @moduledoc """
  Plug that proxies requests to a configurable upstream service.
  Supports standard HTTP requests and SSE (Server-Sent Events) streaming.

  ## Usage in Router

      # Forward all /proxy/identity/* to platform-core
      forward "/proxy/identity", LurusPhoenix.ApiProxy,
        upstream: "http://platform-core.lurus-platform.svc:18104",
        finch: MyApp.Finch

      # Forward with custom path prefix stripping
      forward "/proxy/notification", LurusPhoenix.ApiProxy,
        upstream: "http://notification.lurus-platform.svc:18900",
        finch: MyApp.Finch

  ## Options

  - `:upstream` — base URL of the target service (required)
  - `:finch` — Finch pool name (required)
  - `:timeout` — request timeout in ms (default: 120_000)
  - `:forward_headers` — list of request headers to forward (default: standard set)
  """

  @behaviour Plug

  import Plug.Conn

  @default_forward_headers ["authorization", "content-type", "accept", "x-request-id"]
  @default_timeout 120_000

  @impl true
  def init(opts) do
    upstream = Keyword.fetch!(opts, :upstream)
    finch = Keyword.fetch!(opts, :finch)
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    forward_headers = Keyword.get(opts, :forward_headers, @default_forward_headers)

    %{
      upstream: String.trim_trailing(upstream, "/"),
      finch: finch,
      timeout: timeout,
      forward_headers: forward_headers
    }
  end

  @impl true
  def call(conn, %{upstream: upstream, finch: finch, timeout: timeout, forward_headers: fwd_headers}) do
    path = Enum.join(conn.path_info, "/")
    query = if conn.query_string != "", do: "?#{conn.query_string}", else: ""
    target_url = "#{upstream}/#{path}#{query}"

    headers =
      conn.req_headers
      |> Enum.filter(fn {k, _} -> k in fwd_headers end)
      |> Enum.concat([
        {"x-real-ip", remote_ip_string(conn)},
        {"x-forwarded-proto", "https"}
      ])

    {:ok, body, conn} = read_body(conn)

    method = conn.method |> String.downcase() |> String.to_atom()
    req = Finch.build(method, target_url, headers, body)

    accept = get_req_header(conn, "accept") |> List.first("")

    if String.contains?(accept, "text/event-stream") do
      stream_sse(conn, req, finch)
    else
      proxy_request(conn, req, finch, timeout)
    end
  end

  defp proxy_request(conn, req, finch, timeout) do
    case Finch.request(req, finch, receive_timeout: timeout) do
      {:ok, %{status: status, headers: resp_headers, body: body}} ->
        resp_headers
        |> Enum.filter(fn {k, _} -> k in ["content-type", "cache-control"] end)
        |> Enum.reduce(conn, fn {k, v}, c -> put_resp_header(c, k, v) end)
        |> send_resp(status, body)

      {:error, _reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(502, Jason.encode!(%{error: "upstream_unavailable"}))
    end
  end

  defp stream_sse(conn, req, finch) do
    conn =
      conn
      |> put_resp_header("content-type", "text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    ref = Finch.async_request(req, finch)

    receive_stream(conn, ref)
  end

  defp receive_stream(conn, ref) do
    receive do
      {^ref, {:status, _status}} ->
        receive_stream(conn, ref)

      {^ref, {:headers, _headers}} ->
        receive_stream(conn, ref)

      {^ref, {:data, data}} ->
        case chunk(conn, data) do
          {:ok, conn} -> receive_stream(conn, ref)
          {:error, _} -> conn
        end

      {^ref, :done} ->
        conn
    after
      120_000 -> conn
    end
  end

  defp remote_ip_string(conn) do
    conn.remote_ip |> :inet.ntoa() |> to_string()
  end
end
