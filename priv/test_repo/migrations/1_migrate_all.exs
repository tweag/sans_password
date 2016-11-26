defmodule Passwordless.TestRepo.Migrations.MigrateAll do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string

      # trackable
      add :sign_in_count, :integer, default: 0
      add :last_sign_in_ip, :string
      add :last_sign_in_at, :datetime
      add :current_sign_in_ip, :string
      add :current_sign_in_at, :datetime
    end

    create unique_index(:users, [:email])
  end
end
