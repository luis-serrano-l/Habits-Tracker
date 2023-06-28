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

  describe "habits" do
    alias Habits.Tracker.DailyHabit

    import Habits.TrackerFixtures

    @invalid_attrs %{name: nil, options: nil, select: nil}

    test "list_habits/0 returns all habits" do
      daily_habit = daily_habit_fixture()
      assert Tracker.list_habits() == [daily_habit]
    end

    test "get_daily_habit!/1 returns the daily_habit with given id" do
      daily_habit = daily_habit_fixture()
      assert Tracker.get_daily_habit!(daily_habit.id) == daily_habit
    end

    test "create_daily_habit/1 with valid data creates a daily_habit" do
      valid_attrs = %{name: "some name", options: ["option1", "option2"], select: "some select"}

      assert {:ok, %DailyHabit{} = daily_habit} = Tracker.create_daily_habit(valid_attrs)
      assert daily_habit.name == "some name"
      assert daily_habit.options == ["option1", "option2"]
      assert daily_habit.select == "some select"
    end

    test "create_daily_habit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_daily_habit(@invalid_attrs)
    end

    test "update_daily_habit/2 with valid data updates the daily_habit" do
      daily_habit = daily_habit_fixture()
      update_attrs = %{name: "some updated name", options: ["option1"], select: "some updated select"}

      assert {:ok, %DailyHabit{} = daily_habit} = Tracker.update_daily_habit(daily_habit, update_attrs)
      assert daily_habit.name == "some updated name"
      assert daily_habit.options == ["option1"]
      assert daily_habit.select == "some updated select"
    end

    test "update_daily_habit/2 with invalid data returns error changeset" do
      daily_habit = daily_habit_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_daily_habit(daily_habit, @invalid_attrs)
      assert daily_habit == Tracker.get_daily_habit!(daily_habit.id)
    end

    test "delete_daily_habit/1 deletes the daily_habit" do
      daily_habit = daily_habit_fixture()
      assert {:ok, %DailyHabit{}} = Tracker.delete_daily_habit(daily_habit)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_daily_habit!(daily_habit.id) end
    end

    test "change_daily_habit/1 returns a daily_habit changeset" do
      daily_habit = daily_habit_fixture()
      assert %Ecto.Changeset{} = Tracker.change_daily_habit(daily_habit)
    end
  end

  describe "daily_habits" do
    alias Habits.Tracker.DailyHabit

    import Habits.TrackerFixtures

    @invalid_attrs %{name: nil, options: nil, select: nil}

    test "list_daily_habits/0 returns all daily_habits" do
      daily_habit = daily_habit_fixture()
      assert Tracker.list_daily_habits() == [daily_habit]
    end

    test "get_daily_habit!/1 returns the daily_habit with given id" do
      daily_habit = daily_habit_fixture()
      assert Tracker.get_daily_habit!(daily_habit.id) == daily_habit
    end

    test "create_daily_habit/1 with valid data creates a daily_habit" do
      valid_attrs = %{name: "some name", options: ["option1", "option2"], select: "some select"}

      assert {:ok, %DailyHabit{} = daily_habit} = Tracker.create_daily_habit(valid_attrs)
      assert daily_habit.name == "some name"
      assert daily_habit.options == ["option1", "option2"]
      assert daily_habit.select == "some select"
    end

    test "create_daily_habit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_daily_habit(@invalid_attrs)
    end

    test "update_daily_habit/2 with valid data updates the daily_habit" do
      daily_habit = daily_habit_fixture()
      update_attrs = %{name: "some updated name", options: ["option1"], select: "some updated select"}

      assert {:ok, %DailyHabit{} = daily_habit} = Tracker.update_daily_habit(daily_habit, update_attrs)
      assert daily_habit.name == "some updated name"
      assert daily_habit.options == ["option1"]
      assert daily_habit.select == "some updated select"
    end

    test "update_daily_habit/2 with invalid data returns error changeset" do
      daily_habit = daily_habit_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_daily_habit(daily_habit, @invalid_attrs)
      assert daily_habit == Tracker.get_daily_habit!(daily_habit.id)
    end

    test "delete_daily_habit/1 deletes the daily_habit" do
      daily_habit = daily_habit_fixture()
      assert {:ok, %DailyHabit{}} = Tracker.delete_daily_habit(daily_habit)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_daily_habit!(daily_habit.id) end
    end

    test "change_daily_habit/1 returns a daily_habit changeset" do
      daily_habit = daily_habit_fixture()
      assert %Ecto.Changeset{} = Tracker.change_daily_habit(daily_habit)
    end
  end

  describe "daily_habits" do
    alias Habits.Tracker.DailyHabit

    import Habits.TrackerFixtures

    @invalid_attrs %{choice: nil, name: nil, options: nil}

    test "list_daily_habits/0 returns all daily_habits" do
      daily_habit = daily_habit_fixture()
      assert Tracker.list_daily_habits() == [daily_habit]
    end

    test "get_daily_habit!/1 returns the daily_habit with given id" do
      daily_habit = daily_habit_fixture()
      assert Tracker.get_daily_habit!(daily_habit.id) == daily_habit
    end

    test "create_daily_habit/1 with valid data creates a daily_habit" do
      valid_attrs = %{choice: "some choice", name: "some name", options: ["option1", "option2"]}

      assert {:ok, %DailyHabit{} = daily_habit} = Tracker.create_daily_habit(valid_attrs)
      assert daily_habit.choice == "some choice"
      assert daily_habit.name == "some name"
      assert daily_habit.options == ["option1", "option2"]
    end

    test "create_daily_habit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_daily_habit(@invalid_attrs)
    end

    test "update_daily_habit/2 with valid data updates the daily_habit" do
      daily_habit = daily_habit_fixture()
      update_attrs = %{choice: "some updated choice", name: "some updated name", options: ["option1"]}

      assert {:ok, %DailyHabit{} = daily_habit} = Tracker.update_daily_habit(daily_habit, update_attrs)
      assert daily_habit.choice == "some updated choice"
      assert daily_habit.name == "some updated name"
      assert daily_habit.options == ["option1"]
    end

    test "update_daily_habit/2 with invalid data returns error changeset" do
      daily_habit = daily_habit_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_daily_habit(daily_habit, @invalid_attrs)
      assert daily_habit == Tracker.get_daily_habit!(daily_habit.id)
    end

    test "delete_daily_habit/1 deletes the daily_habit" do
      daily_habit = daily_habit_fixture()
      assert {:ok, %DailyHabit{}} = Tracker.delete_daily_habit(daily_habit)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_daily_habit!(daily_habit.id) end
    end

    test "change_daily_habit/1 returns a daily_habit changeset" do
      daily_habit = daily_habit_fixture()
      assert %Ecto.Changeset{} = Tracker.change_daily_habit(daily_habit)
    end
  end
end
