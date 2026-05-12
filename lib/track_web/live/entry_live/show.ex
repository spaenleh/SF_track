defmodule TrackWeb.EntryLive.Show do
  use TrackWeb, :live_view

  alias Track.Time

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Entry {@entry.id}
        <:subtitle>This is a entry record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/entries"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/entries/#{@entry}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit entry
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Date">{@entry.date}</:item>
        <:item title="Time spent">{@entry.time_spent}</:item>
        <:item title="Comment">{@entry.comment}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Time.subscribe_entries(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Entry")
     |> assign(:entry, Time.get_entry!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Track.Time.Entry{id: id} = entry},
        %{assigns: %{entry: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :entry, entry)}
  end

  def handle_info(
        {:deleted, %Track.Time.Entry{id: id}},
        %{assigns: %{entry: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current entry was deleted.")
     |> push_navigate(to: ~p"/entries")}
  end

  def handle_info({type, %Track.Time.Entry{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
