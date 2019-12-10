defmodule StoneApiWeb.PageController do
  use StoneApiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
