defmodule LurusWwwWeb.AuthController do
  use LurusWwwWeb, :controller

  alias LurusWww.OIDC

  def login(conn, params) do
    secret = conn.secret_key_base
    verifier = OIDC.generate_code_verifier()
    challenge = OIDC.generate_code_challenge(verifier)
    state = OIDC.generate_state(secret)

    redirect_uri = callback_url(conn)
    prompt = params["prompt"]

    auth_url =
      OIDC.authorize_url(
        redirect_uri: redirect_uri,
        code_challenge: challenge,
        state: state,
        prompt: prompt
      )

    conn
    |> put_session(:oidc_verifier, verifier)
    |> put_session(:oidc_state, state)
    |> redirect(external: auth_url)
  end

  def callback(conn, %{"code" => code, "state" => state}) do
    secret = conn.secret_key_base
    stored_state = get_session(conn, :oidc_state)
    verifier = get_session(conn, :oidc_verifier)

    with true <- state == stored_state,
         :ok <- OIDC.verify_state(state, secret),
         redirect_uri = callback_url(conn),
         {:ok, tokens} <- OIDC.exchange_code(code, verifier, redirect_uri),
         access_token = tokens["access_token"],
         {:ok, userinfo} <- OIDC.fetch_userinfo(access_token) do
      user = %{
        name: userinfo["name"] || userinfo["preferred_username"] || userinfo["email"],
        email: userinfo["email"],
        sub: userinfo["sub"],
        picture: userinfo["picture"]
      }

      conn
      |> delete_session(:oidc_verifier)
      |> delete_session(:oidc_state)
      |> put_session(:current_user, user)
      |> put_session(:access_token, access_token)
      |> put_session(:refresh_token, tokens["refresh_token"])
      |> redirect(to: "/")
    else
      _ ->
        conn
        |> put_flash(:error, "登录失败，请重试")
        |> redirect(to: "/")
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "登录回调参数缺失")
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    issuer = Application.get_env(:lurus_www, :zitadel_issuer)
    post_logout_uri = url(~p"/")

    conn
    |> clear_session()
    |> redirect(external: "#{issuer}/oidc/v1/end_session?post_logout_redirect_uri=#{URI.encode(post_logout_uri)}")
  end

  defp callback_url(_conn) do
    url(~p"/auth/callback")
  end
end
