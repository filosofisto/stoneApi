defmodule StoneApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  require Logger
  alias StoneApi.Repo
  alias StoneApi.Accounts.User
  alias StoneApi.Accounts.FinancialAccount
  alias StoneApi.Accounts.Transaction
  alias StoneApi.Guardian
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  @default_balance 1000.0

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)
      _ ->
        {:error, :unauthorized}
    end
  end
  
  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email),
    do: verify_password(password, user)
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        dummy_checkpw()
        {:error, "Login error."}
      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if checkpw(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end

  def list_transactions do
    Transaction |> order_by(desc: :inserted_at) |> Repo.all()
  end

  @doc """
    Calculate total value grouped by day
  """
  def total_by_day do
    results = Ecto.Adapters.SQL.query!(
      StoneApi.Repo,
      """
        select date(inserted_at) as date, sum(value) as value
        from public.transaction
        group by date(inserted_at)
      """
    )

    columns = results.columns
    Logger.info("columns: #{inspect(columns)}")

    rows = results.rows
    Logger.info("rows: #{inspect(rows)}")

    array = for item <- rows do
      %{:date => Enum.at(item, 0), :value => Enum.at(item, 1)}
    end
  end

  @doc """
    Calculate total value grouped by month/year
  """
  def total_by_month do
    results = Ecto.Adapters.SQL.query!(
      StoneApi.Repo,
      """
        select q.month, q.year, sum(q.value) as value
        from (
          select extract(month from inserted_at) as month, extract(year from inserted_at) as year, value as value
          from public.transaction
        ) as q
        group by q.month, q.year
        order by q.year desc, q.month
      """
    )

    columns = results.columns
    Logger.info("columns: #{inspect(columns)}")

    rows = results.rows
    Logger.info("rows: #{inspect(rows)}")

    array = for item <- rows do
      %{:month => Enum.at(item, 0), :year => Enum.at(item, 1), :value => Enum.at(item, 2)}
    end
  end

  @doc """
    Calculate total value grouped by year
  """
  def total_by_year do
    results = Ecto.Adapters.SQL.query!(
      StoneApi.Repo,
      """
        select q.year, sum(q.value) as value
        from (select extract(year from inserted_at) as year, value as value from public.transaction) as q
        group by q.year
        order by q.year desc
      """
    )

    columns = results.columns
    Logger.info("columns: #{inspect(columns)}")

    rows = results.rows
    Logger.info("rows: #{inspect(rows)}")

    array = for item <- rows do
      %{:year => Enum.at(item, 0), :value => Enum.at(item, 1)}
    end
  end

  @doc """
    Calculate total of transactions
  """
  def total do
    results = Ecto.Adapters.SQL.query!(
      StoneApi.Repo,
      """
        select sum(value) as value
        from public.transaction
      """
    )

    columns = results.columns
    Logger.info("columns: #{inspect(columns)}")

    rows = results.rows
    Logger.info("rows: #{inspect(rows)}")

#    array = for item <- rows do
#      %{:value => Enum.at(item, 0)}
#    end

    Enum.at(Enum.at(rows, 0), 0)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user and initialize his financial account with 1000.0 balance

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    Logger.debug "--> Create User <--"
#    Repo.transaction(fn ->
      # Create User 
      user = User.changeset(%User{}, attrs)
      { status_user, changeset_user } = Repo.insert(user)
      Logger.debug("status: #{status_user}")
      Logger.debug("user changeset: #{inspect(changeset_user)}")

      # Create FinancialAccount with 1000.0 balance 
      financial_account = FinancialAccount.changeset(
        %FinancialAccount{}, 
        %{user_id: changeset_user.id, balance: @default_balance}
      )
      { status_financial_account, changeset_financial_account } = Repo.insert(financial_account)
      Logger.debug("status: #{status_financial_account}")
      Logger.debug("financial_account changeset: #{inspect(changeset_financial_account)}")
      Logger.debug("Operation success")

      { status_user, changeset_user }
#    end)
  end

  @doc """
    Withdrawal operation.
    It is not permitted negative balance.

    ## Examples



  """
  def withdrawal(user, value) do
    Logger.debug "--> Withdrawal Transaction <--"
    Repo.transaction(fn -> 
      financial_account = get_financial_account_by_user(user)

      new_balance = financial_account.balance - value

      if (new_balance >= 0) do
        update_balance(financial_account, new_balance)
        withdrawal_transaction(financial_account, value)
        # TODO: Send email for client
        Logger.debug("Operation success")
        true
      else
        Logger.warn("Insuficient balance")
        false
      end
    end)
  end

  @doc """
    Transfer Operation.
    It is not permitted negative balance.

  """
  def transfer(user, value, financial_account_target_id) do
    Logger.debug "--> Transfer Transaction <--"
    Repo.transaction(fn -> 
      financial_account_origin = get_financial_account_by_user(user)

      new_balance_origin = financial_account_origin.balance - value

      if (new_balance_origin >= 0) do
        update_balance(financial_account_origin, new_balance_origin)
        
        financial_account_target = get_financial_account(financial_account_target_id)
        new_balance_target = financial_account_target.balance + value
        update_balance(financial_account_target, new_balance_target)

        transfer_transaction(financial_account_origin, financial_account_target, value)

        # TODO: Send email for client
        Logger.debug("Operation success")
        true
      else
        Logger.warn("Insuficient balance")
        false
      end
    end)
  end

  @doc """
    Insert a transfer record for Tranfer Operation.
  """
  defp transfer_transaction(financial_account_origin, financial_account_target, value) do
    unless financial_account_origin.id != financial_account_target.id do
      raise ArgumentError, message: "Financial Account must be different for transfer operation"
    end

    transaction = Transaction.changeset(
      %Transaction{},
      %{value: value, account_origin_id: financial_account_origin.id, account_target_id: financial_account_target.id}
    ) |> Repo.insert()
    Logger.debug("Transaction inserted")

    transaction
  end

  @doc """
    Returns FinancialAccount by id (pk).
  """
  defp get_financial_account(id) do
    Repo.get(FinancialAccount, id)
  end

  @doc """
    Return FinancialAccount by user (logged - use token).
  """
  defp get_financial_account_by_user(user) do
    financial_account_id = get_financial_account_id_by_user(user)
    Logger.debug("Get Financial Account from User #{user.id} => #{financial_account_id}")

    financial_account = Repo.get(FinancialAccount, financial_account_id)
    Logger.debug("Actual balance: #{financial_account.balance}")

    financial_account
  end

  @doc """
    Return FinancialAccount id by user (logged - use token).
  """
  defp get_financial_account_id_by_user(user) do
    query = 
      from f in "financial_account",
      where: f.user_id == ^user.id,
      select: f.id

    Repo.one(query)
  end

  @doc """
    Insert a transaction operation representing a withdrawal.
  """
  defp withdrawal_transaction(financial_account, value) do
    transaction = Transaction.changeset(
      %Transaction{},
      %{value: value, account_origin_id: financial_account.id}
    ) |> Repo.insert()
    Logger.debug("Transaction inserted")

    transaction
  end

  @doc """
    Update FinancialAccount balance.
  """
  defp update_balance(financial_account, new_balance) do
    financial_account_changeset = Ecto.Changeset.change financial_account, balance: new_balance 
    Repo.update financial_account_changeset
    Logger.debug("New balance: #{new_balance} updated")
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
