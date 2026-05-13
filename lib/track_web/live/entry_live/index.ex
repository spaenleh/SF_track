defmodule TrackWeb.EntryLive.Index do
  use TrackWeb, :live_view

  alias Track.Time

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Entries
        <:actions>
          <.button variant="primary" navigate={~p"/track"}>
            <.icon name="hero-plus" /> New Entry
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="entries-form" phx-change="filter_project">
        <.input
          field={@form[:project_id]}
          type="select"
          label="Filter by project"
          options={@projects}
        />
      </.form>

      <.table
        id="entries"
        rows={@streams.entries}
        row_click={fn {_id, entry} -> JS.navigate(~p"/entries/#{entry}") end}
      >
        <:col :let={{_id, entry}} label="Date">{entry.date}</:col>
        <:col :let={{_id, entry}} label="Time spent">
          {entry.time_spent |> Time.format_time_spent()}
        </:col>
        <:col :let={{_id, entry}} label="Project">{entry.project.name}</:col>
        <:col :let={{_id, entry}} label="Comment">{entry.comment}</:col>
        <:action :let={{_id, entry}}>
          <div class="sr-only">
            <.link navigate={~p"/entries/#{entry}"}>Show</.link>
          </div>
          <.link navigate={~p"/entries/#{entry}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, entry}}>
          <.link
            phx-click={JS.push("delete", value: %{id: entry.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>

      <span class="mt-6">Your total time: {@total_time |> Time.format_time_spent()}</span>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Time.subscribe_entries(socket.assigns.current_scope)
    end

    projects =
      Track.Time.list_projects(socket.assigns.current_scope)
      |> Enum.map(fn p -> {p.name, p.id} end)

    {:ok,
     socket
     |> assign(:page_title, "Listing Entries")
     |> assign(:total_time, Time.get_user_total(socket.assigns.current_scope))
     |> assign(:filtered_project_id, "")
     |> assign(:form, to_form(%{project_id: nil}))
     |> assign(:projects, [{"No Project", nil} | projects])
     |> stream(:entries, list_entries(socket.assigns.current_scope, ""))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    entry = Time.get_entry!(socket.assigns.current_scope, id)
    {:ok, _} = Time.delete_entry(socket.assigns.current_scope, entry)

    {:noreply, stream_delete(socket, :entries, entry)}
  end

  @impl true
  def handle_event("filter_project", %{"project_id" => project_id}, socket) do
    entries =
      list_entries(socket.assigns.current_scope, project_id)

    total_time =
      case project_id do
        "" -> Time.get_user_total(socket.assigns.current_scope)
        _ -> Time.get_user_total(socket.assigns.current_scope, project_id)
      end

    {:noreply,
     socket
     |> assign(:filtered_project_id, project_id)
     |> assign(:form, to_form(%{project_id: project_id}))
     |> assign(:total_time, total_time)
     |> stream(:entries, entries, reset: true)}
  end

  @impl true
  def handle_info({type, %Track.Time.Entry{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(
       socket,
       :entries,
       list_entries(socket.assigns.current_scope, socket.assigns.filtered_project_id),
       reset: true
     )}
  end

  defp list_entries(current_scope, project_id) do
    case project_id do
      "" -> Time.list_entries(current_scope)
      _ -> Time.list_all_entries_for_project(current_scope, project_id)
    end
  end
end
