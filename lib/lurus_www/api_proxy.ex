defmodule LurusWww.ApiProxy do
  @moduledoc """
  Plug that proxies /api/* requests to api.lurus.cn.
  Delegates to LurusPhoenix.ApiProxy with www-specific config.
  """

  @behaviour Plug

  @impl true
  def init(_opts) do
    # Resolve at runtime so config is read from Application env
    :ok
  end

  @impl true
  def call(%{path_info: ["api" | _rest]} = conn, _opts) do
    api_url = Application.get_env(:lurus_www, :api_url, "https://api.lurus.cn")

    opts =
      LurusPhoenix.ApiProxy.init(
        upstream: api_url,
        finch: LurusWww.Finch
      )

    # Strip the leading "api" segment so ApiProxy sees the real path
    conn = %{conn | path_info: tl(conn.path_info)}
    LurusPhoenix.ApiProxy.call(conn, opts)
  end

  def call(conn, _opts), do: conn
end
