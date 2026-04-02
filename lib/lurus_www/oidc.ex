defmodule LurusWww.OIDC do
  @moduledoc """
  OIDC wrapper — delegates to LurusPhoenix.OIDC with :lurus_www as the app key.
  Uses PKCE (public client, no client_secret).
  """

  defdelegate generate_code_verifier(), to: LurusPhoenix.OIDC
  defdelegate generate_code_challenge(verifier), to: LurusPhoenix.OIDC
  defdelegate generate_state(secret), to: LurusPhoenix.OIDC
  defdelegate verify_state(state, secret), to: LurusPhoenix.OIDC

  def authorize_url(opts \\ []) do
    LurusPhoenix.OIDC.authorize_url(:lurus_www, opts)
  end

  def exchange_code(code, code_verifier, redirect_uri) do
    LurusPhoenix.OIDC.exchange_code(:lurus_www, code, code_verifier, redirect_uri, LurusWww.Finch)
  end

  def fetch_userinfo(access_token) do
    LurusPhoenix.OIDC.fetch_userinfo(:lurus_www, access_token, LurusWww.Finch)
  end
end
