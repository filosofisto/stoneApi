defmodule StoneApi.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table (:transaction) do
      add :account_origin_id, references(:financial_account)
      add :account_target_id, references(:financial_account)
      add :value, :float

      timestamps()
    end
  end
end
