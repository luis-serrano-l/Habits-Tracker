defmodule HabitsWeb.RedirectLive do
  use HabitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/habits")}
  end
end
