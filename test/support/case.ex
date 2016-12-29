defmodule SansPassword.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import SansPassword.Case
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SansPassword.TestRepo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SansPassword.TestRepo, {:shared, self()})
    end

    :ok
  end

  def refute_emails_sent do
    refute_received({:delivered_email, _, _, _})
  end
end
