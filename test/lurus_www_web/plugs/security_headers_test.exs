defmodule LurusWwwWeb.Plugs.SecurityHeadersTest do
  use LurusWwwWeb.ConnCase

  alias LurusWwwWeb.Plugs.SecurityHeaders

  test "sets all security headers", %{conn: conn} do
    conn = SecurityHeaders.call(conn, SecurityHeaders.init([]))

    assert get_resp_header(conn, "strict-transport-security") == ["max-age=31536000; includeSubDomains"]
    assert get_resp_header(conn, "x-content-type-options") == ["nosniff"]
    assert get_resp_header(conn, "x-frame-options") == ["DENY"]
    assert get_resp_header(conn, "referrer-policy") == ["strict-origin-when-cross-origin"]
    assert get_resp_header(conn, "permissions-policy") == ["camera=(), microphone=(), geolocation=()"]
    assert get_resp_header(conn, "cross-origin-opener-policy") == ["same-origin"]

    [csp] = get_resp_header(conn, "content-security-policy")
    assert csp =~ "default-src 'self'"
    assert csp =~ "frame-ancestors 'none'"
  end
end
