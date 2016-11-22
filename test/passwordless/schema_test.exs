defmodule Passwordless.SchemaTest do
  use Passwordless.Case
  alias Passwordless.TestUser

  describe "passwordless_changeset with :invite" do
    test "sets a login_requested_at timestamp" do
      changeset = TestUser.passwordless_changeset(%TestUser{}, %{}, :invite)
      assert changeset.changes.login_requested_at
    end
  end
end
