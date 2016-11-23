defmodule Passwordless.Adapters.Bamboo do
  alias Passwordless.Config

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
    emails = Config.get!(:emails, __MODULE__)
    mailer = Config.get!(:mailer, __MODULE__)

    emails
    |> apply(name, args)
    |> mailer.deliver_now
  end
end
