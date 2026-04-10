defmodule LurusPhoenix.Plugs.Auth do
  @moduledoc """
  Loads current user from encrypted session cookie into conn assigns.

  Assigns:
  - `conn.assigns.current_user` — user map or nil
  - `conn.assigns.access_token` — Zitadel access token or nil
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    user = get_session(conn, :current_user)
    token = get_session(conn, :access_token)

    conn
    |> assign(:current_user, user)
    |> assign(:access_token, token)
  end
end
