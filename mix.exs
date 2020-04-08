defmodule SansPassword.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sans_password,
      version: "1.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :sans_password,
      description: "Passwordless authentication utilities based on Guardian.",
      files: ["lib", "mix.exs", "README.md", "LICENSE.txt"],
      maintainers: ["Ray Zane"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/promptworks/sans_password"}
    ]
  end

  defp deps do
    [
      {:guardian, "~> 1.0 or ~> 2.0"},
      {:plug, ">= 0.0.0", only: [:dev, :test], optional: true},
      {:jason, ">= 0.0.0", only: :test, optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  def aliases do
    ["test.setup": ["ecto.drop", "ecto.create", "ecto.migrate"]]
  end
end
