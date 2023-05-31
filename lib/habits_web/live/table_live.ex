defmodule HabitsWeb.TableLive do
  use HabitsWeb, :live_view
  alias Habits.Tracker

  def mount(_params, _session, socket) do
    # All habits ever tracked
    habit_list = Map.keys(Tracker.list_all_opts_maps())

    # Habits that have numbers as options and we can operate with them.
    nums_habits = Tracker.list_num_habits()

    {:ok, assign(socket, habit_list: habit_list, nums_habits: nums_habits)}
  end

  # Cannot operate with strings
  defp calculate_value(_, false, _), do: "x"

  defp calculate_value(op, true, habit) do
    habit
    |> int_records()
    |> operate(op)
  end

  defp operate(list, :avg), do: Float.round(Enum.sum(list) / length(list), 2)
  defp operate(list, :max), do: Enum.max(list)
  defp operate(list, :min), do: Enum.min(list)

  defp get_value(:times, habit), do: length(records(habit))

  defp get_value(:most, habit) do
    freq_map =
      records(habit)
      |> Enum.frequencies()

    freq_map
    |> Map.values()
    |> Enum.max()
    |> values_for_frequencies(freq_map)
  end

  defp get_value(:least, habit) do
    records = records(habit)

    unselected_map =
      (Enum.uniq(Tracker.list_all_opts_maps()[habit]) -- records)
      |> Enum.reduce(%{}, fn key, acc -> Map.merge(%{key => 0}, acc) end)

    freq_map =
      Enum.frequencies(records)
      |> Map.merge(unselected_map)

    freq_map
    |> Map.values()
    |> Enum.min()
    |> values_for_frequencies(freq_map)
  end

  defp values_for_frequencies(value, freq_map) do
    freq_map
    |> Enum.filter(fn {_, count} -> count == value end)
    |> Enum.map_join(" || ", fn {key, _} -> key end)
  end

  defp records(habit) do
    Tracker.list_days()
    |> Enum.filter(fn day -> habit in Map.keys(day.questions) end)
    |> Enum.map(fn day -> hd(day.questions[habit]) end)
  end

  defp int_records(habit) do
    habit
    |> records()
    |> Enum.map(&String.to_integer/1)
  end
end
