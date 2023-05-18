defmodule HabitsWeb.ChartLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker

  def mount(_params, _session, socket) do
    {:ok, assign(socket, habit: nil, days: [])}
  end

  def handle_params(%{"habit" => habit}, _uri, socket) do
    days = Tracker.list_days()

    {:noreply, assign(socket, :days, days) |> assign(:habit, habit)}
  end

  def habit_to_chart(days, habit) do
    days_to_track =
      days
      |> Enum.filter(fn day -> habit in Map.keys(day.questions) end)

    option_index = List.last(days_to_track).questions[habit] |> Enum.sort() |> Enum.with_index()

    chart_data =
      days_to_track
      |> Enum.map(fn day ->
        [day.date, opt_to_num(option_index, hd(day.questions[habit]))]
      end)
      |> IO.inspect(label: "CHART!!!")

    chart_data
    |> Jason.encode!()
    |> Chartkick.line_chart()
    |> Phoenix.HTML.raw()
  end

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
        </tr>
        <%= for option <- @options do %>
          <tr>
            <td><%= option %></td>
            <td><%= Enum.find_index(options, &(&1 == option)) + 1 %></td>
          </tr>
        <% end %>
      </table>
    </div>
    """
  end

  def opt_to_num(option_index, option) do
    case for {opt, i} <- option_index, opt == option, do: i + 1 do
      [n] -> to_string(n)
      [] -> "0"
    end
  end
end
