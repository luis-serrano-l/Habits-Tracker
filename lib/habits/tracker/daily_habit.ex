defmodule Habits.Tracker.DailyHabit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "daily_habits" do
    field :choice, :string
    field :name, :string
    field :options, {:array, :string}

    timestamps()

    belongs_to :days, Habits.Tracker.Day
  end

  @doc false
  def changeset(daily_habit, attrs) do
    daily_habit
    |> cast(attrs, [:name, :options, :choice])
    |> validate_required([:name, :options])
  end
end
