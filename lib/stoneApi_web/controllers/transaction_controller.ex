defmodule StoneApiWeb.TransactionController do
  use StoneApiWeb, :controller

  require Logger

  alias StoneApi.Accounts
  alias StoneApi.Accounts.User
  alias StoneApi.Accounts.FinancialAccount
  alias StoneApi.Accounts.Transaction
  alias StoneApi.Guardian

  action_fallback StoneApiWeb.FallbackController

  # def index(conn, _params) do
  #   users = Accounts.list_users()
  #   render(conn, "index.json", users: users)
  # end

  # def withdrawal(conn, %{"user" => user_params}) do
  #   with {:ok, %User{} = user} <- Accounts.create_user(user_params),
  #        {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
  #     conn |> render("jwt.json", jwt: token)
  #     # |> put_status(:created)
  #     # |> put_resp_header("location", user_path(conn, :show, user))
  #     # |> render("show.json", user: user)
  #   end
  # end

  def withdrawal(conn, %{"value" => value}) do
    user = Guardian.Plug.current_resource(conn)
    { status, operation_success } = Accounts.withdrawal(user, value)

    if operation_success do
      send_resp(conn, :created, "")
    else
      send_resp(conn, :unprocessable_entity, "Insufficient funds")
    end
  end

  # def show(conn, _params) do
  #   # user = Accounts.get_user!(id)
  #   # render(conn, "show.json", user: user)
  #   user = Guardian.Plug.current_resource(conn)
  #   conn |> render("user.json", user: user)
  # end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Accounts.get_user!(id)

  #   with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Accounts.get_user!(id)
  #   with {:ok, %User{}} <- Accounts.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
