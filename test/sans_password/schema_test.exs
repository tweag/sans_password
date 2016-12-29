defmodule Passwordless.SchemaTest do
  use Passwordless.Case

  alias Passwordless.TestUser

  test "trackable_changeset/1" do
    assert %Ecto.Changeset{} = TestUser.trackable_changeset(%TestUser{})
  end

  test "trackable_changeset/2" do
    assert %Ecto.Changeset{} = TestUser.trackable_changeset(%TestUser{}, %{})
  end
end
