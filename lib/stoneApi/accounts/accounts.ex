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
  Creates a user.

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
        %{user_id: changeset_user.id, balance: 1000.0}
      )
      { status_financial_account, changeset_financial_account } = Repo.insert(financial_account)
      Logger.debug("status: #{status_financial_account}")
      Logger.debug("financial_account changeset: #{inspect(changeset_financial_account)}")
      Logger.debug("Operation success")

      { status_user, changeset_user }
#    end)
  end

  @doc """
    Withdrawal operation

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

  defp transfer_transaction(financial_account_origin, financial_account_target, value) do
    transaction = Transaction.changeset(
      %Transaction{},
      %{value: value, account_origin_id: financial_account_origin.id, account_target_id: financial_account_target.id}
    ) |> Repo.insert()
    Logger.debug("Transaction inserted")

    transaction
  end

  defp get_financial_account(id) do
    Repo.get(FinancialAccount, id)
  end

  defp get_financial_account_by_user(user) do
    financial_account_id = get_financial_account_id_by_user(user)
    Logger.debug("Get Financial Account from User #{user.id} => #{financial_account_id}")

    financial_account = Repo.get(FinancialAccount, financial_account_id)
    Logger.debug("Actual balance: #{financial_account.balance}")

    financial_account
  end

  defp get_financial_account_id_by_user(user) do
    query = 
      from f in "financial_account",
      where: f.user_id == ^user.id,
      select: f.id

    Repo.one(query)
  end

  defp withdrawal_transaction(financial_account, value) do
    transaction = Transaction.changeset(
      %Transaction{},
      %{value: value, account_origin_id: financial_account.id}
    ) |> Repo.insert()
    Logger.debug("Transaction inserted")

    transaction
  end

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
