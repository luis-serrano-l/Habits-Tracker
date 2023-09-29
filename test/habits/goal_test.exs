defmodule Habits.GoalTest do
  use Habits.DataCase

  alias Habits.Goal

  describe "habits" do
    alias Habits.Goal.Habit

    import Habits.GoalFixtures

    @invalid_attrs %{name: nil}

    test "create_habit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Goal.create_habit(@invalid_attrs)
    end

    test "update_habit/2 with valid data updates the habit" do
      habit = habit_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Habit{} = habit} = Goal.update_habit(habit, update_attrs)
      assert habit.name == "some updated name"
    end

    test "update_habit/2 with invalid data returns error changeset" do
      habit = habit_fixture()
      assert {:error, %Ecto.Changeset{}} = Goal.update_habit(habit, @invalid_attrs)
      assert habit == Goal.get_habit!(habit.id)
    end

    test "delete_habit/1 deletes the habit" do
      habit = habit_fixture()
      assert {:ok, %Habit{}} = Goal.delete_habit(habit)
      assert_raise Ecto.NoResultsError, fn -> Goal.get_habit!(habit.id) end
    end

    test "change_habit/1 returns a habit changeset" do
      habit = habit_fixture()
      assert %Ecto.Changeset{} = Goal.change_habit(habit)
    end
  end
end
