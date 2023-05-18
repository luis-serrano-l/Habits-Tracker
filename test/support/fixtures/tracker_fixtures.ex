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
end
