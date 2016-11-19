defmodule Passwordless.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Passwordless.Case
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Passwordless.TestRepo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Passwordless.TestRepo, {:shared, self()})
    end

    :ok
  end

  def assert_email_sent(email) when is_tuple(email) do
    email = Tuple.insert_at(email, 0, :delivered_email)
    assert_received(^email)
  end

  def refute_emails_sent do
    refute_received({:delivered_email, _, _, _})
  end
end
