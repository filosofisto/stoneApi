defmodule StoneApiWeb.Router do
  use StoneApiWeb, :router

  # pipeline :browser do
  #   plug :accepts, ["html"]
  #   plug :fetch_session
  #   plug :fetch_flash
  #   plug :protect_from_forgery
  #   plug :put_secure_browser_headers
  # end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug StoneApi.Guardian.AuthPipeline
  end

  scope "/api/v1", StoneApiWeb do
    pipe_through :api 

    post "/sign_up", UserController, :create
    post "/sign_in", UserController, :sign_in

    # resources "/users", UserController, only: [:create, :show]

    # get "/", PageController, :index
  end

  scope "/api/v1", StoneApiWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/my_user", UserController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", StoneApiWeb do
  #   pipe_through :api
  # end
end
