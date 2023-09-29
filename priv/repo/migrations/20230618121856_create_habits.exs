defmodule Habits.Repo.Migrations.CreateHabits do
  use Ecto.Migration

  def change do
    create table(:habits) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:habits, [:user_id])
  end
end
