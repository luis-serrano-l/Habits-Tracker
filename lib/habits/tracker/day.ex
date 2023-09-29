defmodule Habits.Tracker.Day do
  use Ecto.Schema
  import Ecto.Changeset

  alias Habits.Accounts.User
  alias Habits.Tracker.HabitStatus

  schema "days" do
    field(:date, :date)

    timestamps()

    belongs_to(:user, User)
    has_many :habits_status, HabitStatus, on_replace: :delete
  end

  def changeset(day, params \\ %{}) do
    day
    |> cast(params, [:date])
  end
end
