defmodule Passwordless.Schema do
  @login_fields ~w(email login_requested_at last_login_at)

  defmacro __using__(_) do
    quote do
      import Passwordless.Schema, only: :macros
      defdelegate passwordless_changeset(struct, params), to: Passwordless.Schema
      defdelegate passwordless_changeset(struct, params, action), to: Passwordless.Schema
      defoverridable [passwordless_changeset: 2, passwordless_changeset: 3]
    end
  end

  defmacro passwordless_schema() do
    quote do
      field :login_requested_at, Ecto.DateTime
      field :last_login_at, Ecto.DateTime
    end
  end

  def passwordless_changeset(struct, params, action)
  def passwordless_changeset(struct, params, :invite) do
    passwordless_changeset(struct, Map.merge(params, %{
      login_requested_at: Ecto.DateTime.utc
    }))
  end
  def passwordless_changeset(struct, params, :callback) do
    passwordless_changeset(struct, Map.merge(params, %{
      login_requested_at: nil,
      last_login_at: Ecto.DateTime.utc
    }))
  end
  def passwordless_changeset(struct, params) do
    struct
    |> Ecto.Changeset.cast(params, @login_fields)
    |> Ecto.Changeset.unique_constraint(:email)
  end
end
