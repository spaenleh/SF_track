defmodule TrackWeb.ProjectLive.Show do
  use TrackWeb, :live_view

  alias Track.Time

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Project {@project.id}
        <:subtitle>This is a project record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/projects"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/projects/#{@project}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit project
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@project.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Time.subscribe_projects(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Project")
     |> assign(:project, Time.get_project!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Track.Time.Project{id: id} = project},
        %{assigns: %{project: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :project, project)}
  end

  def handle_info(
        {:deleted, %Track.Time.Project{id: id}},
        %{assigns: %{project: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current project was deleted.")
     |> push_navigate(to: ~p"/admin/projects")}
  end

  def handle_info({type, %Track.Time.Project{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
