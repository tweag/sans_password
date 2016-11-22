defmodule Passwordless.TestRepo.Migrations.MigrateAll do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :login_requested_at, :datetime
      add :last_login_at, :datetime
    end

    create unique_index(:users, [:email])
  end
end
