defmodule HabitsWeb.TableLive do
  use HabitsWeb, :live_view
  alias Habits.Tracker
  alias Habits.Accounts

  def mount(_params, session, socket) do
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    # All habits ever tracked
    habit_list = Tracker.list_habits(user_id)
    habit_choices_tuples = Enum.map(habit_list, &{&1, Tracker.habit_choices(user_id, &1)})
    # Habits that have numbers as options and we can operate with them.
    nums_habits =
      habit_choices_tuples
      |> Enum.filter(fn {_habit, choices} -> Enum.all?(choices, &String.match?(&1, ~r/^\d+$/)) end)
      |> Enum.map(fn {habit, _choices} -> habit end)

    {:ok,
     assign(socket,
       user_id: user_id,
       habit_choices_tuples: habit_choices_tuples,
       habit_list: habit_list,
       nums_habits: nums_habits
     )}
  end

  # Cannot operate with strings
  defp calculate_value(_, false, _, _), do: "x"

  defp calculate_value(op, true, habit, habit_choices_tuples) do
    habit
    |> int_records(habit_choices_tuples)
    |> operate(op)
  end

  defp operate(list, :avg), do: Float.round(Enum.sum(list) / length(list), 2)
  defp operate(list, :max), do: Enum.max(list)
  defp operate(list, :min), do: Enum.min(list)

  defp get_value(:times, habit, habit_choices_tuples),
    do: length(records(habit, habit_choices_tuples))

  defp get_value(:most, habit, habit_choices_tuples) do
    freq_map =
      records(habit, habit_choices_tuples)
      |> Enum.frequencies()

    freq_map
    |> Map.values()
    |> Enum.max()
    |> values_for_frequencies(freq_map)
  end

  defp get_value(:least, habit, habit_choices_tuples, user_id) do
    records = records(habit, habit_choices_tuples)

    unselected_map =
      Enum.uniq(Tracker.get_last_options(user_id, habit) -- records)
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
    |> Enum.map_join(" | ", fn {key, _} -> key end)
  end

  defp records(habit, habit_choices_tuples),
    do: List.keyfind(habit_choices_tuples, habit, 0) |> elem(1)

  defp int_records(habit, habit_choices_tuples) do
    habit
    |> records(habit_choices_tuples)
    |> Enum.map(&String.to_integer/1)
  end
end
