defmodule SansPasswordTest do
  use ExUnit.Case, async: true

  doctest SansPassword

  alias SansPassword.Dummy.{Mailer, User, Guardian}

  setup do
    start_supervised(Mailer)
    [user: %User{id: 1}]
  end

  test "encode_magic and decode_magic", %{user: user} do
    assert {:ok, login_token, _}  = Guardian.encode_magic(user)
    assert {:ok, ^user, _}        = Guardian.decode_magic(login_token)
  end

  test "encode_access and decode_access", %{user: user} do
    assert {:ok, access_token, _} = Guardian.encode_access(user)
    assert {:ok, ^user, _}        = Guardian.decode_access(access_token)
  end

  test "exchange_magic", %{user: user} do
    assert {:ok, login_token, _}  = Guardian.encode_magic(user)
    assert {:ok, access_token, _} = Guardian.exchange_magic(login_token)
    assert {:ok, ^user, _}        = Guardian.decode_access(access_token)
  end

  test "send_magic_link", %{user: user} do
    assert {:ok, login_token, _} = Guardian.send_magic_link(user, %{}, %{foo: 1})
    assert Mailer.sent_emails   == [{user, login_token, %{foo: 1}}]
    assert {:ok, ^user, _}       = Guardian.decode_magic(login_token)
  end
end
