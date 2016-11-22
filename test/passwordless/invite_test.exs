defmodule Passwordless.InviteTest do
  use Passwordless.Case
  alias Passwordless.{Invite, TestUser, TestRepo}

  @email "user@example.com"

  defp insert_user(_) do
    [user: TestRepo.insert!(%TestUser{email: @email})]
  end

  describe "invite_to_login/2" do
    setup :insert_user

    test "returns the user", %{user: user} do
      assert Invite.invite_to_login(user).id == user.id
    end

    test "returns the user given an email", %{user: user} do
      assert Invite.invite_to_login(@email).id == user.id
    end

    test "returns nil when user not found" do
      refute Invite.invite_to_login("bogus@example.com")
    end

    test "user is assigned a login_requested_at" do
      assert Invite.invite_to_login(@email).login_requested_at
    end

    test "an email is delivered", %{user: user} do
      user = Invite.invite_to_login(user)
      assert_received({:delivered_email, :login, ^user, [login_token: _]})
    end

    test "an email is delivered with extra params", %{user: user} do
      user = Invite.invite_to_login(user, redirect: "/foo")
      assert_received({:delivered_email, :login, ^user, [login_token: _, redirect: "/foo"]})
    end

    test "an email is delivered when given an email addresses" do
      user = Invite.invite_to_login(@email)
      assert_received({:delivered_email, :login, ^user, [login_token: _]})
    end

    test "an email is not delivered when user not found" do
      Invite.invite_to_login("bogus@example.com")
      refute_emails_sent()
    end
  end

  describe "invite_to_confirm/2" do
    setup :insert_user

    test "returns the user", %{user: user} do
      assert Invite.invite_to_confirm(user).id == user.id
    end

    test "returns the user given an email", %{user: user} do
      assert Invite.invite_to_confirm(@email).id == user.id
    end

    test "returns nil when user not found" do
      refute Invite.invite_to_confirm("bogus@example.com")
    end

    test "user is assigned a login_requested_at" do
      assert Invite.invite_to_confirm(@email).login_requested_at
    end

    test "an email is delivered", %{user: user} do
      user = Invite.invite_to_confirm(user)
      assert_received({:delivered_email, :confirm, ^user, [login_token: _]})
    end

    test "an email is delivered with extra params", %{user: user} do
      user = Invite.invite_to_confirm(user, redirect: "/foo")
      assert_received({:delivered_email, :confirm, ^user, [login_token: _, redirect: "/foo"]})
    end

    test "an email is delivered when given an email address" do
      user = Invite.invite_to_confirm(@email)
      assert_received({:delivered_email, :confirm, ^user, [login_token: _]})
    end

    test "an email is not delivered when user is not found" do
      Invite.invite_to_confirm("bogus@example.com")
      refute_received({:delivered_email, _, _, _})
    end
  end

  describe "invite_to_register/2" do
    test "returns the email address" do
      assert Invite.invite_to_register(@email) == @email
    end

    test "an email is delivered with email and token" do
      Invite.invite_to_register(@email)
      assert_received({:delivered_email, :register, "user@example.com", [registration_token: _]})
    end

    test "an email is delivered with email, token, and extra params" do
      Invite.invite_to_register(@email, redirect: "/foo")
      assert_received({:delivered_email, :register, "user@example.com", [registration_token: _, redirect: "/foo"]})
    end
  end
end
