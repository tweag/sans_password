defmodule SansPassword.Adapters.Bamboo do
  alias SansPassword.Config

  def deliver(name, email, params) do
    emails = Config.get!(:emails, __MODULE__)
    mailer = Config.get!(:mailer, __MODULE__)

    emails
    |> apply(name, [email, params])
    |> mailer.deliver_now
  end
end
