defmodule StoneApi.Repo.Migrations.CreateFinancialAccount do
  use Ecto.Migration

  def change do
    create table (:financial_account) do
      add :user_id, references(:users)
      add :balance, :float

      timestamps()
    end
  end
end
