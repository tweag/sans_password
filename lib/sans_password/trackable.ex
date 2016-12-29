defmodule SansPassword.Trackable do
  use Guardian.Hooks
  alias SansPassword.Config

  def after_sign_in(conn, _params) do
    track(conn, :sign_in)
  end

  def before_sign_out(conn, _params) do
    track(conn, :sign_out)
  end

  defp track(conn, action) do
    user =
      conn
      |> Guardian.Plug.current_resource()
      |> to_trackable_changeset(conn, action)
      |> Config.repo.update!

    Guardian.Plug.set_current_resource(conn, user)
  end

  defp to_trackable_changeset(user, conn, action) do
    attributes = trackable_attributes(conn, user, action)
    Config.schema.trackable_changeset(user, attributes)
  end

  defp trackable_attributes(conn, user, :sign_in) do
    {last_at, last_ip} = get_last_sign_in(conn, user)

    %{
      sign_in_count: user.sign_in_count + 1,
      current_sign_in_at: Ecto.DateTime.utc,
      current_sign_in_ip: get_ip_address(conn),
      last_sign_in_at: last_at,
      last_sign_in_ip: last_ip
    }
  end
  defp trackable_attributes(_conn, user, :sign_out) do
    %{
      last_sign_in_at: user.current_sign_in_at,
      last_sign_in_ip: user.current_sign_in_ip,
      current_sign_in_at: nil,
      current_sign_in_ip: nil
    }
  end

  defp get_last_sign_in(conn, user) do
    cond do
      is_nil(user.last_sign_in_at) and is_nil(user.current_sign_in_at) ->
        {Ecto.DateTime.utc, get_ip_address(conn)}
      !!user.current_sign_in_at ->
        {user.current_sign_in_at, user.current_sign_in_ip}
      true ->
        {user.last_sign_in_at, user.last_sign_in_ip}
    end
  end

  defp get_ip_address(conn) do
    conn.peer
    |> elem(0)
    |> Tuple.to_list
    |> Enum.join(".")
  end
end
