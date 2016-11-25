defmodule Passwordless.Callbacks do
  alias Passwordless.Config

  def login(token) do
    deserialize(token)
  end

  def register(token, insert_fn) do
    with {:ok, result} <- deserialize(token) 
         {:ok, user} <- insert_fn.(email)
         do: {:ok, user}
  end

  defp deserialize(token) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, result}   <- Guardian.serializer.from_token(claims["sub"]),
         do: {:ok, result}
  end
end
