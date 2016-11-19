defmodule Passwordless.TestUser do
  use Ecto.Schema
  use Passwordless.Schema

  schema "users" do
    field :email, :string
    passwordless_schema()
  end
end
