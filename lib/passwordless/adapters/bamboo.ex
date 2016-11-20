defmodule Passwordless.Adapters.Bamboo do
  @behaviour Passwordless.Mailer

  @config Application.get_env(:passwordless, Passwordless.Adapters.Bamboo)

  def login(user, params) do
    deliver(:login, [user, params])
  end

  def confirm(user, params) do
    deliver(:confirm, [user, params])
  end

  def register(email, params) do
    deliver(:register, [email, params])
  end

  defp deliver(name, args) do
    @config[:emails]
    |> apply(name, args)
    |> @config[:mailer].deliver_now
  end
end
