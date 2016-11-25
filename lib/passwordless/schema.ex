defmodule Passwordless.Schema do
  @callback changeset(struct :: struct(), params :: map()) :: Ecto.Changeset.t

  defmacro __using__(_) do
    quote do
      import Passwordless.Schema, only: :macros

      @behaviour Passwordless.Schema
    end
  end

  defmacro passwordless_schema() do
    quote do
      field :login_requested_at, Ecto.DateTime
      field :last_login_at, Ecto.DateTime
    end
  end
end
