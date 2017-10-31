# SansPassword

Passwordless authentication helpers for [Guardian](https://github.com/ueberauth/guardian).

Take a look at the [demo app](https://github.com/promptworks/sans_password_demo).

## Installation

Add `sans_password` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sans_password, "~> 1.0.0-beta"}]
end
```

Next, follow Guardian's [installation instructions](https://github.com/ueberauth/guardian#installation) to setup a Guardian module.

Now, you should have a `Guardian` module, so you can sprinkle in `SansPassword`.

```elixir
defmodule MyApp.Guardian do
  use Guardian, otp_app: :my_app
  use SansPassword

  ...

  @impl true
  def deliver_magic_link(user, magic_token) do
    user
    |> MyMailer.magic_link_email(magic_token)
    |> MyMailer.deliver
  end
end
```

`SansPassword` uses two token types:

* `magic` - This token will be sent to your users in an email. They are very short-lived and will be sent to your users via email. This token will be included in the "magic link" to your app.
* `access` - This token will allow your users to request content from your app.

This part is VERY important, you need to configure the TTLs for the token types that `SansPassword` uses:

```elixir
config :guardian, MyApp.Guardian,
  secret_key: "super secret key",
  issuer: "my_app",
  token_ttl: %{
    "magic" => {30, :minutes},
    "access" => {1, :days}
  }
```

## Usage

SansPassword provides just a few convenience functions.

```elixir
# We'll assume you have a user record
{:ok, user} = Repo.insert(%User{email: "user@example.com"})

# Send a login link that will allow the user to login
{:ok, magic_token, _claims} = MyApp.Guardian.send_magic_link(user)

# If you're building an API, you'll probably want to convert the magic token to an access token
{:ok, access_token, _claims} = MyApp.Guardian.exchange_magic(magic_token)

# If you're storing sessions, you can sign your users in like this
{:ok, user, _claims} = MyApp.Guardian.decode_magic(magic_token)
MyApp.Guardian.Plug.sign_in(user)
```

### Trackable (optional)

To track your users sessions, see [guardian_trackable](https://github.com/promptworks/guardian_trackable).

### Accessing the current user

Under the hood, SansPassword just uses Guardian, so to get the current user, just say:

```elixir
Guardian.Plug.current_resource(conn)
```
