defmodule LurusWwwWeb.Plugs.Auth do
  @moduledoc """
  OIDC session management plug.
  Loads current user from encrypted session cookie.
  """

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    user = get_session(conn, :current_user)
    assign(conn, :current_user, user)
  end
end
