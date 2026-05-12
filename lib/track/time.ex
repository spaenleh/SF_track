defmodule Track.Time do
  @moduledoc """
  The Time context.
  """

  import Ecto.Query, warn: false
  alias Track.Repo

  alias Track.Time.Project
  alias Track.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any project changes.

  The broadcasted messages match the pattern:

    * {:created, %Project{}}
    * {:updated, %Project{}}
    * {:deleted, %Project{}}

  """
  def subscribe_projects(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Track.PubSub, "user:#{key}:projects")
  end

  defp broadcast_project(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Track.PubSub, "user:#{key}:projects", message)
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects(scope)
      [%Project{}, ...]

  """
  def list_projects(%Scope{} = _scope) do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(scope, 123)
      %Project{}

      iex> get_project!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(%Scope{} = _scope, id) do
    Repo.get_by!(Project, id: id)
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(scope, %{field: value})
      {:ok, %Project{}}

      iex> create_project(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(%Scope{} = scope, attrs) do
    with {:ok, project = %Project{}} <-
           %Project{}
           |> Project.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_project(scope, {:created, project})
      {:ok, project}
    end
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(scope, project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(scope, project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Scope{} = scope, %Project{} = project, attrs) do
    true = scope.user.is_admin

    with {:ok, project = %Project{}} <-
           project
           |> Project.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_project(scope, {:updated, project})
      {:ok, project}
    end
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(scope, project)
      {:ok, %Project{}}

      iex> delete_project(scope, project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Scope{} = scope, %Project{} = project) do
    true = scope.user.is_admin

    with {:ok, project = %Project{}} <-
           Repo.delete(project) do
      broadcast_project(scope, {:deleted, project})
      {:ok, project}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(scope, project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Scope{} = scope, %Project{} = project, attrs \\ %{}) do
    true = scope.user.is_admin

    Project.changeset(project, attrs, scope)
  end

  alias Track.Time.Entry
  alias Track.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any entry changes.

  The broadcasted messages match the pattern:

    * {:created, %Entry{}}
    * {:updated, %Entry{}}
    * {:deleted, %Entry{}}

  """
  def subscribe_entries(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Track.PubSub, "user:#{key}:entries")
  end

  def subscribe_entries_admin() do
    Phoenix.PubSub.subscribe(Track.PubSub, "entries")
  end

  defp broadcast_entry(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Track.PubSub, "user:#{key}:entries", message)
    Phoenix.PubSub.broadcast(Track.PubSub, "entries", message)
  end

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries(scope)
      [%Entry{}, ...]

  """
  def list_entries(%Scope{} = scope) do
    Repo.all_by(Entry, user_id: scope.user.id) |> Repo.preload(:project)
  end

  def list_all_entries(%Scope{} = scope) do
    true = scope.user.is_admin
    Repo.all(Entry) |> Repo.preload(:project) |> Repo.preload(:user)
  end

  def list_all_entries(%Scope{} = scope, user_id) do
    true = scope.user.is_admin
    Repo.all_by(Entry, user_id: user_id) |> Repo.preload(:project) |> Repo.preload(:user)
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(scope, 123)
      %Entry{}

      iex> get_entry!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(%Scope{} = scope, id) do
    Repo.get_by!(Entry, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a entry.

  ## Examples

      iex> create_entry(scope, %{field: value})
      {:ok, %Entry{}}

      iex> create_entry(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(%Scope{} = scope, attrs) do
    with {:ok, entry = %Entry{}} <-
           %Entry{}
           |> Entry.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_entry(scope, {:created, entry})
      {:ok, entry}
    end
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(scope, entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry(scope, entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%Scope{} = scope, %Entry{} = entry, attrs) do
    true = entry.user_id == scope.user.id

    attrs = Map.put(attrs, :time_spent, time_to_minutes(attrs[:time_spent]))

    with {:ok, entry = %Entry{}} <-
           entry
           |> Entry.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_entry(scope, {:updated, entry})
      {:ok, entry}
    end
  end

  @doc """
  Deletes a entry.

  ## Examples

      iex> delete_entry(scope, entry)
      {:ok, %Entry{}}

      iex> delete_entry(scope, entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%Scope{} = scope, %Entry{} = entry) do
    true = entry.user_id == scope.user.id

    with {:ok, entry = %Entry{}} <-
           Repo.delete(entry) do
      broadcast_entry(scope, {:deleted, entry})
      {:ok, entry}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_entry(scope, entry)
      %Ecto.Changeset{data: %Entry{}}

  """
  def change_entry(%Scope{} = scope, %Entry{} = entry, attrs \\ %{}) do
    true = entry.user_id == scope.user.id

    Entry.changeset(entry, attrs, scope)
  end

  def get_user_total(%Scope{} = scope) do
    query = from e in Entry, where: [user_id: ^scope.user.id]

    Repo.aggregate(query, :sum, :time_spent)
  end

  def get_overall_total(%Scope{} = scope) do
    true = scope.user.is_admin

    query = from(e in Entry)
    Repo.aggregate(query, :sum, :time_spent)
  end

  def time_to_minutes(<<_h1, _h2, ?:, _m1, _m2>> = time) do
    [hours, minutes] = time |> String.split(":") |> Enum.map(&String.to_integer/1)
    hours * 60 + minutes
  end

  def time_to_minutes(time_spent) when is_binary(time_spent) do
    with {time_number, _} <- Float.parse(time_spent) do
      case time_number do
        v when v <= 10 -> floor(v * 60)
        v when v > 10 -> floor(v)
      end
    else
      _ -> 0
    end
  end

  def format_minutes(time_spent) when is_integer(time_spent) do
    hours = div(time_spent, 60) |> Integer.to_string() |> String.pad_leading(2, "0")
    minutes = rem(time_spent, 60) |> Integer.to_string() |> String.pad_leading(2, "0")

    "#{hours}:#{minutes}"
  end

  def format_time_spent(time_spent) when is_binary(time_spent) do
    time_spent |> time_to_minutes() |> format_minutes()
  end

  def format_time_spent(time_spent) do
    time_spent |> format_minutes()
  end
end
