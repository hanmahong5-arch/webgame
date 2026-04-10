defmodule LurusPhoenix.Plugs.RequireRole do
  @moduledoc """
  Plug that enforces Zitadel role-based access control.
  Checks that the current user's roles (from session) include the required role.

  ## Usage

      # In router pipeline:
      plug LurusPhoenix.Plugs.RequireRole, role: "admin"

      # Multiple roles (any match):
      plug LurusPhoenix.Plugs.RequireRole, role: ["admin", "operator"]
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts) do
    role = Keyword.fetch!(opts, :role)
    roles = List.wrap(role)
    %{roles: roles}
  end

  @impl true
  def call(conn, %{roles: required_roles}) do
    user = conn.assigns[:current_user]

    cond do
      is_nil(user) ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(401, "Unauthorized")
        |> halt()

      has_required_role?(user, required_roles) ->
        conn

      true ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(403, "Forbidden: insufficient role")
        |> halt()
    end
  end

  defp has_required_role?(user, required_roles) do
    user_roles = extract_roles(user)
    Enum.any?(required_roles, &(&1 in user_roles))
  end

  # Zitadel roles come in the userinfo/token as a map like:
  # %{"urn:zitadel:iam:org:project:roles" => %{"admin" => %{"orgId" => "..."}}}
  # Or simplified in session as: %{roles: ["admin", "user"]}
  defp extract_roles(%{roles: roles}) when is_list(roles), do: roles
  defp extract_roles(%{"roles" => roles}) when is_list(roles), do: roles

  defp extract_roles(%{roles: roles}) when is_map(roles), do: Map.keys(roles)
  defp extract_roles(%{"roles" => roles}) when is_map(roles), do: Map.keys(roles)

  defp extract_roles(_), do: []
end
