defmodule Habits.Goal.Habit do
  use Ecto.Schema
  import Ecto.Changeset
  alias Habits.Accounts.User

  schema "habits" do
    field :name, :string

    timestamps()

    belongs_to(:user, User)
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:user_id)
  end
end
