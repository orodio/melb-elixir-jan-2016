defmodule BankAccount do
  use GenServer

  def start_link do
    GenServer.start_link(BankAccount, [])
  end

  def send_balance(acc, pid) do
    cast(acc, { :send_balance, pid })
  end

  def deposit(acc, amount) do
    cast(acc, { :deposit, amount })
  end

  def withdraw(acc, amount) do
    cast(acc, { :withdraw, amount })
  end

  def balance(acc) do
    GenServer.call(acc, { :get_balance })
  end



  ## internal

  ### calls
  def handle_call({ :get_balance }, _from, history) do
    { :reply, calc_balance(history), history }
  end

  ### casts
  def handle_cast({ :send_balance, pid }, history) do
    Process.send(pid, { :balance, calc_balance(history) }, [])
    { :noreply, history }
  end

  def handle_cast(event = { :withdraw, amount }, history) when amount > 0 do
    if calc_balance(history) >= amount do
      { :noreply, [ event | history ] }
    else
      { :noreply, history }
    end
  end

  def handle_cast(event = { :deposit, amount }, history) when amount > 0 do
    { :noreply, [ event | history ] }
  end

  def handle_cast(_event, history), do: { :noreply, history }





  ## helpers
  def calc_balance(history) do
    Enum.reduce(history, 0, &balance_reducer/2)
  end

  def balance_reducer({ :deposit, amount }, acc),  do: acc + amount
  def balance_reducer({ :withdraw, amount }, acc), do: acc - amount
  def balance_reducer(_event, acc),                do: acc

  def cast(pid, msg) do
    GenServer.cast(pid, msg)
    pid
  end
end
