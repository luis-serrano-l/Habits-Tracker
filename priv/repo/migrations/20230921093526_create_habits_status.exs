defmodule Habits.Repo.Migrations.CreateHabitsStatus do
  use Ecto.Migration

  def change do
    create table(:habits_status) do
      add :name, :string
      add :status, :string
      add :day_id, references(:days, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:habits_status, [:name])
  end
end
