defmodule Passwordless.Invite do
  import Ecto.Query, only: [from: 2]

  alias Passwordless.Crypto

  @schema Application.get_env(:passwordless, :schema)
  @repo Application.get_env(:passwordless, :repo)
  @mailer Application.get_env(:passwordless, :mailer)

  @doc """
  Sends an email to a user inviting them to login.

  1. If given an email address, it will find the user.
  2. Once we have a user, we'll update user with a login_token.
  3. Send an email inviting them to login.

  If the user is not found, it will return nil.
  """
  def invite_to_login(email_or_user, opts \\ []) do
    invite(email_or_user, opts, &@mailer.login/2)
  end

  @doc """
  Same as invite_to_login/2, except that it sends an email to confirm.
  """
  def invite_to_confirm(email_or_user, opts \\ []) do
    invite(email_or_user, opts, &@mailer.confirm/2)
  end

  def invite_to_register(email, opts \\ []) do
    @mailer.register(email, registration_params(email, opts))
    email
  end

  def registration_params(email, opts \\ []) do
    opts
    |> Keyword.put(:email, email)
    |> Keyword.put(:registration_token, Crypto.hmac(email))
  end

  @doc """
  Assign a login_token to the user. Using this token,
  the user can be granted a session.
  """
  def prepare_for_login(user) do
    user
    |> @schema.passwordless_changeset(login_request())
    |> @repo.update!
  end

  defp invite(nil, _mailer, _opts), do: nil
  defp invite(%{login_token: _} = user, opts, mailer) do
    user = prepare_for_login(user)
    mailer.(user, opts)
    user
  end
  defp invite(email, mailer, opts) when is_binary(email) do
    if user = email |> to_email_query |> @repo.one do
      invite(user, mailer, opts)
    end
  end

  defp to_email_query(email) do
    from u in @schema, where: fragment("lower(?)", u.email) == ^String.downcase(email)
  end

  defp login_request(), do: %{
    login_token: Crypto.generate_token(),
    login_requested_at: Ecto.DateTime.utc
  }
end
