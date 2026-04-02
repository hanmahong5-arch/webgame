defmodule LurusWwwWeb.Plugs.Auth do
  @moduledoc """
  OIDC session management plug — delegates to LurusPhoenix.Plugs.Auth.
  """

  defdelegate init(opts), to: LurusPhoenix.Plugs.Auth
  defdelegate call(conn, opts), to: LurusPhoenix.Plugs.Auth
end
