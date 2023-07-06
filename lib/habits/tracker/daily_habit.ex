defmodule Habits.Tracker.DailyHabit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habits.Tracker.Day

  schema "daily_habits" do
    field :choice, :string
    field :name, :string
    field :options, {:array, :string}

    timestamps()

    belongs_to :day, Day
  end

  @doc false
  def changeset(daily_habit, attrs) do
    daily_habit
    |> cast(attrs, [:name, :options, :choice])
    |> validate_required([:name, :options, :choice])
  end
end
