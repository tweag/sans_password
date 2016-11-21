defmodule Passwordless.Adapters.Bamboo do
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
    mailer = get_config(:mailer)
    emails = get_config(:emails)

    emails
    |> apply(name, args)
    |> mailer.deliver_now
  end

  defp get_config(name) do
    get_config()
    |> Keyword.get(name)
  end

  defp get_config do
    Application.get_env(:passwordless, Passwordless.Adapters.Bamboo)
  end
end
