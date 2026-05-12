defmodule TrackWeb.PageController do
  use TrackWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
