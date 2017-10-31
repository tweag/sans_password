defmodule SansPassword.Dummy.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email])
  end
end

defmodule SansPassword.Dummy.Repo do
  use Ecto.Repo, otp_app: :sans_password
end

defmodule SansPassword.Dummy.Guardian do
  use Guardian, otp_app: :sans_password
  use SansPassword

  alias SansPassword.Dummy.{Repo, User}

  @impl true
  def subject_for_token(resource, _claims) do
    case resource.id do
      nil -> {:error, :invalid}
      id  -> {:ok, to_string(id)}
    end
  end

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    case Repo.get(User, id) do
      nil  -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @impl true
  def resource_from_params(%{"email" => email}) do
    case Repo.get_by(User, email: email) do
      nil ->
        %User{}
        |> User.changeset(%{email: email})
        |> Repo.insert()
        |> case do
          {:ok, user} -> {:ok, user}
          {:error, _} -> {:error, :validation_error}
        end

      user ->
        {:ok, user}
    end
  end
end
