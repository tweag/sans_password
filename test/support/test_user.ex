defmodule Passwordless.TestUser do
  use Ecto.Schema
  use Passwordless.Schema

  schema "users" do
    field :email, :string
    field :login_token, :string
    field :login_requested_at, Ecto.DateTime
    field :last_login_at, Ecto.DateTime
  end
end
