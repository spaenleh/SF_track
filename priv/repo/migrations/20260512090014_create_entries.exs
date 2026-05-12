defmodule Track.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :date, :date, null: false
      add :time_spent, :integer, null: false
      add :comment, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:entries, [:user_id])

    alter table(:users) do
      add :last_project_id, references(:projects, on_delete: :delete_all)
    end

    create index(:users, [:last_project_id])
  end
end
