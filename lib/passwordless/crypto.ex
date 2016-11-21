defmodule Passwordless.Crypto do
  alias Passwordless.Config

  def valid_hmac?(token, from: str) do
    hmac(str) == token
  end

  def hmac(str) do
    :sha256
    |> :crypto.hmac(Config.secret_key, str)
    |> to_url_safe
  end

  def generate_token(size \\ 64) do
    size
    |> :crypto.strong_rand_bytes
    |> to_url_safe
  end

  defp to_url_safe(str) do
    Base.url_encode64(str, padding: false)
  end
end
