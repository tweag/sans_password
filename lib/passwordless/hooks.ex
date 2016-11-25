defmodule Passwordless.Hooks do
  alias Passwordless.Config

  @callback register(email :: String.t) :: tuple()
  @callback translate_error(error :: struct()) :: String.t
  @callback after_invite_path(conn :: Phoenix.Conn.t, params :: map()) :: String.t
  @callback after_invite_failed_path(conn :: Phoenix.Conn.t, params :: map()) :: String.t
  @callback after_login_path(conn :: Phoenix.Conn.t, params :: map()) :: String.t
  @callback after_login_failed_path(conn :: Phoenix.Conn.t, params :: map()) :: String.t
  @callback after_logout_path(conn :: Phoenix.Conn.t, params :: map()) :: String.t

  defmacro __using__(_) do
    quote do
      @behaviour Passwordless.Hooks

      defdelegate register(email), to: Passwordless.Hooks
      defdelegate translate_error(error), to: Passwordless.Hooks

      defoverridable [register: 1, translate_error: 1]
    end
  end

  def register(email) do
    Config.schema
    |> struct
    |> Config.schema.changeset(%{email: email})
    |> Config.repo.insert
  end

  def translate_error(_error) do
    "An error occurred."
  end
end
