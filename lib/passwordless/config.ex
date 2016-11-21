defmodule Passwordless.Config do
  def schema,     do: get_config(:schema)
  def repo,       do: get_config(:repo)
  def mailer,     do: get_config(:mailer)
  def secret_key, do: get_config(:secret_key)

  defp get_config(name) do
    if value = Keyword.get(get_config(), name) do
      value
    else
      raise "Missing Passwordless configuration: #{name}"
    end
  end

  defp get_config do
    Application.get_env(:passwordless, Passwordless)
  end
end
