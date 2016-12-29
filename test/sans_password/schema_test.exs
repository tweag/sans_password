defmodule SansPassword.SchemaTest do
  use SansPassword.Case

  alias SansPassword.TestUser

  test "trackable_changeset/1" do
    assert %Ecto.Changeset{} = TestUser.trackable_changeset(%TestUser{})
  end

  test "trackable_changeset/2" do
    assert %Ecto.Changeset{} = TestUser.trackable_changeset(%TestUser{}, %{})
  end
end
