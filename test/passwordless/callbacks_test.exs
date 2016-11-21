defmodule Passwordless.CallbacksTest do
  use Passwordless.Case
  import Passwordless.Callbacks
  import Passwordless.Invite, only: [prepare_for_login: 1, registration_params: 1]

  alias Passwordless.{TestUser, TestRepo}

  describe "login/1" do
    setup do
      user =
        %TestUser{email: "user@example.com"}
        |> TestRepo.insert!
        |> prepare_for_login

      [login_token: user.raw_login_token, user: user]
    end

    test "resets the login_token", %{login_token: login_token} do
      {:ok, user} = login(login_token)
      refute user.login_token
    end

    test "resets the login_requested_at", %{login_token: login_token} do
      {:ok, user} = login(login_token)
      refute user.login_requested_at
    end

    test "updates the last_login_at", %{login_token: login_token} do
      {:ok, user} = login(login_token)
      assert user.last_login_at
    end

    test "returns {:ok, user} when successful", %{login_token: login_token, user: user} do
      {:ok, next_user} = login(login_token)
      assert next_user.id == user.id
    end

    test "returns :invalid_token when not found" do
      assert login("bogus") == :invalid_token
    end
  end

  describe "register/1" do
    setup do: registration_params("user@example.com")

    setup %{email: email} do
      [changeset: TestUser.changeset(%TestUser{}, %{email: email})]
    end

    test "sets the last_login_at", %{email: email, registration_token: token, changeset: changeset} do
      {:ok, user} = register(changeset, token: token, email: email)
      assert user.last_login_at
    end

    test "returns {:ok, user}", %{email: email, registration_token: token, changeset: changeset} do
      assert {:ok, %TestUser{}} = register(changeset, token: token, email: email)
    end

    test "returns {:error, changeset} when invalid", %{email: email, registration_token: token} do
      changeset = TestUser.changeset(%TestUser{}, %{email: ""})
      assert {:error, %Ecto.Changeset{}} = register(changeset, token: token, email: email)
    end

    test "returns :invalid_token with invalid token", %{email: email, changeset: changeset} do
      assert register(changeset, token: "fake", email: email) == :invalid_token
    end
  end
end
