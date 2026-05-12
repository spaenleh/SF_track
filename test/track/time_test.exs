defmodule Track.TimeTest do
  use Track.DataCase

  alias Track.Time

  describe "projects" do
    alias Track.Time.Project

    import Track.AccountsFixtures, only: [user_scope_fixture: 0]
    import Track.TimeFixtures

    @invalid_attrs %{name: nil}

    test "list_projects/1 returns all scoped projects" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)
      other_project = project_fixture(other_scope)
      assert Time.list_projects(scope) == [project]
      assert Time.list_projects(other_scope) == [other_project]
    end

    test "get_project!/2 returns the project with given id" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      other_scope = user_scope_fixture()
      assert Time.get_project!(scope, project.id) == project
      assert_raise Ecto.NoResultsError, fn -> Time.get_project!(other_scope, project.id) end
    end

    test "create_project/2 with valid data creates a project" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Project{} = project} = Time.create_project(scope, valid_attrs)
      assert project.name == "some name"
      assert project.user_id == scope.user.id
    end

    test "create_project/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Time.create_project(scope, @invalid_attrs)
    end

    test "update_project/3 with valid data updates the project" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Project{} = project} = Time.update_project(scope, project, update_attrs)
      assert project.name == "some updated name"
    end

    test "update_project/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)

      assert_raise MatchError, fn ->
        Time.update_project(other_scope, project, %{})
      end
    end

    test "update_project/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Time.update_project(scope, project, @invalid_attrs)
      assert project == Time.get_project!(scope, project.id)
    end

    test "delete_project/2 deletes the project" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert {:ok, %Project{}} = Time.delete_project(scope, project)
      assert_raise Ecto.NoResultsError, fn -> Time.get_project!(scope, project.id) end
    end

    test "delete_project/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)
      assert_raise MatchError, fn -> Time.delete_project(other_scope, project) end
    end

    test "change_project/2 returns a project changeset" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert %Ecto.Changeset{} = Time.change_project(scope, project)
    end
  end

  describe "entries" do
    alias Track.Time.Entry

    import Track.AccountsFixtures, only: [user_scope_fixture: 0]
    import Track.TimeFixtures

    @invalid_attrs %{date: nil, comment: nil, time_spent: nil}

    test "list_entries/1 returns all scoped entries" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      entry = entry_fixture(scope)
      other_entry = entry_fixture(other_scope)
      assert Time.list_entries(scope) == [entry]
      assert Time.list_entries(other_scope) == [other_entry]
    end

    test "get_entry!/2 returns the entry with given id" do
      scope = user_scope_fixture()
      entry = entry_fixture(scope)
      other_scope = user_scope_fixture()
      assert Time.get_entry!(scope, entry.id) == entry
      assert_raise Ecto.NoResultsError, fn -> Time.get_entry!(other_scope, entry.id) end
    end

    test "create_entry/2 with valid data creates a entry" do
      valid_attrs = %{date: ~D[2026-05-11], comment: "some comment", time_spent: 42}
      scope = user_scope_fixture()

      assert {:ok, %Entry{} = entry} = Time.create_entry(scope, valid_attrs)
      assert entry.date == ~D[2026-05-11]
      assert entry.comment == "some comment"
      assert entry.time_spent == 42
      assert entry.user_id == scope.user.id
    end

    test "create_entry/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Time.create_entry(scope, @invalid_attrs)
    end

    test "update_entry/3 with valid data updates the entry" do
      scope = user_scope_fixture()
      entry = entry_fixture(scope)
      update_attrs = %{date: ~D[2026-05-12], comment: "some updated comment", time_spent: 43}

      assert {:ok, %Entry{} = entry} = Time.update_entry(scope, entry, update_attrs)
      assert entry.date == ~D[2026-05-12]
      assert entry.comment == "some updated comment"
      assert entry.time_spent == 43
    end

    test "update_entry/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      entry = entry_fixture(scope)

      assert_raise MatchError, fn ->
        Time.update_entry(other_scope, entry, %{})
      end
    end

    test "update_entry/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      entry = entry_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Time.update_entry(scope, entry, @invalid_attrs)
      assert entry == Time.get_entry!(scope, entry.id)
    end

    test "delete_entry/2 deletes the entry" do
      scope = user_scope_fixture()
      entry = entry_fixture(scope)
      assert {:ok, %Entry{}} = Time.delete_entry(scope, entry)
      assert_raise Ecto.NoResultsError, fn -> Time.get_entry!(scope, entry.id) end
    end

    test "delete_entry/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      entry = entry_fixture(scope)
      assert_raise MatchError, fn -> Time.delete_entry(other_scope, entry) end
    end

    test "change_entry/2 returns a entry changeset" do
      scope = user_scope_fixture()
      entry = entry_fixture(scope)
      assert %Ecto.Changeset{} = Time.change_entry(scope, entry)
    end
  end
end
