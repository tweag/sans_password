defmodule Passwordless.Schema do
  alias Passwordless.Crypto

  @login_fields ~w(login_token raw_login_token login_requested_at last_login_at)

  defmacro __using__(_) do
    quote do
      import Passwordless.Schema, only: :macros
      defdelegate passwordless_changeset(struct, params), to: Passwordless.Schema
    end
  end

  defmacro passwordless_schema() do
    quote do
      field :login_token, :string
      field :raw_login_token, :string, virtual: true
      field :login_requested_at, Ecto.DateTime
      field :last_login_at, Ecto.DateTime
    end
  end

  def passwordless_changeset(struct, params \\ %{})
  def passwordless_changeset(struct, :invite) do
    raw_token = Crypto.generate_token()
    hashed_token = Crypto.hmac(raw_token)

    passwordless_changeset(struct, %{
      login_token: hashed_token,
      raw_login_token: raw_token,
      login_requested_at: Ecto.DateTime.utc
    })
  end
  def passwordless_changeset(struct, :callback) do
    passwordless_changeset(struct, %{
      login_token: nil,
      raw_login_token: nil,
      login_requested_at: nil,
      last_login_at: Ecto.DateTime.utc
    })
  end
  def passwordless_changeset(struct, params) do
    struct
    |> Ecto.Changeset.cast(params, @login_fields)
  end
end
