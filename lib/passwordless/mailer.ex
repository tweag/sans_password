defmodule Passwordless.Mailer do
  @schema Application.get_env(:passwordless, :schema)

  @callback login(user :: @schema.t, params :: list()) :: any
  @callback confirm(user :: @schema.t, params :: list()) :: any
  @callback register(email :: String.t, params :: list()) :: any
end
