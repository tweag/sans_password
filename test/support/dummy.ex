defmodule SansPassword.Dummy.User do
  defstruct [:id, :email]
end

defmodule SansPassword.Dummy.Repo do
  @moduledoc "A fake Ecto.Repo"

  use Agent

  def start_link(_) do
    Agent.start_link(fn -> {0, MapSet.new} end, name: __MODULE__)
  end

  def get(_schema, id) do
    {id, _} = Integer.parse(id)

    Agent.get(__MODULE__, fn {_, data} ->
      Enum.find data, fn user ->
        user.id == id
      end
    end)
  end

  def insert(record) do
    Agent.get_and_update(__MODULE__, fn {last_id, data} ->
      record = %{record | id: last_id + 1}
      {{:ok, record}, {record.id, MapSet.put(data, record)}}
    end)
  end
end

defmodule SansPassword.Dummy.Guardian do
  use Guardian, otp_app: :sans_password
  use SansPassword

  alias SansPassword.Dummy.{Repo, User}

  def subject_for_token(resource, _claims) do
    case resource.id do
      nil -> {:error, :invalid}
      id  -> {:ok, to_string(id)}
    end
  end

  def resource_from_claims(%{"sub" => id}) do
    case Repo.get(User, id) do
      nil  -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
