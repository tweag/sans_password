defmodule SansPassword.ConnCase do
  use ExUnit.CaseTemplate

  @secret "12345ksadfjlaskfjadsklfjaskldfjalsdkjfaklsdjfladksjfadkljflkadsjfkl678"

  @signing_opts [
    store: :cookie,
    key: "sans_password-test",
    signing_salt: "signing salt",
    encrypt: false
  ]

  using do
    quote do
      use SansPassword.Case
      use Phoenix.ConnTest
    end
  end

  setup do
    [conn: sign_conn(Phoenix.ConnTest.build_conn())]
  end

  defp sign_conn(conn) do
    put_in(conn.secret_key_base, @secret)
    |> Plug.Session.call(Plug.Session.init(@signing_opts))
    |> Plug.Conn.fetch_session
    |> Phoenix.Controller.fetch_flash
  end
end
