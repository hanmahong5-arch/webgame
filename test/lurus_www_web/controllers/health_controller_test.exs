defmodule LurusWwwWeb.HealthControllerTest do
  use LurusWwwWeb.ConnCase

  test "GET /health returns 200 OK", %{conn: conn} do
    conn = get(conn, "/health")
    assert response(conn, 200) == "OK"
    assert response_content_type(conn, :text) =~ "text/plain"
  end
end
