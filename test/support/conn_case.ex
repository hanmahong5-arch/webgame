defmodule LurusWwwWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint LurusWwwWeb.Endpoint

      use LurusWwwWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import LurusWwwWeb.ConnCase
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
