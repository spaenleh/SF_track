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
end
