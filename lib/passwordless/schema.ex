defmodule Passwordless.Schema do
  defmacro __using__(_) do
    quote do
      @login_fields ~w(login_token login_requested_at last_login_at)

      def passwordless_changeset(struct, params \\ %{}) do
        struct
        |> Ecto.Changeset.cast(params, @login_fields)
      end
    end
  end
end
