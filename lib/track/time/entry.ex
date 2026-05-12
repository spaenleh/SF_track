defmodule Track.Time.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :date, :date
    field :time_spent, :integer
    field :comment, :string
    belongs_to :user, Track.Accounts.User
    belongs_to :project, Track.Time.Project
    # virtual field for time spent input (e.g. "08:30")
    field :time_spent_input, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entry, attrs, user_scope) do
    entry
    |> cast(attrs, [:date, :time_spent_input, :comment, :project_id])
    |> default_today_date()
    |> parse_time_spent_input()
    |> validate_required([:date, :time_spent, :project_id])
    |> put_change(:user_id, user_scope.user.id)
  end

  defp default_today_date(changeset) do
    case get_field(changeset, :date) do
      nil -> put_change(changeset, :date, Date.utc_today())
      _ -> changeset
    end
  end

  defp parse_time_spent_input(changeset) do
    case get_change(changeset, :time_spent_input) do
      nil -> changeset
      "" -> put_change(changeset, :time_spent, nil)
      value -> put_change(changeset, :time_spent, Track.TimeConversions.to_minutes(value))
    end
  end
end
