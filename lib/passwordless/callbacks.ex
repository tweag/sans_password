defmodule Passwordless.Callbacks do
  alias Passwordless.Crypto

  @repo Application.get_env(:passwordless, :repo)
  @schema Application.get_env(:passwordless, :schema)

  def login(token) do
    if user = @repo.get_by(@schema, login_token: token) do
      reset_token(user)
    else
      :invalid_token
    end
  end

  def register(changeset, [token: token, email: email]) do
    if Crypto.valid_hmac?(token, from: email) do
      with {:ok, user} <- @repo.insert(changeset),
           {:ok, user} <- reset_token(user),
           do: {:ok, user}
    else
      :invalid_token
    end
  end

  defp reset_token(user) do
    changeset = @schema.passwordless_changeset(user, %{
      login_token: nil,
      login_requested_at: nil,
      last_login_at: Ecto.DateTime.utc
    })

    @repo.update(changeset)
  end
end
