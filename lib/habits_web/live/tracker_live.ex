defmodule HabitsWeb.TrackerLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker

  def mount(_params, _session, socket) do
    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date()
    days = Tracker.list_days()

    most_recent_day =
      case days do
        [] -> []
        days -> Enum.max_by(days, & &1.date)
      end

    opts_map = create_opts_map(days, today, most_recent_day)

    questions = Enum.map(days, fn day -> Map.keys(day.questions) end) |> List.flatten()

    socket =
      assign(socket,
        habits: Map.keys(opts_map),
        opts_map: opts_map,
        new: false,
        open_option: false,
        date: today,
        questions: questions
      )

    {:ok, socket}
  end

  # Renders link to the chart that shows the records of a habit.
  def chart_link(assigns) do
    ~H"""
    <.link href={~p"/habits/#{@habit}"}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # Travelling in time is available.
  def handle_event("yesterday", _, socket), do: change_day(-1, socket)

  def handle_event("tomorrow", _, socket), do: change_day(1, socket)

  # Saves changes
  def handle_event("save", _, socket) do
    create_or_update(socket.assigns.opts_map, socket.assigns.date)

    Process.send_after(self(), :clear_flash, 2000)
    days = Tracker.list_days()
    questions = Enum.map(days, fn day -> Map.keys(day.questions) end) |> List.flatten()

    {:noreply,
     put_flash(
       socket,
       :info,
       "Progress saved. Remember your habits will lead you to your goals!"
     )
     |> assign(:questions, questions)}
  end

  @doc """
  Picks an option for a habit.

  - The selected option jumps to the head of the list.
  - Now the first option in the list is the one that will be shown in the chart when saved.

  Changes need to be saved.
  """
  def handle_event("select", %{"value" => option, "habit" => habit}, socket) do
    opts_map =
      Map.update(
        socket.assigns.opts_map,
        habit,
        [],
        &[option | List.delete(&1, option)]
      )

    {:noreply,
     socket
     |> assign(opts_map: opts_map)
     |> assign(open_option: false)}
  end

  def handle_event("delete-habit", %{"habit" => habit}, socket) do
    habits = List.delete(socket.assigns.habits, habit)

    opts_map =
      socket.assigns.opts_map
      |> Map.delete(habit)

    {:noreply,
     socket
     |> assign(habits: habits)
     |> assign(opts_map: opts_map)
     |> assign(open_option: false)}
  end

  def handle_event("new-habit", _, socket) do
    {:noreply, assign(socket, new: true, open_option: false)}
  end

  def handle_event("add-habit", %{"habit" => habit}, socket) do
    if habit in socket.assigns.habits do
      Process.send_after(self(), :clear_flash, 900)
      {:noreply, put_flash(socket, :error, "Already existing habit")}
    else
      opts_map = Map.update(socket.assigns.opts_map, habit, ["1", "2", "3", "4", "5"], & &1)

      {:noreply,
       socket
       |> clear_flash()
       |> update(:habits, &[habit | &1])
       |> assign(:opts_map, opts_map)
       |> assign(:new, false)}
    end
  end

  def handle_event("reset-options", %{"habit" => habit}, socket) do
    opts_map = clear_options(socket, habit)

    socket = assign(socket, opts_map: opts_map, open_option: false)

    {:noreply, socket}
  end

  def handle_event("open-option", %{"habit" => habit}, socket) do
    {:noreply, assign(socket, open_option: habit)}
  end

  def handle_event("add-option", %{"option" => option, "habit" => habit}, socket) do
    opts_map = add_option(socket, option, habit)

    socket = assign(socket, opts_map: opts_map, open_option: false)

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp change_day(value, socket) do
    days = Tracker.list_days()

    case Enum.find(days, &(&1.date == Date.add(socket.assigns.date, value))) do
      # If the day is not in the database, it will display the current habit-options unsaved.
      nil ->
        {:noreply, update(socket, :date, &Date.add(&1, value))}

      # If the day in the database, it will display the habit-options recorded that day.
      day ->
        {:noreply,
         socket
         |> update(:date, &Date.add(&1, value))
         |> assign(:opts_map, day.questions)
         |> assign(:habits, Map.keys(day.questions))}
    end
  end

  @doc """
  - Creates today's habit map. It has the habits and the list of options for each habit.
  - The first option in the list is the one that is picked by default.
  - If today hasn't been saved yet, it displays the habits and options of the last day saved.

  opts_map => %{
    "How are you feeling today?" => ["1", "2", "3", "4", "5"],
    "Did you wake up early?" => ["Yes", "No"]
  }
  Later, if we pick a different option, it will become the first in the list.
  """
  @spec create_opts_map(days :: list(map), today :: map, most_recent_day :: map) :: map
  def create_opts_map(_, _, []), do: %{}

  def create_opts_map(days, today, most_recent_day) do
    case Enum.find(days, &(&1.date == today)) do
      nil -> most_recent_day.questions
      day -> day.questions
    end
  end

  # Displays the options available for a certain habit.
  defp possible_answers(assigns, habit) do
    assigns.opts_map[habit]
  end

  # Adds an option to chose for a habit.
  defp add_option(socket, option, habit) do
    Map.update(
      socket.assigns.opts_map,
      habit,
      "",
      &Enum.uniq(&1 ++ [option])
    )
  end

  # Clears all options.
  defp clear_options(socket, habit) do
    Map.replace(socket.assigns.opts_map, habit, [])
  end

  @doc """
  - If today is not in the database, it creates the day with the habits.
  - Else it updates changes.
  """
  def create_or_update(opts_map, date) do
    days = Tracker.list_days()

    case Enum.find(days, &(&1.date == date)) do
      nil -> Tracker.create_day(%{questions: opts_map, date: date})
      day -> Tracker.update_day(day, %{questions: opts_map})
    end
  end
end
