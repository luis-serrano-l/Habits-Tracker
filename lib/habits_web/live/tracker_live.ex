defmodule HabitsWeb.TrackerLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker

  @default_options ["1", "2", "3", "4", "5"]

  def mount(_params, _session, socket) do
    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date()

    last_day_saved =
      case Tracker.list_days() do
        [] -> []
        days -> Enum.max_by(days, & &1.date)
      end

    current_day =
      case Tracker.get_day_by_date(today) do
        nil -> last_day_saved
        current_day -> current_day
      end

    socket =
      assign(socket,
        habits: Map.keys(current_day.questions),
        new: false,
        open_option: false,
        date: today,
        current_day: current_day,
        form: to_form(%{"new_habit" => "", "new_option" => ""})
      )

    {:ok, socket}
  end

  # Travelling in time is available.
  def handle_event("yesterday", _, socket), do: travel_day(-1, socket)

  def handle_event("tomorrow", _, socket), do: travel_day(1, socket)

  # Saves changes
  def handle_event("save", _, socket) do
    create_or_update(socket.assigns.current_day.questions, socket.assigns.date)

    Process.send_after(self(), :clear_flash, 2000)

    {:noreply,
     put_flash(
       socket,
       :info,
       "Progress saved. Remember your habits will lead you to your goals!"
     )}
  end

  @doc """
  Picks an option for a habit.

  - The selected option jumps to the head of the list.
  - Now the first option in the list is the one that will be shown in the chart when saved.

  Changes need to be saved.
  """
  def handle_event("select", %{"value" => option, "habit" => habit}, socket) do
    current_day =
      do_update_in(socket.assigns.current_day, habit, &[option | List.delete(&1, option)])

    {:noreply,
     socket
     |> assign(current_day: current_day)
     |> assign(open_option: false)}
  end

  def handle_event("delete-habit", %{"habit" => habit}, socket) do
    habits = List.delete(socket.assigns.habits, habit)

    opts_map =
      socket.assigns.current_day.questions
      |> Map.delete(habit)

    {:ok, current_day} = Tracker.update_day(socket.assigns.current_day, %{questions: opts_map})

    {:noreply,
     socket
     |> assign(habits: habits)
     |> assign(current_day: current_day)
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
      opts_map =
        Map.update(socket.assigns.current_day.questions, habit, existing_or_default(habit), & &1)

      {:ok, current_day} = Tracker.update_day(socket.assigns.current_day, %{questions: opts_map})

      {:noreply,
       socket
       |> clear_flash()
       |> assign(:form, to_form(%{"new_habit" => habit, "new_option" => ""}))
       |> update(:habits, &[habit | &1])
       |> assign(:current_day, current_day)
       |> assign(:new, false)}
    end
  end

  def handle_event("reset-options", %{"habit" => habit}, socket) do
    current_day = do_update_in(socket.assigns.current_day, habit, fn _ -> [] end)

    {:noreply, assign(socket, current_day: current_day, open_option: false)}
  end

  def handle_event("open-option", %{"habit" => habit}, socket) do
    {:noreply, assign(socket, open_option: habit)}
  end

  def handle_event("add-option", %{"option" => option, "habit" => habit}, socket) do
    current_day = do_update_in(socket.assigns.current_day, habit, &Enum.uniq(&1 ++ [option]))

    {:noreply,
     socket
     |> assign(:current_day, current_day)
     |> assign(:open_option, false)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp travel_day(value, socket) do
    date = Date.add(socket.assigns.date, value)

    case Tracker.get_day_by_date(date) do
      # If the day is not in the database, it will display the current habit-options unsaved.
      nil ->
        {:noreply, update(socket, :date, &Date.add(&1, value))}

      # If the day in the database, it will display the habit-options recorded that day.
      day ->
        {:noreply,
         socket
         |> update(:date, &Date.add(&1, value))
         |> assign(:current_day, day)
         |> assign(:habits, Map.keys(day.questions))}
    end
  end

  # The Kernel.update_in function does not work because Day doesnt implement the Access behaviour
  defp do_update_in(current_day, habit, func) do
    opts_map = Map.update(current_day.questions, habit, [], &func.(&1))
    Map.update(current_day, :questions, %{}, fn _ -> opts_map end)
  end

  # If a new habit is added and it already existed in the database, it gets the same options,
  # else default.
  defp existing_or_default(habit) do
    all_opts_maps = Tracker.list_all_opts_maps()

    Map.get(all_opts_maps, habit, @default_options)
  end

  # Displays the options available for a certain habit.
  defp possible_options(assigns, habit) do
    assigns.current_day.questions[habit]
  end

  # - If today is not in the database, it creates the day with the habits.
  # - Else it updates changes.
  defp create_or_update(opts_map, date) do
    case Tracker.get_day_by_date(date) do
      nil -> Tracker.create_day(%{questions: opts_map, date: date})
      day -> Tracker.update_day(day, %{questions: opts_map})
    end
  end
end
