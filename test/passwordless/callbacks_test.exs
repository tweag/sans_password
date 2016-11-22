defmodule Passwordless.CallbacksTest do
  use Passwordless.Case
  alias Passwordless.{Callbacks, Invite, TestUser, TestRepo}

  @email "user@example.com"

  defp create_user!(email) do
    TestRepo.insert! %TestUser{email: email}
  end

  describe "login/1" do
    setup do
      user = @email |> create_user! |> Invite.prepare_for_login
      user |> Invite.login_params |> Keyword.put(:user, user)
    end

    test "returns {:ok, user} when successful", %{login_token: login_token, user: user} do
      {:ok, next_user} = Callbacks.login(login_token)
      assert next_user.id == user.id
    end

    test "resets the login_requested_at", %{login_token: login_token} do
      {:ok, user} = Callbacks.login(login_token)
      refute user.login_requested_at
    end

    test "updates the last_login_at", %{login_token: login_token} do
      {:ok, user} = Callbacks.login(login_token)
      assert user.last_login_at
    end

    test "returns :invalid_token when not found" do
      assert {:error, %CaseClauseError{}} = Callbacks.login("bogus")
    end
  end

  describe "register/2" do
    setup do: Invite.registration_params(@email)

    test "returns {:ok, user} when successful", %{registration_token: token} do
      assert {:ok, %TestUser{}} = Callbacks.register(token)
    end

    test "sets the email for the new user", %{registration_token: token} do
      {:ok, user} = Callbacks.register(token)
      assert user.email
    end

    test "sets the last_login_at", %{registration_token: token} do
      {:ok, user} = Callbacks.register(token)
      assert user.last_login_at
    end

    test "returns {:error, changeset} when invalid", %{registration_token: token} do
      create_user!(@email)
      assert {:error, %Ecto.Changeset{}} = Callbacks.register(token)
    end

    test "returns :invalid_token with invalid token" do
      assert {:error, %CaseClauseError{}} = Callbacks.register("fillibuster")
    end
  end
end
