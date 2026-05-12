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
end
