defmodule StoneApiWeb.PageController do
  use StoneApiWeb, :controller

  alias StoneApi.Accounts

  def index(conn, _params) do
    render conn, "index.html"
  end

  def report(conn, _params) do
#    render conn, "report.html", transactions: Accounts.list_transactions()
    render conn, "report.html",
           by_day: Accounts.total_by_day(),
           by_month: Accounts.total_by_month(),
           by_year: Accounts.total_by_year(),
           total: Accounts.total(),
           transactions: Accounts.list_transactions()
  end
end
