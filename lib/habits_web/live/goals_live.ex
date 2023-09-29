defmodule HabitsWeb.GoalsLive do
  use HabitsWeb, :live_view
  alias Habits.Goal
  alias Habits.Accounts

  def mount(_params, session, socket) do
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    habits = Goal.list_habits(user_id)

    socket =
      assign(socket,
        deleting: false,
        new: false,
        habits: habits,
        form: to_form(%{"new_habit" => ""}),
        user_id: user_id
      )

    {:ok, socket}
  end

  def handle_event("allow-delete", _, socket) do
    {:noreply, assign(socket, deleting: true)}
  end

  def handle_event("disable-delete", _, socket) do
    {:noreply, assign(socket, deleting: false)}
  end

  def handle_event("delete-habit", %{"habit" => habit}, socket) do
    habits =
      List.delete(
        socket.assigns.habits,
        habit
      )

    Goal.delete_habit(socket.assigns.user_id, habit)

    {:noreply,
     socket
     |> assign(habits: habits)}

    # Create an option for removing or keeping the track of the habits
  end

  def handle_event("new-habit", _, socket) do
    {:noreply, assign(socket, new: true)}
  end

  def handle_event("add-habit", %{"habit" => habit}, socket) do
    if habit in socket.assigns.habits do
      Process.send_after(self(), :clear_flash, 900)

      {:noreply,
       put_flash(socket, :error, "Already existing habit")
       |> assign(form: to_form(%{"new_habit" => ""}))}
    else
      habits = [habit | socket.assigns.habits]
      Goal.add_habit(socket.assigns.user_id, habit)

      {:noreply,
       socket
       |> clear_flash()
       |> assign(:habits, habits)
       |> assign(:new, false)}
    end
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
