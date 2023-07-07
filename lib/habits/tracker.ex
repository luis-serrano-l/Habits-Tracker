defmodule Habits.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Habits.Repo
  alias Habits.Accounts.User
  alias Habits.Tracker.DailyHabit

  def list_dates(user_id) do
    dates =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        select: day.date

    Repo.all(dates)
  end

  def get_habit_options(user_id, habit, default) do
    options =
      from user in User,
        where: user.id == ^user_id,
        join: daily_habit in assoc(user, :daily_habits),
        where: daily_habit.name == ^habit,
        select: daily_habit.options,
        limit: 1

    case Repo.one(options) do
      nil -> default
      options -> options
    end
  end

  def get_last_options(user_id, habit) do
    query =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        order_by: [desc: day.date],
        join: daily_habit in assoc(day, :daily_habits),
        where: daily_habit.name == ^habit,
        select: daily_habit.options,
        limit: 1

    Repo.one(query)
  end

  def list_daily_habits(user_id, date) do
    dates = list_dates(user_id)

    case {dates, date in dates} do
      {[], false} ->
        []

      {dates, false} ->
        get_daily_habits(user_id, Enum.max(dates))

      _ ->
        get_daily_habits(user_id, date)
    end
  end

  def list_habits(user_id) do
    query =
      from user in User,
        where: user.id == ^user_id,
        join: daily_habit in assoc(user, :daily_habits),
        select: daily_habit.name,
        distinct: true

    Repo.all(query)
  end

  def create_or_update(user_id, date, daily_habits) do
    daily_habits_list = convert_daily_habits(daily_habits)

    if date in list_dates(user_id) do
      update_daily_habits(user_id, date, daily_habits_list)
    else
      create_daily_habits(user_id, date, daily_habits_list)
    end
  end

  defp update_daily_habits(user_id, date, daily_habits_list) do
    current_day = day_daily_habits_schema(user_id, date)

    habit_id_tuples = get_id_tuple_list(current_day.daily_habits)

    params = %{
      "daily_habits" =>
        Enum.map(daily_habits_list, fn %{name: name, choice: choice, options: options} ->
          case List.keyfind(habit_id_tuples, name, 0) do
            # New habit. The id will be created at insert
            nil ->
              %{
                "name" => name,
                "choice" => choice,
                "options" => options
              }

            # Existing habit
            {name, id} ->
              %{
                "name" => name,
                "id" => id,
                "choice" => choice,
                "options" => options
              }
          end
        end)
    }

    changeset =
      current_day
      |> cast(params, [])
      |> cast_assoc(:daily_habits)

    Repo.update(changeset)
  end

  defp create_daily_habits(user_id, date, daily_habits_list) do
    # Create
    user = Repo.one(from user in User, where: user.id == ^user_id)

    new_day = Ecto.build_assoc(user, :days, date: date, daily_habits: daily_habits_list)

    Repo.insert(new_day)
  end

  def habit_choices(user_id, habit) do
    query =
      from user in User,
        where: user.id == ^user_id,
        join: daily_habit in assoc(user, :daily_habits),
        where: daily_habit.name == ^habit,
        select: daily_habit.choice

    Repo.all(query)
  end

  def date_choice_array(user_id, habit) do
    query =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        join: daily_habit in assoc(day, :daily_habits),
        where: daily_habit.name == ^habit,
        select: [day.date, daily_habit.choice]

    Repo.all(query)
  end

  defp get_id_tuple_list(daily_habits) do
    daily_habits
    |> Enum.map(&{&1.name, &1.id})
  end

  # [{habit0, options0}, {habit1, options1}] =>
  #
  # [%DailyHabit{name: habit0, options: options0}, %DailyHabit{name: habit1, options: options1}]
  defp convert_daily_habits(daily_habits) do
    daily_habits
    |> Enum.map(fn {habit, options} ->
      %DailyHabit{name: habit, options: options, choice: hd(options)}
    end)
  end

  defp get_daily_habits(user_id, date) do
    day_daily_habits_schema(user_id, date)
    |> Map.get(:daily_habits)
    |> Enum.map(&{&1.name, &1.options})
  end

  defp day_daily_habits_schema(user_id, date) do
    query =
      from user in User,
        where: user.id == ^user_id,
        join: day in assoc(user, :days),
        where: day.date == ^date,
        select: day

    Repo.one(query)
    |> Repo.preload(:daily_habits)
  end
end
