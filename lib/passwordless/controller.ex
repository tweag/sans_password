defmodule Passwordless.Controller do
  defmacro __using__([view: view, hooks: hooks]) do
    quote do
      alias Passwordless.{Invite, Callbacks, Config}

      @hooks unquote(hooks)
      @view unquote(view)

      plug :scrub_session

      def new(conn, params) do
        render conn, @view, "new.html"
      end

      def create(conn, %{"session" => %{"email" => nil}} = params) do
        conn
        |> put_flash(:error, "Email can't be blank.")
        |> new(params)
      end
      def create(conn, %{"session" => %{"email" => email}} = params) do
        @hooks.invite(email)

        conn
        |> put_flash(:info, "A login link has been sent to #{email}.")
        |> redirect(to: @hooks.after_invite_path(conn, params))
      end

      def callback(conn, %{"login_token" => token} = params) do
        token
        |> Callbacks.login()
        |> process_callback(conn, params)
      end
      def callback(conn, %{"registration_token" => token} = params) do
        token
        |> Callbacks.register(&@hooks.register/1)
        |> process_callback(conn, params)
      end

      def delete(conn, params) do
        conn
        |> Guardian.Plug.sign_out()
        |> put_flash(:info, "Logged out successfully.")
        |> redirect(to: @hooks.after_logout_path(conn, params))
      end

      defp process_callback(result, conn, params) do
        case result do
          {:ok, user} ->
            conn
            |> Guardian.Plug.sign_in(user)
            |> put_flash(:info, "You are now logged in.")
            |> redirect(to: @hooks.after_login_path(conn, params))
          {:error, error} ->
            conn
            |> put_flash(:error, @hooks.translate_error(error))
            |> redirect(to: @hooks.after_login_failed_path(conn, :new))
        end
      end

      defp scrub_session(conn, _params) do
        if action_name(conn) == :create do
          scrub_params(conn, "session")
        else
          conn
        end
      end
    end
  end
end
