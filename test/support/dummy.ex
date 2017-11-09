defmodule SansPassword.Dummy.User do
  @enforce_keys [:id]
  defstruct [:id]
end

defmodule SansPassword.Dummy.Mailer do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def sent_emails do
    Agent.get(__MODULE__, &(&1))
  end

  def deliver(args) do
    Agent.update(__MODULE__, fn state ->
      [args | state]
    end)
  end
end

defmodule SansPassword.Dummy.Guardian do
  use Guardian, otp_app: :sans_password
  use SansPassword

  alias SansPassword.Dummy.{Mailer, User}

  @impl true
  def subject_for_token(user, _claims) do
    case user.id do
      nil -> {:error, :invalid}
      id  -> {:ok, to_string(id)}
    end
  end

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    {id, _} = Integer.parse(id)
    {:ok, %User{id: id}}
  end

  @impl true
  def deliver_magic_link(user, magic_token, params) do
    Mailer.deliver({user, magic_token, params})
  end
end
