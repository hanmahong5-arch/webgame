defmodule LurusPhoenix do
  @moduledoc """
  Shared Phoenix modules for Lurus web services.

  Provides common functionality:
  - `LurusPhoenix.OIDC` — Zitadel OIDC with PKCE and confidential client support
  - `LurusPhoenix.ApiProxy` — Configurable upstream API proxy with SSE streaming
  - `LurusPhoenix.Plugs.Auth` — Load current_user from encrypted session
  - `LurusPhoenix.Plugs.RequireRole` — Zitadel role-based access control
  - `LurusPhoenix.HealthPlug` — K8s liveness/readiness probe endpoint
  """
end
