defmodule LurusWww.ApiProxy do
  @moduledoc """
  Plug that proxies /api/* requests to api.lurus.cn.
  Replaces nginx reverse proxy. Supports SSE streaming.
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{path_info: ["api" | rest]} = conn, _opts) do
    api_url = Application.get_env(:lurus_www, :api_url, "https://api.lurus.cn")
    path = Enum.join(rest, "/")
    query = if conn.query_string != "", do: "?#{conn.query_string}", else: ""
    target_url = "#{api_url}/#{path}#{query}"

    # Forward relevant headers
    headers =
      conn.req_headers
      |> Enum.filter(fn {k, _} -> k in ["authorization", "content-type", "accept"] end)
      |> Enum.concat([
        {"host", "api.lurus.cn"},
        {"x-real-ip", to_string(:inet_parse.ntoa(conn.remote_ip))},
        {"x-forwarded-proto", "https"}
      ])

    {:ok, body, conn} = read_body(conn)

    method = conn.method |> String.downcase() |> String.to_atom()
    req = Finch.build(method, target_url, headers, body)

    # Check if client wants SSE
    accept = get_req_header(conn, "accept") |> List.first("")

    if String.contains?(accept, "text/event-stream") do
      stream_sse(conn, req)
    else
      proxy_request(conn, req)
    end
  end

  def call(conn, _opts), do: conn

  defp proxy_request(conn, req) do
    case Finch.request(req, LurusWww.Finch, receive_timeout: 120_000) do
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

  defp stream_sse(conn, req) do
    conn =
      conn
      |> put_resp_header("content-type", "text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    ref = Finch.async_request(req, LurusWww.Finch)

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
end
