defmodule HabitsWeb.TableLive do
  use HabitsWeb, :live_view
  alias Habits.Tracker

  def mount(_params, _session, socket) do
    days = Tracker.list_days()

    # All habits ever tracked
    habit_list =
      days
      |> Stream.map(&Map.get(&1, :questions))
      |> Stream.flat_map(&Map.keys/1)
      |> Enum.uniq()

    # Habits that have integers as selected options.
    # We are going to ignore if there is a non_integer option that was never selected.
    nums_habits =
      habit_list
      |> Enum.filter(&all_nums?(records(&1, days)))

    {:ok, assign(socket, days: days, habit_list: habit_list, nums_habits: nums_habits)}
  end

  # Cannot operate with strings
  defp calculate_value(_, false, _, _), do: "x"

  defp calculate_value(op, true, habit, days) do
    habit
    |> int_records(days)
    |> operate(op)
  end

  defp operate(list, :avg), do: Float.round(Enum.sum(list) / length(list), 2)
  defp operate(list, :max), do: Enum.max(list)
  defp operate(list, :min), do: Enum.min(list)

  defp get_value(:times, list), do: length(list)

  defp get_value(frequency, list) do
    freq_map = Enum.frequencies(list)

    max_or_min =
      if frequency == :most do
        freq_map
        |> Map.values()
        |> Enum.max()
      else
        freq_map
        |> Map.values()
        |> Enum.min()
      end

    freq_map
    |> Stream.filter(fn {_, count} -> count == max_or_min end)
    |> Enum.map_join(" || ", fn {key, _} -> key end)
  end

  defp records(habit, days) do
    days
    |> Stream.filter(fn day -> habit in Map.keys(day.questions) end)
    |> Enum.map(fn day -> hd(day.questions[habit]) end)
  end

  defp int_records(habit, days) do
    habit
    |> records(days)
    |> Enum.map(&String.to_integer/1)
  end

  defp all_nums?(selections_list) do
    Enum.all?(selections_list, &String.match?(&1, ~r/^\d+$/))
  end
end
