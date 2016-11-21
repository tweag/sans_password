defmodule Passwordless.Callbacks do
  alias Passwordless.{Config, Crypto}

  def login(raw_login_token) do
    if user = find_login_token(raw_login_token) do
      reset_login_token(user)
    else
      :invalid_token
    end
  end

  def register(changeset, [token: token, email: email]) do
    if Crypto.valid_hmac?(token, from: email) do
      with {:ok, user} <- Config.repo.insert(changeset),
           {:ok, user} <- reset_login_token(user),
           do: {:ok, user}
    else
      :invalid_token
    end
  end

  defp find_login_token(raw_login_token) do
    hashed_login_token = Crypto.hmac(raw_login_token)

    Config.schema
    |> Config.repo.get_by(login_token: hashed_login_token)
  end

  defp reset_login_token(user) do
    user
    |> Config.schema.passwordless_changeset(:callback)
    |> Config.repo.update()
  end
end
