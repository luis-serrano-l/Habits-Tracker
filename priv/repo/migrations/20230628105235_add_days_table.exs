defmodule Habits.Repo.Migrations.AddDaysTable do
  use Ecto.Migration

  def change do
    create table(:days) do
      add :date, :date
      add :token, references(:users_tokens), null: false

      timestamps()
    end
  end
end
