defmodule SansPassword.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sans_password,
      version: "0.1.0",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps()
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp package do
    [
      name: :sans_password,
      description: "A passwordless authentication system based on Guardian.",
      files: ["lib", "mix.exs", "README.md", "LICENSE.txt"],
      maintainers: ["Ray Zane"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/promptworks/sans_password"}
    ]
  end

  defp deps do
    [
      {:guardian, "~> 1.0-beta"},
      {:plug, "~> 1.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
