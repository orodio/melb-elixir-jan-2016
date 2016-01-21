defmodule BankAccountTest do
  use ExUnit.Case
  import BankAccount, only: [
    send_balance: 2,
    deposit:      2,
    withdraw:     2,
    calc_balance: 1,
    balance:      1,
  ]

  test "can send balance to a pid" do
    new_account
    |> send_balance(self)

    assert_receive { :balance, 0 }
  end

  test "initial balance of zero" do
    new_account
    |> assert_balance(0)
  end

  test "can deposit moneys" do
    new_account
    |> deposit(50)
    |> assert_balance(50)
  end

  test "can withdraw moneys" do
    new_account
    |> deposit(100)
    |> withdraw(50)
    |> assert_balance(50)
  end

  test "cant deposit negative moneys" do
    new_account
    |> deposit(100)
    |> deposit(-50)
    |> assert_balance(100)
  end

  test "cant withdraw negative moneys" do
    new_account
    |> deposit(100)
    |> withdraw(-50)
    |> assert_balance(100)
  end

  test "cant withdraw moneys if not enough moneys" do
    new_account
    |> deposit(50)
    |> withdraw(100)
    |> assert_balance(50)
  end

  test "#calc_balance" do
    history = [
      { :deposit,  50 },
      { :deposit,  50 },
      { :withdraw, 50 },
      { :withdraw, 60 },
    ]

    assert -10 = calc_balance(history)
  end

  ## helpers
  def new_account do
    { :ok, pid } = BankAccount.start_link
    pid
  end

  def assert_balance(pid, amount) do
    assert amount == balance(pid)
    pid
  end
end
