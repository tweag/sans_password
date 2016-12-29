defmodule SansPassword.Mixfile do
  use Mix.Project

  def project do
    [app: :sans_password,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: applications(Mix.env)]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ecto, "~> 2.0"},
     {:guardian, "~> 0.13"},
     {:phoenix, "~> 1.2", optional: true},
     {:postgrex, "~> 0.12", only: :test},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp applications(:test), do: [:logger, :phoenix, :ecto, :postgrex]
  defp applications(_),     do: [:logger, :phoenix, :ecto]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp description do
    "A simple, passwordless authentication system based on Guardian."
  end

  defp package do
    [name: :sans_password,
     files: ["lib", "mix.exs", "README.md", "LICENSE.txt"],
     maintainers: ["Ray Zane"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/promptworks/sans_password"}]
  end
end
