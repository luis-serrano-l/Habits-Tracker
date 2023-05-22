defmodule HabitsWeb.ChartLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # Assigns the habit that will be shown in the chart.
  def handle_params(%{"habit" => habit}, _uri, socket) do
    days = Tracker.list_days()

    {:noreply, assign(socket, days: days, habit: habit)}
  end

  @doc """
  - For a habit renders the html of its chart.
  - The chart shows the option selected in each day that the habit was recorded.
  """
  @spec habit_to_chart(days :: list(map), habit :: map) :: {:safe, binary}
  def habit_to_chart(days, habit) do
    days_to_track =
      days
      |> Enum.filter(fn day -> habit in Map.keys(day.questions) end)

    # List of the options that the habit has with the index of each element.
    # Example => [{"Maybe", 0}, {"No", 1}, {"Yes", 2}]
    # This will be used to match each option with a number and display it in the chart.
    options_with_index =
      List.last(days_to_track).questions[habit] |> Enum.sort() |> Enum.with_index()

    # The list matches each day with the option selected that day.
    # Example => [[~D[2023-05-12], "No"], [~D[2023-05-14], "Yes"]]
    chart_data =
      Enum.map(days_to_track, fn day ->
        [day.date, opt_to_num(options_with_index, hd(day.questions[habit]))]
      end)

    chart_data
    |> Jason.encode!()
    |> Chartkick.line_chart()
    |> Phoenix.HTML.raw()
  end

  @doc """
  - Creates legend as a table that matches options with chart values.
  - Necessary for options that are words, because they are shown as numbers in the chart.

  Apparently Chartkick doesn't show words in a line chart in Elixir yet.
  """
  @spec legend_table(map) :: Phoenix.LiveView.Rendered.t()
  def legend_table(assigns) do
    habit = assigns[:habit]

    days_to_track =
      assigns[:days]
      |> Enum.filter(fn day -> habit in Map.keys(day.questions) end)

    options = List.last(days_to_track).questions[habit] |> Enum.sort()
    assigns = assign(assigns, :options, options) |> assign(:habit, habit)

    ~H"""
    <div>
      <table>
        <tr>
          <th><%= @habit %></th>
          <th>Value</th>
        </tr>
        <tr :for={option <- @options}>
          <td><%= option %></td>
          <td><%= Enum.find_index(@options, &(&1 == option)) + 1 %></td>
        </tr>
      </table>
    </div>
    """
  end

  @doc """
  - Matches the options of a habit to a number.
  - Necessary for options that are words.
  - Wouldn't need it for default.
  - The number needs to be returned as a string, because it doesn't work with integers.

  ## Examples

     iex> opt_to_num([{"No", 0}, {"Yes", 1}], "Yes")
     "2"
     iex> opt_to_num([{"1", 0}, {"2", 1}], "1")
     "1"
  """
  @spec opt_to_num(option_index :: list, option :: String.t()) :: binary
  def opt_to_num(option_index, option) do
    case for {opt, i} <- option_index, opt == option, do: i + 1 do
      [n] -> to_string(n)
      [] -> "0"
    end
  end
end
