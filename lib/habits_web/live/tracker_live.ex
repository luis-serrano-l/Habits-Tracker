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

    socket =
      assign(socket,
        habits: Map.keys(opts_map),
        opts_map: opts_map,
        new: true,
        open_option: false,
        date: today
      )

    {:ok, socket}
  end

  def chart_link(assigns) do
    ~H"""
    <.link href={~p"/habits/#{@habit}"}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  def create_opts_map(_, _, []), do: %{}

  def create_opts_map(days, today, most_recent_day) do
    case Enum.find(days, &(&1.date == today)) do
      nil -> most_recent_day.questions
      day -> day.questions
    end
  end

  def handle_event("save", _, socket) do
    create_or_update(socket.assigns.opts_map, socket.assigns.date)

    Process.send_after(self(), :clear_flash, 2000)

    {:noreply,
     put_flash(
       socket,
       :info,
       "Progress saved. Remember your habits will lead you to your goals!"
     )}
  end

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

  # quiero hacer un patch pero no se como se hace
  def handle_event("open-chart", _, socket) do
    {:noreply, push_patch(socket, to: "/chart")}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  # <span><%= live_patch "Edit", to: Routes.product_show_path(@socket, :edit, @product), class: "button" %></span>
  # <%= if @live_action in [:edit] do %>
  defp possible_answers(assigns, habit) do
    assigns.opts_map[habit]
  end

  defp add_option(socket, option, habit) do
    Map.update(
      socket.assigns.opts_map,
      habit,
      "",
      &Enum.uniq(&1 ++ [option])
    )
  end

  defp clear_options(socket, habit) do
    Map.replace(socket.assigns.opts_map, habit, [])
  end

  def create_or_update(opts_map, date) do
    days = Tracker.list_days()

    case Enum.find(days, &(&1.date == date)) do
      nil -> Tracker.create_day(%{questions: opts_map, date: date})
      day -> Tracker.update_day(day, %{questions: opts_map})
    end
  end
end
