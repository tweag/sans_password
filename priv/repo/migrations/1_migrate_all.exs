defmodule SansPassword.Dummy.Migration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      timestamps()
    end
  end
end


