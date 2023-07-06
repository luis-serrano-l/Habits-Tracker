defmodule Habits.TrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habits.Tracker` context.
  """

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
end
