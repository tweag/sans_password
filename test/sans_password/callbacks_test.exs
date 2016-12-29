defmodule Passwordless.CallbacksTest do
  use Passwordless.Case
  alias Passwordless.{Callbacks, Invite, TestUser, TestRepo}

  @email "user@example.com"

  defp create_user(email) do
    TestRepo.insert TestUser.changeset(%TestUser{}, %{email: email})
  end

  describe "login/1" do
    setup do
      {:ok, user} = create_user(@email)
      user |> Invite.login_params |> Keyword.put(:user, user)
    end

    test "returns {:ok, user} when successful", %{login_token: login_token, user: user} do
      {:ok, next_user} = Callbacks.login(login_token)
      assert next_user.id == user.id
    end

    test "handles invalid token" do
      assert {:error, %CaseClauseError{}} = Callbacks.login("bogus")
    end
  end

  describe "register/2" do
    setup do: Invite.registration_params(@email)

    test "returns {:ok, user} when successful", %{registration_token: token} do
      assert {:ok, %TestUser{}} = Callbacks.register(token, &create_user/1)
    end

    test "sets the email for the new user", %{registration_token: token} do
      {:ok, user} = Callbacks.register(token, &create_user/1)
      assert user.email
    end

    test "handles invalid changeset", %{registration_token: token} do
      {:ok, _} = create_user(@email)
      assert {:error, %Ecto.Changeset{}} = Callbacks.register(token, &create_user/1)
    end

    test "handles invalid token" do
      assert {:error, %CaseClauseError{}} = Callbacks.register("fillibuster", &create_user/1)
    end
  end
end
