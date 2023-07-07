defmodule Habits.Tracker.Day do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habits.Accounts.User
  alias Habits.Tracker.DailyHabit

  schema "days" do
    field(:date, :date)

    timestamps()

    has_many(:daily_habits, DailyHabit, on_replace: :nilify)
    belongs_to(:user, User)
  end

  def changeset(day, attrs) do
    day
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end
end
