defmodule Passwordless.Hooks do
  alias Passwordless.{Config, Invite}

  @callback invite(email :: String.t) :: any()
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

      defdelegate invite(email), to: Passwordless.Hooks
      defdelegate register(email), to: Passwordless.Hooks
      defdelegate translate_error(error), to: Passwordless.Hooks

      defoverridable [invite: 1, register: 1, translate_error: 1]
    end
  end

  def invite(email) do
    unless Invite.invite_to_login(email) do
      Invite.invite_to_register(email)
    end
  end

  def register(email) do
    Config.schema
    |> struct
    |> Config.schema.changeset(%{email: email})
    |> Config.repo.insert
  end

  def translate_error(error) do
    IO.warn """
    An error occurred:

    #{inspect error}

    If you want to handle this error, override translate_error/1 in your
    Passwordless hooks module.
    """

    "An error occurred."
  end
end
