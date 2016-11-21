defmodule Passwordless.Callbacks do
  alias Passwordless.{Config, Crypto}

  def login(token) do
    if user = Config.repo.get_by(Config.schema, login_token: token) do
      reset_token(user)
    else
      :invalid_token
    end
  end

  def register(changeset, [token: token, email: email]) do
    if Crypto.valid_hmac?(token, from: email) do
      with {:ok, user} <- Config.repo.insert(changeset),
           {:ok, user} <- reset_token(user),
           do: {:ok, user}
    else
      :invalid_token
    end
  end

  defp reset_token(user) do
    user
    |> Config.schema.passwordless_changeset(:callback)
    |> Config.repo.update()
  end
end
