defmodule Passwordless.HooksTest do
  use Passwordless.Case

  alias Passwordless.{Hooks, TestUser}

  test "register/1" do
    assert {:ok, %TestUser{}} = Hooks.register("user@example.com")
    assert {:error, %Ecto.Changeset{}} = Hooks.register("user@example.com")
  end
end
