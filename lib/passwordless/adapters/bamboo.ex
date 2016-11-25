defmodule Passwordless.Adapters.Bamboo do
  alias Passwordless.Config

  def deliver(name, email, params) do
    emails = Config.get!(:emails, __MODULE__)
    mailer = Config.get!(:mailer, __MODULE__)

    emails
    |> apply(name, [email, params])
    |> mailer.deliver_now
  end
end
