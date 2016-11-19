defmodule Passwordless.Login do
  @repo Application.get_env(:passwordless, :repo)
  @schema Application.get_env(:passwordless, :schema)

  @doc """
  Attepts to find the user by the token. If the user is found,
  their login token will be reset and return the user. Otherwise,
  it will return nil.
  """
  def authenticate_login_token(token) do
    if user = @repo.get_by(@schema, login_token: token) do
      user
      |> @schema.passwordless_changeset(reset_login_request())
      |> @repo.update!
    end
  end

  defp reset_login_request, do: %{
    login_token: nil,
    login_requested_at: nil,
    last_login_at: Ecto.DateTime.utc
  }
end
