defmodule StoneApi.Accounts.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias StoneApi.Accounts.Transaction

  schema "transaction" do
    field :account_origin_id, :integer
    field :account_target_id, :integer
    field :value, :float

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:account_origin_id, :account_target_id, :value])
    |> validate_required([:account_origin_id, :account_target_id, :value])
  end
end