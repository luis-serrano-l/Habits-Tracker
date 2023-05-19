defmodule HabitsWeb.ChartLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker

  def mount(_params, _session, socket) do
    {:ok, assign(socket, habit: nil, days: [])}
  end

  def handle_params(%{"habit" => habit}, _uri, socket) do
    days = Tracker.list_days()

    {:noreply, assign(socket, days: days, habit: habit)}
  end

  @doc """
  Renders the html for the chart
  """
  def habit_to_chart(days, habit) do
    days_to_track =
      days
      |> Enum.filter(fn day -> habit in Map.keys(day.questions) end)

    options_with_index =
      List.last(days_to_track).questions[habit] |> Enum.sort() |> Enum.with_index()

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
  Creates legend as a table that matches options with chart values.
  Necessary for options that are words, because they are shown as numbers in the chart.
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
  """
  @spec opt_to_num(option_index :: String.t(), option :: non_neg_integer) :: binary
  def opt_to_num(option_index, option) do
    case for {opt, i} <- option_index, opt == option, do: i + 1 do
      [n] -> to_string(n)
      [] -> "0"
    end
  end
end
