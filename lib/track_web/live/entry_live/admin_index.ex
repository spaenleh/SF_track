defmodule TrackWeb.EntryLive.AdminIndex do
  use TrackWeb, :live_view

  alias Track.Time
  alias Track.Accounts.Scope

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing All Entries
        <:actions>
          <.button navigate={~p"/admin"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="entries-form" phx-change="filter_user">
        <.input field={@form[:user_id]} type="select" label="Filter by user" options={@employees} />
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
        <:col :let={{_id, entry}} label="User">{entry.user.name}</:col>
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
      <span class="mt-6">
        <%= if @filtered_user_id != "" do %>
          Time for user: {@total_time |> Time.format_time_spent()}
        <% else %>
          Total time: {@total_time |> Time.format_time_spent()}
        <% end %>
      </span>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Time.subscribe_entries_admin()
    end

    employees =
      Track.Accounts.list_users(socket.assigns.current_scope) |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(:page_title, "Listing All Entries")
     |> assign(:total_time, Time.get_overall_total(socket.assigns.current_scope))
     |> assign(:filtered_user_id, "")
     |> assign(:form, to_form(%{user_id: nil}))
     |> assign(:employees, [{"Select someone", nil} | employees])
     |> stream(:entries, list_entries(socket.assigns.current_scope, ""))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    entry = Time.get_entry!(socket.assigns.current_scope, id)
    {:ok, _} = Time.delete_entry(socket.assigns.current_scope, entry)

    {:noreply, stream_delete(socket, :entries, entry)}
  end

  @impl true
  def handle_event("filter_user", %{"user_id" => user_id}, socket) do
    entries =
      list_entries(socket.assigns.current_scope, user_id)

    total_time =
      case user_id do
        "" -> Time.get_overall_total(socket.assigns.current_scope)
        _ -> Time.get_user_total(%Scope{user: %{id: user_id}})
      end

    {:noreply,
     socket
     |> assign(:filtered_user_id, user_id)
     |> assign(:form, to_form(%{user_id: user_id}))
     |> assign(:total_time, total_time)
     |> stream(:entries, entries, reset: true)}
  end

  @impl true
  def handle_info({type, %Track.Time.Entry{}}, socket)
      when type in [:created, :updated, :deleted] do
    entries = list_entries(socket.assigns.current_scope, socket.assigns.filtered_user_id)

    {:noreply,
     stream(
       socket,
       :entries,
       entries,
       reset: true
     )}
  end

  defp list_entries(current_scope, user_id) do
    case user_id do
      "" -> Time.list_all_entries(current_scope)
      _ -> Time.list_all_entries(current_scope, user_id)
    end
  end
end
