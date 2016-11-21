defmodule Passwordless.InviteTest do
  use Passwordless.Case
  import Passwordless.Invite

  alias Passwordless.{TestUser, TestRepo}

  @email "user@example.com"

  defp insert_user(_) do
    [user: TestRepo.insert!(%TestUser{email: @email})]
  end

  describe "invite_to_login/2" do
    setup :insert_user

    test "returns the user", %{user: user} do
      assert invite_to_login(user).id == user.id
    end

    test "returns the user given an email", %{user: user} do
      assert invite_to_login(@email).id == user.id
    end

    test "returns nil when user not found" do
      refute invite_to_login("bogus@example.com")
    end

    test "user is assigned a login_token", %{user: user} do
      assert invite_to_login(user).login_token
    end

    test "user is assigned a login_requested_at" do
      assert invite_to_login(@email).login_token
    end

    test "an email is delivered", %{user: user} do
      user = invite_to_login(user)
      assert_email_sent({:login, user, [login_token: user.raw_login_token]})
    end

    test "an email is delivered with extra params", %{user: user} do
      user = invite_to_login(user, redirect: "/foo")
      assert_email_sent({:login, user, [login_token: user.raw_login_token, redirect: "/foo"]})
    end

    test "an email is delivered when given an email addresses" do
      user = invite_to_login(@email)
      assert_email_sent({:login, user, [login_token: user.raw_login_token]})
    end

    test "an email is not delivered when user not found" do
      invite_to_login("bogus@example.com")
      refute_emails_sent()
    end
  end

  describe "invite_to_confirm/2" do
    setup :insert_user

    test "returns the user", %{user: user} do
      assert invite_to_confirm(user).id == user.id
    end

    test "returns the user given an email", %{user: user} do
      assert invite_to_confirm(@email).id == user.id
    end

    test "returns nil when user not found" do
      refute invite_to_confirm("bogus@example.com")
    end

    test "user is assigned a login_token", %{user: user} do
      assert invite_to_confirm(user).login_token
    end

    test "user is assigned a login_requested_at" do
      assert invite_to_confirm(@email).login_token
    end

    test "an email is delivered", %{user: user} do
      user = invite_to_confirm(user)
      assert_email_sent({:confirm, user, [login_token: user.raw_login_token]})
    end

    test "an email is delivered with extra params", %{user: user} do
      user = invite_to_confirm(user, redirect: "/foo")
      assert_email_sent({:confirm, user, [login_token: user.raw_login_token, redirect: "/foo"]})
    end

    test "an email is delivered when given an email address" do
      user = invite_to_confirm(@email)
      assert_email_sent({:confirm, user, [login_token: user.raw_login_token]})
    end

    test "an email is not delivered when user is not found" do
      invite_to_confirm("bogus@example.com")
      refute_emails_sent()
    end
  end

  describe "invite_to_register/2" do
    setup do: [params: registration_params(@email)]

    test "returns the email address" do
      assert invite_to_register(@email) == @email
    end

    test "an email is delivered with email and token", %{params: params} do
      invite_to_register(@email)
      assert_email_sent({:register, @email, params})
    end

    test "an email is delivered with email, token, and extra params", %{params: params} do
      invite_to_register(@email, redirect: "/foo")
      params = Keyword.merge(params, [redirect: "/foo"])
      assert_email_sent({:register, @email, params})
    end
  end
end
