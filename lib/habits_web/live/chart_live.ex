defmodule HabitsWeb.ChartLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker
  alias Habits.Accounts

  def mount(_params, session, socket) do
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    {:ok, assign(socket, user_id: user_id)}
  end

  # Assigns the habit that will be shown in the chart.
  def handle_params(%{"habit" => habit}, _uri, socket) do
    options =
      Tracker.get_last_options(socket.assigns.user_id, habit)
      |> Enum.sort()

    options_with_index = options |> Enum.with_index()
    date_choice_array = Tracker.date_choice_array(socket.assigns.user_id, habit)

    chart_data =
      date_choice_array
      |> Enum.map(fn [date, choice] -> [date, opt_to_num(options_with_index, choice)] end)

    {:noreply,
     assign(socket, chart_data: chart_data, habit: habit, options: Enum.reverse(options))}
  end

  @doc """
  - For a habit renders the html of its chart.
  - The chart shows the option selected in each day that the habit was recorded.
  """
  @spec habit_to_chart(chart_data :: list(list)) :: {:safe, binary}
  def habit_to_chart(chart_data) do
    chart_data
    |> Jason.encode!()
    |> Chartkick.line_chart()
    |> Phoenix.HTML.raw()
  end

  # - Matches the options of a habit to a number.
  # - Necessary for options that are words.
  # - Wouldn't need it for default.
  # - The number needs to be returned as a string, because it doesn't work with integers.

  # ## Examples

  #    iex> opt_to_num([{"No", 0}, {"Yes", 1}], "Yes")
  #    "2"
  #    iex> opt_to_num([{"1", 0}, {"2", 1}], "1")
  #    "1"

  defp opt_to_num(option_index, option) do
    case for {opt, i} <- option_index, opt == option, do: i + 1 do
      [n] -> to_string(n)
      [] -> "0"
    end
  end
end
