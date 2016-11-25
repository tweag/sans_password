defmodule Passwordless.HooksTest do
  use Passwordless.Case

  alias Passwordless.{Hooks, TestUser}

  test "register/1" do
    assert {:ok, %TestUser{}} = Hooks.register("user@example.com")
    assert {:error, %Ecto.Changeset{}} = Hooks.register("user@example.com")
  end

  test "translate_error/1" do
    assert Hooks.translate_error(%{}) == "An error occurred."
  end
end
