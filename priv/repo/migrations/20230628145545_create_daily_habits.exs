defmodule Habits.Repo.Migrations.CreateDailyHabits do
  use Ecto.Migration

  def change do
    create table(:daily_habits) do
      add :name, :string
      add :options, {:array, :string}
      add :choice, :string
      add :day_id, references(:days), null: false

      timestamps()
    end
  end
end
