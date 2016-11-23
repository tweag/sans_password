defmodule Passwordless.Callbacks do
  alias Passwordless.Config

  def login(token) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user}   <- Guardian.serializer.from_token(claims["sub"]),
         {:ok, user}   <- update_login_timestamps(user),
         do: {:ok, user}
  end

  def register(token, insert_fn) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, email}  <- Guardian.serializer.from_token(claims["sub"]),
         {:ok, user}   <- insert_fn.(email),
         {:ok, user}   <- update_login_timestamps(user),
         do: {:ok, user}
  end

  defp update_login_timestamps(user) do
    user
    |> Config.schema.passwordless_changeset(%{}, :callback)
    |> Config.repo.update
  end
end
