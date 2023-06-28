defmodule Habits.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  alias Habits.Repo

  alias Habits.Tracker.Day

  @doc """
  Returns the list of days.

  ## Examples

      iex> list_days()
      [%Day{}, ...]

  """
  def list_days do
    Repo.all(Day)
  end

  # Lists merged map of %{habit => options}.
  def all_opts_maps do
    query = from day in Day, select: day.questions

    Repo.all(query)
    |> Enum.reduce(%{}, fn opts_map, acc ->
      Map.merge(opts_map, acc, fn _k, v1, v2 -> v1 ++ v2 end)
    end)
  end

  @doc """
  # Gets habits that have integers as options.
  # We are going to ignore if there is a non_integer option that was never selected.

  ## Examples

    iex> all_opts_maps()
    %{habit1 => ["Yes", "No"], habit2 => ["1", "2", "3"], habit3 => ["1", "2"], habit4 => ["Yes", "1"]}

    iex> list_all_habits()
    [habit1, habit2, habit3, habit4]

    iex> num_habits()
    [habit2, habit3]
  """
  def num_habits() do
    all_opts_maps()
    |> Map.keys()
    |> Enum.filter(fn habit -> all_num_options?(habit) end)
  end

  defp all_num_options?(habit) do
    list_days()
    |> Enum.filter(fn day -> habit in Map.keys(day.questions) end)
    |> Enum.map(fn day -> hd(day.questions[habit]) end)
    |> Enum.all?(&String.match?(&1, ~r/^\d+$/))
  end

  def get_day_by_date([]), do: create_day()

  def get_day_by_date(date) do
    from(Day)
    |> where(date: ^date)
    |> Repo.one()
  end

  @doc """
  Gets a single day.

  Raises `Ecto.NoResultsError` if the Day does not exist.

  ## Examples

      iex> get_day!(123)
      %Day{}

      iex> get_day!(456)
      ** (Ecto.NoResultsError)

  """
  def get_day!(id), do: Repo.get!(Day, id)

  @doc """
  Creates a day.

  ## Examples

      iex> create_day(%{field: value})
      {:ok, %Day{}}

      iex> create_day(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_day(attrs \\ %{}) do
    %Day{}
    |> Day.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a day.

  ## Examples

      iex> update_day(day, %{field: new_value})
      {:ok, %Day{}}

      iex> update_day(day, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_day(%Day{} = day, attrs) do
    day
    |> Day.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a day.

  ## Examples

      iex> delete_day(day)
      {:ok, %Day{}}

      iex> delete_day(day)
      {:error, %Ecto.Changeset{}}

  """
  def delete_day(%Day{} = day) do
    Repo.delete(day)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking day changes.

  ## Examples

      iex> change_day(day)
      %Ecto.Changeset{data: %Day{}}

  """
  def change_day(%Day{} = day, attrs \\ %{}) do
    Day.changeset(day, attrs)
  end

  alias Habits.Tracker.DailyHabit

  @doc """
  Returns the list of habits.

  ## Examples

      iex> list_habits()
      [%DailyHabit{}, ...]

  """
  def list_habits do
    Repo.all(DailyHabit)
  end

  @doc """
  Gets a single daily_habit.

  Raises `Ecto.NoResultsError` if the Daily habit does not exist.

  ## Examples

      iex> get_daily_habit!(123)
      %DailyHabit{}

      iex> get_daily_habit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_daily_habit!(id), do: Repo.get!(DailyHabit, id)

  @doc """
  Creates a daily_habit.

  ## Examples

      iex> create_daily_habit(%{field: value})
      {:ok, %DailyHabit{}}

      iex> create_daily_habit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_daily_habit(attrs \\ %{}) do
    %DailyHabit{}
    |> DailyHabit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a daily_habit.

  ## Examples

      iex> update_daily_habit(daily_habit, %{field: new_value})
      {:ok, %DailyHabit{}}

      iex> update_daily_habit(daily_habit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_daily_habit(%DailyHabit{} = daily_habit, attrs) do
    daily_habit
    |> DailyHabit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a daily_habit.

  ## Examples

      iex> delete_daily_habit(daily_habit)
      {:ok, %DailyHabit{}}

      iex> delete_daily_habit(daily_habit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_daily_habit(%DailyHabit{} = daily_habit) do
    Repo.delete(daily_habit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking daily_habit changes.

  ## Examples

      iex> change_daily_habit(daily_habit)
      %Ecto.Changeset{data: %DailyHabit{}}

  """
  def change_daily_habit(%DailyHabit{} = daily_habit, attrs \\ %{}) do
    DailyHabit.changeset(daily_habit, attrs)
  end
end
