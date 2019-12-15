defmodule StoneApi.Accounts.FinancialAccount do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias StoneApi.Accounts.FinancialAccount

  schema "financial_account" do
    # field :user_id, :integer
    belongs_to :user, StoneApi.Accounts.User
    field :balance, :float

    timestamps()
  end

  @doc false
  def changeset(financial_account, attrs) do
    financial_account
    |> cast(attrs, [:user_id, :balance])
    |> validate_required([:user_id, :balance])
  end
end
