defmodule Passwordless.TestController do
  use Phoenix.Controller

  use Passwordless.Controller, [
    view: __MODULE__.TestView,
    hooks: __MODULE__.TestHooks
  ]

  defmodule TestHooks do
    use Passwordless.Hooks

    def after_invite_path(_conn, _params), do: "/invite_success"
    def after_invite_failed_path(_conn, _params), do: "/invite_failed"

    def after_login_path(_conn, _params), do: "/login_success"
    def after_login_failed_path(_conn, _params), do: "/login_failed"

    def after_logout_path(_conn, _params), do: "/logout_success"

    def translate_error(_error), do: "err!"
  end

  # Stub out view-rendering
  defmodule TestView do
    def render(_, _) do
      ""
    end
  end
end
