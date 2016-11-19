defmodule Passwordless.LoginTest do
  use Passwordless.Case
  import Passwordless.Login
  import Passwordless.Invite, only: [prepare_for_login: 1]

  alias Passwordless.{TestUser, TestRepo}

  describe "authenticate_login_token/1" do
    setup do
      user =
        %TestUser{email: "user@example.com"}
        |> TestRepo.insert!
        |> prepare_for_login

      [login_token: user.login_token, user: user]
    end

    test "resets the login_token", %{login_token: login_token} do
      user = authenticate_login_token(login_token)
      refute user.login_token
    end

    test "resets the login_requested_at", %{login_token: login_token} do
      user = authenticate_login_token(login_token)
      refute user.login_requested_at
    end

    test "updates the last_login_at", %{login_token: login_token} do
      user = authenticate_login_token(login_token)
      assert user.last_login_at
    end

    test "returns the user", %{login_token: login_token, user: user} do
      assert authenticate_login_token(login_token).id == user.id
    end

    test "returns nil when not found" do
      refute authenticate_login_token("bogus")
    end
  end
end
