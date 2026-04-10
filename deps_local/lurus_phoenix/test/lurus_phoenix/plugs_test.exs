defmodule LurusPhoenix.Plugs.RequireRoleTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  alias LurusPhoenix.Plugs.RequireRole

  describe "init/1" do
    test "wraps single role into list" do
      assert %{roles: ["admin"]} = RequireRole.init(role: "admin")
    end

    test "accepts list of roles" do
      assert %{roles: ["admin", "operator"]} = RequireRole.init(role: ["admin", "operator"])
    end
  end

  describe "call/2" do
    test "returns 401 when no user" do
      conn =
        conn(:get, "/admin")
        |> assign(:current_user, nil)
        |> RequireRole.call(%{roles: ["admin"]})

      assert conn.status == 401
      assert conn.halted
    end

    test "returns 403 when user lacks required role" do
      conn =
        conn(:get, "/admin")
        |> assign(:current_user, %{roles: ["user"]})
        |> RequireRole.call(%{roles: ["admin"]})

      assert conn.status == 403
      assert conn.halted
    end

    test "passes when user has required role (list format)" do
      conn =
        conn(:get, "/admin")
        |> assign(:current_user, %{roles: ["admin", "user"]})
        |> RequireRole.call(%{roles: ["admin"]})

      refute conn.halted
    end

    test "passes when user has any of multiple required roles" do
      conn =
        conn(:get, "/admin")
        |> assign(:current_user, %{roles: ["operator"]})
        |> RequireRole.call(%{roles: ["admin", "operator"]})

      refute conn.halted
    end

    test "handles Zitadel map-style roles" do
      conn =
        conn(:get, "/admin")
        |> assign(:current_user, %{roles: %{"admin" => %{"orgId" => "123"}}})
        |> RequireRole.call(%{roles: ["admin"]})

      refute conn.halted
    end

    test "handles string-keyed user map" do
      conn =
        conn(:get, "/admin")
        |> assign(:current_user, %{"roles" => ["admin"]})
        |> RequireRole.call(%{roles: ["admin"]})

      refute conn.halted
    end
  end
end
