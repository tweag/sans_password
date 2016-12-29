defmodule SansPassword.Schema do
  @trackable [
    :sign_in_count,
    :last_sign_in_at,
    :last_sign_in_ip,
    :current_sign_in_at,
    :current_sign_in_ip
  ]

  defmacro __using__(_) do
    quote do
      import SansPassword.Schema

      defdelegate trackable_changeset(struct), to: SansPassword.Schema
      defdelegate trackable_changeset(struct, params), to: SansPassword.Schema
    end
  end

  defmacro trackable_fields() do
    quote do
      field :sign_in_count, :integer, default: 0
      field :last_sign_in_at, Ecto.DateTime
      field :last_sign_in_ip, :string
      field :current_sign_in_at, Ecto.DateTime
      field :current_sign_in_ip, :string
    end
  end

  def trackable_changeset(struct, params \\ %{}) do
    Ecto.Changeset.cast(struct, params, @trackable)
  end
end
