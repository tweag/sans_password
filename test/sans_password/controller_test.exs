defmodule Passwordless.ControllerTest do
  use Passwordless.ConnCase

  alias Passwordless.{TestRepo, TestUser, TestController}

  @existing_email "existing@example.com"
  @new_email "new@example.com"

  setup do
    user = TestRepo.insert!(%TestUser{email: @existing_email})
    [user: user]
  end

  describe "new" do
    setup %{conn: conn} do
      [conn: conn |> TestController.new(%{})]
    end

    test "renders using the configured view", %{conn: conn} do
      assert conn.private.phoenix_view == TestController.TestView
    end

    test "renders the new.html template", %{conn: conn} do
      assert conn.private.phoenix_template == "new.html"
    end
  end

  describe "create" do
    @params %{
      "session" => %{
        "email" => @existing_email
      }
    }

    @register_params put_in(@params, ["session", "email"], @new_email)
    @blank_params put_in(@params, ["session", "email"], nil)

    test "re-renders the form with blank email", %{conn: conn} do
      conn = TestController.create(conn, @blank_params)
      assert conn.private.phoenix_template == "new.html"
    end

    test "adds a flash message with blank email", %{conn: conn} do
      conn = TestController.create(conn, @blank_params)
      assert get_flash(conn, :error) =~ "can't be blank"
    end

    test "sends an email when logging in", %{conn: conn} do
      TestController.create(conn, @params)
      assert_received({:delivered_email, :login, _, _})
    end

    test "redirects to after_invite_path when logging in", %{conn: conn} do
      conn = TestController.create(conn, @params)
      assert redirected_to(conn) == "/invite_success"
    end

    test "sets a flash message when logging in", %{conn: conn} do
      conn = TestController.create(conn, @params)
      assert get_flash(conn, :info) =~ "login link"
    end

    test "sends an email when registering", %{conn: conn} do
      TestController.create(conn, @register_params)
      assert_received({:delivered_email, :register, _, _})
    end

    test "redirects to after_invite_path when registering", %{conn: conn} do
      conn = TestController.create(conn, @register_params)
      assert redirected_to(conn) == "/invite_success"
    end

    test "sets a flash message when registering", %{conn: conn} do
      conn = TestController.create(conn, @register_params)
      assert get_flash(conn, :info) =~ "login link"
    end
  end

  describe "callback" do
    def parameterize(map) do
      for {key, value} <- map, into: %{} do
        {Atom.to_string(key), value}
      end
    end

    setup %{user: user}, do: [
      login: parameterize(Passwordless.Invite.login_params(user)),
      register: parameterize(Passwordless.Invite.registration_params(@new_email))
    ]

    test "logs the user in with a login token", %{conn: conn, login: login} do
      conn = TestController.callback(conn, login)
      assert Guardian.Plug.current_resource(conn)
    end

    test "redirects to the after_login_path with a login token", %{conn: conn, login: login} do
      conn = TestController.callback(conn, login)
      assert redirected_to(conn) == "/login_success"
    end

    test "sets a flash message with a login token", %{conn: conn, login: login} do
      conn = TestController.callback(conn, login)
      assert get_flash(conn, :info) == "You are now logged in."
    end

    test "does not login with invalid login token", %{conn: conn} do
      conn = TestController.callback(conn, %{"login_token" => ""})
      refute Guardian.Plug.current_resource(conn)
    end

    test "sets an error flash with invalid login token", %{conn: conn} do
      conn = TestController.callback(conn, %{"login_token" => ""})
      assert get_flash(conn, :error) == "err!"
    end

    test "redirects to after_login_failed_path with invalid login token", %{conn: conn} do
      conn = TestController.callback(conn, %{"login_token" => ""})
      assert redirected_to(conn) == "/login_failed"
    end

    test "logs the user in with a registration token", %{conn: conn, register: register} do
      conn = TestController.callback(conn, register)
      assert Guardian.Plug.current_resource(conn)
    end

    test "redirects to the after_login_path with a registration token", %{conn: conn, register: register} do
      conn = TestController.callback(conn, register)
      assert redirected_to(conn) == "/login_success"
    end

    test "sets a flash message with a registration token", %{conn: conn, register: register} do
      conn = TestController.callback(conn, register)
      assert get_flash(conn, :info) == "You are now logged in."
    end

    test "does not login with invalid registration token", %{conn: conn} do
      conn = TestController.callback(conn, %{"registration_token" => ""})
      refute Guardian.Plug.current_resource(conn)
    end

    test "sets an error flash with invalid registration token", %{conn: conn} do
      conn = TestController.callback(conn, %{"registration_token" => ""})
      assert get_flash(conn, :error) == "err!"
    end

    test "redirects to after_login_failed_path with invalid registration token", %{conn: conn} do
      conn = TestController.callback(conn, %{"registration_token" => ""})
      assert redirected_to(conn) == "/login_failed"
    end
  end

  describe "delete" do
    setup %{conn: conn, user: user} do
      [conn: Guardian.Plug.sign_in(conn, user)]
    end

    test "logs the user out", %{conn: conn} do
      assert Guardian.Plug.current_resource(conn)
      conn = TestController.delete(conn, %{})
      refute Guardian.Plug.current_resource(conn)
    end

    test "sets a flash message", %{conn: conn} do
      conn = TestController.delete(conn, %{})
      assert get_flash(conn, :info) == "Logged out successfully."
    end

    test "redirects using the after_logout_path", %{conn: conn} do
      conn = TestController.delete(conn, %{})
      assert redirected_to(conn) == "/logout_success"
    end
  end
end
