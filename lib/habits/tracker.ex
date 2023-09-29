defmodule Habits.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Habits.Repo
  alias Habits.Accounts.User
  alias Habits.Tracker.HabitStatus

  def list_habits(user_id) do
    habits =
      from user in User,
        where: user.id == ^user_id,
        join: habit in assoc(user, :habits),
        select: habit.name

    Repo.all(habits)
  end

  def list_dates(user_id) do
    dates =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        select: day.date

    Repo.all(dates)
  end

  def create_day_with_habit_status(user_id, date, habit, status) do
    user = Repo.get_by(User, id: user_id)
    day = Ecto.build_assoc(user, :days, date: date)

    case Repo.insert(day) do
      {:ok, day_created} ->
        habit_status = Ecto.build_assoc(day_created, :habits_status, name: habit, status: status)
        Repo.insert(habit_status)

      {:error, _} ->
        "Failed"
    end
  end

  def add_habit_status(user_id, date, new_habits_status) do
    day =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        where: day.date == ^date,
        select: day

    day =
      Repo.one(day)
      |> Repo.preload(:habits_status)

    habits_status_params = %{
      "habits_status" =>
        Enum.map(new_habits_status, fn {habit, status} ->
          %{"name" => habit, "status" => status}
        end)
    }

    day
    |> IO.inspect(label: "PRELOADED HABITS STATUS")
    |> cast(habits_status_params, [])
    |> cast_assoc(:habits_status)
    |> Repo.update()
  end

  @spec delete_habit_status(any, any, any) :: any
  def delete_habit_status(user_id, date, habit) do
    habit_status =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        where: day.date == ^date,
        join: habit_status in assoc(day, :habits_status),
        where: habit_status.name == ^habit,
        select: habit_status

    Repo.one(habit_status)
    |> Repo.delete()
    |> IO.inspect(label: "HABIT STATUS DELETED")
  end

  def change_habit_status(user_id, date, habit, new_status) do
    habit_status =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        where: day.date == ^date,
        join: habit_status in assoc(day, :habits_status),
        where: habit_status.name == ^habit,
        select: habit_status

    habit_status
    |> Repo.one()
    |> HabitStatus.changeset(%{"status" => new_status})
    |> Repo.update()
  end

  def get_habits_status(user_id, date) do
    query =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        where: day.date == ^date,
        join: habit_status in assoc(day, :habits_status),
        select: {habit_status.name, habit_status.status}

    case Repo.all(query) do
      nil -> []
      habits_status -> habits_status
    end
  end
end
