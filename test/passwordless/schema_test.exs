defmodule Passwordless.SchemaTest do
  use Passwordless.Case
  alias Passwordless.{Crypto, TestUser}

  describe "passwordless_changeset with :invite" do
    test "sets a raw token" do
      changeset = TestUser.passwordless_changeset(%TestUser{}, :invite)
      %{raw_login_token: raw, login_token: hashed} = changeset.changes
      assert Crypto.valid_hmac?(hashed, from: raw)
    end
  end
end
