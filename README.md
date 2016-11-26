# Passwordless

A simple, passwordless authentication system based on [Guardian](https://github.com/ueberauth/guardian).

Passwordless supports two different authentication flows:

+ _Login_ - When a user enters their email address, if their account exists, they'll be sent an email containing a link to login.
+ _Register_ - When a user enters their email address, if their account does not exist, they'll be sent an email containing a link. When they click the link, an account will be created using the provided email address, and they'll be signed in.

See the source code for the demo app [here](https://github.com/promptworks/passwordless_demo).

## Installation

1. Add `passwordless` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:passwordless, "~> 0.1.0"}]
end
```

2. Ensure bamboo is started before your application:

```elixir
def application do
  [applications: [:passwordless]]
end
```

## Usage

First, you'll need to configure passwordless and guardian. A minimal configuration looks like this:

```elixir
config :passwordless, Passwordless,
  repo: MyApp.Repo,
  schema: MyApp.User,
  mailer: Passwordless.Adapters.Bamboo

config :passwordless, Passwordless.Adapters.Bamboo,
  emails: MyApp.Emails,
  mailer: MyApp.Mailer

config :guardian, Guardian,
  issuer: "MyApp",
  ttl: {30, :days},
  secret_key: "super secret key!",
  serializer: Passwordless.Serializer
```

You'll want to look at [Guardian's documentation](https://github.com/ueberauth/guardian) for all of it's configuration options.

The configuration above uses Bamboo for emails, but you could very easily implement your own adapter.

### Controllers/Views

Passwordless includes a macro for creating a controller. You'll need to tell it which view to use to render templates, as well as which module to use for hooks.

`Passwordless.Hooks` brings in a behaviour that will tell you which functions need to be implemented.

```elixir
# web/views/session_controller.ex
defmodule MyApp.SessionController do
  use MyApp.Web, :controller
  use Passwordless.Hooks
  use Passwordles.Controller, view: MyApp.SessionView, hooks: __MODULE__

  # Passwordless.Hooks requires that you implement the following functions:

  def after_invite_path(conn, _params), do: session_path(conn, :new)
  def after_invite_failed_path(conn, _params), do: session_path(conn, :new)

  def after_login_path(conn, _params), do: page_path(conn, :index)
  def after_login_failed_path(conn, _params), do: session_path(conn, :new)

  def after_logout_path(conn, _parms), do: session_path(conn, :new)
end
```

You'll just need to create a view:

```elixir
# web/views/session_view.ex
defmodule MyApp.SessionView do
  use MyApp.Web, :view
end
```

Then, create a template for the login form:

```eex
<!-- web/templates/new.html.eex -->
<%= form_for @conn, session_path(@conn, :create), [as: :session], fn f -> %>
  <div class="form-group">
    <label for="session[email]" class="control-label">Email</label>
    <%= text_input f, :email, class: "form-control" %>
  </div>

  <%= submit "Submit", class: "btn btn-primary" %>
<% end %>
```

### Routing

We'll need to add Guardian's plugs to our routes, and declare routes for our new session controller.

```elixir
# web/router.ex
pipeline :browser do
  # ...
end

pipeline :browser_session do
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.LoadResource
end

pipeline :require_auth do
  plug Guardian.Plug.EnsureAuthenticated
end

# Unauthenticated routes go here
scope "/", MyApp do
  pipe_through [:browser, :browser_session]

  get "/login", SessionController, :new
  post "/login", SessionController, :create
  get "/login/callback", SessionController, :callback
end

# Authenticated routes go here
scope "/", MyApp do
  pipe_through [:browser, :browser_session, :require_auth]

  get "/logout", SessionController, :delete
end
```

### Mailers

Here's an example Emails module using Bamboo:

```elixir
# web/emails.ex
defmodule MyApp.Emails do
  import Bamboo.Email
  use Bamboo.Phoenix, view: MyApp.EmailView

  @from "admin@myapp.com"

  def login(user, params) do
    new_email
    |> from(@from)
    |> to(user.email)
    |> subject("Login to MyApp")
    |> assign(:user, user)
    |> assign(:params, params)
    |> render(:login)
  end

  def register(email, params) do
    new_email
    |> from(@from)
    |> to(email)
    |> subject("Register with MyApp")
    |> assign(:params, params)
    |> render(:register)
  end
end
```

When rendering the email template, all that matters is that you include the login link like so:

```eex
<%= link "Click here to login", to: session_url(MyApp.Endpoint, :callback, @params) %>
```

### Trackable (optional)

Add the required fields in a migration:

```elixir
alter table(:users) do
  add :sign_in_count, :integer, default: 0
  add :last_sign_in_ip, :string
  add :last_sign_in_at, :datetime
  add :current_sign_in_ip, :string
  add :current_sign_in_at, :datetime
end
```

Make some minor tweaks to your model:

```elixir
defmodule MyApp.User do
  use Passwordless.Schema

  schema "users" do
    # ...
    trackable_fields()
  end
end
```

Configure Guardian to use `Passwordless.Trackable` module:

```elixir
config :guardian, Guardian,
  hooks: Passwordless.Trackable
```

### Accessing the current user

Under the hood, Passwordless just uses Guardian, so to get the current user, just say:

```elixir
Guardian.Plug.current_resource(conn)
```
