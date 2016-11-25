defmodule Passwordless.TestMailer do
  def deliver(name, email_or_user, params) do
    send self(), {:delivered_email, name, email_or_user, params}
  end
end
