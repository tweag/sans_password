defmodule Passwordless.TestUser do
  use Ecto.Schema
  use Passwordless.Schema

  import Ecto.Changeset

  schema "users" do
    field :email, :string
    passwordless_schema()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required(:email)
    |> unique_constraint(:email)
  end
end
