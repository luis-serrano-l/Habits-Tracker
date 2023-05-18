defmodule Habits.Tracker.Day do
  use Ecto.Schema
  import Ecto.Changeset

  schema "days" do
    field :date, :date
    field :questions, {:map, {:array, :string}}

    timestamps()
  end

  @doc false
  def changeset(day, attrs) do
    day
    |> cast(attrs, [:questions, :date])
    |> validate_required([:questions, :date])
  end
end
