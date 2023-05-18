defmodule Habits.TrackerTest do
  use Habits.DataCase

  alias Habits.Tracker

  describe "days" do
    alias Habits.Tracker.Day

    import Habits.TrackerFixtures

    @invalid_attrs %{date: nil, questions: nil}

    test "list_days/0 returns all days" do
      day = day_fixture()
      assert Tracker.list_days() == [day]
    end

    test "get_day!/1 returns the day with given id" do
      day = day_fixture()
      assert Tracker.get_day!(day.id) == day
    end

    test "create_day/1 with valid data creates a day" do
      valid_attrs = %{date: ~D[2023-05-17], questions: %{}}

      assert {:ok, %Day{} = day} = Tracker.create_day(valid_attrs)
      assert day.date == ~D[2023-05-17]
      assert day.questions == %{}
    end

    test "create_day/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_day(@invalid_attrs)
    end

    test "update_day/2 with valid data updates the day" do
      day = day_fixture()
      update_attrs = %{date: ~D[2023-05-18], questions: %{}}

      assert {:ok, %Day{} = day} = Tracker.update_day(day, update_attrs)
      assert day.date == ~D[2023-05-18]
      assert day.questions == %{}
    end

    test "update_day/2 with invalid data returns error changeset" do
      day = day_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_day(day, @invalid_attrs)
      assert day == Tracker.get_day!(day.id)
    end

    test "delete_day/1 deletes the day" do
      day = day_fixture()
      assert {:ok, %Day{}} = Tracker.delete_day(day)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_day!(day.id) end
    end

    test "change_day/1 returns a day changeset" do
      day = day_fixture()
      assert %Ecto.Changeset{} = Tracker.change_day(day)
    end
  end
end
