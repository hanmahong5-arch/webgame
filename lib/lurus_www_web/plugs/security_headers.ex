defmodule LurusWwwWeb.Plugs.SecurityHeaders do
  @moduledoc false
  import Plug.Conn

  @behaviour Plug

  # style-src 'unsafe-inline' required by Tailwind CSS 4 runtime injection
  @csp [
    "default-src 'self'",
    "script-src 'self'",
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' data:",
    "connect-src 'self' https://api.lurus.cn https://api.github.com https://auth.lurus.cn wss:",
    "font-src 'self'",
    "frame-ancestors 'none'",
    "upgrade-insecure-requests"
  ] |> Enum.join("; ")

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    conn
    |> put_resp_header("strict-transport-security", "max-age=31536000; includeSubDomains")
    |> put_resp_header("content-security-policy", @csp)
    |> put_resp_header("x-content-type-options", "nosniff")
    |> put_resp_header("x-frame-options", "DENY")
    |> put_resp_header("referrer-policy", "strict-origin-when-cross-origin")
    |> put_resp_header("permissions-policy", "camera=(), microphone=(), geolocation=()")
    |> put_resp_header("cross-origin-opener-policy", "same-origin")
  end
end
