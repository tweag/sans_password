defmodule Passwordless.Serializer do
  @behaviour Guardian.Serializer

  alias Passwordless.{Config, Invite}

  def for_token(invite = %Invite{}) do
    {:ok, "Invite:#{invite.email}"}
  end
  def for_token(%{id: id, __struct__: _}) when not is_nil(id) do
    {:ok, "User:#{id}"}
  end
  def for_token(_) do
    {:error, "Unknown resource type"}
  end

  def from_token("Invite:" <> email) do
    {:ok, email}
  end
  def from_token("User:" <> id) do
    {:ok, Config.repo.get(Config.schema, id)}
  end
  def from_token(_) do
    {:error, "Unknown resource type"}
  end
end
