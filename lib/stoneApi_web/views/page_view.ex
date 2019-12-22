defmodule StoneApiWeb.PageView do
  use StoneApiWeb, :view

  import Number.Currency

  def currency_format(value) do
    number_to_currency(value)
  end

  def format_date(date_tuple) do
    { :ok, date } = Ecto.Date.cast(date_tuple)
    "#{lz(date.day)}/#{lz(date.month)}/#{date.year}"
  end

  def format_datetime(datetime) do
    "#{lz(datetime.day)}/#{lz(datetime.month)}/#{datetime.year} #{lz(datetime.hour)}:#{lz(datetime.minute)}:#{lz(datetime.second)}"
  end

  def transaction_type(transaction) do
    if transaction.account_target_id == nil do
      "cash withdrawal"
    else
      "transfer"
    end
  end

  def to_account(transaction) do
    if transaction.account_target_id == nil do
      "---"
    else
      transaction.account_target_id
    end
  end

  defp lz(value) do
    if value < 10 do
      "0#{value}"
    else
      "#{value}"
    end
  end
end
