defmodule SansPassword.TrackableTest do
  use SansPassword.ConnCase
  alias SansPassword.{Trackable, TestUser, TestRepo}

  setup %{conn: conn} do
    user = TestRepo.insert!(%TestUser{email: "user@example.com"})
    conn = Guardian.Plug.sign_in(conn, user)
    [user: user, conn: conn]
  end

  describe "after_sign_in/2" do
    test "increments sign_in_count", %{conn: conn} do
      conn = Trackable.after_sign_in(conn, %{})
      user = Guardian.Plug.current_resource(conn)
      assert user.sign_in_count == 1
    end

    test "sets current_sign_in_at", %{conn: conn} do
      conn = Trackable.after_sign_in(conn, %{})
      user = Guardian.Plug.current_resource(conn)
      assert user.current_sign_in_at
    end

    test "sets current_sign_in_ip", %{conn: conn} do
      conn = Trackable.after_sign_in(conn, %{})
      user = Guardian.Plug.current_resource(conn)
      assert user.current_sign_in_ip == "127.0.0.1"
    end

    test "sets last_sign_in_at", %{conn: conn} do
      conn = Trackable.after_sign_in(conn, %{})
      user = Guardian.Plug.current_resource(conn)
      assert user.last_sign_in_at
    end

    test "sets last_sign_in_ip", %{conn: conn} do
      conn = Trackable.after_sign_in(conn, %{})
      user = Guardian.Plug.current_resource(conn)
      assert user.last_sign_in_ip == "127.0.0.1"
    end
  end

  describe "before_sign_out/2" do
    setup %{user: user, conn: conn} do
      conn = Trackable.after_sign_in(conn, user)
      user = Guardian.Plug.current_resource(conn)
      [conn: conn, user: user]
    end

    test "resets current_sign_in_at", %{conn: conn} do
      conn = Trackable.before_sign_out(conn, %{})
      user = Guardian.Plug.current_resource(conn)
      refute user.current_sign_in_at
    end

    test "resets current_sign_in_ip", %{conn: conn} do
      conn = Trackable.before_sign_out(conn, %{})
      user = Guardian.Plug.current_resource(conn)
      refute user.current_sign_in_ip == "127.0.0.1"
    end

    test "sets last_sign_in_at to the current_sign_in_at", %{conn: conn, user: user} do
      conn = Trackable.before_sign_out(conn, %{})
      next_user = Guardian.Plug.current_resource(conn)
      assert next_user.last_sign_in_at == user.current_sign_in_at
    end

    test "sets last_sign_in_ip to the current_sign_in_ip", %{conn: conn, user: user} do
      conn = Trackable.before_sign_out(conn, %{})
      next_user = Guardian.Plug.current_resource(conn)
      assert next_user.last_sign_in_ip == user.current_sign_in_ip
    end
  end
end
