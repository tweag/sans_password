defmodule Passwordless.Crypto do
  @secret_key Application.get_env(:passwordless, :secret_key)

  def valid_hmac?(token, from: str) do
    hmac(str) == token
  end

  def hmac(str) do
    :sha256
    |> :crypto.hmac(@secret_key, str)
    |> to_url_safe
  end

  def generate_token(size \\ 64) do
    size
    |> :crypto.strong_rand_bytes
    |> to_url_safe
  end

  defp to_url_safe(str) do
    str
    |> Base.url_encode64
    |> String.replace(~r([\n\=]), "")
    |> String.replace(~r(\+), "-")
    |> String.replace(~r(\/), "_")
  end
end
