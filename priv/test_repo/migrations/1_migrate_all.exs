defmodule Passwordless.TestRepo.Migrations.MigrateAll do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :login_token, :string
      add :login_requested_at, :datetime
      add :last_login_at, :datetime
    end
  end
end
