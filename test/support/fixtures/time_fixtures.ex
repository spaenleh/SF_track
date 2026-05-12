defmodule Track.TimeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Track.Time` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, project} = Track.Time.create_project(scope, attrs)
    project
  end

  @doc """
  Generate a entry.
  """
  def entry_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        comment: "some comment",
        date: ~D[2026-05-11],
        time_spent: 42
      })

    {:ok, entry} = Track.Time.create_entry(scope, attrs)
    entry
  end
end
