defmodule Passwordless.Invite do
  defstruct [:email]

  import Ecto.Query, only: [from: 2]

  alias Passwordless.Config

  @doc """
  Sends an email to a user inviting them to login. If the user is not found,
  it will return nil.
  """
  def invite_to_login(email, params \\ [], opts \\ [])
  def invite_to_login(nil, _params, _opts), do: nil
  def invite_to_login(%{login_requested_at: _} = user, params, opts) do
    email_name = Keyword.get(opts, :email, :login)
    params = login_params(user, params)
    Config.mailer.deliver(email_name, params)
    user
  end
  def invite_to_login(email, params, opts) when is_binary(email) do
    if user = email |> to_email_query |> Config.repo.one do
      invite(user, params, opts)
    end
  end

  def invite_to_register(email, params \\ [], opts \\ []) do
    email_name = Keyword.get(opts, :email, :register)
    params = registration_params(email, params)
    Config.mailer.deliver(email_name, email, params)
    email
  end

  def login_params(user, params \\ []) do
    put_token(params, :login_token, user)
  end

  def registration_params(email, params \\ []) do
    put_token(params, :registration_token, %__MODULE__{email: email})
  end

  defp put_token(params, name, struct) do
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(struct)
    Keyword.put(params, name, jwt)
  end

  defp to_email_query(email) do
    from u in Config.schema, where: fragment("lower(?)", u.email) == ^String.downcase(email)
  end
end
