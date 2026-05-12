defmodule TrackWeb.EntryLive.Form do
  use TrackWeb, :live_view

  alias Track.Time
  alias Track.Time.Entry
  alias Track.TimeConversions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="entry-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:date]} type="date" label="Date" phx-mounted={JS.focus()}>
          <.button type="button" phx-click="set_yesterday">
            Yesterday
          </.button>
        </.input>
        <.input field={@form[:project_id]} type="select" label="Project" options={@projects} />
        <.input
          field={@form[:time_spent_input]}
          type="text"
          label="Time spent"
          phx-blur="format_time_spent"
        />
        <.input field={@form[:comment]} type="text" label="Comment" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Entry</.button>
          <.button navigate={return_path(@current_scope, @return_to, @entry)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    projects =
      Track.Time.list_projects(socket.assigns.current_scope) |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:projects, projects)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    entry = Time.get_entry!(socket.assigns.current_scope, id)
    formatted = Track.TimeConversions.format_minutes(entry.time_spent)

    socket
    |> assign(:page_title, "Edit time tracking entry")
    |> assign(:entry, entry)
    |> assign(
      :form,
      to_form(
        Time.change_entry(socket.assigns.current_scope, entry, %{
          "time_spent_input" => formatted
        })
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    preferred_project_id = socket.assigns.current_scope.user.last_project_id

    entry = %Entry{
      user_id: socket.assigns.current_scope.user.id,
      project_id: preferred_project_id
    }

    socket
    |> assign(:page_title, "New time tracking entry")
    |> assign(:entry, entry)
    |> assign(:form, to_form(Time.change_entry(socket.assigns.current_scope, entry)))
  end

  @impl true
  def handle_event("validate", %{"entry" => entry_params}, socket) do
    changeset =
      Time.change_entry(socket.assigns.current_scope, socket.assigns.entry, entry_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("set_yesterday", _params, socket) do
    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_change(:date, Date.add(Date.utc_today(), -1))

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("format_time_spent", %{"value" => ""}, socket) do
    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_change(:time_spent_input, "")
      |> Ecto.Changeset.put_change(:time_spent, nil)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("format_time_spent", %{"value" => value}, socket) do
    minutes = TimeConversions.to_minutes(value)
    formatted = TimeConversions.format_minutes(minutes)

    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_change(:time_spent_input, formatted)
      |> Ecto.Changeset.put_change(:time_spent, minutes)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"entry" => entry_params}, socket) do
    save_entry(socket, socket.assigns.live_action, entry_params)
  end

  defp save_entry(socket, :edit, entry_params) do
    case Time.update_entry(socket.assigns.current_scope, socket.assigns.entry, entry_params) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Entry updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, entry)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_entry(socket, :new, entry_params) do
    case Time.create_entry(socket.assigns.current_scope, entry_params) do
      {:ok, entry} ->
        {:ok, _user} =
          Track.Accounts.save_project_preference(socket.assigns.current_scope, entry.project_id)

        {:noreply,
         socket
         |> put_flash(:info, "Entry created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, entry)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _entry), do: ~p"/entries"
  defp return_path(_scope, "show", entry), do: ~p"/entries/#{entry}"
end
