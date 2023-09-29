defmodule Habits.TrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Habits.Tracker` context.
  """

  @doc """
  Generate a habit_status.
  """
  def habit_status_fixture(attrs \\ %{}) do
    {:ok, habit_status} =
      attrs
      |> Enum.into(%{
        name: "some name",
        status: "some status"
      })
      |> Habits.Tracker.create_habit_status()

    habit_status
  end
end
