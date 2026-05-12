defmodule TrackWeb.AdminLive.Index do
  use TrackWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>Admin Page</.header>
      <div class="flex flex-row gap-2">
        <.button navigate={~p"/admin/users"}>User management</.button>
        <.button navigate={~p"/admin/projects"}>Project management</.button>
        <.button navigate={~p"/admin/entries"}>Entry management</.button>
      </div>
    </Layouts.app>
    """
  end
end
