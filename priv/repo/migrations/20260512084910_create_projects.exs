defmodule Track.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:name])
  end
end
