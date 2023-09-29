defmodule Habits.Repo.Migrations.AddDaysTable do
  use Ecto.Migration

  def change do
    create table(:days) do
      add :date, :date, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:days, [:user_id])
  end
end
