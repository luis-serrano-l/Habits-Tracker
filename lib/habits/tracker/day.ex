defmodule Habits.Tracker.Day do
  use Ecto.Schema
  import Ecto.Changeset

  schema "days" do
    field :date, :date
    # field :questions, {:map, {:array, :string}}

    timestamps()

    belongs_to :user_tokens, Habits.Accounts.UserToken
    has_many :daily_habits, Habits.Tracker.DailyHabit
  end

  def changeset(day, attrs) do
    day
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end
end
