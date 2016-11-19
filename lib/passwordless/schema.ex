defmodule Passwordless.Schema do
  defmacro __using__(_) do
    quote do
      import Passwordless.Schema

      @login_fields ~w(login_token login_requested_at last_login_at)

      def passwordless_changeset(struct, params \\ %{}) do
        struct
        |> Ecto.Changeset.cast(params, @login_fields)
      end
    end
  end

  defmacro passwordless_schema() do
    quote do
      field :login_token, :string
      field :login_requested_at, Ecto.DateTime
      field :last_login_at, Ecto.DateTime
    end
  end
end
