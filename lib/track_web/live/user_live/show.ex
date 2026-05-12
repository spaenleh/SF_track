defmodule TrackWeb.UserLive.Show do
  use TrackWeb, :live_view

  alias Track.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        User {@user.id}
        <:subtitle>This is a user record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/users"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/users/#{@user}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit user
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@user.name}</:item>
        <:item title="Email">{@user.email}</:item>
        <:item title="Is admin">{@user.is_admin}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe_users(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:user, Accounts.get_user!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Track.Accounts.User{id: id} = user},
        %{assigns: %{user: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :user, user)}
  end

  def handle_info(
        {:deleted, %Track.Accounts.User{id: id}},
        %{assigns: %{user: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current user was deleted.")
     |> push_navigate(to: ~p"/admin/users")}
  end

  def handle_info({type, %Track.Accounts.User{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
