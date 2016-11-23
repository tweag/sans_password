defmodule Passwordless.Config do
  def schema,     do: get!(:schema)
  def repo,       do: get!(:repo)
  def mailer,     do: get!(:mailer)
  def secret_key, do: get!(:secret_key)

  def get(name, mod \\ Passwordless) do
    :passwordless
    |> Application.get_env(mod)
    |> Keyword.get(name)
  end

  def get!(name, mod \\ Passwordless) do
    if value = get(name, mod) do
      value
    else
      raise "Missing required #{inspect mod} configuration: #{name}"
    end
  end
end
