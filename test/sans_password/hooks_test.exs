defmodule SansPassword.HooksTest do
  use SansPassword.Case

  alias SansPassword.{Hooks, TestUser}

  test "register/1" do
    assert {:ok, %TestUser{}} = Hooks.register("user@example.com")
    assert {:error, %Ecto.Changeset{}} = Hooks.register("user@example.com")
  end
end
