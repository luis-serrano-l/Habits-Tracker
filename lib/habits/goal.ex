defmodule Habits.Goal do
  @moduledoc """
  The Goal context.
  """

  import Ecto.Query, warn: false
  alias Habits.Repo
  alias Habits.Accounts.User

  @doc """
  Returns the list of habits.

  ## Examples

      iex> list_habits()
      [%Habit{}, ...]

  """
  def list_habits(user_id) do
    habits =
      from user in User,
        where: user.id == ^user_id,
        join: habit in assoc(user, :habits),
        select: habit.name

    case Repo.all(habits) do
      nil -> []
      habits -> habits
    end
  end

  @doc """
  Creates a habit.

  ## Examples

      iex> create_habit(%{field: value})
      {:ok, %Habit{}}

      iex> create_habit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def add_habit(user_id, habit) do
    user = Repo.one(from user in User, where: user.id == ^user_id)

    new_habit = Ecto.build_assoc(user, :habits, name: habit)
    Repo.insert(new_habit)
  end

  @doc """
  Deletes a habit.

  ## Examples

      iex> #

      iex> #
      #

  """
  def delete_habit(user_id, habit) do
    habit_name =
      from user in User,
        where: user.id == ^user_id,
        join: habit in assoc(user, :habits),
        where: habit.name == ^habit,
        select: habit

    Repo.one(habit_name)
    |> Repo.delete()
  end
end
