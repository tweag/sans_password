defmodule Passwordless.TestMailer do
  def login(user, params) do
    send self(), {:delivered_email, :login, user, params}
  end

  def confirm(user, params) do
    send self(), {:delivered_email, :confirm, user, params}
  end

  def register(email, params) do
    send self(), {:delivered_email, :register, email, params}
  end
end
