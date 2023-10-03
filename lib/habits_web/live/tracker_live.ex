defmodule HabitsWeb.TrackerLive do
  use HabitsWeb, :live_view

  alias Habits.Tracker
  alias Habits.Accounts

  def mount(_params, session, socket) do
    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date()
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id

    habits = Tracker.list_habits(user_id)

    habits_status = Tracker.get_habits_status(user_id, today)

    socket =
      assign(socket,
        habits_status: habits_status,
        habits: habits,
        new: false,
        date: today,
        form: to_form(%{"new_habit" => ""}),
        user_id: user_id
      )

    {:ok, socket}
  end

  # Travelling in time is available.
  def handle_event("yesterday", _, socket), do: travel_day(-1, socket)

  def handle_event("tomorrow", _, socket), do: travel_day(1, socket)

  def handle_event("today", _, socket), do: travel_day(:today, socket)

  @doc """
  Picks an option for a habit.

  - The selected option jumps to the head of the list.
  - Now the first option in the list is the one that will be shown in the chart when saved.

  Changes need to be saved.
  """
  def handle_event("select", %{"value" => new_status, "habit" => habit}, socket) do
    day_is_saved = socket.assigns.date in Tracker.list_dates(socket.assigns.user_id)
    current_habit_status = Enum.find(socket.assigns.habits_status, fn {h, _s} -> h == habit end)

    case {day_is_saved, current_habit_status, new_status} do
      {_, nil, ""} ->
        {:noreply, socket}

      {true, {_, current_status}, current_status} ->
        {:noreply, socket}

      {false, nil, new_status} ->
        Tracker.create_day_with_habit_status(
          socket.assigns.user_id,
          socket.assigns.date,
          habit,
          new_status
        )
        |> IO.inspect(label: "DAY CREATED")

        {:noreply, socket |> assign(habits_status: [{habit, new_status}])}

      {true, nil, new_status} ->
        new_habits_status =
          [{habit, new_status} | socket.assigns.habits_status]
          |> IO.inspect(label: "NEW STATUS FOR RENDER")

        Tracker.add_habit_status(
          socket.assigns.user_id,
          socket.assigns.date,
          new_habits_status
        )
        |> IO.inspect(label: "NEW STATUS FROM A HABIT THAT HAD NO STATUS")

        {:noreply, socket |> assign(habits_status: new_habits_status)}

      {true, {_habit, _current_status}, ""} ->
        new_habits_status =
          Enum.filter(socket.assigns.habits_status, fn {h, _s} -> h != habit end)
          |> IO.inspect(label: "DELETED STATUS FOR RENDER")

        Tracker.delete_habit_status(
          socket.assigns.user_id,
          socket.assigns.date,
          habit
        )
        |> IO.inspect(label: "STATUS DELETED")

        {:noreply, socket |> assign(habits_status: new_habits_status)}

      {true, {_habit, _current_status}, new_status} ->
        new_habits_status =
          Enum.map(socket.assigns.habits_status, fn {h, s} ->
            if h != habit,
              do: {h, s},
              else: {h, new_status}
          end)
          |> IO.inspect(label: "CHANGED STATUS FOR RENDER")

        Tracker.change_habit_status(
          socket.assigns.user_id,
          socket.assigns.date,
          habit,
          new_status
        )
        |> IO.inspect(label: "STATUS CHANGED")

        {:noreply, socket |> assign(habits_status: new_habits_status)}
    end
  end

  defp travel_day(:today, socket) do
    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date()
    habits_status = Tracker.get_habits_status(socket.assigns.user_id, today)

    {:noreply,
     socket
     |> assign(:date, today)
     |> assign(:habits_status, habits_status)}
  end

  defp travel_day(value, socket) do
    date = Date.add(socket.assigns.date, value)
    dates = Tracker.list_dates(socket.assigns.user_id)

    # If the day is in the database, it will show the habit-status recorded that day.
    if date in dates do
      habits_status = Tracker.get_habits_status(socket.assigns.user_id, date)

      {:noreply,
       socket
       |> update(:date, &Date.add(&1, value))
       |> assign(:habits_status, habits_status)}
    else
      new_date = Date.add(socket.assigns.date, value)

      {:noreply,
       socket
       |> assign(date: new_date)
       |> assign(habits_status: [])}
    end
  end

  def selected?(habits_status, habit, status) do
    List.keyfind(habits_status, habit, 0) == {habit, status}
  end
end
