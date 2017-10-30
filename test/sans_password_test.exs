defmodule SansPasswordTest do
  use ExUnit.Case, async: true
  doctest SansPassword

  alias SansPassword.Dummy.{Repo, User, Guardian}

  setup do
    {:ok, _} = start_supervised(Repo)
    {:ok, user} = Repo.insert(%User{email: "user@example.com"})
    [user: user]
  end

  test "encode_login and decode_login", %{user: user} do
    assert {:ok, login_token, _}  = Guardian.encode_login(user)
    assert {:ok, ^user, _}        = Guardian.decode_login(login_token)
  end

  test "encode_access and decode_access", %{user: user} do
    assert {:ok, access_token, _} = Guardian.encode_access(user)
    assert {:ok, ^user, _}        = Guardian.decode_access(access_token)
  end

  test "exchange_login", %{user: user} do
    assert {:ok, login_token, _}  = Guardian.encode_login(user)
    assert {:ok, access_token, _} = Guardian.exchange_login(login_token)
    assert {:ok, ^user, _}        = Guardian.decode_access(access_token)
  end
end
