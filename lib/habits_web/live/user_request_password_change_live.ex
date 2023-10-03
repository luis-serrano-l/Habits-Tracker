defmodule HabitsWeb.UserRequestPasswordChangeLive do
  use HabitsWeb, :live_view

  alias Habits.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Want to change your password?
        <:subtitle>We'll send a password change link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full fit-button">
            Send password change instructions
          </.button>
        </:actions>
      </.simple_form>

      <div id="corner-links">
        <div id="menu-container">
          <div id="user-box" class="hidden">
            <.link href={~p"/habits/goals"} id="user-link">Habits</.link>
            <.link href={~p"/habits"} id="user-link">Track</.link>
          </div>
          <!-- Hamburger Icon -->
          <div id="hamburger-icon" class="menu-icon">
            <div class="bar"></div>
            <div class="bar"></div>
            <div class="bar"></div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_change_password_instructions(
        user,
        &url(~p"/users/update_password/#{&1}")
      )
    end

    Process.send_after(self(), :clear_flash, 1200)

    info =
      "If your email is in our system, you will receive instructions to change your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
