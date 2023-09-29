defmodule Habits.Tracker.HabitStatus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Habits.Tracker.Day
  alias Habits.Accounts.User

  schema "habits_status" do
    field(:name, :string)
    field(:status, :string)

    timestamps()

    belongs_to(:day, Day)
    belongs_to(:user, User)
  end

  @doc false
  def changeset(habit_status, attrs) do
    habit_status
    |> cast(attrs, [:name, :status])
    |> validate_required([:name, :status])
  end
end
