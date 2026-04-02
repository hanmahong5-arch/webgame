defmodule LurusWww.OIDCTest do
  use ExUnit.Case, async: true

  alias LurusWww.OIDC

  describe "PKCE" do
    test "generates code verifier of correct length" do
      verifier = OIDC.generate_code_verifier()
      assert is_binary(verifier)
      assert byte_size(verifier) >= 43
    end

    test "generates different verifiers each time" do
      v1 = OIDC.generate_code_verifier()
      v2 = OIDC.generate_code_verifier()
      assert v1 != v2
    end

    test "generates S256 code challenge" do
      verifier = OIDC.generate_code_verifier()
      challenge = OIDC.generate_code_challenge(verifier)
      assert is_binary(challenge)
      assert challenge != verifier
    end
  end

  describe "state" do
    @secret "test_secret_key_for_state_hmac"

    test "generates and verifies state" do
      state = OIDC.generate_state(@secret)
      assert :ok = OIDC.verify_state(state, @secret)
    end

    test "rejects tampered state" do
      state = OIDC.generate_state(@secret)
      tampered = state <> "x"
      assert {:error, _} = OIDC.verify_state(tampered, @secret)
    end

    test "rejects wrong secret" do
      state = OIDC.generate_state(@secret)
      assert {:error, _} = OIDC.verify_state(state, "wrong_secret")
    end
  end
end
