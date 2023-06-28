defmodule Habits.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  alias Habits.Repo

  alias Habits.Tracker.DailyHabit

  @doc """
  Returns the list of daily_habits.

  ## Examples

      iex> list_daily_habits()
      [%DailyHabit{}, ...]

  """
  def list_daily_habits do
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
