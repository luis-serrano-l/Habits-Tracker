defmodule Habits.TrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habits.Tracker` context.
  """

  @doc """
  Generate a day.
  """
  def day_fixture(attrs \\ %{}) do
    {:ok, day} =
      attrs
      |> Enum.into(%{
        date: ~D[2023-05-17],
        questions: %{}
      })
      |> Habits.Tracker.create_day()

    day
  end

  @doc """
  Generate a daily_habit.
  """
  def daily_habit_fixture(attrs \\ %{}) do
    {:ok, daily_habit} =
      attrs
      |> Enum.into(%{
        name: "some name",
        options: ["option1", "option2"],
        select: "some select"
      })
      |> Habits.Tracker.create_daily_habit()

    daily_habit
  end

  @doc """
  Generate a daily_habit.
  """
  def daily_habit_fixture(attrs \\ %{}) do
    {:ok, daily_habit} =
      attrs
      |> Enum.into(%{
        choice: "some choice",
        name: "some name",
        options: ["option1", "option2"]
      })
      |> Habits.Tracker.create_daily_habit()

    daily_habit
  end
end
