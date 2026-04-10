defmodule LurusPhoenix.OIDCTest do
  use ExUnit.Case, async: true

  alias LurusPhoenix.OIDC

  describe "generate_code_verifier/0" do
    test "returns URL-safe base64 string" do
      verifier = OIDC.generate_code_verifier()
      assert is_binary(verifier)
      assert String.length(verifier) >= 32
      assert Regex.match?(~r/^[A-Za-z0-9_-]+$/, verifier)
    end

    test "generates unique values" do
      v1 = OIDC.generate_code_verifier()
      v2 = OIDC.generate_code_verifier()
      assert v1 != v2
    end
  end

  describe "generate_code_challenge/1" do
    test "returns S256 challenge for verifier" do
      verifier = "test_verifier_value"
      challenge = OIDC.generate_code_challenge(verifier)
      assert is_binary(challenge)
      assert Regex.match?(~r/^[A-Za-z0-9_-]+$/, challenge)
    end

    test "same verifier produces same challenge" do
      verifier = OIDC.generate_code_verifier()
      c1 = OIDC.generate_code_challenge(verifier)
      c2 = OIDC.generate_code_challenge(verifier)
      assert c1 == c2
    end
  end

  describe "state generation and verification" do
    test "generate_state returns a 3-part dot-separated string" do
      secret = "test_secret_key_32bytes_minimum!!"
      state = OIDC.generate_state(secret)
      parts = String.split(state, ".")
      assert length(parts) == 3
    end

    test "verify_state succeeds for valid state" do
      secret = "test_secret_key_32bytes_minimum!!"
      state = OIDC.generate_state(secret)
      assert :ok = OIDC.verify_state(state, secret)
    end

    test "verify_state fails for wrong secret" do
      secret = "test_secret_key_32bytes_minimum!!"
      state = OIDC.generate_state(secret)
      assert {:error, :invalid_state} = OIDC.verify_state(state, "wrong_secret_key_also_32bytes!!")
    end

    test "verify_state fails for tampered state" do
      secret = "test_secret_key_32bytes_minimum!!"
      state = OIDC.generate_state(secret)
      tampered = state <> "x"
      assert {:error, _} = OIDC.verify_state(tampered, secret)
    end

    test "verify_state fails for malformed state" do
      assert {:error, :malformed_state} = OIDC.verify_state("no_dots_here", "secret")
    end
  end

  describe "authorize_url/2" do
    setup do
      Application.put_env(:test_app, :zitadel_issuer, "https://auth.example.com")
      Application.put_env(:test_app, :zitadel_client_id, "test-client-123")
      Application.put_env(:test_app, :zitadel_client_secret, nil)

      on_exit(fn ->
        Application.delete_env(:test_app, :zitadel_issuer)
        Application.delete_env(:test_app, :zitadel_client_id)
        Application.delete_env(:test_app, :zitadel_client_secret)
      end)
    end

    test "builds valid authorize URL with PKCE" do
      {:ok, url} =
        OIDC.authorize_url(:test_app,
          redirect_uri: "https://example.com/callback",
          code_challenge: "test_challenge",
          state: "test_state"
        )

      assert String.starts_with?(url, "https://auth.example.com/oauth/v2/authorize?")
      assert String.contains?(url, "client_id=test-client-123")
      assert String.contains?(url, "code_challenge=test_challenge")
      assert String.contains?(url, "code_challenge_method=S256")
      assert String.contains?(url, "state=test_state")
      assert String.contains?(url, "scope=openid+profile+email")
    end

    test "builds URL without PKCE for confidential client" do
      {:ok, url} =
        OIDC.authorize_url(:test_app,
          redirect_uri: "https://example.com/callback",
          state: "test_state"
        )

      refute String.contains?(url, "code_challenge")
      refute String.contains?(url, "code_challenge_method")
    end

    test "supports custom scope" do
      {:ok, url} =
        OIDC.authorize_url(:test_app,
          redirect_uri: "https://example.com/callback",
          scope: "openid profile email urn:zitadel:iam:org:project:roles"
        )

      assert String.contains?(url, "urn%3Azitadel%3Aiam%3Aorg%3Aproject%3Aroles")
    end

    test "returns error when client_id is missing" do
      Application.put_env(:test_app, :zitadel_client_id, nil)

      assert {:error, :missing_client_id} =
               OIDC.authorize_url(:test_app, redirect_uri: "https://example.com/callback")
    end
  end

  describe "end_session_url/2" do
    setup do
      Application.put_env(:test_app, :zitadel_issuer, "https://auth.example.com")
      on_exit(fn -> Application.delete_env(:test_app, :zitadel_issuer) end)
    end

    test "builds end_session URL" do
      url = OIDC.end_session_url(:test_app, "https://example.com/")
      assert String.starts_with?(url, "https://auth.example.com/oidc/v1/end_session?")
      assert String.contains?(url, "post_logout_redirect_uri=")
    end
  end
end
