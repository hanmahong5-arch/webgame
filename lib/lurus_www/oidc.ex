defmodule LurusWww.OIDC do
  @moduledoc """
  OIDC (OpenID Connect) with PKCE for Zitadel authentication.
  Token stored in server-side encrypted cookie session.
  """

  @doc "Generate PKCE code verifier (43-128 chars, URL-safe)"
  def generate_code_verifier do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end

  @doc "Generate code challenge from verifier (S256)"
  def generate_code_challenge(verifier) do
    :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)
  end

  @doc "Generate state parameter with HMAC signature"
  def generate_state(secret) do
    nonce = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    timestamp = System.system_time(:second) |> Integer.to_string()
    payload = nonce <> "." <> timestamp
    signature = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.url_encode64(padding: false)
    payload <> "." <> signature
  end

  @doc "Verify state parameter (10 minute timeout)"
  def verify_state(state, secret) do
    case String.split(state, ".", parts: 3) do
      [nonce, timestamp_str, signature] ->
        payload = nonce <> "." <> timestamp_str
        expected = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.url_encode64(padding: false)

        with true <- Plug.Crypto.secure_compare(signature, expected),
             {timestamp, ""} <- Integer.parse(timestamp_str),
             true <- System.system_time(:second) - timestamp < 600 do
          :ok
        else
          _ -> {:error, :invalid_state}
        end

      _ ->
        {:error, :malformed_state}
    end
  end

  @doc "Build authorization URL for OIDC login"
  def authorize_url(opts \\ []) do
    issuer = Application.get_env(:lurus_www, :zitadel_issuer)
    client_id = Application.get_env(:lurus_www, :zitadel_client_id)
    redirect_uri = Keyword.get(opts, :redirect_uri, "https://www.lurus.cn/auth/callback")
    code_challenge = Keyword.get(opts, :code_challenge)
    state = Keyword.get(opts, :state)
    prompt = Keyword.get(opts, :prompt)

    params =
      [
        {"response_type", "code"},
        {"client_id", client_id},
        {"redirect_uri", redirect_uri},
        {"scope", "openid profile email"},
        {"code_challenge_method", "S256"},
        {"code_challenge", code_challenge},
        {"state", state}
      ]
      |> then(fn p -> if prompt, do: p ++ [{"prompt", prompt}], else: p end)

    query = URI.encode_query(params)
    "#{issuer}/oauth/v2/authorize?#{query}"
  end

  @doc "Exchange authorization code for tokens"
  def exchange_code(code, code_verifier, redirect_uri) do
    issuer = Application.get_env(:lurus_www, :zitadel_issuer)
    client_id = Application.get_env(:lurus_www, :zitadel_client_id)
    url = "#{issuer}/oauth/v2/token"

    body =
      URI.encode_query(%{
        "grant_type" => "authorization_code",
        "code" => code,
        "redirect_uri" => redirect_uri,
        "client_id" => client_id,
        "code_verifier" => code_verifier
      })

    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    case Finch.build(:post, url, headers, body) |> Finch.request(LurusWww.Finch) do
      {:ok, %{status: 200, body: resp_body}} ->
        {:ok, Jason.decode!(resp_body)}

      {:ok, %{status: status, body: resp_body}} ->
        {:error, {status, resp_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Fetch user info from OIDC provider"
  def fetch_userinfo(access_token) do
    issuer = Application.get_env(:lurus_www, :zitadel_issuer)
    url = "#{issuer}/oidc/v1/userinfo"
    headers = [{"authorization", "Bearer #{access_token}"}]

    case Finch.build(:get, url, headers) |> Finch.request(LurusWww.Finch) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
