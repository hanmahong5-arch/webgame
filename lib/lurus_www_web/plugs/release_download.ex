defmodule LurusWwwWeb.Plugs.ReleaseDownload do
  @moduledoc """
  Adds Content-Disposition: attachment for release file downloads.
  """

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{path_info: ["releases" | _]} = conn, _opts) do
    put_resp_header(conn, "content-disposition", "attachment")
  end

  def call(conn, _opts), do: conn
end
