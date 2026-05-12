defmodule Track.Time.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :date, :date
    field :time_spent, :integer
    field :comment, :string
    belongs_to :user, Track.Accounts.User
    belongs_to :project, Track.Time.Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entry, attrs, user_scope) do
    entry
    |> cast(attrs, [:date, :time_spent, :comment, :project_id])
    |> default_today_date()
    |> validate_required([:date, :time_spent, :project_id])
    |> put_change(:user_id, user_scope.user.id)
  end

  defp default_today_date(changeset) do
    case get_field(changeset, :date) do
      nil -> put_change(changeset, :date, Date.utc_today())
      _ -> changeset
    end
  end
end
