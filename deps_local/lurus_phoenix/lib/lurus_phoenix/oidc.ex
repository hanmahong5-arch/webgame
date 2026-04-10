defmodule LurusPhoenix.OIDC do
  @moduledoc """
  OIDC (OpenID Connect) for Zitadel authentication.
  Supports both PKCE (public client) and Authorization Code + client_secret (confidential client).

  ## Configuration

  Each consuming app provides its own config under its OTP app name:

      config :my_app,
        zitadel_issuer: "https://auth.lurus.cn",
        zitadel_client_id: "...",
        zitadel_client_secret: "..."   # optional, for confidential clients

  Then call functions with the app name:

      LurusPhoenix.OIDC.authorize_url(:my_app, redirect_uri: "...", code_challenge: "...")
  """

  @state_timeout_seconds 600

  # --- PKCE helpers ---

  @doc "Generate PKCE code verifier (43-128 chars, URL-safe)"
  def generate_code_verifier do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end

  @doc "Generate code challenge from verifier (S256)"
  def generate_code_challenge(verifier) do
    :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)
  end

  # --- State helpers ---

  @doc "Generate state parameter with HMAC signature"
  def generate_state(secret) do
    nonce = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    timestamp = System.system_time(:second) |> Integer.to_string()
    payload = nonce <> "." <> timestamp
    signature = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.url_encode64(padding: false)
    payload <> "." <> signature
  end

  @doc "Verify state parameter signature and expiry (#{@state_timeout_seconds}s timeout)"
  def verify_state(state, secret) do
    case String.split(state, ".", parts: 3) do
      [nonce, timestamp_str, signature] ->
        payload = nonce <> "." <> timestamp_str
        expected = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.url_encode64(padding: false)

        with true <- Plug.Crypto.secure_compare(signature, expected),
             {timestamp, ""} <- Integer.parse(timestamp_str),
             true <- System.system_time(:second) - timestamp < @state_timeout_seconds do
          :ok
        else
          _ -> {:error, :invalid_state}
        end

      _ ->
        {:error, :malformed_state}
    end
  end

  # --- Config ---

  @doc "Read OIDC config for the given OTP app"
  def config(app) do
    %{
      issuer: Application.get_env(app, :zitadel_issuer),
      client_id: Application.get_env(app, :zitadel_client_id),
      client_secret: Application.get_env(app, :zitadel_client_secret)
    }
  end

  # --- Authorization ---

  @doc """
  Build authorization URL for OIDC login.

  Options:
  - `:redirect_uri` — callback URL (required)
  - `:code_challenge` — PKCE challenge (omit for confidential client without PKCE)
  - `:state` — CSRF state parameter
  - `:prompt` — force login prompt (e.g., "login")
  - `:scope` — override default scope (default: "openid profile email")
  """
  def authorize_url(app, opts \\ []) do
    %{issuer: issuer, client_id: client_id} = config(app)

    if is_nil(client_id) or client_id == "" do
      {:error, :missing_client_id}
    else
      build_authorize_url(issuer, client_id, opts)
    end
  end

  defp build_authorize_url(issuer, client_id, opts) do
    redirect_uri = Keyword.fetch!(opts, :redirect_uri)
    code_challenge = Keyword.get(opts, :code_challenge)
    state = Keyword.get(opts, :state)
    prompt = Keyword.get(opts, :prompt)
    scope = Keyword.get(opts, :scope, "openid profile email")

    params =
      [
        {"response_type", "code"},
        {"client_id", client_id},
        {"redirect_uri", redirect_uri},
        {"scope", scope}
      ]
      |> maybe_add("code_challenge_method", if(code_challenge, do: "S256"))
      |> maybe_add("code_challenge", code_challenge)
      |> maybe_add("state", state)
      |> maybe_add("prompt", prompt)

    query = URI.encode_query(params)
    {:ok, "#{issuer}/oauth/v2/authorize?#{query}"}
  end

  # --- Token exchange ---

  @doc """
  Exchange authorization code for tokens.

  For PKCE (public client): pass `code_verifier`.
  For confidential client: `code_verifier` can be nil; uses `client_secret` from config.
  """
  def exchange_code(app, code, code_verifier, redirect_uri, finch_name) do
    %{issuer: issuer, client_id: client_id, client_secret: client_secret} = config(app)
    url = "#{issuer}/oauth/v2/token"

    body_params =
      %{
        "grant_type" => "authorization_code",
        "code" => code,
        "redirect_uri" => redirect_uri,
        "client_id" => client_id
      }
      |> maybe_put("code_verifier", code_verifier)
      |> maybe_put("client_secret", client_secret)

    body = URI.encode_query(body_params)
    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    case Finch.build(:post, url, headers, body) |> Finch.request(finch_name) do
      {:ok, %{status: 200, body: resp_body}} ->
        {:ok, Jason.decode!(resp_body)}

      {:ok, %{status: status, body: resp_body}} ->
        {:error, {status, resp_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Fetch user info from OIDC provider"
  def fetch_userinfo(app, access_token, finch_name) do
    %{issuer: issuer} = config(app)
    url = "#{issuer}/oidc/v1/userinfo"
    headers = [{"authorization", "Bearer #{access_token}"}]

    case Finch.build(:get, url, headers) |> Finch.request(finch_name) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Build end_session URL for logout redirect"
  def end_session_url(app, post_logout_redirect_uri) do
    %{issuer: issuer} = config(app)
    "#{issuer}/oidc/v1/end_session?post_logout_redirect_uri=#{URI.encode(post_logout_redirect_uri)}"
  end

  # --- Helpers ---

  defp maybe_add(params, _key, nil), do: params
  defp maybe_add(params, key, value), do: params ++ [{key, value}]

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
