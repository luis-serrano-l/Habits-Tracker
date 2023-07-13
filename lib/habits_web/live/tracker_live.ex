defmodule HabitsWeb.TrackerLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker
  alias Habits.Accounts

  @default_options ["1", "2", "3", "4", "5"]

  def mount(_params, session, socket) do
    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date()
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    daily_habits = Tracker.list_daily_habits(user_id, today)
    habits = Enum.map(daily_habits, &elem(&1, 0))

    socket =
      assign(socket,
        habits: habits,
        new: false,
        open_option: false,
        date: today,
        daily_habits: daily_habits,
        form: to_form(%{"new_habit" => "", "new_option" => ""}),
        user_id: user_id
      )

    {:ok, socket}
  end

  # Travelling in time is available.
  def handle_event("yesterday", _, socket), do: travel_day(-1, socket)

  def handle_event("tomorrow", _, socket), do: travel_day(1, socket)

  # Saves changes
  def handle_event("save", _, socket) do
    Tracker.create_or_update(
      socket.assigns.user_id,
      socket.assigns.date,
      socket.assigns.daily_habits
    )

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
    daily_habits = update_options(socket.assigns.daily_habits, habit, option)

    {:noreply,
     socket
     |> assign(daily_habits: daily_habits)
     |> assign(open_option: false)}
  end

  def handle_event("delete-habit", %{"habit" => habit}, socket) do
    daily_habits =
      List.delete(
        socket.assigns.daily_habits,
        List.keyfind(socket.assigns.daily_habits, habit, 0)
      )

    habits = Enum.map(daily_habits, &elem(&1, 0))

    {:noreply,
     socket
     |> assign(habits: habits)
     |> assign(daily_habits: daily_habits)
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
      options = Tracker.get_habit_options(socket.assigns.user_id, habit, @default_options)
      daily_habits = [{habit, options} | socket.assigns.daily_habits]
      habits = Enum.map(daily_habits, &elem(&1, 0))

      {:noreply,
       socket
       |> clear_flash()
       |> assign(:form, to_form(%{"new_habit" => habit, "new_option" => ""}))
       |> assign(:habits, habits)
       |> assign(:daily_habits, daily_habits)
       |> assign(:new, false)}
    end
  end

  def handle_event("reset-options", %{"habit" => habit}, socket) do
    daily_habits = update_options(socket.assigns.daily_habits, habit, [])

    {:noreply, assign(socket, daily_habits: daily_habits, open_option: false)}
  end

  def handle_event("open-option", %{"habit" => habit}, socket) do
    {:noreply, assign(socket, open_option: habit)}
  end

  def handle_event("add-option", %{"option" => option, "habit" => habit}, socket) do
    daily_habits = update_options(socket.assigns.daily_habits, habit, option)

    {:noreply,
     socket
     |> assign(:daily_habits, daily_habits)
     |> assign(:open_option, false)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp travel_day(value, socket) do
    date = Date.add(socket.assigns.date, value)
    dates = Tracker.list_dates(socket.assigns.user_id)

    # If the day in the database, it will display the habit-options recorded that day.
    if date in dates do
      daily_habits = Tracker.list_daily_habits(socket.assigns.user_id, date)

      habits = Enum.map(daily_habits, fn {habit, _options} -> habit end)

      {:noreply,
       socket
       |> update(:date, &Date.add(&1, value))
       |> assign(:daily_habits, daily_habits)
       |> assign(:habits, habits)}

      # If the day is not in the database, it will display the current habit-options unsaved.
    else
      {:noreply, update(socket, :date, &Date.add(&1, value))}
    end
  end

  defp update_options(daily_habits, habit, option) do
    Enum.map(daily_habits, fn {h, options} ->
      cond do
        h != habit -> {h, options}
        option == [] -> {h, []}
        true -> {h, Enum.uniq([option | options])}
      end
    end)
  end

  def possible_options(assigns, habit) do
    List.keyfind(assigns.daily_habits, habit, 0) |> elem(1)
  end
end
